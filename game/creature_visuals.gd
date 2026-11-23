extends RefCounted

func ellipsoid(game,parent,pos: Vector3,scale: Vector3,color: Color):
 var shape=SphereMesh.new(); shape.radial_segments=20; shape.rings=10
 var node=game.mesh(parent,shape,pos,color); node.scale=scale
 return node

func link(game,parent,a: Vector3,b: Vector3,radius: float,color: Color):
 var node=game.cylinder(parent,(a+b)*0.5,radius,a.distance_to(b),color,radius*0.7)
 node.quaternion=Quaternion(Vector3.UP,(b-a).normalized())
 return node

func build(game,root: Node3D,kind: int) -> Array:
 if kind==0: dog(game,root)
 else: crab(game,root)
 for child in root.get_children():
  if child.has_meta("phase"): merge_meshes(child)
 merge_meshes(root)
 var parts=[]
 for node in root.get_children():
  if node is MeshInstance3D or node.has_meta("phase"):
   parts.append({"node":node,"position":node.position,"rotation":node.rotation})
 return parts

func merge_meshes(parent: Node3D):
 var surface=SurfaceTool.new(); surface.begin(Mesh.PRIMITIVE_TRIANGLES)
 var sources=[]
 for child in parent.get_children():
  if not child is MeshInstance3D: continue
  sources.append(child)
  var arrays=child.mesh.surface_get_arrays(0)
  var vertices=arrays[Mesh.ARRAY_VERTEX]; var normals=arrays[Mesh.ARRAY_NORMAL]
  var indices=arrays[Mesh.ARRAY_INDEX]
  var normal_basis=child.transform.basis.inverse().transposed()
  for i in range(indices.size() if indices!=null else vertices.size()):
   var index=indices[i] if indices!=null else i
   surface.set_color(child.material_override.albedo_color)
   surface.set_normal((normal_basis*normals[index]).normalized())
   surface.add_vertex(child.transform*vertices[index])
 if sources.is_empty(): return
 var merged=MeshInstance3D.new(); merged.mesh=surface.commit()
 var material=StandardMaterial3D.new(); material.vertex_color_use_as_albedo=true; material.roughness=0.9
 merged.material_override=material
 for source in sources: parent.remove_child(source); source.queue_free()
 parent.add_child(merged)

func dog(game,root):
 var coat=Color("7b8178"); var pale=Color("aaa99a"); var dark=Color("454c46")
 ellipsoid(game,root,Vector3(0,0.94,0.05),Vector3(0.65,0.67,1.48),coat)
 ellipsoid(game,root,Vector3(0,1.03,-0.48),Vector3(0.76,0.84,0.65),pale)
 var head=Node3D.new(); head.position=Vector3(0,1.25,-0.73); root.add_child(head)
 head.set_meta("phase",0.0); head.set_meta("strike",true)
 ellipsoid(game,head,Vector3.ZERO,Vector3(0.49,0.53,0.62),coat)
 ellipsoid(game,head,Vector3(0,-0.09,-0.36),Vector3(0.31,0.27,0.57),pale)
 ellipsoid(game,head,Vector3(0,-0.03,-0.62),Vector3(0.23,0.13,0.12),dark)
 for side in [-1,1]:
  var ear=game.cylinder(head,Vector3(side*0.19,0.29,0.02),0.13,0.38,dark,0.015)
  ear.rotation.z=-side*0.2
  ellipsoid(game,head,Vector3(side*0.235,0.05,-0.19),Vector3(0.06,0.055,0.07),Color("cfba7d"))
  ellipsoid(game,head,Vector3(side*0.258,0.05,-0.205),Vector3(0.025,0.035,0.035),Color("1d2927"))
  for z in [-0.48,0.53]:
   var joint=Node3D.new(); joint.position=Vector3(side*0.25,0.91,z); root.add_child(joint)
   joint.set_meta("phase",0.0 if (side<0)==(z<0) else 1.0)
   var knee=Vector3(side*0.055,-0.38,0.12 if z>0 else -0.03)
   var ankle=Vector3(side*0.07,-0.77,-0.06)
   link(game,joint,Vector3.ZERO,knee,0.12,coat)
   link(game,joint,knee,ankle,0.065,pale)
   ellipsoid(game,joint,ankle+Vector3(0,-0.04,-0.09),Vector3(0.2,0.16,0.33),dark)
  for i in range(3):
   ellipsoid(game,root,Vector3(side*0.3,1.01+i*0.06,0.18+i*0.12),Vector3(0.05,0.17,0.22),pale)
 link(game,root,Vector3(0,1.0,0.65),Vector3(0,1.15,1.2),0.13,coat)
 link(game,root,Vector3(0,1.15,1.2),Vector3(0,0.92,1.53),0.09,dark)

func crab(game,root):
 var shell=Color("846b52"); var edge=Color("ad906c"); var dark=Color("514c40")
 ellipsoid(game,root,Vector3(0,0.7,0),Vector3(1.5,0.62,1.06),shell)
 ellipsoid(game,root,Vector3(0,0.86,-0.03),Vector3(1.1,0.31,0.83),edge)
 for side in [-1,1]:
  for i in range(4):
   var z=-0.38+i*0.25
   var joint=Node3D.new(); joint.position=Vector3(side*0.55,0.67,z); root.add_child(joint)
   joint.set_meta("phase",float(i%2) if side<0 else float((i+1)%2))
   var knee=Vector3(side*(0.53+sin(i)*0.1),-0.06,(i-1.5)*0.16)
   var foot=Vector3(side*0.72,-0.6,(i-1.5)*0.23)
   link(game,joint,Vector3.ZERO,knee,0.085,shell)
   link(game,joint,knee,foot,0.055,dark)
  var claw=Node3D.new(); claw.position=Vector3(side*0.58,0.77,-0.48); root.add_child(claw)
  claw.set_meta("phase",float(side>0)); claw.set_meta("strike",true)
  link(game,claw,Vector3.ZERO,Vector3(side*0.26,0,-0.38),0.12,shell)
  ellipsoid(game,claw,Vector3(side*0.28,0.02,-0.49),Vector3(0.43,0.32,0.52),edge)
  link(game,claw,Vector3(side*0.19,0.03,-0.63),Vector3(side*0.13,0.03,-0.91),0.07,dark)
  link(game,claw,Vector3(side*0.41,0.03,-0.63),Vector3(side*0.31,0.03,-0.9),0.065,edge)
  link(game,root,Vector3(side*0.25,0.83,-0.43),Vector3(side*0.31,1.05,-0.62),0.035,dark)
  ellipsoid(game,root,Vector3(side*0.31,1.06,-0.62),Vector3(0.1,0.1,0.1),Color("262e29"))
 for i in range(5):
  var line=game.box(root,Vector3((i-2)*0.19,1.01,0.05),Vector3(0.025,0.025,0.46),shell)
  line.rotation.y=(i-2)*0.1
