extends Node3D
# Evaluation adapter: original geometry driven by the licensed animation skeleton.
# Not enabled for normal gameplay until equipment and collision workflows are verified.
var game
var rig: Node3D
var skeleton: Skeleton3D
var animator: AnimationPlayer
var sockets={}
var hand_socket: BoneAttachment3D

func point(bone: String) -> Vector3:
 return to_local(skeleton.global_transform*skeleton.get_bone_global_rest(skeleton.find_bone(bone)).origin)

func socket(bone: String) -> BoneAttachment3D:
 if sockets.has(bone): return sockets[bone]
 var node=BoneAttachment3D.new(); skeleton.add_child(node); node.bone_name=bone
 node.transform=skeleton.get_bone_global_rest(skeleton.find_bone(bone))
 sockets[bone]=node
 return node

func bind(node: Node3D,bone: String):
 var rest=skeleton.global_transform*skeleton.get_bone_global_rest(skeleton.find_bone(bone))
 var transform=rest.affine_inverse()*node.global_transform
 node.reparent(socket(bone),false); node.transform=transform

func build(owner_game) -> bool:
 game=owner_game
 rig=load("res://assets/characters/UAL1_Standard.glb").instantiate(); add_child(rig)
 rig.rotation.y=PI
 for mesh in rig.find_children("*","MeshInstance3D",true,false): mesh.hide()
 var bones=rig.find_children("*","Skeleton3D",true,false)
 var animations=rig.find_children("*","AnimationPlayer",true,false)
 if bones.size()!=1 or animations.size()!=1: return false
 skeleton=bones[0]; animator=animations[0]
 for bone in ["Head","pelvis","spine_01","spine_02","spine_03","upperarm_l","lowerarm_l","hand_l","upperarm_r","lowerarm_r","hand_r","thigh_l","calf_l","foot_l","thigh_r","calf_r","foot_r"]:
  if skeleton.find_bone(bone)<0: return false
 var art=preload("res://creature_visuals.gd").new()
 var coat=Color("617579"); var pants=Color("3e5053"); var skin=Color("b5a38b")
 var hip=point("pelvis"); var chest=point("spine_03"); var head=point("Head")
 bind(art.ellipsoid(game,self,(hip+chest)*0.5,Vector3(0.5,hip.distance_to(chest)+0.18,0.34),coat),"spine_01")
 bind(art.ellipsoid(game,self,hip,Vector3(0.42,0.24,0.31),pants),"pelvis")
 bind(art.ellipsoid(game,self,head+Vector3.UP*0.1,Vector3(0.29,0.33,0.3),skin),"Head")
 bind(game.cylinder(self,head+Vector3.UP*0.26,0.17,0.08,Color("505f55")),"Head")
 bind(game.box(self,head+Vector3(0,0.23,-0.15),Vector3(0.32,0.025,0.18),Color("505f55")),"Head")
 bind(game.box(self,chest+Vector3(0,-0.12,0.22),Vector3(0.4,0.42,0.18),Color("5c6552")),"spine_02")
 for side in ["l","r"]:
  var arm="upperarm_"+side; var forearm="lowerarm_"+side; var hand="hand_"+side
  bind(art.link(game,self,point(arm),point(forearm),0.085,coat),arm)
  bind(art.link(game,self,point(forearm),point(hand),0.065,coat),forearm)
  bind(art.ellipsoid(game,self,point(hand),Vector3(0.14,0.14,0.16),Color("554f40")),hand)
  var thigh="thigh_"+side; var calf="calf_"+side; var foot="foot_"+side
  bind(art.link(game,self,point(thigh),point(calf),0.105,pants),thigh)
  bind(art.link(game,self,point(calf),point(foot),0.075,pants),calf)
  bind(art.ellipsoid(game,self,point(foot)+Vector3(0,-0.015,-0.06),Vector3(0.21,0.17,0.32),Color("323a36")),foot)
 for bone in sockets: art.merge_meshes(sockets[bone])
 hand_socket=socket("hand_r")
 return true

func play_action(clip: String):
 if animator.has_animation(clip): animator.play(clip,0.15)
