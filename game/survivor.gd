extends CharacterBody3D

var game
var visual: Node3D
var home: Vector3
var destination=Vector3.ZERO
var activity="整理补给"
var route=[]
var route_clock=0.0
var phase=0.0
var schedule_id=-1
var revision=-1
var stopped_for_player=false

func schedule(hour: float,weather: int) -> Dictionary:
 if weather in [3,5]: return {"id":4,"title":"避雨整理物资","point":Vector2(home.x,home.z)}
 if hour<6 or hour>=20: return {"id":3,"title":"休息","point":Vector2(home.x+1,home.z+1)}
 if hour<9: return {"id":0,"title":"巡查海岸","point":Vector2(-40,26)}
 if hour<17: return {"id":1,"title":"整理补给","point":Vector2(home.x,home.z)}
 return {"id":2,"title":"守望灯塔","point":Vector2(-38,24)}

func reset():
 position=home; velocity=Vector3.ZERO
 route=[]; route_clock=0; schedule_id=-1; stopped_for_player=false

func _physics_process(dt: float):
 if not game.playing or game.panel_open: return
 var plan=schedule(game.clock,game.weather)
 activity=plan.title
 if schedule_id!=plan.id:
  schedule_id=plan.id; destination=game.ground(plan.point); route_clock=0
 var to_player=game.player.position-position
 to_player.y=0
 stopped_for_player=to_player.length()<2.8 and game.visible_between(position+Vector3.UP,game.player.position+Vector3.UP)
 var direction=Vector3.ZERO
 var delta=destination-position; delta.y=0
 if stopped_for_player:
  if to_player.length()>0.1: visual.rotation.y=lerp_angle(visual.rotation.y,atan2(-to_player.x,-to_player.z),dt*6)
 elif delta.length()>0.7 and game.navigation.ready:
  route_clock-=dt
  if game.visible_between(position+Vector3.UP,destination+Vector3.UP): direction=delta
  else:
   if route_clock<=0 or revision!=game.navigation.revision:
    route=game.navigation.path(position,destination); route_clock=1; revision=game.navigation.revision
   while not route.is_empty() and Vector2(position.x,position.z).distance_to(Vector2(route[0].x,route[0].z))<0.9: route.pop_front()
   if not route.is_empty(): direction=route[0]-position; direction.y=0
 var moving=direction.length()>0.1
 var motion=direction.normalized()*1.45
 velocity=Vector3(motion.x,velocity.y-dt*20,motion.z)
 move_and_slide()
 if moving: visual.rotation.y=lerp_angle(visual.rotation.y,atan2(-motion.x,-motion.z),dt*8)
 phase+=dt*(7 if moving else 1)
 for limb in visual.get_children():
  if limb.has_meta("walk_phase"):
   limb.rotation.x=sin(phase+float(limb.get_meta("walk_phase")))*0.38 if moving else move_toward(limb.rotation.x,0,dt*3)
 visual.position.y=sin(phase)*0.025 if moving else sin(phase)*0.008
