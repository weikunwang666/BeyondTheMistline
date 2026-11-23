extends Node
var game
var driver

func check(ok: bool,message: String) -> bool:
 if not ok: push_error("COMPACT_FAILED "+message); get_tree().quit(1)
 return ok

func shot(name: String):
 await driver.frames(8)
 if game.qa_dir!="": game.get_viewport().get_texture().get_image().save_png(game.qa_dir.path_join("compact-"+name+".png"))

func run():
 driver=preload("res://journey_test.gd").new(); driver.game=game; add_child(driver)
 game.start_new(); await driver.frames(90)
 if not check(game.body.has_method("outfit") and game.survivors[0].visual.has_method("outfit"),"player/NPC rig not enabled"): return
 if not check(game.body.current_action=="Idle","idle state"): return
 await shot("coast")
 var initial=game.player.position
 driver.key(KEY_W,true); await driver.frames(35)
 if not check(game.player.position.distance_to(initial)>1 and game.body.current_action=="Jog_Fwd","actual movement/locomotion"): return
 driver.key(KEY_SHIFT,true); await driver.frames(8)
 if not check(game.body.current_action=="Sprint","sprint transition"): return
 driver.key(KEY_SHIFT,false); driver.key(KEY_W,false); await driver.frames(15)
 driver.key(KEY_CTRL,true); await driver.frames(15)
 if not check(game.body.current_action=="Crouch_Idle","crouch state"): return
 driver.key(KEY_CTRL,false); await driver.frames(12)
 game.inv["石斧"]=1; game.use_item("石斧"); await driver.frames(5)
 if not check(game.held_tool.get_parent()==game.body.tool_grip,"tool not bound to animated hand"): return
 game.attack(); await driver.frames(10)
 if not check(game.body.current_action=="Sword_Attack","attack transition"): return
 var hand=game.body.tool_grip.global_position
 await driver.frames(12)
 if not check(game.body.tool_grip.global_position.distance_to(hand)>0.02,"attack did not move equipped tool"): return
 await shot("axe")
 game.menu(); await driver.frames(5)
 var time=game.body.animator.current_animation_position
 var position=game.body.tool_grip.global_position
 await driver.frames(15)
 if not check(is_equal_approx(time,game.body.animator.current_animation_position) and position.distance_to(game.body.tool_grip.global_position)<0.001,"menu did not freeze rig/tool"): return
 game.close_panel(); await driver.frames(45)
 game.body.rotation.y=PI/2
 game.inv["防雨外套"]=1; game.use_item("防雨外套"); await driver.frames(4)
 if not check(is_instance_valid(game.outfit_visual),"outfit mount"): return
 var front=game.body.outfit("加固背心")
 await driver.frames(4)
 var chest=game.body.skeleton.global_transform*game.body.skeleton.get_bone_global_pose(game.body.skeleton.find_bone("spine_02"))
 var local_front=game.body.to_local(front.global_position)-game.body.to_local(chest.origin)
 if not check(local_front.z< -0.1,"outfit facing changed with world rotation"): return
 front.queue_free()
 game.start_new(); await driver.frames(20)
 if not check(game.equipped=="" and game.gear.worn=="" and game.body.current_action=="Idle","new game retained previous action/equipment"): return
 game.chapter_complete(); await shot("ending-layout")
 var continue_button=driver.find_button(game.content,"继续探索与建造")
 if not check(continue_button!=null,"chapter continuation missing"): return
 game.content.get_parent().ensure_control_visible(continue_button); await driver.frames(10)
 await driver.click(continue_button.get_global_rect().get_center())
 await driver.frames(8)
 if not check(not game.panel_open and game.playing,"chapter continuation did not resume game"): return
 print("COMPACT_OK normal_player npc walk sprint crouch attack hand_tool menu_pause outfit new_game")
 get_tree().quit()
