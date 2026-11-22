extends Node3D
var game
var velocity=Vector3.ZERO
var damage=35.0
var life=3.0
var flying=true

func _physics_process(dt):
 life-=dt
 if life<=0: queue_free(); return
 if not flying: return
 var next=global_position+velocity*dt
 var query=PhysicsRayQueryParameters3D.create(global_position,next)
 query.exclude=[game.player.get_rid()]
 var hit=get_world_3d().direct_space_state.intersect_ray(query)
 if not hit.is_empty():
  global_position=hit.position
  for enemy in game.enemies:
   if enemy.node==hit.collider and enemy.hp>0:
    game.damage_enemy(enemy,damage); break
  flying=false; life=1.5
  game.soundscape.play_at("stone",global_position)
  return
 global_position=next
 velocity.y-=dt*2.5
 if velocity.length()>0.1: look_at(global_position+velocity.normalized(),Vector3.UP)
