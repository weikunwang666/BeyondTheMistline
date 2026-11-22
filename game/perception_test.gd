extends Node
var game

func check(ok: bool,message: String) -> bool:
 if not ok:
  push_error("PERCEPTION_FAILED "+message)
  get_tree().quit(1)
 return ok

func frames(count: int):
 for i in range(count): await get_tree().physics_frame

func run():
 game.start_new()
 for e in game.enemies:
  e.hp=0; e.node.hide(); game.set_collisions(e.node,true)
 game.player.position=game.ground(Vector2(-35,135))+Vector3.UP
 var enemy=game.enemies[0]
 enemy.hp=60; enemy.node.show(); game.set_collisions(enemy.node,false)
 enemy.node.position=game.ground(Vector2(-35,123))
 enemy.home=enemy.node.position; enemy.state="Idle"; enemy.timer=0
 # Taller than the throwing arc, so flying over it is not a valid result.
 game.box(game,game.ground(Vector2(-35,129))+Vector3(0,3,0),Vector3(10,6,0.3),Color.GRAY,true)
 game.navigation.invalidate()
 await frames(90)
 if not check(enemy.memory==0,"saw through opaque wall"): return
 game.inv["石头"]=2
 game.yaw=-PI/2
 await frames(35)
 var event=InputEventKey.new(); event.keycode=KEY_G; event.pressed=true
 Input.parse_input_event(event)
 await frames(1)
 event=InputEventKey.new(); event.keycode=KEY_G; event.pressed=false
 Input.parse_input_event(event)
 await frames(35)
 if not check(game.inv.get("石头",0)==1,"G did not consume exactly one stone"): return
 if not check(game.noise_time>0 and enemy.get("stimulus","")=="noise","landing did not alert enemy"): return
 var landing=game.noise_position
 if not check(enemy.last_known.distance_to(landing)<0.01 and landing.distance_to(game.player.position)>5,"enemy tracked player instead of landing"): return
 var before=enemy.node.position
 await frames(90)
 if not check(enemy.node.position.distance_to(before)>0.5 and enemy.last_known.distance_to(landing)<0.01,"enemy did not investigate remembered landing"): return
 # A second throw heads into the wall; pause during flight, then resume.
 game.yaw=0
 await frames(35)
 game.throw_stone()
 var lures=get_tree().get_nodes_in_group("stone_lures")
 var rock=lures.back()
 await frames(3)
 game.menu()
 var paused_position=rock.global_position
 await frames(35)
 if not check(rock.global_position==paused_position and not rock.landed,"stone moved while menu paused"): return
 game.close_panel()
 var old_yaw=game.yaw; var old_pitch=game.pitch
 var motion=InputEventMouseMotion.new(); motion.relative=Vector2(300,300)
 Input.parse_input_event(motion)
 await frames(1)
 if not check(game.yaw==old_yaw and game.pitch==old_pitch,"camera jumped on recapture"): return
 await frames(10)
 motion=InputEventMouseMotion.new(); motion.relative=Vector2(1,1)
 Input.parse_input_event(motion)
 await frames(1)
 if not check(game.yaw!=old_yaw,"camera remained locked after guard"): return
 await frames(40)
 if not check(rock.landed and rock.global_position.z>128.8,"stone crossed wall position=%s landed=%s"%[rock.global_position,rock.landed]): return
 if not check(game.inv.get("石头",0)==0,"second stone consumption incorrect"): return
 game.throw_stone()
 if not check(game.inv.get("石头",0)==0 and get_tree().get_nodes_in_group("stone_lures").size()==lures.size(),"empty inventory spawned stone"): return
 game.start_new()
 await frames(2)
 if not check(get_tree().get_nodes_in_group("stone_lures").is_empty() and game.noise_time==0,"new game retained noise"): return
 print("PERCEPTION_LIVE_OK opaque_wall G_input stone_cost landing_noise investigation flight_wall pause empty_inventory new_game_reset camera_recapture")
 get_tree().quit()
