extends Node3D
# Original CC0 body with locally fitted clothing and offline retargeted actions.
var game
var gameplay=false
var coat_color=Color("617579")
var jacket_materials=[]
var tool_grip: Node3D
var current_action=""
var rig: Node3D
var skeleton: Skeleton3D
var animator: AnimationPlayer
var hand_socket: BoneAttachment3D

func build(owner_game) -> bool:
 game=owner_game
 rig=load("res://assets/characters/base/Superhero_Male_FullBody.gltf").instantiate()
 add_child(rig); rig.rotation.y=PI
 var bones=rig.find_children("*","Skeleton3D",true,false)
 if bones.size()!=1: return false
 skeleton=bones[0]
 make_clothing()
 var source=load("res://assets/characters/UAL1_Standard.glb").instantiate()
 add_child(source)
 var source_skeleton=source.find_children("*","Skeleton3D",true,false)[0]
 var source_player=source.find_children("*","AnimationPlayer",true,false)[0]
 var max_rest_error=0.0
 var max_basis_error=0.0
 for i in range(skeleton.get_bone_count()):
  var other=source_skeleton.find_bone(skeleton.get_bone_name(i))
  if other<0: source.queue_free(); return false
  max_rest_error=maxf(max_rest_error,skeleton.get_bone_global_rest(i).origin.distance_to(source_skeleton.get_bone_global_rest(other).origin))
  max_basis_error=maxf(max_basis_error,skeleton.get_bone_rest(i).basis.get_rotation_quaternion().angle_to(source_skeleton.get_bone_rest(other).basis.get_rotation_quaternion()))
 print("BASE_RIG_REST_DELTA ",max_rest_error," orientation=",max_basis_error)
 if max_rest_error>0.15: source.queue_free(); return false
 animator=AnimationPlayer.new(); rig.add_child(animator)
 var cache="res://assets/characters/survivor_motion.res"
 var library
 if ResourceLoader.exists(cache) and not "--bake-rig" in OS.get_cmdline_user_args():
  library=load(cache)
  print("BASE_RIG_BAKED_LIBRARY loaded")
 else:
  library=bake_library(source_skeleton,source_player,rig.get_path_to(skeleton))
  if "--bake-rig" in OS.get_cmdline_user_args():
   var error=ResourceSaver.save(library,cache,ResourceSaver.FLAG_COMPRESS)
   if error!=OK: push_error("Cannot save baked rig animations: "+str(error)); return false
   print("BASE_RIG_BAKED_LIBRARY saved")
 animator.add_animation_library("",library)
 hand_socket=BoneAttachment3D.new(); skeleton.add_child(hand_socket); hand_socket.bone_name="hand_r"
 tool_grip=accessory_root("hand_r",Vector3.ZERO)
 add_accessories(game)
 remove_child(source); source.queue_free()
 return true

func bake_library(source_skeleton: Skeleton3D,source_player: AnimationPlayer,skeleton_path: NodePath) -> AnimationLibrary:
 var library=AnimationLibrary.new()
 for clip in source_player.get_animation_list():
  var original=source_player.get_animation(clip)
  var animation=Animation.new(); animation.length=original.length; animation.loop_mode=original.loop_mode
  for i in range(skeleton.get_bone_count()):
   var track=animation.add_track(Animation.TYPE_ROTATION_3D)
   animation.track_set_path(track,NodePath(String(skeleton_path)+":"+skeleton.get_bone_name(i)))
  var pelvis=skeleton.find_bone("pelvis")
  var motion=animation.add_track(Animation.TYPE_POSITION_3D)
  animation.track_set_path(motion,NodePath(String(skeleton_path)+":pelvis"))
  source_player.play(clip)
  var samples=maxi(1,ceili(original.length*30))
  for sample in range(samples+1):
   var time=original.length*float(sample)/samples
   source_player.seek(time,true); source_skeleton.force_update_all_bone_transforms()
   var desired=[]
   for i in range(skeleton.get_bone_count()):
    var other=source_skeleton.find_bone(skeleton.get_bone_name(i))
    var source_rest=source_skeleton.get_bone_global_rest(other).basis.get_rotation_quaternion()
    var source_pose=source_skeleton.get_bone_global_pose(other).basis.get_rotation_quaternion()
    var target_rest=skeleton.get_bone_global_rest(i).basis.get_rotation_quaternion()
    desired.append((source_pose*source_rest.inverse()*target_rest).normalized())
   for i in range(skeleton.get_bone_count()):
    var parent=skeleton.get_bone_parent(i)
    var parent_rotation=desired[parent] if parent>=0 else Quaternion.IDENTITY
    animation.rotation_track_insert_key(i,time,(parent_rotation.inverse()*desired[i]).normalized())
   var source_pelvis=source_skeleton.find_bone("pelvis")
   var offset=source_skeleton.get_bone_pose_position(source_pelvis)-source_skeleton.get_bone_rest(source_pelvis).origin
   animation.position_track_insert_key(motion,time,skeleton.get_bone_rest(pelvis).origin+offset)
  library.add_animation(clip,animation)
 return library

