extends Node
var game

func check(value: bool,message: String) -> bool:
 if not value: push_error("COMBAT_FAILED "+message); get_tree().quit(1)
 return value

func frames(count: int):
 for i in range(count): await get_tree().physics_frame

func run():
 game.start_new()
 for e in game.enemies:
  e.hp=0; e.node.hide(); game.set_collisions(e.node,true)
 game.player.position=game.ground(Vector2(-35,135))+Vector3.UP
 var enemy=game.enemies[0]
 enemy.hp=60; enemy.node.show(); game.set_collisions(enemy.node,false)
 enemy.node.position=game.ground(Vector2(-35,129))
 enemy.state="Alert"; enemy.timer=-20
 var a=game.player.position+Vector3.UP
 var b=enemy.node.position+Vector3(0,0.8,0)
 var wall=game.box(game,(a+b)*0.5,Vector3(3,3,0.25),Color("756b5b"),true)
 await frames(3)
 var arrow=game.launch_arrow(a,(b-a).normalized(),35)
 await frames(24)
 if not check(enemy.hp==60 and is_instance_valid(arrow) and not arrow.flying,"wall failed to stop arrow"): return
 if not check(arrow.can_recover,"wall arrow cannot be recovered"): return
 game.player.position=arrow.global_position+Vector3(0,0,1)
 await frames(3)
 if not check(game.target.get("kind","")=="recover-arrow","arrow pickup not targeted"): return
 var before=game.inv.get("箭",0)
 var key=InputEventKey.new(); key.keycode=KEY_E; key.pressed=true; Input.parse_input_event(key)
 await frames(2)
 key=InputEventKey.new(); key.keycode=KEY_E; key.pressed=false; Input.parse_input_event(key)
 if not check(game.inv.get("箭",0)==before+1,"E did not recover one arrow"): return
 await frames(2)
 if not check(not is_instance_valid(arrow),"recovered projectile remained active"): return
 game.player.position=game.ground(Vector2(-35,135))+Vector3.UP
 wall.queue_free(); await frames(3)
 enemy.timer=-20
 a=game.player.position+Vector3.UP; b=enemy.node.position+Vector3(0,0.8,0)
 game.launch_arrow(a,(b-a).normalized(),35)
 await frames(24)
 if not check(enemy.hp==25,"unblocked projectile failed to hit"): return
 enemy.state="Alert"; enemy.timer=-20
 b=enemy.node.position+Vector3(0,0.8,0)
 game.launch_arrow(a,(b-a).normalized(),35)
 await frames(32)
 if not check(enemy.hp<=0 and enemy.state=="Dead","projectile kill failed"): return
 var kills=game.dropped_loot.size()
 game.damage_enemy(enemy,35)
 if not check(game.dropped_loot.size()==kills,"dead enemy generated duplicate loot"): return
 game.inv={"弓":1,"箭":0}; game.equipped="弓"; game.attack_time=0; game.stamina=100
 game.attack()
 if not check(game.stamina==100 and game.attack_time==0,"empty bow spent stamina"): return
 game.make_structure("篝火",game.player.position+Vector3(5,0,0),0)
 game.inv={"木材":3,"净水":1}; game.craft_job={"item":"木矛","left":2.0,"cost":{"木材":4,"纤维":2}}
 game.skill_xp["战斗"]=120
 game.health=0; game.die()
 if not check(game.death_time>0 and game.inv.get("木材",0)==3,"death pose phase missing"): return
 await frames(160)
 var drops=game.dropped_loot.back()
 if not check(game.death_time==0 and game.inv.is_empty() and drops.gives.get("木材",0)==7,"death did not drop inventory and reserved materials"): return
 if not check(game.structures.size()==1 and game.skill_xp["战斗"]==120,"death lost base or growth"): return
 print("COMBAT_OK projectile_wall hit kill loot_once empty_bow death_pose reserved_drops base_growth")
 get_tree().quit()
