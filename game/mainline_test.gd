extends Node
# Guided engine-input playthrough. No inventory grants, teleporting or disabled enemies.
var game
var driver
var started=0

func check(value: bool,message: String) -> bool:
 if not value:
  print("MAINLINE_SURVIVAL health=",game.health," stamina=",game.stamina," fatigue=",game.survival.fatigue," temperature=",game.temperature)
  for enemy in game.enemies:
   if enemy.hp>0 and enemy.node.position.distance_to(game.player.position)<25: print("MAINLINE_NEAR_ENEMY ",enemy.kind," ",enemy.state," ",enemy.node.position)
  push_error("MAINLINE_FAILED "+message+" position="+str(game.player.position)+" inventory="+str(game.inv))
  get_tree().quit(1)
 return value

func _process(_dt):
 if started>0 and Time.get_ticks_msec()-started>720000:
  check(false,"twelve minute timeout")

func button(prefix: String) -> bool:
 var control=driver.find_button(game.content,prefix)
 if not check(control!=null and not control.disabled,"button unavailable "+prefix): return false
 game.content.get_parent().ensure_control_visible(control)
 await driver.frames(10)
 await driver.click(control.get_global_rect().get_center())
 return true

func travel(point: Vector2) -> bool:
 if game.panel_open: await driver.tap(KEY_ESCAPE)
 for i in range(180):
  if game.navigation.ready: break
  await driver.frames(1)
 var route=game.navigation.path(game.player.position,game.ground(point))
 if not check(not route.is_empty(),"no route to "+str(point)): return false
 print("MAINLINE_TRAVEL ",point," waypoints=",route.size())
 var cursor=0
 while cursor<route.size():
  var selected=cursor
  for next in range(cursor+1,min(cursor+8,route.size())):
   if route[next].distance_to(Vector3(game.player.position.x,0,game.player.position.z))<15 and route_clear(route[next]): selected=next
  var waypoint=route[selected]
  if not await walk(Vector2(waypoint.x,waypoint.z),false): return false
  cursor=selected+1
  if game.health<70 and game.inv.get("绷带",0)>0: await driver.tap(KEY_3)
  if game.thirst<65 and game.inv.get("净水",0)>0: await driver.tap(KEY_2)
  if game.hunger<65 and game.inv.get("罐头",0)>0: await driver.tap(KEY_4)
 if game.visible_between(game.player.position+Vector3.UP,game.ground(point)+Vector3.UP):
  if not await walk(point,true): return false
 driver.key(KEY_W,false); driver.key(KEY_SHIFT,false)
 return check(game.health>0 and game.death_time==0,"death during travel")

func route_clear(point: Vector3) -> bool:
 var a=game.player.position+Vector3.UP
 var b=game.ground(Vector2(point.x,point.z))+Vector3.UP
 var side=(b-a).cross(Vector3.UP).normalized()*0.5
 for offset in [Vector3.ZERO,side,-side]:
  if not game.visible_between(a+offset,b+offset): return false
 return true

func walk(point: Vector2,stop=true) -> bool:
 driver.key(KEY_W,true)
 var running=Input.is_physical_key_pressed(KEY_SHIFT)
 for i in range(1200):
  if game.death_time>0:
   driver.key(KEY_W,false); driver.key(KEY_SHIFT,false)
   return check(false,"death during guided walk to "+str(point))
  var delta=Vector3(point.x-game.player.position.x,0,point.y-game.player.position.z)
  if delta.length()<0.55:
   if stop: driver.key(KEY_W,false); driver.key(KEY_SHIFT,false); await driver.frames(6)
   return true
  game.yaw=atan2(-delta.x,-delta.z)
  var danger=false
  for enemy in game.enemies:
   if enemy.hp>0 and enemy.node.position.distance_to(game.player.position)<16: danger=true; break
  var sprint=danger and game.stamina>20
  if sprint!=running: driver.key(KEY_SHIFT,sprint); running=sprint
  if i%30==0 and game.health<70 and game.inv.get("绷带",0)>0: await driver.tap(KEY_3)
  await driver.frames(1)
 driver.key(KEY_W,false); driver.key(KEY_SHIFT,false)
 return check(false,"guided walk blocked at "+str(point))

