extends Node
var game
var pilot
var crossing=false
var deepest=-100.0

func check(ok: bool,message: String) -> bool:
 if not ok:
  push_error("TIDE_JOURNEY_FAILED "+message+" position=%s clock=%s depth=%s"%[game.player.position,game.clock,deepest])
  get_tree().quit(1)
 return ok

func _physics_process(_dt):
 if crossing: deepest=max(deepest,game.sea.position.y-game.player.position.y)

func run_edge():
 var driver=preload("res://journey_test.gd").new(); driver.game=game; add_child(driver)
 game.start_new(); game.clock=9; game.inv={"木材":20,"石头":20}
 game.player.position=game.ground(Vector2(-151,-98))+Vector3.UP
 await driver.frames(60)
 driver.key(KEY_W,true)
 var arrived=false
 for i in range(600):
  var delta=Vector3(-165-game.player.position.x,0,-100-game.player.position.z)
  if delta.length()<0.55: arrived=true; break
  game.yaw=atan2(-delta.x,-delta.z)
  if i%60==0:
   print("EDGE position=",game.player.position," floor=",game.player.is_on_floor()," normal=",game.player.get_floor_normal()," velocity=",game.player.velocity)
   for j in range(game.player.get_slide_collision_count()):
    var collision=game.player.get_slide_collision(j)
    print("EDGE_COLLISION normal=",collision.get_normal()," collider=",collision.get_collider().get_path())
  await driver.frames(1)
 driver.key(KEY_W,false)
 if not check(arrived,"controlled overloaded slope walk"): return
 print("TIDE_EDGE_OK actual_overweight_slope_walk")
 get_tree().quit()

func run():
 # Expert route from the normal new-game spawn: no grants, teleport or clock change.
 pilot=preload("res://mainline_test.gd").new(); pilot.game=game; add_child(pilot)
 pilot.driver=preload("res://journey_test.gd").new(); pilot.driver.game=game; add_child(pilot.driver)
 game.start_new()
 await pilot.driver.frames(15)
 for i in range(6):
  if not await pilot.interact_id("start"+str(i)): return
 if not await pilot.interact_id("poi-village"): return
 if not await pilot.interact_id("tide-sign"): return
 if not check(game.panel_open,"tide warning did not open"): return
 await pilot.driver.tap(KEY_ESCAPE)
 if not check(game.sea.position.y< -0.25,"missed natural low tide departure"): return
 crossing=true
 var before=game.health
 for x in [-120,-132,-144,-156,-168,-174]:
  if not await pilot.walk(Vector2(x,-100)): return
 await pilot.driver.frames(10)
 if not check(game.target.get("id","")=="tidal-cargo","cargo interaction not reachable"): return
 await pilot.driver.tap(KEY_E)
 if not check("tidal-cargo" in game.removed and game.inv.get("电池",0)>=1 and game.inv.get("零件",0)>=5,"cargo did not grant actual supplies"): return
 for x in [-162,-150,-138,-126,-114,-108]:
  if not await pilot.walk(Vector2(x,-96 if x==-108 else -100)): return
 crossing=false
 if not check(deepest<0.35 and game.health>=before-0.1 and game.death_time==0,"low-tide round trip caused deep water damage"): return
 await pilot.driver.tap(KEY_F5)
 if game.qa_dir!="": game.get_viewport().get_texture().get_image().save_png(game.qa_dir.path_join("tide-roundtrip.png"))
 print("TIDE_JOURNEY_OK normal_spawn natural_low_tide W_movement warning cargo roundtrip save max_depth=",deepest," clock=",game.clock)
 get_tree().quit()
