extends Node3D

var game
var origin: Vector3
var destination: Vector3
var elapsed=0.0
var landed=false
var lifetime=4.0

func _physics_process(dt: float):
 if not game.playing or game.panel_open or game.death_time>0: return
 if landed:
  lifetime-=dt
  if lifetime<=0: queue_free()
  return
 elapsed=min(0.55,elapsed+dt)
 var t=elapsed/0.55
 var next=origin.lerp(destination,t)+Vector3.UP*sin(t*PI)*1.8
 var query=PhysicsRayQueryParameters3D.create(global_position,next)
 query.exclude=[game.player.get_rid()]
 var hit=get_world_3d().direct_space_state.intersect_ray(query)
 if not hit.is_empty():
  global_position=hit.position+hit.normal*0.08
  land()
 else:
  global_position=next
  if t>=1: land()

func land():
 landed=true
 game.noise_position=global_position
 game.noise_time=3
 game.soundscape.play_at("stone",global_position)
 game.toast("石块落地，引开附近未发现你的敌人。")
