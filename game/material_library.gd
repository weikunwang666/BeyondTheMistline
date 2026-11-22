extends RefCounted

const ROOT="res://assets/materials/"
var textures={}

func texture(id: String,kind: String) -> Texture2D:
 var key=id+"_"+kind
 if not textures.has(key): textures[key]=load(ROOT+key+".jpg")
 return textures[key]

func pbr(id: String,tint: Color,metal=false) -> StandardMaterial3D:
 var result=StandardMaterial3D.new()
 result.albedo_texture=texture(id,"Diffuse")
 result.albedo_color=tint.lerp(Color.WHITE,0.75)
 result.normal_enabled=true; result.normal_texture=texture(id,"nor_gl"); result.normal_scale=0.55
 result.roughness_texture=texture(id,"Rough"); result.roughness_texture_channel=BaseMaterial3D.TEXTURE_CHANNEL_RED
 result.roughness=1.0; result.metallic=0.12 if metal else 0.0; result.metallic_specular=0.25
 result.uv1_triplanar=true; result.uv1_world_triplanar=true
 result.uv1_scale=Vector3.ONE*(0.45 if metal else 0.35)
 return result

func ground_material() -> ShaderMaterial:
 var result=ShaderMaterial.new(); var shader=Shader.new()
 shader.code="""shader_type spatial;
uniform sampler2D sand_tex: source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D forest_tex: source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D rock_tex: source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform float wet=0.0;
varying vec3 world;
void vertex(){world=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;}
void fragment(){
 vec2 uv=world.xz*0.25;
 vec3 sand=texture(sand_tex,uv).rgb;
 vec3 forest=texture(forest_tex,uv).rgb;
 vec3 rock=texture(rock_tex,uv*0.6).rgb;
 float inland=smoothstep(-65.0,-35.0,world.x);
 float highland=1.0-smoothstep(-120.0,-85.0,world.z);
 vec3 color=mix(mix(sand,forest,inland),rock,highland*0.7);
 float marsh=1.0-smoothstep(20.0,34.0,length(world.xz-vec2(-48.0,-80.0)));
 color=mix(color,color*vec3(0.65,0.79,0.72),marsh*0.65);
 ALBEDO=color*mix(1.0,0.72,wet);
 ROUGHNESS=mix(0.95,0.65,wet);SPECULAR=0.18;
}
"""
 result.shader=shader
 result.set_shader_parameter("sand_tex",texture("coast_sand_01","Diffuse"))
 result.set_shader_parameter("forest_tex",texture("forest_ground_04","Diffuse"))
 result.set_shader_parameter("rock_tex",texture("rock_face_03","Diffuse"))
 return result
