extends Node3D
var game
var velocity=Vector3.ZERO
var damage=35.0
var life=3.0
var flying=true
var can_recover=false

func recover() -> bool:
 if not can_recover: return false
 can_recover=false
 game.inv["箭"]=game.inv.get("箭",0)+1
 game.bag.sync(game.inv)
 game.toast("找回箭矢 ×1")
 hide(); queue_free()
 return true

func _exit_tree():
 if is_instance_valid(game): game.entities=game.entities.filter(func(e): return e.node!=self)

func _physics_process(dt):
 if not game.playing or game.panel_open or game.death_time>0: return
 life-=dt
 if life<=0: queue_free(); return
 if not flying: return
 var next=global_position+velocity*dt
 var query=PhysicsRayQueryParameters3D.create(global_position,next)
 query.exclude=[game.player.get_rid()]
 var hit=get_world_3d().direct_space_state.intersect_ray(query)
 if not hit.is_empty():
  global_position=hit.position
  var hit_enemy=false
  for enemy in game.enemies:
   if enemy.node==hit.collider and enemy.hp>0:
    game.damage_enemy(enemy,damage); hit_enemy=true; break
  flying=false; life=1.5
  if not hit_enemy:
   can_recover=true; life=45
   game.register(self,"箭矢","拾取",{},"arrow-"+str(get_instance_id()),"recover-arrow")
  game.soundscape.play_at("stone",global_position)
  return
 global_position=next
 velocity.y-=dt*2.5
 if velocity.length()>0.1: look_at(global_position+velocity.normalized(),Vector3.UP)
