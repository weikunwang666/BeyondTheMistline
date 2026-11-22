extends RefCounted

static func grass() -> ArrayMesh:
 var surface=SurfaceTool.new()
 surface.begin(Mesh.PRIMITIVE_TRIANGLES)
 for blade in range(4):
  var angle=blade*2.4
  var side=Vector3(cos(angle),0,sin(angle))*0.045
  var origin=Vector3(sin(angle)*0.13,0,cos(angle)*0.13)
  var bend=Vector3(cos(angle+1)*0.13,0,sin(angle+1)*0.13)
  var top=origin+Vector3(0,0.65+blade*0.085,0)+bend
  for p in [origin-side,origin+side,top]:
   surface.set_color(Color("4d6547") if p.y<0.1 else Color("8d9a65"))
   surface.add_vertex(p)
 surface.generate_normals()
 return surface.commit()

static func pine(seed_value: int) -> ArrayMesh:
 var rng=RandomNumberGenerator.new(); rng.seed=seed_value
 var surface=SurfaceTool.new(); surface.begin(Mesh.PRIMITIVE_TRIANGLES)
 for tier in range(8):
  var y=2.3+tier*0.68
  var spread=(8-tier)*0.29
  for branch in range(7):
   var angle=branch*TAU/7+tier*0.8+rng.randf_range(-0.18,0.18)
   var tip=Vector3(cos(angle)*spread,y-0.25,sin(angle)*spread)
   for needle in range(8):
    var fraction=rng.randf_range(0.15,1)
    var center=Vector3.ZERO.lerp(tip,fraction); center.y=y+rng.randf_range(-0.35,0.25)
    var side=Vector3(-sin(angle),0,cos(angle))*rng.randf_range(0.18,0.48)*(1.2-fraction*0.3)
    var a=center-side
    var b=center+side
    var c=center+Vector3(cos(angle)*0.35,0.6,sin(angle)*0.35)
    var color=Color("314d42").lightened(rng.randf_range(-0.06,0.16))
    for p in [a,b,c]: surface.set_color(color); surface.add_vertex(p)
 surface.generate_normals()
 return surface.commit()

static func foliage_material() -> ShaderMaterial:
 var material=ShaderMaterial.new(); var shader=Shader.new()
 shader.code="""shader_type spatial;
render_mode cull_disabled;
varying vec3 shade;
void vertex(){
 vec3 world=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
 float strength=clamp(VERTEX.y*0.04,0.0,0.3);
 VERTEX.x+=sin(TIME*1.3+world.x*0.15+world.z*0.12)*strength;
 shade=COLOR.rgb;
}
void fragment(){ALBEDO=shade;ROUGHNESS=0.95;}
"""
 material.shader=shader
 return material
