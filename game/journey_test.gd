extends Node
# Engine-input integration, not native desktop automation or human playtesting.
var game
var failed=false

func check(value: bool,message: String) -> bool:
 if not value:
  failed=true; push_error("JOURNEY_FAILED "+message)
  game.get_tree().quit(1)
 return value

func frames(count: int):
 for i in range(count): await get_tree().physics_frame

func key(code: int,pressed: bool):
 var event=InputEventKey.new(); event.keycode=code; event.physical_keycode=code; event.pressed=pressed
 Input.parse_input_event(event)

func tap(code: int):
 key(code,true); await frames(2); key(code,false); await frames(2)

func click(point: Vector2,right=false):
 var motion=InputEventMouseMotion.new(); motion.position=point; motion.global_position=point
 Input.parse_input_event(motion); await frames(2)
 for down in [true,false]:
  var event=InputEventMouseButton.new(); event.position=point; event.global_position=point
  event.button_index=MOUSE_BUTTON_RIGHT if right else MOUSE_BUTTON_LEFT
  event.pressed=down; Input.parse_input_event(event); await frames(2)

func find_button(root: Node,prefix: String):
 if root is Button and root.text.begins_with(prefix): return root
 for child in root.get_children():
  var result=find_button(child,prefix)
  if result!=null: return result
 return null

func move_to(point: Vector2):
 var before=game.player.position
 key(KEY_W,true)
 for i in range(900):
  var delta=Vector3(point.x-game.player.position.x,0,point.y-game.player.position.z)
  if delta.length()<0.55:
   key(KEY_W,false); await frames(8); return true
  game.yaw=atan2(-delta.x,-delta.z)
  await frames(1)
 key(KEY_W,false)
 check(false,"movement timed out %s -> %s current %s"%[before,point,game.player.position])
 return false

func drag(source: Control,destination: Control):
 var a=source.get_global_rect().get_center(); var b=destination.get_global_rect().get_center()
 var down=InputEventMouseButton.new(); down.position=a; down.global_position=a; down.button_index=MOUSE_BUTTON_LEFT; down.pressed=true
 Input.parse_input_event(down); await frames(3)
 for i in range(1,13):
  var motion=InputEventMouseMotion.new(); motion.position=a.lerp(b,float(i)/12); motion.global_position=motion.position
  motion.relative=(b-a)/12; motion.button_mask=MOUSE_BUTTON_MASK_LEFT
  Input.parse_input_event(motion); await frames(2)
 var up=InputEventMouseButton.new(); up.position=b; up.global_position=b; up.button_index=MOUSE_BUTTON_LEFT; up.pressed=false
 Input.parse_input_event(up); await frames(5)

func run():
 await frames(15)
 var start=find_button(game.content,"开始新的旅程")
 if not check(start!=null,"new game button missing"): return
 await click(start.get_global_rect().get_center())
 if not check(game.playing and not game.panel_open,"new game click did not start"): return
 await frames(30)
 if not await move_to(Vector2(-56,70)): return
 if not await move_to(Vector2(-56,58)): return
 if not await move_to(Vector2(-60,58)): return
 for i in range(8): await tap(KEY_E); await frames(45)
 if not check(game.inv.get("木材",0)>=3 and game.inv.get("石头",0)>=3,"salvage did not provide resources"): return
 print("JOURNEY_MOVEMENT_SALVAGE_OK position=",game.player.position)
 await tap(KEY_TAB)
 if not check(game.panel_open,"Tab did not open inventory"): return
 var recipe=find_button(game.content,"石斧  ·")
 if not check(recipe!=null and not recipe.disabled,"axe recipe unavailable"): return
 var scroll=game.content.get_parent()
 scroll.ensure_control_visible(recipe); await frames(5)
 await click(recipe.get_global_rect().get_center())
 if not check(not game.panel_open and not game.craft_job.is_empty(),"craft button did not start job"): return
 await frames(300)
 if not check(game.inv.get("石斧",0)==1 and game.craft_job.is_empty(),"timed crafting did not complete in world"): return
 await tap(KEY_6)
 if not check(game.equipped=="石斧","quickbar key did not equip"): return
 print("JOURNEY_CRAFT_EQUIP_OK")
 await tap(KEY_TAB)
 var grid
 for child in game.content.get_children():
  if child is GridContainer: grid=child
 scroll.ensure_control_visible(grid); await frames(4)
 var source=-1; var destination=-1
 for i in range(24):
  if not game.bag.slots[i].is_empty() and game.bag.slots[i].count>1: source=i
  if game.bag.slots[i].is_empty(): destination=i
 if not check(source>=0 and destination>=0,"drag fixture unavailable"): return
 var item=game.bag.slots[source].item; var amount=game.bag.slots[source].count
 await drag(grid.get_child(source),grid.get_child(destination))
 if not check(game.bag.slots[source].is_empty() and game.bag.slots[destination].get("item","")==item,"engine GUI drag did not move stack"): return
 print("JOURNEY_DRAG_OK item=",item," amount=",amount)
 if game.qa_dir!="": game.get_viewport().get_texture().get_image().save_png(game.qa_dir.path_join("journey-inventory.png"))
 await tap(KEY_ESCAPE)
 if not await move_to(Vector2(-55,50)): return
 await tap(KEY_B)
 var fire_button=find_button(game.content,"篝火 ·")
 if not check(fire_button!=null and not fire_button.disabled,"salvaged materials cannot build campfire"): return
 game.content.get_parent().ensure_control_visible(fire_button); await frames(3)
 await click(fire_button.get_global_rect().get_center())
 if not check(game.build_kind=="篝火" and not game.panel_open,"build menu did not select campfire"): return
 var valid=false
 for angle in [0.0,PI/2,PI,-PI/2]:
  game.yaw=angle; await frames(12)
  if game.valid_build(): valid=true; break
 if not check(valid,"no clear campsite around beach waypoint"): return
 var previous=game.structures.size()
 await click(Vector2(640,360))
 if not check(game.structures.size()==previous+1,"confirm input did not place campfire"): return
 var fire=game.structures.back()
 await click(Vector2(640,360),true)
 if not await move_to(Vector2(fire.node.position.x,fire.node.position.z+1.5)): return
 for i in range(5):
  if game.panel_open: break
  await tap(KEY_E); await frames(45)
 if not check(game.panel_open and game.content.get_child(0).text=="营地篝火","E did not open campfire management"): return
 if game.qa_dir!="": game.get_viewport().get_texture().get_image().save_png(game.qa_dir.path_join("journey-campfire.png"))
 await tap(KEY_ESCAPE)
 await tap(KEY_F5)
 if not check(game.save_store.read(game.SAVE)!=null,"input save did not produce valid file"): return
 await tap(KEY_ESCAPE)
 var exit=find_button(game.content,"退出")
 if not check(exit!=null,"exit menu missing"): return
 game.content.get_parent().ensure_control_visible(exit); await frames(5)
 game.tree_exiting.connect(func(): print("JOURNEY_EXIT_OK"))
 print("JOURNEY_OK engine_input movement salvage UI_craft quickbar drag campfire save")
 # Do not leave an awaited click coroutine alive while the app is shutting down.
 var point=exit.get_global_rect().get_center()
 var motion=InputEventMouseMotion.new(); motion.position=point; motion.global_position=point
 Input.parse_input_event(motion)
 for down in [true,false]:
  var event=InputEventMouseButton.new(); event.position=point; event.global_position=point
  event.button_index=MOUSE_BUTTON_LEFT; event.pressed=down; Input.parse_input_event(event)