func accessory_root(bone: String,offset: Vector3) -> Node3D:
 var attachment=BoneAttachment3D.new(); skeleton.add_child(attachment); attachment.bone_name=bone
 var rest=skeleton.global_transform*skeleton.get_bone_global_rest(skeleton.find_bone(bone))
 var root=Node3D.new(); attachment.add_child(root)
 root.transform=rest.affine_inverse()*Transform3D(global_basis,rest.origin+global_basis*offset)
 return root

func add_accessories(game):
 var art=preload("res://creature_visuals.gd").new()
 var bag=accessory_root("spine_03",Vector3(0,-0.13,0.21))
 art.ellipsoid(game,bag,Vector3.ZERO,Vector3(0.4,0.46,0.22),Color("5c6552"))
 game.box(bag,Vector3(0,-0.06,0.12),Vector3(0.28,0.2,0.06),Color("46503f"))
 var roll=game.cylinder(bag,Vector3(0,0.24,0),0.07,0.38,Color("9a9677")); roll.rotation.z=PI/2
 for side in [-1,1]:
  game.box(bag,Vector3(side*0.12,0.02,0.13),Vector3(0.025,0.4,0.025),Color("303e37"))
 art.merge_meshes(bag)
 var cap=accessory_root("Head",Vector3(0,0.205,0))
 art.ellipsoid(game,cap,Vector3.ZERO,Vector3(0.25,0.12,0.25),Color("505f55"))
 game.box(cap,Vector3(0,-0.025,-0.12),Vector3(0.24,0.025,0.18),Color("505f55"))
 art.merge_meshes(cap)
 var detail=accessory_root("spine_02",Vector3(0,-0.06,-0.16))
 game.box(detail,Vector3.ZERO,Vector3(0.012,0.35,0.025),Color("344b49"))
 for side in [-1,1]:
  game.box(detail,Vector3(side*0.13,0.04,0),Vector3(0.12,0.13,0.03),Color("52676b"))
  game.box(detail,Vector3(side*0.13,0.105,-0.006),Vector3(0.13,0.018,0.035),Color("455b5d"))
 art.merge_meshes(detail)

