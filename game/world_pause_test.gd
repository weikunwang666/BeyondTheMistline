extends Node
var game
var driver

func check(ok: bool,message: String) -> bool:
 if not ok: push_error("WORLD_PAUSE_FAILED "+message); get_tree().quit(1)
 return ok

func run():
 driver=preload("res://journey_test.gd").new(); driver.game=game; add_child(driver)
 game.start_new()
 var arrow=game.launch_arrow(game.player.position+Vector3.UP*5,Vector3.RIGHT,10)
 await driver.frames(5)
 game.menu(); await driver.frames(2)
 var position_before=arrow.global_position; var life_before=arrow.life
 await driver.frames(30)
 if not check(arrow.global_position==position_before and arrow.life==life_before,"arrow advanced during menu"): return
 game.close_panel(); await driver.frames(4)
 if not check(arrow.global_position.distance_to(position_before)>0.5,"arrow failed to resume"): return
 game.player.velocity=Vector3(50,-30,20)
 game.start_new(); await driver.frames(2)
 if not check(get_tree().get_nodes_in_group("world_projectiles").is_empty() and abs(game.player.velocity.x)<0.1,"new game retained projectile/movement"): return
 game.inv={"石斧":1}; game.use_item("石斧")
 var tree={}
 for e in game.entities:
  if e.title=="灰松": tree=e; break
 game.target=tree; game.harvest_cooldown=0; game.interact()
 if not check(tree.hits==2 and tree.node.has_node("HarvestMarks"),"harvest damage mark missing"): return
 game.save_game(); game.load_game()
 if not check(tree.hits==2 and tree.node.has_node("HarvestMarks"),"partial harvest progress did not reload"): return
 game.target=tree
 var wood_before=game.inv.get("木材",0)
 for i in range(2): game.harvest_cooldown=0; game.interact()
 if not check(tree.id in game.removed and game.inv.get("木材",0)==wood_before+6,"tree harvest completion"): return
 game.harvest_cooldown=0; game.interact()
 if not check(game.inv.get("木材",0)==wood_before+6,"resource awarded twice"): return
 await driver.frames(4)
 if not check(tree.node.rotation.z>0,"tree fall did not begin"): return
 game.menu(); await driver.frames(2)
 var angle=tree.node.rotation.z
 await driver.frames(30)
 if not check(is_equal_approx(tree.node.rotation.z,angle),"fall animation advanced during menu"): return
 game.close_panel(); await driver.frames(60)
 if not check(not tree.node.visible,"tree fall did not finish"): return
 game.start_new(); await driver.frames(2)
 if not check(tree.node.visible and tree.get("hits",0)==0 and tree.node.rotation==tree.initial_rotation and not tree.node.has_node("HarvestMarks"),"new game retained harvested tree state"): return
 var enemy=game.enemies[0]
 game.damage_enemy(enemy,1000)
 game.start_new(); await driver.frames(45)
 if not check(enemy.hp>0 and is_zero_approx(enemy.node.rotation.z),"old death animation changed live enemy"): return
 print("WORLD_PAUSE_OK arrow_pause resume cleanup tree_pause partial_progress damage_marks reset enemy_tween_reset no_duplicate_resource")
 get_tree().quit()
