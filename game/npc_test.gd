extends Node
var game
var driver

func check(ok: bool,message: String) -> bool:
 if not ok:
  var npc=game.survivors[0]
  push_error("NPC_FAILED "+message+" position=%s destination=%s path=%s"%[npc.position,npc.destination,npc.route])
  get_tree().quit(1)
 return ok

func run():
 driver=preload("res://journey_test.gd").new(); driver.game=game; add_child(driver)
 game.start_new()
 var npc=game.survivors[0]
 game.clock=7; game.weather=0
 npc.position=game.ground(Vector2(-46,26))+Vector3.UP
 # A wall taller than the character separates him from his morning destination.
 game.box(game,game.ground(Vector2(-43,26))+Vector3(0,2,0),Vector3(0.4,4,8),Color.GRAY,true)
 game.navigation.invalidate()
 var detour=false; var arrived=false
 for i in range(1500):
  if abs(npc.position.z-26)>4: detour=true
  if Vector2(npc.position.x+40,npc.position.z-26).length()<0.8:
   arrived=true; break
  await driver.frames(1)
 if not check(arrived and detour,"did not walk around wall to scheduled coast stop"): return
 game.player.position=npc.position+Vector3(0,0,2)
 await driver.frames(20)
 if not check(npc.stopped_for_player and game.target.get("id","")=="npc","approach did not stop for conversation"): return
 await driver.tap(KEY_E)
 var stopped=npc.position
 await driver.frames(60)
 if not check(game.panel_open and game.content.get_child(0).text.contains("伊莱") and npc.position.distance_to(stopped)<0.01,"E dialogue or pause failed"): return
 await driver.tap(KEY_ESCAPE)
 if not check(not game.panel_open,"Escape did not close dialogue"): return
 game.player.position=game.ground(Vector2(-65,72))+Vector3.UP
 game.clock=18
 await driver.frames(3)
 if not check(npc.schedule_id==2 and npc.activity=="守望灯塔","evening schedule failed clock=%s playing=%s panel=%s id=%s"%[game.clock,game.playing,game.panel_open,npc.schedule_id]): return
 game.weather=3
 await driver.frames(3)
 if not check(npc.schedule_id==4 and npc.destination.distance_to(npc.home)<0.01,"storm shelter failed"): return
 game.weather=5
 await driver.frames(3)
 if not check(npc.schedule_id==4,"heavy rain shelter failed"): return
 game.weather=0; game.clock=21
 await driver.frames(3)
 if not check(npc.schedule_id==3,"night schedule failed"): return
 arrived=false
 for i in range(1500):
  var delta=npc.destination-npc.position; delta.y=0
  if delta.length()<0.8: arrived=true; break
  await driver.frames(1)
 if not check(arrived,"did not return to night shelter"): return
 game.save_game()
 var data=game.save_store.read(game.SAVE)
 if not check(data!=null and data.survivors.size()==1,"NPC save failed"): return
 var old=data.duplicate(true); old.erase("survivors")
 var bad=data.duplicate(true); bad.survivors=[{"position":[0,"bad",0]}]
 if not check(game.save_store.valid(old) and not game.save_store.valid(bad),"NPC save schema/backward compatibility"): return
 game.player.position=npc.position+Vector3(0,0,3)
 game.yaw=PI; game.update_camera(1)
 await driver.frames(4)
 if game.qa_dir!="": game.get_viewport().get_texture().get_image().save_png(game.qa_dir.path_join("npc-shelter.png"))
 print("NPC_OK physical_detour morning evening storm night approach E_dialogue pause save_schema")
 get_tree().quit()