func make_clothing():
 # Reuse the source skin weights to make fitted cloth shells. Keep the face,
 # fingers and hair visible; no rigid proxy torso is attached to this body.
 for mesh in rig.find_children("*","MeshInstance3D",true,false):
  if mesh.skin==null: continue
  for garment in ["jacket","trousers","boots"]:
   var cloth=ArrayMesh.new()
   for surface in range(mesh.mesh.get_surface_count()):
    var arrays=mesh.mesh.surface_get_arrays(surface).duplicate(true)
    var vertices=arrays[Mesh.ARRAY_VERTEX]; var normals=arrays[Mesh.ARRAY_NORMAL]
    var weights=arrays[Mesh.ARRAY_WEIGHTS]; var indices=arrays[Mesh.ARRAY_INDEX]; var bones=arrays[Mesh.ARRAY_BONES]
    if bones==null or weights==null or vertices.size()==0: continue
    var influences=bones.size()/vertices.size()
    var coverage=[]
    for vertex in range(vertices.size()):
     var amount=0.0
     for influence in range(influences):
      var binding=bones[vertex*influences+influence]
      var name=String(mesh.skin.get_bind_name(binding))
      if name=="": name=skeleton.get_bone_name(mesh.skin.get_bind_bone(binding))
      var match_group=(name.begins_with("spine_") or name.begins_with("clavicle_") or name.begins_with("neck_") or name.begins_with("upperarm_") or name.begins_with("lowerarm_")) if garment=="jacket" else ((name=="pelvis" or name.begins_with("thigh_") or name.begins_with("calf_")) if garment=="trousers" else (name.begins_with("foot_") or name.begins_with("ball_")))
      if match_group: amount+=weights[vertex*influences+influence]
     coverage.append(amount)
     vertices[vertex]+=normals[vertex]*0.014
    var selected=PackedInt32Array()
    for triangle in range(0,indices.size(),3):
     if minf(coverage[indices[triangle]],minf(coverage[indices[triangle+1]],coverage[indices[triangle+2]]))<0.45: continue
     selected.append(indices[triangle]); selected.append(indices[triangle+1]); selected.append(indices[triangle+2])
    if selected.is_empty(): continue
    arrays[Mesh.ARRAY_VERTEX]=vertices; arrays[Mesh.ARRAY_INDEX]=selected
    cloth.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
   if cloth.get_surface_count()==0: continue
   var node=MeshInstance3D.new(); mesh.get_parent().add_child(node)
   node.transform=mesh.transform; node.mesh=cloth; node.skin=mesh.skin; node.skeleton=node.get_path_to(skeleton)
   var material=StandardMaterial3D.new(); material.roughness=0.95
   material.albedo_color=coat_color if garment=="jacket" else (Color("3e5053") if garment=="trousers" else Color("323a36"))
   if garment=="jacket": jacket_materials.append(material)
   node.material_override=material

func outfit(item: String) -> Node3D:
 for material in jacket_materials:
  material.albedo_color=Color("74816c") if item=="防雨外套" else (Color("68736d") if item=="加固背心" else coat_color)
 if item=="": return null
 var root=accessory_root("spine_02",Vector3(0,-0.08,-0.17))
 for side in [-1,1]:
  game.box(root,Vector3(side*0.12,0,0),Vector3(0.11,0.15,0.045),Color("545f50"))
 return root

func play_action(clip: String):
 if animator.has_animation(clip) and current_action!=clip:
  current_action=clip; animator.play(clip,0.15)

func reset_pose():
 current_action=""; animator.stop(); skeleton.reset_bone_poses(); play_action("Idle")

func _process(_dt):
 if not gameplay or game==null: return
 animator.speed_scale=1.0 if game.playing and not game.panel_open else 0.0
 if animator.speed_scale==0: return
 var owner_body=get_parent()
 var moving=Vector2(owner_body.velocity.x,owner_body.velocity.z).length()>0.3
 var clip="Walk" if moving else "Idle"
 if owner_body==game.player:
  if game.death_time>0: clip="Death01"
  elif game.hit_reaction>0.15: clip="Hit_Chest"
  elif game.attack_time>0:
   clip="Sword_Attack" if game.equipped in ["石斧","木矛"] else "Punch_Jab"
  elif game.sea.position.y-owner_body.position.y>0.75: clip="Swim_Fwd" if moving else "Swim_Idle"
  elif not owner_body.is_on_floor(): clip="Jump" if owner_body.velocity.y>0 else "Jump_Land"
  elif Input.is_physical_key_pressed(KEY_CTRL): clip="Crouch_Fwd" if moving else "Crouch_Idle"
  elif game.block_held: clip="Sword_Idle"
  elif moving: clip="Sprint" if Input.is_physical_key_pressed(KEY_SHIFT) and game.stamina>2 else "Jog_Fwd"
 else:
  if owner_body.stopped_for_player: clip="Idle_Talking"
 play_action(clip)
