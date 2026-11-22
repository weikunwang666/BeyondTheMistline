extends Node
var game
var driver

func check(value: bool,message: String) -> bool:
 if not value: push_error("BUILDING_FAILED "+message); get_tree().quit(1)
 return value

func frames(count: int):
 for i in range(count): await get_tree().physics_frame

func run():
 game.start_new()
 driver=preload("res://journey_test.gd").new(); driver.game=game; add_child(driver)
 for e in game.enemies:
  e.hp=0; e.node.hide(); game.set_collisions(e.node,true)
 var base=game.ground(Vector2(-35,120))
 game.player.position=base+Vector3(0,0.75,0)
 game.make_structure("地基",base,0)
 await frames(5)
 for entry in [["墙",Vector3(0,0,-2),0.0],["墙",Vector3(-2,0,0),PI/2],["墙",Vector3(2,0,0),PI/2],["门框",Vector3(0,0,2),0.0],["屋顶",Vector3.ZERO,0.0]]:
  game.build_kind=entry[0]; game.build_pos=base+entry[1]; game.build_angle=entry[2]
  # Disable visual preview updates while checking one explicitly chosen placement.
  game.panel_open=true
  if not check(game.valid_build(),"legal module rejected: "+entry[0]+str(entry[1])): return
  game.make_structure(entry[0],game.build_pos,game.build_angle)
  game.build_kind=""; await frames(3)
 game.panel_open=false
 var inside=game.player.position
 game.player.position=base+Vector3(0,1,6)
 game.panel_open=true; game.build_kind="楼梯"; game.build_pos=base+Vector3(0,0,3.5); game.build_angle=0
 if not check(game.valid_build(),"supported entry stairs rejected"): return
 game.make_structure("楼梯",base+Vector3(0,0,3.5),0)
 game.build_kind="地基"; game.build_pos=base+Vector3(-4,0,0)
 game.player.position=base+Vector3(-7,1,1)
 if not check(game.valid_build(),"adjacent floor foundation rejected"): return
 game.make_structure("地基",game.build_pos,0)
 game.build_kind="屋顶"; game.build_pos=base+Vector3(-16,0,0)
 if not check(not game.valid_build(),"unsupported roof accepted"): return
 game.build_kind=""; game.panel_open=false; game.player.position=inside
 var door={}
 for entity in game.entities:
  if entity.title=="门框": door=entity
 await frames(8)
 if not check(game.is_sheltered(game.player.position),"roof not recognized overhead"): return
 if not check(not game.is_sheltered(base+Vector3(4,0.6,0)),"roof incorrectly shelters outside"): return
 game.yaw=PI; driver.key(KEY_W,true); await frames(90); driver.key(KEY_W,false)
 if not check(game.player.position.z<base.z+2,"closed door did not block player"): return
 game.target=door; game.interact(); await frames(25)
 if not await driver.move_to(Vector2(base.x,base.z+4)): return
 if not check(game.player.position.z>base.z+2.7,"opened door could not be traversed"): return
 if not await driver.move_to(Vector2(base.x,base.z)): return
 game.panel_open=true; game.build_kind="储物箱"; game.build_pos=base; game.snap_build()
 if not check(is_equal_approx(game.build_pos.y,base.y+0.6),"facility did not align to floor surface"): return
 if not check(game.valid_build(),"floor facility rejected"): return
 game.make_structure("储物箱",game.build_pos,0)
 game.build_kind=""; game.panel_open=false
 game.save_game(); game.load_game()
 if not check(game.structures.size()==9,"house did not reload all modules"): return
 if not check(game.is_sheltered(base+Vector3(0,0.6,0)),"loaded roof lost shelter metadata"): return
 if game.qa_dir!="":
  game.set_physics_process(false)
  game.camera.position=base+Vector3(8,6,9); game.camera.look_at(base+Vector3(0,1.5,0))
  await get_tree().process_frame
  await get_tree().process_frame
  game.get_viewport().get_texture().get_image().save_png(game.qa_dir.path_join("building-house.png"))
 print("BUILDING_OK module_corners roof shelter door_block door_cross stairs adjacent_floor floor_facility reload")
 get_tree().quit()
