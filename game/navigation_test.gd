extends Node
var game

func run():
 game.start_new()
 game.player.position=game.ground(Vector2(-54.90564,50.03522))+Vector3.UP
 for i in range(100): await get_tree().physics_frame
 var nav=game.navigation
 var from=game.player.position; var to=game.ground(Vector2(-28,20.5))
 var start=nav.nearest_open(nav.cell(from)); var end=nav.nearest_open(nav.cell(to))
 var route=nav.path(from,to)
 print("NAV_DIAGNOSTIC from=",from," start=",start," target=",nav.cell(to)," end=",end," ready=",nav.ready," route=",route.size())
 for z in range(7,15):
  var row=""
  for x in range(-18,-8):
   var cell=Vector2i(x,z)
   row+="E" if cell==end else ("#" if nav.grid.is_point_solid(cell) else ".")
  print("NAV_ROW z=",z*2," x=-36..-18 ",row)
 if route.is_empty(): push_error("NAV_ROUTE_FAILED village_cargo"); get_tree().quit(1)
 else: print("NAV_ROUTE_OK village_cargo"); get_tree().quit()
