extends Node
var game
var model: Node3D
var look=Vector3.ZERO

func _process(_dt):
 if model==null: return
 game.camera.position=look+Vector3(2.7,1.7,-3.6)
 game.camera.look_at(look+Vector3.UP*0.7)

func run():
 game.start_new(); game.playing=false; game.player.hide()
 for enemy in game.enemies: enemy.node.hide()
 game.clock=10; game.update_world(1)
 var light=DirectionalLight3D.new(); light.rotation_degrees=Vector3(-35,-145,0)
 light.light_energy=1.5; game.add_child(light)
 game.environment.ambient_light_energy=0.8
 for kind in range(3):
  var center=game.ground(Vector2(-70,70))
  if kind<2:
   game.make_enemy(Vector2(-70,70),kind)
   var enemy=game.enemies.back(); enemy.hp=0; model=enemy.node; model.position=center
   model.get_node("Indicator").hide()
  else: model=game.actor(game,center,Color("617579"))
  look=center
  for i in range(20): await get_tree().process_frame
  if game.qa_dir!="": game.get_viewport().get_texture().get_image().save_png(game.qa_dir.path_join("creature-%d.png"%kind))
  model.hide()
 print("CREATURE_GALLERY_OK dog crab survivor calibrated_preview_light")
 get_tree().quit()
