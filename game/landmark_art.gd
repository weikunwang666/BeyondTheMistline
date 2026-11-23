extends RefCounted

func build(game,root: Node3D,kind: String):
 if kind=="wreck": wreck(game,root)
 elif kind=="lighthouse": lighthouse(game,root)
 elif kind in ["village","warehouse","factory","lab","pump"]: building(game,root,kind)

func wreck(game,root):
 var steel=Color("495956"); var wood=Color("655a4a")
 for x in [-4.5,-3,-1.5,0,1.5,3,4.5]:
  game.box(root,Vector3(x,1.85,-1.8),Vector3(0.11,2.4,0.15),steel)
 game.box(root,Vector3(0,3.22,-1.85),Vector3(10.2,0.15,0.22),wood)
 game.box(root,Vector3(0,1.05,-1.8),Vector3(10,0.22,0.12),steel)
 # The cabin stays within the existing wreck's footprint; open deck remains east.
 game.box(root,Vector3(-3,1.65,-0.3),Vector3(2.3,2.2,0.13),Color("61746e"),true)
 for x in [-4.2,-1.8]: game.box(root,Vector3(x,1.65,-1),Vector3(0.12,2.2,1.5),Color("61746e"),true)
 game.box(root,Vector3(-3,2.85,-1),Vector3(2.7,0.17,1.9),wood,true)
 for x in [-3.6,-2.4]:
  game.box(root,Vector3(x,2,-0.21),Vector3(0.72,0.65,0.03),Color("253c40"))
  game.box(root,Vector3(x,2.35,-0.18),Vector3(0.8,0.055,0.08),wood)
 var mast=game.cylinder(root,Vector3(1,3,-1.5),0.08,5.4,steel); mast.rotation.z=-0.16
 game.box(root,Vector3(1.35,4.4,-1.5),Vector3(2.4,0.09,0.1),steel).rotation.z=-0.16
 var rope=game.cylinder(root,Vector3(2.6,2.4,-1.45),0.018,4.5,Color("8e8970")); rope.rotation.z=-0.6
 for side in [-1,1]:
  var ring=game.cylinder(root,Vector3(4*side,1.7,-1.66),0.34,0.12,Color("c68e64")); ring.rotation.x=PI/2
  game.cylinder(root,Vector3(4*side,1.7,-1.58),0.19,0.14,Color("495956")).rotation.x=PI/2

func building(game,root,kind):
 var width=9.0 if kind in ["warehouse","factory","lab"] else 5.0
 var trim=Color("495956")
 game.box(root,Vector3(0,0.38,5.14),Vector3(width*2,0.2,0.12),trim)
 for x in [-width,-width*0.5,width*0.5,width]:
  game.box(root,Vector3(x,2.6,5.18),Vector3(0.12,4.9,0.12),trim)
 game.box(root,Vector3(0,4.7,5.2),Vector3(3.2,0.65,0.18),Color("657a70"))
 var sign=Label3D.new(); sign.font=game.ui_font
 sign.text={"village":"守 岸 人 补 给 站","warehouse":"海 岸 物 资 仓 库","factory":"北 境 机 械 厂","lab":"灰 潮 研 究 所","pump":"地 下 水 站"}[kind]
 sign.font_size=28; sign.pixel_size=0.004; sign.position=Vector3(0,4.7,5.31); root.add_child(sign)
 for x in [-1.35,1.35]:
  game.box(root,Vector3(x,3.75,5.27),Vector3(0.12,0.3,0.22),Color("b9b18d"))
 game.box(root,Vector3(0,5.12,5.6),Vector3(3.3,0.12,1.5),trim)

func lighthouse(game,root):
 var dark=Color("495956")
 for y in [2.0,8.0,14.0]:
  game.cylinder(root,Vector3(0,y,0),lerpf(2.6,1.8,y/18)+0.04,0.18,dark)
 game.cylinder(root,Vector3(0,18.9,0),1.76,1.3,Color("77958e"))
 for i in range(10):
  var angle=i*TAU/10; var p=Vector3(cos(angle)*2.4,18.6,sin(angle)*2.4)
  game.cylinder(root,p,0.035,1.2,dark)
  game.cylinder(root,Vector3(cos(angle)*1.8,18.9,sin(angle)*1.8),0.045,1.7,dark)
 game.cylinder(root,Vector3(0,18.7,0),2.46,0.06,dark)
 game.box(root,Vector3(0,1.25,2.5),Vector3(1,2.5,0.15),Color("495956"))
