extends Node
var game

func check(value: bool,message: String) -> bool:
 if not value: push_error("AI_FAILED "+message); get_tree().quit(1)
 return value

func frames(count: int):
 for i in range(count): await get_tree().physics_frame

func mouse(pressed: bool):
 var event=InputEventMouseButton.new(); event.button_index=MOUSE_BUTTON_RIGHT; event.pressed=pressed
 Input.parse_input_event(event)

func run():
 game.start_new()
 for e in game.enemies:
  e.hp=0; e.node.hide(); game.set_collisions(e.node,true)
 game.player.position=game.ground(Vector2(-35,135))+Vector3.UP
 var enemy=game.enemies[0]
 enemy.hp=60; enemy.node.show(); game.set_collisions(enemy.node,false)
 enemy.node.position=game.ground(Vector2(-35,123))
 enemy.home=enemy.node.position
 enemy.state="Chase"; enemy.timer=0; enemy.cooldown=0
 enemy["last_known"]=game.player.position; enemy["memory"]=6.0; enemy["stimulus"]="player"
 var center=game.ground(Vector2(-35,129))+Vector3(0,1.5,0)
 game.box(game,center,Vector3(10,3,0.3),Color("6d7776"),true)
 game.navigation.invalidate()
 var crossed=false; var detoured=false; var alert=false
 for i in range(1800):
  var delta=enemy.node.position-game.player.position; delta.y=0
  game.yaw=atan2(-delta.x,-delta.z)
  if abs(enemy.node.position.x+35)>5: detoured=true
  if enemy.node.position.z>131: crossed=true
  if enemy.has("windup"):
   alert=true; mouse(true)
  if game.health<99:
   mouse(false)
   if not check(crossed and detoured and alert,"attack occurred without valid obstacle detour and warning"): return
   var expected=(9.0 if enemy.kind==0 else 18.0)*0.25
   if not check(abs((100.0-game.health)-expected)<0.2 and game.stamina<95,"front block failed health=%s stamina=%s kind=%s"%[game.health,game.stamina,enemy.kind]): return
   if game.qa_dir!="": game.get_viewport().get_texture().get_image().save_png(game.qa_dir.path_join("ai-detour.png"))
   print("AI_OK actual_detour no_wall_cross windup front_block stamina")
   get_tree().quit(); return
  await frames(1)
 mouse(false)
 check(false,"chase timed out position=%s state=%s nav=%s path=%s"%[enemy.node.position,enemy.state,game.navigation.ready,enemy.get("path",[])])
