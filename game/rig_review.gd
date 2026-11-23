extends Node
var game
var focus=Vector3.ZERO
var ready_for_view=false

func check(ok: bool,message: String) -> bool:
 if not ok: push_error("RIG_REVIEW_FAILED "+message); get_tree().quit(1)
 return ok

func _process(_dt):
 if not ready_for_view: return
 game.camera.position=focus+Vector3(2.7,1.6,-3.4)
 game.camera.look_at(focus+Vector3.UP*0.95)

func run():
 game.start_new(); game.playing=false; game.player.hide()
 for enemy in game.enemies: enemy.node.hide()
 var scene=load("res://assets/characters/UAL1_Standard.glb")
 if not check(scene is PackedScene,"GLB did not import as a scene"): return
 var rig
 if "--base-rig-review" in OS.get_cmdline_user_args():
  rig=preload("res://rigged_base.gd").new(); game.add_child(rig)
  if not check(rig.build(game),"base character skeleton compatibility"): return
 elif "--rig-body-review" in OS.get_cmdline_user_args():
  rig=preload("res://rigged_survivor.gd").new(); game.add_child(rig)
  if not check(rig.build(game),"bone-driven survivor could not bind"): return
 else:
  rig=scene.instantiate(); game.add_child(rig)
 focus=game.ground(Vector2(-70,70)); rig.position=focus
 if "--base-rig-review" in OS.get_cmdline_user_args():
  var tool=Node3D.new(); rig.hand_socket.add_child(tool)
  var rest=rig.skeleton.global_transform*rig.skeleton.get_bone_global_rest(rig.skeleton.find_bone("hand_r"))
  tool.transform=rest.affine_inverse()*Transform3D(Basis.IDENTITY,rest.origin)
  game.cylinder(tool,Vector3.ZERO,0.025,0.7,Color("796047"))
  game.box(tool,Vector3(0,0.24,0),Vector3(0.3,0.16,0.08),Color("8c9491"))
 var players=rig.find_children("*","AnimationPlayer",true,false)
 var skeletons=rig.find_children("*","Skeleton3D",true,false)
 if not check(players.size()==1 and skeletons.size()==1,"missing animation player or skeleton"): return
 var animation=players[0]; var skeleton=skeletons[0]
 print("RIG_IMPORTED_CLIPS ",animation.get_animation_list())
 var required=["Idle","Walk","Sprint","Crouch_Fwd","Jump_Start","Jump_Land","Interact","Sword_Attack","Hit_Chest","Death01"]
 for clip in required:
  if not check(animation.has_animation(clip),"missing clip "+clip): return
 var hand=skeleton.find_bone("hand_r")
 if not check(hand>=0 and skeleton.get_bone_count()>40,"missing usable hand rig"): return
 game.clock=10; game.update_world(1)
 var light=DirectionalLight3D.new(); light.rotation_degrees=Vector3(-35,-145,0); light.light_energy=1.5; game.add_child(light)
 game.environment.ambient_light_energy=0.8; ready_for_view=true
 animation.play("Walk"); animation.advance(0.1)
 var before=skeleton.get_bone_pose_rotation(hand)
 animation.advance(0.3)
 if not check(before.angle_to(skeleton.get_bone_pose_rotation(hand))>0.01,"clip did not animate the skeleton"): return
 for clip in ["Idle","Walk","Sword_Attack"]:
  animation.play(clip)
  for i in range(24): await get_tree().process_frame
  if "--base-rig-review" in OS.get_cmdline_user_args():
   var head=skeleton.global_transform*skeleton.get_bone_global_pose(skeleton.find_bone("Head")).origin
   var hip=skeleton.global_transform*skeleton.get_bone_global_pose(skeleton.find_bone("pelvis")).origin
   var foot=skeleton.global_transform*skeleton.get_bone_global_pose(skeleton.find_bone("foot_l")).origin
   if not check(head.y>hip.y+0.35 and foot.y<hip.y-0.3,"retargeted body collapsed in "+clip): return
   var grip=skeleton.global_transform*skeleton.get_bone_global_pose(hand).origin
   if not check(rig.hand_socket.global_position.distance_to(grip)<0.03,"tool socket did not follow hand in "+clip): return
  var prefix="base-rig-" if "--base-rig-review" in OS.get_cmdline_user_args() else ("rig-body-" if "--rig-body-review" in OS.get_cmdline_user_args() else "rig-review-")
  if game.qa_dir!="": game.get_viewport().get_texture().get_image().save_png(game.qa_dir.path_join(prefix+clip+".png"))
 print("RIG_REVIEW_OK imported_scene bones=",skeleton.get_bone_count()," clips=",animation.get_animation_list().size()," hand_attachment animated_pose required_actions")
 get_tree().quit()