func entity(id: String):
 for e in game.entities:
  if e.id==id: return e
 return {}

func interact_id(id: String) -> bool:
 var e=entity(id)
 if not check(not e.is_empty(),"missing interaction "+id): return false
 var p=e.node.global_position
 if not await travel(Vector2(p.x,p.z+1.5)): return false
 await driver.frames(10)
 for i in range(6):
  if game.target.get("id","")==id:
   await driver.tap(KEY_E); await driver.frames(45)
   print("MAINLINE_INTERACT ",id)
   return true
  if game.target.get("kind","")=="resource": await driver.tap(KEY_E); await driver.frames(45)
  else: break
 return check(false,"interaction target blocked for "+id+" selected "+str(game.target.get("id","none")))

func craft(item: String) -> bool:
 print("MAINLINE_CRAFT_BEGIN ",item)
 var before=game.inv.get(item,0)
 await driver.tap(KEY_TAB)
 if not await button(item+"  ·"): return false
 for i in range(700):
  if game.craft_job.is_empty(): break
  await driver.frames(1)
 var complete=check(game.inv.get(item,0)==before+1,"craft not completed "+item)
 if complete: print("MAINLINE_CRAFT_OK ",item)
 return complete

func build(kind: String) -> bool:
 print("MAINLINE_BUILD_BEGIN ",kind)
 await driver.tap(KEY_B)
 if not await button(kind+" ·"): return false
 var valid=false
 for angle in [0.0,PI/2,PI,-PI/2]:
  game.yaw=angle; await driver.frames(15)
  if game.valid_build(): valid=true; break
 if not check(valid,"no build position "+kind): return false
 var count=game.structures.size()
 await driver.click(Vector2(640,360))
 await driver.click(Vector2(640,360),true)
 var complete=check(game.structures.size()==count+1,"build not placed "+kind)
 if complete: print("MAINLINE_BUILD_OK ",kind)
 return complete

func run():
 started=Time.get_ticks_msec()
 var overlay=CanvasLayer.new(); overlay.layer=20; add_child(overlay)
 var caption=Label.new(); caption.position=Vector2(925,22); caption.text="引擎输入引导流程\n非人工盲测"; caption.add_theme_font_size_override("font_size",16)
 caption.modulate=Color("d7c9a9"); overlay.add_child(caption)
 driver=preload("res://journey_test.gd").new(); driver.game=game; add_child(driver)
 await driver.frames(15)
 if not await button("开始新的旅程"): return
 await driver.frames(30)
 if not await driver.move_to(Vector2(-56,70)): return
 if not await driver.move_to(Vector2(-56,58)): return
 for i in range(6):
  if not await interact_id("start"+str(i)): return
 if not await craft("石斧"): return
 await driver.tap(KEY_6)
 if not await driver.move_to(Vector2(-55,50)): return
 if not await build("篝火"): return
 for id in ["poi-village","poi-warehouse","poi-factory","poi-lighthouse"]:
  if not await interact_id(id): return
  while game.inv.get("布料",0)>=2 and game.inv.get("绷带",0)<3:
   if not await craft("绷带"): return
 if not await interact_id("lighthouse"): return
 if not check("lighthouse" in game.repairs,"lighthouse repair failed"): return
 if not await build("工作台"): return
 if not await craft("工具包"): return
 if not await craft("电池"): return
 if not await interact_id("lab"): return
 if not check("lab" in game.repairs,"research repair failed"): return
 if not await interact_id("tower"): return
 if not check(game.repairs.size()==3,"final signal not restored"): return
 await driver.tap(KEY_F5)
 await driver.tap(KEY_J)
 await driver.frames(6)
 if game.qa_dir!="": game.get_viewport().get_texture().get_image().save_png(game.qa_dir.path_join("mainline-complete.png"))
 print("MAINLINE_OK guided_engine_input chapter_complete seconds=",(Time.get_ticks_msec()-started)/1000.0)
 get_tree().quit()
