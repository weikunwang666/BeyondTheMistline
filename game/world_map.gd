extends Control
var game
const SIDE=420.0

func point(p: Vector2) -> Vector2:
 return (p/420.0+Vector2.ONE*0.5)*Vector2(size.x,size.y)

func _draw():
 if game.map_texture==null: game.map_texture=game.make_map_texture()
 draw_texture_rect(game.map_texture,Rect2(Vector2.ZERO,size),false)
 for x in range(21):
  for z in range(21):
   if not game.explored.has(str(x)+","+str(z)):
    draw_rect(Rect2(Vector2(x,z)*size/21, size/21+Vector2.ONE),Color(0.025,0.045,0.05,0.78))
 for i in range(1,10):
  draw_line(Vector2(size.x*i/10,0),Vector2(size.x*i/10,size.y),Color(1,1,1,0.08))
  draw_line(Vector2(0,size.y*i/10),Vector2(size.x,size.y*i/10),Color(1,1,1,0.08))
 var font=ThemeDB.fallback_font
 draw_string(font,Vector2(12,22),"北 ↑   ·   北境沉降带",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("e8dcc0"))
 for poi in game.POIS:
  if poi[0] not in game.discovered: continue
  var p=point(poi[1])
  draw_circle(p,5,Color("e6c77b"))
  draw_string(font,p+Vector2(8,-6),poi[0],HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("f1e5ce"))
 for id in game.quests.states:
  if game.quests.states[id]!=1: continue
  var target=game.quests.DEFINITIONS[id].target
  if id=="aid" and game.inv.get("急救箱",0)>0 and not game.survivors.is_empty():
   target=Vector2(game.survivors[0].position.x,game.survivors[0].position.z)
  var p=point(target)
  draw_arc(p,10,0,TAU,16,Color("8cdce3"),2)
  draw_string(font,p+Vector2(12,14),game.quests.DEFINITIONS[id].title,HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("8cdce3"))
 if "废弃渔村" in game.discovered and not game.survivors.is_empty():
  var npc=game.survivors[0]
  var location=point(Vector2(npc.position.x,npc.position.z))
  draw_circle(location,4,Color("b7d49d"))
  draw_string(font,location+Vector2(7,-10),"伊莱",HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("b7d49d"))
 for s in game.structures:
  var p=point(Vector2(s.pos[0],s.pos[2]))
  draw_rect(Rect2(p-Vector2.ONE*3,Vector2.ONE*6),Color("9dc9ad"))
 for p in game.map_markers:
  var v=point(Vector2(p[0],p[1]))
  draw_line(v-Vector2(5,5),v+Vector2(5,5),Color("ed956c"),2)
  draw_line(v-Vector2(5,-5),v+Vector2(5,-5),Color("ed956c"),2)
 var p=point(Vector2(game.player.position.x,game.player.position.z))
 draw_circle(p,6,Color("dceff2"))
 draw_line(p,p+Vector2(-sin(game.yaw),-cos(game.yaw))*17,Color.WHITE,2)

func _gui_input(event):
 if event is InputEventMouseButton and event.pressed:
  var p=(event.position/size-Vector2.ONE*0.5)*SIDE
  if event.button_index==MOUSE_BUTTON_LEFT:
   if game.map_markers.size()<20: game.map_markers.append([p.x,p.y])
  elif event.button_index==MOUSE_BUTTON_RIGHT:
   var nearest=-1; var distance=20.0
   for i in range(game.map_markers.size()):
    var marker=game.map_markers[i]
    var d=p.distance_to(Vector2(marker[0],marker[1]))
    if d<distance: nearest=i; distance=d
   if nearest>=0: game.map_markers.remove_at(nearest)
  queue_redraw()
