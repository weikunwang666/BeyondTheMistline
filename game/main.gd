extends Node3D

const SAVE = "user://mistline.json"
var save_store=preload("res://save_store.gd").new()
const Bag = preload("res://bag.gd")
const BagSlot = preload("res://bag_slot.gd")
var bag = Bag.new()
var quickbar = ["野果","净水","绷带","罐头","烤肉","石斧","木矛","弓"]
var equipped = ""
var durability = {}
var selected_slot = -1
var quick_hud: HBoxContainer
var held_tool: Node3D
var harvest_cooldown = 0.0
var quick_signature = ""
var terrain_body: RID
var bag_preview = false
var ghost_material: StandardMaterial3D
const WorldNavigation = preload("res://navigation.gd")
var navigation = WorldNavigation.new()
var map_markers = []
var story_read = []
var block_held = false
var damage_flash: ColorRect
var map_preview=false
const EnvironmentArt=preload("res://environment_art.gd")
var pine_meshes=[]
var foliage_material: ShaderMaterial
var sky_material: ProceduralSkyMaterial
var explored = {}
var map_texture: ImageTexture
var tide_warning=0.0
var coast_gallery=false
var material_library=preload("res://material_library.gd").new()
var terrain_material: ShaderMaterial
var wet_ground=0.0
var sky_update_clock=0.0
var soundscape
var invert_y=false
var shadows_enabled=true
var selected_resolution=0
var saved_fullscreen=false
var survival=preload("res://survival_state.gd").new()
var skill_xp={"生存":0,"采集":0,"制作":0,"战斗":0,"探索":0}
var craft_job={}
var milestones={}
var quests=preload("res://quest_log.gd").new()
var pump_stock=0.0
var pump_cooldown=0.0
var signal_lights={}
var signal_screens={}
var signal_signature=""
var senses=preload("res://enemy_senses.gd").new()
var noise_position=Vector3.ZERO
var noise_time=0.0
var mouse_look_guard=0.0
var hit_reaction=0.0
var landing_reaction=0.0
var death_time=0.0
var previous_fall_speed=0.0
var settings_active=false
const RESOLUTIONS=[Vector2i(1280,720),Vector2i(1600,900),Vector2i(1920,1080)]
var rng = RandomNumberGenerator.new()
var player: CharacterBody3D
var body: Node3D
var limbs = []
var camera: Camera3D
var yaw = 0.0
var pitch = -0.24
var clock = 8.0
var weather = 0
var weather_time = 0.0
var health = 100.0
var hunger = 100.0
var thirst = 100.0
var stamina = 100.0
var temperature = 37.0
var inv = {}
var removed = []
var structures = []
var repairs = []
var discovered = []
var entities = []
var enemies = []
var target = {}
var playing = false
var panel_open = false
var build_kind = ""
var ghost: Node3D
var build_pos = Vector3.ZERO
var build_angle = 0.0
var attack_time = 0.0
var walk_time = 0.0
var autosave = 0.0
var sun: DirectionalLight3D
var environment: Environment
var sea: MeshInstance3D
var hud: Label
var prompt: Label
var notices: Label
var panel: PanelContainer
var content: VBoxContainer
var toast_time = 0.0
var synth: AudioStreamPlayer
var audio_playback
var tone = 0.0
var tone_length = 0.0
var volume = 0.5
var sensitivity = 0.003
var fov = 72.0
var smoke = false
var frame_count = 0
var stats_label: Label
var materials = {}
var dropped_loot = []
var rain: CPUParticles3D
var ambience_phase = 0.0
var gallery = false
var qa_dir = ""

const ITEMS = {"急救箱":0.7,"河水":0.5,"木材":0.8,"石头":1.0,"纤维":0.1,"野果":0.1,"金属":0.5,"布料":0.1,"零件":0.3,"生肉":0.4,"烤肉":0.3,"净水":0.5,"罐头":0.4,"绷带":0.1,"石斧":1.5,"木矛":1.5,"火把":0.5,"弓":1.0,"箭":0.05,"滤芯":0.2,"绳索":0.2,"工具包":1.0,"电池":0.4,"研究数据":0.1}
const RECIPES = {
 "石斧":{"木材":3,"石头":3},"木矛":{"木材":4,"纤维":2},"绷带":{"布料":2},"火把":{"木材":2,"纤维":2},
 "绳索":{"纤维":3},"箭":{"木材":1,"石头":1},"弓":{"木材":5,"绳索":2},"滤芯":{"纤维":5,"石头":2},
 "净水":{"滤芯":1,"河水":1},"烤肉":{"生肉":1,"木材":1},"工具包":{"金属":4,"木材":2},"电池":{"金属":3,"零件":2}}
const BUILDS = {"楼梯":{"木材":4},"篝火":{"木材":5,"石头":3},"睡袋":{"布料":4,"纤维":4},"工作台":{"木材":8,"金属":3},"储物箱":{"木材":6},"地基":{"木材":6,"石头":2},"墙":{"木材":4},"门框":{"木材":4},"屋顶":{"木材":5},"集雨器":{"金属":3,"纤维":3}}
const POIS = [
 ["海难沙滩",Vector2(-65,65),"wreck"], ["旧灯塔",Vector2(-88,-34),"lighthouse"],
 ["废弃渔村",Vector2(-30,12),"village"], ["森林营地",Vector2(38,70),"camp"],
 ["盐业加工厂",Vector2(100,-18),"factory"], ["废弃仓库",Vector2(72,16),"warehouse"],
 ["地下水泵站",Vector2(26,-65),"pump"], ["旧研究所",Vector2(90,-100),"lab"],
 ["沉没港口",Vector2(-105,-100),"port"], ["山地通讯站",Vector2(20,-145),"tower"]]

func _ready():
 rng.seed = 2049
 load_settings()
 smoke = "--smoke" in OS.get_cmdline_user_args()
 gallery = "--gallery" in OS.get_cmdline_user_args()
 bag_preview="--bag-preview" in OS.get_cmdline_user_args()
 map_preview="--map-preview" in OS.get_cmdline_user_args()
 coast_gallery="--coast-gallery" in OS.get_cmdline_user_args()
 qa_dir=OS.get_environment("MISTLINE_QA_DIR")
 make_world()
 make_player()
 make_ui()
 make_audio()
 menu()
 if "--mainline-read" in OS.get_cmdline_user_args():
  load_game()
  var okay=playing and repairs.size()==3 and inv.get("研究数据",0)==1 and structures.size()>=2 and skill_xp.get("制作",0)>=100
  if okay: print("MAINLINE_RESTART_OK actual_completed_chapter"); get_tree().quit()
  else: push_error("MAINLINE_RESTART_FAILED"); get_tree().quit(1)
  return
 if "--mainline-test" in OS.get_cmdline_user_args():
  var test=preload("res://mainline_test.gd").new(); test.game=self; add_child(test); test.call_deferred("run")
  return
 if "--quest-test" in OS.get_cmdline_user_args():
  var test=preload("res://quest_test.gd").new(); test.game=self; add_child(test); test.call_deferred("run")
  return
 if "--benchmark" in OS.get_cmdline_user_args():
  var benchmark=preload("res://benchmark.gd").new(); benchmark.game=self; add_child(benchmark)
  return
 if "--perception-test" in OS.get_cmdline_user_args():
  var test=preload("res://perception_test.gd").new(); test.game=self; add_child(test); test.call_deferred("run")
  return
 if "--ai-test" in OS.get_cmdline_user_args():
  var ai=preload("res://ai_test.gd").new(); ai.game=self; add_child(ai); ai.call_deferred("run")
  return
 if "--building-test" in OS.get_cmdline_user_args():
  var building=preload("res://building_test.gd").new(); building.game=self; add_child(building); building.call_deferred("run")
  return
 if "--combat-test" in OS.get_cmdline_user_args():
  var combat=preload("res://combat_test.gd").new(); combat.game=self; add_child(combat); combat.call_deferred("run")
  return
 if "--journey-test" in OS.get_cmdline_user_args():
  var journey=preload("res://journey_test.gd").new(); journey.game=self; add_child(journey); journey.call_deferred("run")
  return
 if "--journey-read" in OS.get_cmdline_user_args():
  load_game()
  var valid=playing and inv.get("石斧",0)==1 and equipped=="石斧" and structures.size()==1 and structures[0].kind=="篝火" and structures[0].fuel>0
  valid=valid and milestones.get("gather",false) and milestones.get("axe",false) and milestones.get("fire",false)
  if valid: print("JOURNEY_RESTART_OK actual_journey_save"); get_tree().quit()
  else: push_error("JOURNEY_RESTART_FAILED"); get_tree().quit(1)
  return
 if "--settings-write" in OS.get_cmdline_user_args():
  volume=0.27; sensitivity=0.006; fov=83; invert_y=true; shadows_enabled=false; selected_resolution=1; saved_fullscreen=false
  save_settings(); print("SETTINGS_WRITE_OK"); get_tree().quit(); return
 if "--settings-read" in OS.get_cmdline_user_args():
  var valid=is_equal_approx(volume,0.27) and is_equal_approx(sensitivity,0.006) and fov==83 and invert_y and not shadows_enabled and selected_resolution==1 and not saved_fullscreen
  valid=valid and not sun.shadow_enabled and DisplayServer.window_get_size()==RESOLUTIONS[1]
  if valid: print("SETTINGS_READ_OK"); get_tree().quit()
  else: push_error("SETTINGS_READ_FAILED"); get_tree().quit(1)
  return
 if "--save-write" in OS.get_cmdline_user_args(): persistence_fixture(); return
 if "--save-read" in OS.get_cmdline_user_args(): persistence_verify(); return
 if "--save-unreadable" in OS.get_cmdline_user_args():
  load_game()
  if playing: push_error("CORRUPT_SAVE_STARTED_GAME"); get_tree().quit(1)
  else: print("PERSIST_UNREADABLE_OK menu_preserved"); get_tree().quit()
  return
 if smoke:
  start_new()
  test_rules()
  test_signal_visuals()
  call_deferred("test_extended_rules")
  call_deferred("test_v03_rules")
  call_deferred("test_v04_rules")
  call_deferred("test_v06_rules")
  call_deferred("test_v08_rules")
  test_audio()
  test_materials()
 if gallery: start_new()
 if coast_gallery: start_new()
 if "--settings-preview" in OS.get_cmdline_user_args(): settings()
 if bag_preview:
  start_new()
  inv={"木材":27,"石头":12,"野果":8,"净水":3,"石斧":1,"布料":4,"金属":5}
  use_item("石斧")
  inventory()
 if map_preview:
  start_new()
  for poi in POIS: discovered.append(poi[0])
  map_markers=[[-25,48],[60,-74]]
  map_view()
 if "--ui-test" in OS.get_cmdline_user_args():
  start_new(); inv={"木材":27,"石头":12,"野果":8,"净水":3,"石斧":1}
  inventory()

func height(x: float,z: float) -> float:
 var base=4.0 + sin(x*0.025)*1.8 + cos(z*0.028)*1.3 + sin((x+z)*0.058)*0.6 + max(0.0,-z-75.0)*0.085 - max(0.0,-x-90.0)*0.24
 var marsh=clamp(1.0-Vector2(x+48,z+80).length()/33.0,0,1)
 base=lerp(base,0.12+sin(x*0.3)*cos(z*0.25)*0.18,smoothstep(0.0,0.65,marsh))
 if x< -111 and x> -173 and abs(z+100)<6: base=max(base,-0.25+cos(x*0.15)*0.06)
 var island=Vector2(x+174,z+100).length()
 if island<19: base=max(base,3.5*(1-island/19))
 return base

func tide_level(hour: float) -> float:
 return sin(hour/12*TAU)*0.65

func in_marsh(p: Vector3) -> bool:
 return Vector2(p.x+48,p.z+80).length()<30

func ground(p: Vector2) -> Vector3:
 return Vector3(p.x,height(p.x,p.y),p.y)

func material(color: Color,metal = 0.0) -> StandardMaterial3D:
 if materials.has(color): return materials[color]
 var hex=color.to_html(false)
 var resource=""
 if hex in ["78634b","766048","655a4a","796047","686447","756044","68604e"]: resource="wood_planks"
 elif hex in ["875c45","3d4847","737566","92958b","414f50"]: resource="rusty_metal_02"
 elif hex in ["7c8581","6c7471"]: resource="rock_face_03"
 elif hex in ["929488","c4bba1","656960"]: resource="concrete_wall_004"
 if resource!="":
  var pbr=material_library.pbr(resource,color,resource=="rusty_metal_02")
  materials[color]=pbr; return pbr
 var m = StandardMaterial3D.new()
 m.albedo_color = color
 m.roughness = 0.85
 m.metallic = metal
 var noise = FastNoiseLite.new()
 noise.frequency = 0.075
 var texture = NoiseTexture2D.new()
 texture.width=128; texture.height=128; texture.noise=noise
 var ramp = Gradient.new()
 ramp.set_color(0,Color(0.85,0.85,0.85))
 ramp.set_color(1,Color(1,1,1))
 texture.color_ramp=ramp
 m.albedo_texture=texture
 m.uv1_triplanar=true
 m.uv1_world_triplanar=true
 m.uv1_scale=Vector3.ONE*0.16
 materials[color]=m
 return m

func mesh(parent: Node3D, shape: Mesh, pos: Vector3, color: Color) -> MeshInstance3D:
 var m = MeshInstance3D.new()
 m.mesh = shape
 m.position = pos
 m.material_override = material(color)
 parent.add_child(m)
 return m

func box(parent: Node3D,pos: Vector3,size: Vector3,color: Color,solid = false) -> MeshInstance3D:
 var s = BoxMesh.new()
 s.size = size
 var m = mesh(parent,s,pos,color)
 if solid: m.create_trimesh_collision()
 return m

func cylinder(parent: Node3D,pos: Vector3,r: float,h: float,color: Color,top = -1.0) -> MeshInstance3D:
 var s = CylinderMesh.new()
 s.bottom_radius = r
 s.top_radius = r if top < 0 else top
 s.height = h
 s.radial_segments = 10
 return mesh(parent,s,pos,color)

func sphere(parent: Node3D,pos: Vector3,size: Vector3,color: Color) -> MeshInstance3D:
 var s = SphereMesh.new()
 s.radial_segments = 12
 s.rings = 6
 var m = mesh(parent,s,pos,color)
 m.scale = size
 return m

func make_world():
 var w = WorldEnvironment.new()
 environment = Environment.new()
 w.environment = environment
 environment.background_mode = Environment.BG_SKY
 var sky = Sky.new()
 var sky_mat = ProceduralSkyMaterial.new()
 sky_material=sky_mat
 sky_mat.sky_top_color = Color("304b5b")
 sky_mat.sky_horizon_color = Color("a0b5b7")
 sky_mat.ground_horizon_color = Color("9ba7a4")
 sky.sky_material = sky_mat
 environment.sky = sky
 environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
 environment.ambient_light_color = Color("91b7c1")
 environment.ambient_light_energy = 0.65
 environment.fog_enabled = true
 environment.fog_light_color = Color("91a9ad")
 environment.fog_density = 0.0035
 environment.tonemap_mode = Environment.TONE_MAPPER_ACES
 add_child(w)
 sun = DirectionalLight3D.new()
 sun.rotation_degrees = Vector3(-35,-35,0)
 sun.light_color = Color("eee2cd")
 sun.shadow_enabled = shadows_enabled
 sun.directional_shadow_max_distance = 130
 add_child(sun)
 var surface = SurfaceTool.new()
 surface.begin(Mesh.PRIMITIVE_TRIANGLES)
 for x in range(-210,210,5):
  for z in range(-210,210,5):
   for off in [Vector2(0,0),Vector2(5,0),Vector2(0,5),Vector2(5,0),Vector2(5,5),Vector2(0,5)]:
    var p = Vector2(x,z)+off
    var c = Color("68705a") if p.x > -45 else Color("a79977")
    if p.x>60: c = Color("646b62")
    if p.y < -90: c = Color("6d7776")
    surface.set_color(c.lightened(sin(p.x*0.19)*sin(p.y*0.16)*0.035))
    surface.add_vertex(ground(p))
 surface.generate_normals()
 var terrain = MeshInstance3D.new()
 terrain.mesh = surface.commit()
 terrain_material=material_library.ground_material()
 terrain.material_override = terrain_material
 add_child(terrain)
 terrain.create_trimesh_collision()
 terrain_body=terrain.get_child(0).get_rid()
 var plane = PlaneMesh.new()
 plane.size = Vector2(1500,1500)
 plane.subdivide_width=160; plane.subdivide_depth=160
 sea = mesh(self,plane,Vector3(-510,0,0),Color("426d78"))
 var water = ShaderMaterial.new()
 var shader = Shader.new()
 shader.code = "shader_type spatial; uniform vec4 water_color:source_color=vec4(0.14,0.32,0.38,1.0); varying float wave; void vertex(){wave=sin(VERTEX.x*0.14+TIME)*0.16+sin(VERTEX.z*0.21+TIME*1.3)*0.12;VERTEX.y+=wave;} void fragment(){ALBEDO=water_color.rgb+vec3(sin(UV.x*1400.0+TIME+sin(UV.y*600.0))*0.025);ROUGHNESS=0.65;METALLIC=0.0;SPECULAR=0.18;}"
 water.shader = shader
 sea.material_override = water
 foliage_material=EnvironmentArt.foliage_material()
 for i in range(4): pine_meshes.append(EnvironmentArt.pine(2049+i))
 for i in range(270):
  var p = Vector2(rng.randf_range(-65,170),rng.randf_range(-170,170))
  if p.x > -25 and not near_poi(p,12) and not in_marsh(ground(p)): tree(ground(p),rng.randf_range(0.7,1.6),i)
 for i in range(130):
  var p = Vector2(rng.randf_range(-100,150),rng.randf_range(-160,140))
  var n = Node3D.new()
  n.position = ground(p)
  add_child(n)
  sphere(n,Vector3(0,0.35,0),Vector3(1.4,0.8,1),Color("7c8581"))
  register(n,"石头","采集",{"石头":2},"rock"+str(i))
 for i in range(95):
  var p = Vector2(rng.randf_range(-65,130),rng.randf_range(-120,120))
  var n = Node3D.new()
  n.position = ground(p)
  add_child(n)
  sphere(n,Vector3(0,0.45,0),Vector3(1.1,0.8,1.1),Color("465b3c"))
  for j in range(4): sphere(n,Vector3(rng.randf_range(-0.4,0.4),0.8,rng.randf_range(-0.4,0.4)),Vector3(0.16,0.16,0.16),Color("a45b46"))
  register(n,"野果灌木","采集",{"野果":3,"纤维":2},"bush"+str(i))
 for poi in POIS: make_poi(poi)
 make_details()
 make_wetland()
 for i in range(14): make_enemy(Vector2(rng.randf_range(-20,130),rng.randf_range(-125,100)),i%2)
 # Nearby wreck salvage makes initial progression independent of random spawns.
 for i in range(6): loot(ground(Vector2(-62+i*2,58)),"漂流物资",{"木材":3,"石头":2,"纤维":2},"start"+str(i))

func make_details():
 # Small ground-cover clusters break the terrain silhouette without collisions.
 var grass_mesh = EnvironmentArt.grass()
 grass_mesh.surface_set_material(0,foliage_material)
 var instances = MultiMesh.new()
 instances.transform_format=MultiMesh.TRANSFORM_3D
 instances.mesh=grass_mesh
 instances.instance_count=3600
 for i in range(instances.instance_count):
  var p = Vector2(rng.randf_range(-87,170),rng.randf_range(-170,150))
  var scale_value = rng.randf_range(0.6,1.6)
  var basis = Basis(Vector3.UP,rng.randf()*TAU).scaled(Vector3.ONE*scale_value)
  instances.set_instance_transform(i,Transform3D(basis,ground(p)))
 var field = MultiMeshInstance3D.new()
 field.multimesh=instances
 add_child(field)
 for poi in POIS:
  var origin = ground(poi[1])
  if poi[2] in ["factory","warehouse","lab","village","pump"]:
   for j in range(4):
    var x = -3.6+j*2.4
    var glass = box(self,origin+Vector3(x,3.1,-4.78),Vector3(1.3,1.4,0.08),Color("3f5c60"))
    box(self,glass.position+Vector3(0,0,0.08),Vector3(0.07,1.5,0.1),Color("afaa8c"))
    box(self,glass.position+Vector3(0,0,0.09),Vector3(1.4,0.07,0.1),Color("afaa8c"))
   for j in range(3):
    cylinder(self,origin+Vector3(4+j,0.65,3),0.4,1.3,Color("737566"))
   for j in range(7):
    var p = origin+Vector3(rng.randf_range(-10,10),0,rng.randf_range(-7,8))
    p.y=height(p.x,p.z)+0.1
    box(self,p,Vector3(0.6,0.15,0.9),Color("9a9176")).rotation.y=rng.randf()*TAU
 # Rain particles remain local to the player and fade with weather transitions.
 rain=CPUParticles3D.new()
 rain.amount=700
 rain.lifetime=1.1
 rain.emission_shape=CPUParticles3D.EMISSION_SHAPE_BOX
 rain.emission_box_extents=Vector3(12,1,12)
 rain.direction=Vector3(0,-1,0)
 rain.spread=8
 rain.initial_velocity_min=16; rain.initial_velocity_max=22
 rain.gravity=Vector3(2,-9,0)
 var streak = BoxMesh.new()
 streak.size=Vector3(0.018,0.55,0.018)
 streak.material=material(Color("adc6cb"))
 rain.mesh=streak
 rain.emitting=false
 add_child(rain)

func make_wetland():
 var marsh_rng=RandomNumberGenerator.new(); marsh_rng.seed=721
 var reeds=MultiMesh.new(); reeds.transform_format=MultiMesh.TRANSFORM_3D
 reeds.mesh=EnvironmentArt.grass(); reeds.mesh.surface_set_material(0,foliage_material)
 reeds.instance_count=850
 for i in range(850):
  var angle=marsh_rng.randf()*TAU; var radius=sqrt(marsh_rng.randf())*29
  var p=Vector2(-48,-80)+Vector2(cos(angle),sin(angle))*radius
  reeds.set_instance_transform(i,Transform3D(Basis(Vector3.UP,angle).scaled(Vector3(1.2,marsh_rng.randf_range(1.5,3.0),1.2)),ground(p)))
 var field=MultiMeshInstance3D.new(); field.multimesh=reeds; add_child(field)
 var start=Vector3(-63,1.35,-60); var finish=Vector3(-28,1.35,-93)
 for i in range(34):
  var p=start.lerp(finish,float(i)/33)
  var plank=box(self,p,Vector3(2.8,0.16,1.3),Color("686447"),true)
  plank.rotation.y=atan2(start.x-finish.x,start.z-finish.z)
  if i%4==0:
   for offset in [-1,1]: cylinder(self,p+Vector3(offset*1.25,-0.6,0),0.09,1.5,Color("494c3c"))
 for i in range(12):
  var p=ground(Vector2(marsh_rng.randf_range(-70,-30),marsh_rng.randf_range(-99,-62)))
  var plant=Node3D.new(); plant.position=p; add_child(plant)
  for j in range(4): cylinder(plant,Vector3(sin(j)*0.25,0.7,cos(j)*0.25),0.045,1.4,Color("728260"))
  register(plant,"湿地芦苇","割取",{"纤维":4},"marsh-reed"+str(i))
 make_enemy(Vector2(-46,-67),1); make_enemy(Vector2(-34,-88),1)
 # A real terrain shelf is exposed at low tide, not an invisible time gate.
 for x in range(-116,-172,-8):
  cylinder(self,Vector3(x,0.6,-104),0.08,2.2,Color("9d8d6c"))
  box(self,Vector3(x,1.25,-104),Vector3(0.25,0.15,0.25),Color("b76d4d"))
 loot(ground(Vector2(-174,-100)),"避潮礁 · 密封货箱",{"零件":5,"电池":1,"罐头":3},"tidal-cargo")
 var sign=Node3D.new(); sign.position=ground(Vector2(-108,-96)); add_child(sign)
 box(sign,Vector3(0,1.2,0),Vector3(1.4,0.8,0.12),Color("b19865"))
 cylinder(sign,Vector3(0,0.6,0),0.07,1.2,Color("756044"))
 register(sign,"浅滩潮汐警示","阅读",{},"tide-sign","sign")

func make_map_texture() -> ImageTexture:
 var image=Image.create(210,210,false,Image.FORMAT_RGB8)
 for x in range(210):
  for z in range(210):
   var wx=x*2-210; var wz=z*2-210
   var h=height(wx,wz)
   var color=Color("3c5948")
   if wx>60: color=Color("736a59")
   if wz< -100: color=Color("777e79")
   if wx< -85: color=Color("b3a37e")
   if in_marsh(Vector3(wx,h,wz)): color=Color("5c7564")
   if h<0.65: color=Color("667d78")
   if h< -0.5: color=Color("304e5b")
   var slope=height(wx-1,wz-1)-height(wx+1,wz+1)
   image.set_pixel(x,z,color.lightened(clamp(slope*0.045,-0.12,0.12)))
 return ImageTexture.create_from_image(image)

func near_poi(p: Vector2,r: float) -> bool:
 for poi in POIS:
  if p.distance_to(poi[1])<r: return true
 return false

func tree(pos: Vector3,s: float,i: int):
 var n = Node3D.new()
 n.position = pos
 n.scale = Vector3.ONE*s
 add_child(n)
 cylinder(n,Vector3(0,3,0),0.28,6,Color("594e40"),0.15).create_trimesh_collision()
 var foliage=MeshInstance3D.new(); foliage.mesh=pine_meshes[i%4]; foliage.material_override=foliage_material
 foliage.rotation.y=i*2.4; n.add_child(foliage)
 register(n,"灰松","砍伐",{"木材":6,"纤维":1},"tree"+str(i))

func register(n: Node3D,title: String,action: String,gives: Dictionary,id: String,kind = "resource"):
 entities.append({"node":n,"title":title,"action":action,"gives":gives,"id":id,"kind":kind})

func loot(pos: Vector3,title: String,gives: Dictionary,id: String):
 var n = Node3D.new()
 n.position = pos
 add_child(n)
 box(n,Vector3(0,0.4,0),Vector3(1.1,0.8,0.8),Color("766048"))
 for x in [-0.4,0.4]: box(n,Vector3(x,0.43,0),Vector3(0.08,0.85,0.86),Color("3d4847"))
 register(n,title,"搜索",gives,id)
 if id.begins_with("death-") or id.begins_with("enemy"):
  dropped_loot.append({"pos":[pos.x,pos.y,pos.z],"title":title,"gives":gives,"id":id})

func make_poi(poi: Array):
 var n = Node3D.new()
 n.position = ground(poi[1])
 add_child(n)
 var kind = poi[2]
 var rust = Color("875c45")
 if kind == "lighthouse":
  cylinder(n,Vector3(0,9,0),2.6,18,Color("c4bba1"),1.8).create_trimesh_collision()
  cylinder(n,Vector3(0,18,0),2.5,0.5,rust)
  cylinder(n,Vector3(0,20,0),2.7,2,rust,0)
  var light = OmniLight3D.new()
  light.position.y = 19
  light.light_color = Color("ffd49a")
  light.light_energy = 5
  light.omni_range = 35
  n.add_child(light)
  signal_lights["lighthouse"]=light
 elif kind == "tower":
  for x in [-2,2]: cylinder(n,Vector3(x,12,0),0.18,24,rust).create_trimesh_collision()
  for y in range(2,25,3): box(n,Vector3(0,y,0),Vector3(4.4,0.14,0.3),rust)
  sphere(n,Vector3(0,22,0),Vector3(3,3,0.5),Color("b6bbb0"))
 elif kind == "wreck" or kind == "port":
  for j in range(8):
   box(n,Vector3(j*1.5-5,0.5,sin(j)*0.3),Vector3(1.25,0.3,4),Color("655a4a"),true).rotation.z = j*0.035
  box(n,Vector3(0,2,-2),Vector3(10,2.4,0.3),rust,true)
 elif kind == "camp":
  for side in [-1,1]:
   var roof = box(n,Vector3(side*1.2,1.2,0),Vector3(3.4,0.15,4),Color("b1905c"),true)
   roof.rotation.z = -side*0.7
   roof.set_meta("shelter",true)
  make_structure("篝火",n.position+Vector3(5,0,0),0,false)
 else:
  var wide = 9.0 if kind in ["factory","warehouse","lab"] else 5.0
  box(n,Vector3(0,0.1,0),Vector3(wide*2,0.3,10),Color("656960"),true)
  box(n,Vector3(0,2.5,-5),Vector3(wide*2,5,0.3),rust,true)
  for x in [-wide,wide]: box(n,Vector3(x,2.5,0),Vector3(0.3,5,10),rust,true)
  for x in [-wide*0.65,wide*0.65]: box(n,Vector3(x,2.5,5),Vector3(wide*0.65,5,0.3),Color("929488"),true)
  for side in [-1,1]:
   var roof = box(n,Vector3(side*wide*0.5,5.6,0),Vector3(wide+0.5,0.25,11),Color("414f50"),true)
   roof.rotation.z = side*-0.15
   roof.set_meta("shelter",true)
  box(n,Vector3(-2,0.8,-3),Vector3(3,1.5,1.2),Color("68604e"),true)
  if kind == "factory":
   for x in [12,17]: cylinder(n,Vector3(x,4,-2),2,8,Color("92958b")).create_trimesh_collision()
 var label = Label3D.new()
 label.text = poi[0]
 label.font_size = 40
 label.pixel_size = 0.012
 label.position = Vector3(0,6,4)
 label.modulate = Color("f2deaa")
 label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
 n.add_child(label)
 loot(n.position+Vector3(2,0,7),"封存补给 · "+poi[0],{"金属":4,"布料":3,"零件":2,"罐头":1,"净水":1},"poi-"+kind)
 if kind in ["lighthouse","lab","tower"]:
  var terminal = Node3D.new()
  terminal.position = n.position+Vector3(-3,0,7)
  add_child(terminal)
  box(terminal,Vector3(0,0.8,0),Vector3(0.8,1.6,0.6),Color("3e6668"),true)
  register(terminal,poi[0]+"控制台","修复",{},kind,"repair")
  var screen=box(terminal,Vector3(0,1.1,0.32),Vector3(0.55,0.3,0.04),Color("447170"))
  var status=StandardMaterial3D.new(); status.emission_enabled=true; screen.material_override=status
  signal_screens[kind]=status
  if kind=="tower":
   var light=OmniLight3D.new(); light.position=n.position+Vector3(0,22,0); light.omni_range=20
   add_child(light); signal_lights["tower"]=light
 if kind == "pump":
  register(n,"淡水泵","取水",{},"water","water")
 var notes={"camp":["林务员日志","犬群会追逐奔跑声。蹲低，沿林缘绕过去。\n营地的主人留下了一束箭，盼有人能走到灯塔。"],"pump":["泵站维修记录","灰潮污染了海水，地下水仍能通过滤芯处理。\n雨季补给会恢复；不要让收集器空转。"],"port":["最后一班撤离","2049年10月17日。研究站要求关闭海岸信号。\n不是因为风暴，而是为了让外界听不见实验。\n伊莱拒绝撤离，他说灯塔必须为归航的人亮着。"]}
 if notes.has(kind):
  var page=Node3D.new(); page.position=n.position+Vector3(-2,0,7); add_child(page)
  box(page,Vector3(0,0.6,0),Vector3(0.6,1.2,0.35),Color("a89d76"))
  register(page,notes[kind][0],"阅读",{},"note-"+kind,"note")
  entities.back()["text"]=notes[kind][1]
 if kind=="warehouse": loot(n.position+Vector3(-4,0.2,-1),"仓库急救补给",{"急救箱":1},"medkit-cache")
 if kind=="camp":
  var radio=Node3D.new(); radio.position=n.position+Vector3(3,0,4); add_child(radio)
  box(radio,Vector3(0,0.65,0),Vector3(1.1,0.7,0.5),Color("3e6668"),true)
  cylinder(radio,Vector3(0.35,1.5,0),0.018,1.5,Color("92958b"))
  register(radio,"营地电台","维修",{},"camp-radio","side-radio")
 if kind == "village":
  var npc = actor(n,Vector3(4,0,7),Color("a78c5d"))
  register(npc,"守岸人 伊莱","交谈",{},"npc","npc")

func actor(parent: Node3D,pos: Vector3,color: Color) -> Node3D:
 var n = Node3D.new()
 parent.add_child(n)
 n.position = pos
 sphere(n,Vector3(0,1.75,0),Vector3(0.4,0.5,0.4),Color("b5a38b"))
 sphere(n,Vector3(0,1.15,0),Vector3(0.73,1.0,0.5),color)
 cylinder(n,Vector3(0,2.01,0),0.25,0.14,Color("595c4b"))
 box(n,Vector3(0,1.53,-0.18),Vector3(0.26,0.12,0.12),Color("4a5a5b"))
 box(n,Vector3(0,1.1,0.3),Vector3(0.5,0.6,0.24),Color("615d46"))
 for side in [-1,1]:
  var leg=Node3D.new(); leg.position=Vector3(side*0.18,0.85,0); n.add_child(leg)
  var leg_mesh=CapsuleMesh.new(); leg_mesh.radius=0.12; leg_mesh.height=0.72
  mesh(leg,leg_mesh,Vector3(0,-0.35,0),Color("35494e"))
  sphere(leg,Vector3(0,-0.72,-0.06),Vector3(0.29,0.18,0.45),Color("323a36"))
  var arm=Node3D.new(); arm.position=Vector3(side*0.41,1.45,0); n.add_child(arm)
  var sleeve=CapsuleMesh.new(); sleeve.radius=0.115; sleeve.height=0.56
  mesh(arm,sleeve,Vector3(0,-0.25,0),color)
  sphere(arm,Vector3(0,-0.57,0),Vector3(0.2,0.23,0.22),Color("554f40"))
  if parent == player: limbs.append(leg); limbs.append(arm)
 return n

func make_player():
 player = CharacterBody3D.new()
 add_child(player)
 var collider = CollisionShape3D.new()
 var shape = CapsuleShape3D.new()
 shape.radius = 0.35
 shape.height = 1.85
 collider.shape = shape
 collider.position.y = 0.95
 player.add_child(collider)
 body = actor(player,Vector3.ZERO,Color("bd9869"))
 camera = Camera3D.new()
 camera.far = 650
 add_child(camera)
 player.position = ground(Vector2(-65,65))+Vector3.UP

func make_enemy(p: Vector2,kind: int):
 var n = CharacterBody3D.new()
 n.position = ground(p)+Vector3.UP
 add_child(n)
 var c = CollisionShape3D.new()
 var s = SphereShape3D.new()
 s.radius = 0.65
 c.shape = s
 c.position.y = 0.65
 n.add_child(c)
 var color = Color("7f8981") if kind == 0 else Color("9a6247")
 sphere(n,Vector3(0,0.8,0),Vector3(1.4,0.8,0.8) if kind == 0 else Vector3(1.8,0.65,1.3),color)
 sphere(n,Vector3(0,1,-0.65),Vector3(0.65,0.6,0.7),color)
 for side in [-1,1]:
  for z in [-0.5,0.5]:
   var leg = box(n,Vector3(side*0.65,0.35,z),Vector3(0.18,0.65,0.2),color)
   leg.rotation.z = side*0.4
   leg.set_meta("phase",side+z)
 if kind==0:
  for side in [-1,1]: cylinder(n,Vector3(side*0.22,1.4,-0.6),0.16,0.45,color,0)
  var tail=cylinder(n,Vector3(0,0.9,0.9),0.12,0.9,color,0.04); tail.rotation.x=0.8
 else:
  for side in [-1,1]:
   for z in [-0.2,0.2]:
    var leg=box(n,Vector3(side*1.05,0.3,z),Vector3(0.85,0.13,0.14),color); leg.rotation.z=side*0.3; leg.set_meta("phase",side+z)
   sphere(n,Vector3(side*0.9,0.8,-0.9),Vector3(0.6,0.4,0.7),color)
 var parts=[]
 for part in n.get_children():
  if part is MeshInstance3D: parts.append({"node":part,"position":part.position,"rotation":part.rotation})
 var indicator=Label3D.new(); indicator.name="Indicator"; indicator.position=Vector3(0,1.9,0)
 indicator.billboard=BaseMaterial3D.BILLBOARD_ENABLED; indicator.font_size=30; indicator.pixel_size=0.008
 indicator.modulate=Color("e9c4a6"); n.add_child(indicator)
 enemies.append({"node":n,"home":n.position,"hp":60.0 if kind == 0 else 100.0,"kind":kind,"state":"Patrol","timer":0.0,"cooldown":0.0,"parts":parts})

func make_ui():
 var canvas = CanvasLayer.new()
 add_child(canvas)
 var theme = Theme.new()
 theme.default_font_size = 18
 var root = Control.new()
 root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 root.mouse_filter = Control.MOUSE_FILTER_IGNORE
 root.theme = theme
 canvas.add_child(root)
 hud = Label.new()
 hud.position = Vector2(28,20)
 root.add_child(hud)
 prompt = Label.new()
 prompt.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
 prompt.position += Vector2(-330,-110)
 prompt.size = Vector2(660,70)
 prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 root.add_child(prompt)
 notices = Label.new()
 notices.position = Vector2(28,302)
 root.add_child(notices)
 damage_flash=ColorRect.new()
 damage_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 damage_flash.mouse_filter=Control.MOUSE_FILTER_IGNORE
 damage_flash.color=Color(0.8,0.16,0.1,0)
 root.add_child(damage_flash)
 quick_hud=HBoxContainer.new()
 quick_hud.position=Vector2(220,656)
 quick_hud.add_theme_constant_override("separation",4)
 root.add_child(quick_hud)
 panel = PanelContainer.new()
 panel.position = Vector2(310,55)
 panel.size = Vector2(660,600)
 var style = StyleBoxFlat.new()
 style.bg_color = Color(0.045,0.09,0.10,0.97)
 style.border_color = Color("a3946c")
 style.set_border_width_all(1)
 style.content_margin_left = 26
 style.content_margin_right = 26
 style.content_margin_top = 20
 style.content_margin_bottom = 20
 panel.add_theme_stylebox_override("panel",style)
 root.add_child(panel)
 var scroll = ScrollContainer.new()
 scroll.custom_minimum_size = Vector2(600,550)
 panel.add_child(scroll)
 content = VBoxContainer.new()
 content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 content.add_theme_constant_override("separation",9)
 scroll.add_child(content)

func clear_panel(title: String):
 for child in content.get_children():
  content.remove_child(child)
  child.queue_free()
 panel.show()
 panel_open = true
 Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
 text_line(title,28)

func text_line(t: String,size = 18):
 var label = Label.new()
 label.text = t
 label.add_theme_font_size_override("font_size",size)
 if size<26:
  label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
  label.custom_minimum_size.x=560
  label.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 content.add_child(label)
 return label

func button(t: String,callback: Callable,enabled = true):
 var b = Button.new()
 b.text = t
 b.clip_text=true; b.tooltip_text=t
 b.custom_minimum_size.y = 36
 b.disabled = not enabled
 b.pressed.connect(callback)
 content.add_child(b)

func close_panel():
 if settings_active: save_settings(); settings_active=false
 panel.hide()
 panel_open = false
 Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
 mouse_look_guard=0.12

func menu():
 if settings_active: save_settings(); settings_active=false
 clear_panel("雾 线 之 外")
 text_line("BEYOND THE MISTLINE",20)
 text_line("2049 · 北境沉降带\n海潮带走了一切，灯塔仍在等待回应。")
 button("开始新的旅程",start_new)
 button("继续旅程",load_game,FileAccess.file_exists(SAVE) or FileAccess.file_exists(SAVE+".bak"))
 if playing:
  button("返回游戏",close_panel)
  button("保存进度",func(): save_game(); toast("进度已保存"))
 button("设置",settings)
 button("操作与素材鸣谢",credits)
 button("退出",func():
  if playing: save_game()
  get_tree().quit())

func start_new():
 for lure in get_tree().get_nodes_in_group("stone_lures"): lure.queue_free()
 inv.clear()
 survival=preload("res://survival_state.gd").new()
 skill_xp={"生存":0,"采集":0,"制作":0,"战斗":0,"探索":0}; craft_job={}
 milestones={}
 quests=preload("res://quest_log.gd").new(); pump_stock=0; pump_cooldown=0
 death_time=0; hit_reaction=0; body.rotation.z=0; noise_time=0
 bag=Bag.new(); equipped=""; durability.clear(); selected_slot=-1
 quickbar=["野果","净水","绷带","罐头","烤肉","石斧","木矛","弓"]
 update_held_tool()
 removed.clear()
 repairs.clear()
 discovered.clear()
 dropped_loot.clear()
 explored.clear()
 story_read.clear(); map_markers.clear(); navigation.invalidate()
 for e in entities:
  if is_instance_valid(e.node):
   e.node.show()
   set_collisions(e.node,false)
   if e.id.begins_with("death-") or e.id.begins_with("enemy"): e.node.queue_free()
 for s in structures:
  if is_instance_valid(s.node): s.node.queue_free()
 structures.clear()
 entities=entities.filter(func(e): return is_instance_valid(e.node) and not e.node.is_queued_for_deletion())
 for e in enemies:
  e.hp = 60.0 if e.kind == 0 else 100.0
  e.node.position = e.home
  e.node.show()
  e.node.rotation.z=0
  set_collisions(e.node,false)
  e.state="Patrol"; e.timer=0
  e["memory"]=0.0; e["last_known"]=e.home; e["stimulus"]=""
  e.erase("path"); e.erase("windup")
 health = 100; hunger = 100; thirst = 100; stamina = 100
 temperature = 37; clock = 8; weather = 0
 player.position = ground(Vector2(-65,72))+Vector3.UP
 playing = true
 close_panel()
 toast("海岸幸存者：搜索漂流物资，制作石斧与篝火。\n前往渔村寻找守岸人；Tab 制作，B 建造，J 查看线索。")

func settings():
 clear_panel("设置")
 settings_active=true
 for data in [["总音量",0.0,1.0,volume],["鼠标灵敏度",0.001,0.008,sensitivity],["视野",55.0,95.0,fov]]:
  text_line(data[0])
  var slider = HSlider.new()
  slider.min_value = data[1]; slider.max_value = data[2]; slider.step = (data[2]-data[1])/100; slider.value = data[3]
  content.add_child(slider)
  var key = data[0]
  slider.value_changed.connect(func(v):
   if key == "总音量": volume = v
   elif key == "鼠标灵敏度": sensitivity = v
   else: fov = v)
 text_line("窗口分辨率")
 var resolutions=OptionButton.new()
 for value in RESOLUTIONS: resolutions.add_item("%d × %d"%[value.x,value.y])
 resolutions.selected=selected_resolution; content.add_child(resolutions)
 resolutions.item_selected.connect(func(index): selected_resolution=index; DisplayServer.window_set_size(RESOLUTIONS[index]))
 var full=CheckButton.new(); full.text="全屏"; full.button_pressed=saved_fullscreen; content.add_child(full)
 full.toggled.connect(func(value): saved_fullscreen=value; DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if value else DisplayServer.WINDOW_MODE_WINDOWED))
 var invert=CheckButton.new(); invert.text="反转鼠标 Y 轴"; invert.button_pressed=invert_y; content.add_child(invert)
 invert.toggled.connect(func(value): invert_y=value)
 var shadows=CheckButton.new(); shadows.text="动态阴影（关闭可减少图形负载）"; shadows.button_pressed=shadows_enabled; content.add_child(shadows)
 shadows.toggled.connect(func(value): shadows_enabled=value; sun.shadow_enabled=value)
 button("保存设置并返回",func(): save_settings(); menu())

func load_settings():
 var config=ConfigFile.new()
 if config.load("user://settings.cfg")!=OK: return
 volume=clamp(float(config.get_value("audio","volume",0.5)),0,1)
 sensitivity=clamp(float(config.get_value("input","sensitivity",0.003)),0.001,0.008)
 fov=clamp(float(config.get_value("video","fov",72)),55,95)
 invert_y=bool(config.get_value("input","invert_y",false))
 shadows_enabled=bool(config.get_value("video","shadows",true))
 selected_resolution=clampi(int(config.get_value("video","resolution",0)),0,2)
 saved_fullscreen=bool(config.get_value("video","fullscreen",false))
 DisplayServer.window_set_size(RESOLUTIONS[selected_resolution])
 DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if saved_fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)

func save_settings():
 var config=ConfigFile.new()
 config.set_value("audio","volume",volume); config.set_value("input","sensitivity",sensitivity)
 config.set_value("input","invert_y",invert_y); config.set_value("video","fov",fov)
 config.set_value("video","shadows",shadows_enabled); config.set_value("video","resolution",selected_resolution)
 config.set_value("video","fullscreen",saved_fullscreen)
 if config.save("user://settings.cfg")!=OK: toast("设置保存失败")

func credits():
 clear_panel("北境生存手册")
 text_line("G 投掷石头：消耗1块石头，落点声响可引开尚未发现你的敌人。\n遮挡视线后蹲伏离开；冲刺声仍可能暴露你的位置。")
 text_line("WASD 移动 · Shift 冲刺 · Ctrl 蹲伏\nSpace 跳跃 · 鼠标转向 · E 交互 / 采集 / 开关门\n左键 攻击 / 确认建造 · 右键 取消建造\nTab 背包制作 · B 建造 · M 地图 · J 任务\n1–8 快捷栏 · 背包中拖拽物品至快捷栏分配\n右键物品拆分，点击物品后装备、使用或丢弃\nF5 保存 · Esc 菜单\n\n地形、程序模型、UI、合成音效：本项目原创。\nGodot Engine 4.5.2：MIT License。\n材质：Poly Haven / CC0，作者见 ASSET_CREDITS。\n当前为开发版本，完整美术及最终验收尚未完成。")
 button("返回",menu)

func inventory():
 bag.sync(inv)
 clear_panel("行囊与制作")
 text_line("负重 %.1f / 30 kg · 装备：%s" % [weight(),equipped if equipped!="" else "徒手"],17)
 text_line("拖拽交换或合并 · 右键拆分 · 点击查看 / 使用\n物品可拖至下方快捷栏，数字键 1–8 使用。",15)
 var grid = GridContainer.new()
 grid.columns=6
 content.add_child(grid)
 for i in range(24):
  var slot = BagSlot.new()
  var data = bag.slots[i]
  slot.index=i; slot.item=data.get("item",""); slot.receiver=drop_slot
  slot.text="%02d\n%s"%[i+1,"—" if data.is_empty() else data.item+" ×"+str(data.count)]
  slot.custom_minimum_size=Vector2(92,52)
  var style=StyleBoxFlat.new()
  style.bg_color=Color("284044") if i==selected_slot else Color("17292d")
  style.border_color=Color("b5a47e") if not data.is_empty() else Color("365054")
  style.set_border_width_all(1); style.set_corner_radius_all(3)
  slot.add_theme_stylebox_override("normal",style)
  slot.add_theme_font_size_override("font_size",15)
  var index = i
  slot.pressed.connect(func(): selected_slot=index; inventory())
  slot.gui_input.connect(func(event):
   if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_RIGHT:
    bag.split(index); inventory())
  grid.add_child(slot)
 if selected_slot>=0 and not bag.slots[selected_slot].is_empty():
  var item = bag.slots[selected_slot].item
  text_line(item+" · 单件 %.2f kg"%ITEMS.get(item,0.2)+( " · 耐久 %d/100"%durability.get(item,100) if item in Bag.TOOLS else ""),16)
  button("装备 / 使用 "+item,func(): use_item(item); inventory(),item in Bag.TOOLS or item in ["野果","净水","绷带","罐头","烤肉","河水","生肉"])
  if item in ["河水","生肉"]: text_line("直接食用有中毒风险；请净水或烹饪。",15)
  button("丢弃所选堆叠（可在地上找回）",func():
   var s = bag.slots[selected_slot].duplicate()
   bag.slots[selected_slot]={}; inv=bag.totals()
   loot(player.position+Vector3(1,0,0),"丢下的物品",{s.item:s.count},"death-drop-"+str(Time.get_ticks_usec()))
   inventory())
 var quick = HBoxContainer.new()
 content.add_child(quick)
 for i in range(8):
  var slot = BagSlot.new()
  slot.index=i; slot.item=quickbar[i]; slot.source_kind="quick"; slot.receiver=drop_slot
  slot.text=str(i+1)+"\n"+quickbar[i]; slot.custom_minimum_size=Vector2(69,48)
  slot.add_theme_font_size_override("font_size",14); quick.add_child(slot)
 if not bag.overflow.is_empty():
  text_line("待领取输出："+str(bag.overflow),15)
  button("领取待输出物品（先腾空背包）",func():
   var pending=bag.overflow.duplicate(); bag.overflow.clear()
   for k in pending: inv[k]=inv.get(k,0)+pending[k]
   inventory())
 text_line("制作配方",22)
 if not craft_job.is_empty():
  text_line("正在制作 %s · 剩余 %.1f 秒\n工作台/烹饪制作需留在设施附近。"%[craft_job.item,craft_job.left],16)
  button("取消制作并返还预留材料",func(): cancel_craft(); inventory())
 for name in RECIPES:
  var n = name
  var cost = RECIPES[n]
  button(n+"  ·  "+cost_text(cost)+"  %.0f秒"%craft_duration(n)+("  [需要工作台]" if n in ["弓","滤芯","工具包","电池"] else ""),func(): begin_craft(n),craft_job.is_empty() and can_pay(cost) and craft_station(n))
 button("关闭",close_panel)

 if "--ui-test" in OS.get_cmdline_user_args() and qa_dir!="":
  var snapshot=FileAccess.open(qa_dir.path_join("ui-state.json"),FileAccess.WRITE)
  snapshot.store_string(JSON.stringify({"slots":bag.slots,"quickbar":quickbar,"inv":inv}))

func drop_slot(data: Dictionary,index: int,kind: String):
 if kind=="quick": quickbar[index]=data.item
 else: bag.move_stack(int(data.index),index)
 inv=bag.totals()
 inventory()

func use_item(item: String):
 if inv.get(item,0)<=0: toast("没有"+item); return
 if item in Bag.TOOLS:
  equipped="" if equipped==item else item
  if not durability.has(item): durability[item]=100
  update_held_tool()
  toast("已装备："+equipped if equipped!="" else "已收起工具")
 else: consume(item)

func wear_tool(amount: int):
 if equipped=="": return
 durability[equipped]=int(durability.get(equipped,100))-amount
 if durability[equipped]<=0:
  inv[equipped]=maxi(0,int(inv.get(equipped,0))-1)
  durability.erase(equipped); toast(equipped+"已损坏"); equipped=""; update_held_tool()

func update_held_tool():
 if is_instance_valid(held_tool): held_tool.queue_free()
 if not is_instance_valid(body) or equipped=="": return
 held_tool=Node3D.new(); limbs[3].add_child(held_tool)
 held_tool.position=Vector3(0,-0.55,-0.16)
 if equipped=="石斧":
  cylinder(held_tool,Vector3.ZERO,0.045,0.8,Color("796047"))
  box(held_tool,Vector3(0,0.35,0),Vector3(0.45,0.25,0.15),Color("8c9491"))
 elif equipped=="木矛":
  cylinder(held_tool,Vector3.ZERO,0.04,2,Color("796047"))
  cylinder(held_tool,Vector3(0,1.1,0),0.1,0.3,Color("a2a69e"),0)
 elif equipped=="弓":
  for i in range(12):
   var a=Vector3(sin(float(i)/12*PI)*0.25,-0.65+float(i)/12*1.3,0)
   var b=Vector3(sin(float(i+1)/12*PI)*0.25,-0.65+float(i+1)/12*1.3,0)
   var piece=cylinder(held_tool,(a+b)*0.5,0.03,a.distance_to(b),Color("796047"))
   piece.quaternion=Quaternion(Vector3.UP,(b-a).normalized())
  cylinder(held_tool,Vector3.ZERO,0.008,1.3,Color("c3b794"))
 else:
  cylinder(held_tool,Vector3.ZERO,0.05,0.8,Color("796047"))
  var light=OmniLight3D.new(); light.light_color=Color("ffbc76"); light.omni_range=15; light.light_energy=2; held_tool.add_child(light)

func cost_text(cost: Dictionary) -> String:
 var t = ""
 for k in cost: t += "%s %d/%d  " % [k,inv.get(k,0),cost[k]]
 return t

func can_pay(cost: Dictionary) -> bool:
 for k in cost:
  if inv.get(k,0)<cost[k]: return false
 return true

func pay(cost: Dictionary):
 for k in cost: inv[k] = inv.get(k,0)-cost[k]

func craft_station(n: String) -> bool:
 if n == "烤肉": return near_structure("篝火")
 if n in ["弓","滤芯","工具包","电池"]: return near_structure("工作台")
 return true

func craft(n: String):
 if can_pay(RECIPES[n]) and craft_station(n):
  pay(RECIPES[n])
  inv[n] = inv.get(n,0)+1
  beep(650,0.15)
  toast("制作完成："+n)

func skill_level(skill: String) -> int:
 return mini(5,int(skill_xp.get(skill,0))/100)

func gain_skill(skill: String,amount: int):
 var before=skill_level(skill)
 skill_xp[skill]=mini(599,int(skill_xp.get(skill,0))+amount)
 if skill_level(skill)>before: toast("%s提升至 %d 级"%[skill,skill_level(skill)])

func craft_duration(item: String) -> float:
 return (8.0 if item in ["工具包","电池","弓"] else 4.0)*(1.0-skill_level("制作")*0.08)

func begin_craft(item: String):
 if not craft_job.is_empty() or not can_pay(RECIPES[item]) or not craft_station(item): return
 pay(RECIPES[item]); bag.sync(inv)
 craft_job={"item":item,"left":craft_duration(item),"cost":RECIPES[item].duplicate()}
 close_panel(); toast("开始制作 "+item+"；材料已预留，Tab 可取消返还。")

func cancel_craft():
 if craft_job.is_empty(): return
 for k in craft_job.cost: inv[k]=inv.get(k,0)+craft_job.cost[k]
 craft_job={}; bag.sync(inv)

func advance_craft(dt: float):
 if craft_job.is_empty() or not craft_station(craft_job.item): return
 craft_job.left=max(0,craft_job.left-dt)
 if craft_job.left<=0:
  var item=craft_job.item; craft_job={}
  inv[item]=inv.get(item,0)+1; bag.sync(inv)
  gain_skill("制作",20); gain_skill("生存",5)
  beep(650,0.15); toast("制作完成："+item)

func weight() -> float:
 var total = 0.0
 for k in inv: total += inv[k]*ITEMS.get(k,0.2)
 return total

func building_menu():
 clear_panel("营地建造")
 text_line("选择组件后，鼠标转向定位，R 旋转。\n左键放置，右键取消。结构组件靠近地基放置。",16)
 for name in BUILDS:
  var n = name
  button(n+" · "+cost_text(BUILDS[n]),func(): build_kind=n; close_panel(),can_pay(BUILDS[n]))
 button("关闭",close_panel)

func make_structure(kind: String,pos: Vector3,angle: float,record = true) -> Node3D:
 var n = Node3D.new()
 n.position = pos
 n.rotation.y = angle
 add_child(n)
 var wood = Color("78634b")
 match kind:
  "篝火":
   for j in range(8): sphere(n,Vector3(cos(j*TAU/8)*0.7,0.2,sin(j*TAU/8)*0.7),Vector3(0.45,0.35,0.4),Color("6c7471"))
   for j in range(3):
    var log_mesh = box(n,Vector3(0,0.3,0),Vector3(1.1,0.18,0.18),wood)
    log_mesh.rotation.y = j*TAU/3
   var flame=sphere(n,Vector3(0,0.65,0),Vector3(0.4,0.9,0.4),Color("ffb34d")); flame.name="Flame"
   var light = OmniLight3D.new()
   light.position.y = 1.2; light.light_color = Color("ffab5b"); light.light_energy = 3; light.omni_range = 12
   n.add_child(light)
   light.name="FireLight"
  "地基": box(n,Vector3(0,0.3,0),Vector3(4,0.6,4),wood,true)
  "楼梯":
   for i in range(4):
    var h=(i+1)*0.15
    box(n,Vector3(0,h/2,1.05-i*0.7),Vector3(1.7,h,0.72),wood,true)
  "墙": box(n,Vector3(0,1.8,0),Vector3(4,3,0.2),wood,true)
  "门框":
   for x in [-1.45,1.45]: box(n,Vector3(x,1.8,0),Vector3(1.1,3,0.22),wood,true)
   box(n,Vector3(0,3,0),Vector3(2,0.6,0.22),wood,true)
   var hinge=Node3D.new(); hinge.name="Door"; hinge.position=Vector3(-0.9,0.6,0); n.add_child(hinge)
   box(hinge,Vector3(0.9,1.1,0),Vector3(1.75,2.2,0.15),wood,true)
   sphere(hinge,Vector3(1.55,1.1,0.14),Vector3(0.12,0.12,0.12),Color("b2a077"))
  "屋顶": box(n,Vector3(0,3.4,0),Vector3(4.2,0.2,4.2),wood,true).set_meta("shelter",true)
  "工作台":
   box(n,Vector3(0,1,0),Vector3(2,0.2,1),wood,true)
   for x in [-0.8,0.8]: box(n,Vector3(x,0.5,0),Vector3(0.2,1,0.7),wood,true)
  "储物箱": box(n,Vector3(0,0.5,0),Vector3(1.5,1,1),wood,true)
  "睡袋": box(n,Vector3(0,0.15,0),Vector3(0.9,0.3,2),Color("8b8d63"))
  "集雨器": cylinder(n,Vector3(0,0.7,0),0.8,1.4,Color("586c6d"))
 if record:
  structures.append({"kind":kind,"pos":[pos.x,pos.y,pos.z],"angle":angle,"node":n,"fuel":120.0 if kind=="篝火" else 0.0,"water":0.0})
  register(n,kind,"使用",{},"base"+str(structures.size()),"facility")
  navigation.invalidate()
 return n

func near_structure(kind: String) -> bool:
 for s in structures:
  if s.kind==kind and s.node.position.distance_to(player.position)<6 and (kind!="篝火" or s.get("fuel",0)>0): return true
 return false

func is_sheltered(position: Vector3) -> bool:
 var query=PhysicsRayQueryParameters3D.create(position+Vector3(0,1.2,0),position+Vector3(0,9,0))
 query.exclude=[player.get_rid()]
 var hit=get_world_3d().direct_space_state.intersect_ray(query)
 if hit.is_empty(): return false
 var object=hit.collider
 while object!=null and object!=self:
  if object.get_meta("shelter",false): return true
  object=object.get_parent()
 return false

func journal():
 clear_panel("寻找最后的信号")
 for id in quests.states:
  var label=["未接受","进行中","已完成"][quests.states[id]]
  text_line("支线 · %s：%s"%[quests.DEFINITIONS[id].title,label],17)
 text_line("潮汐探索 · 避潮礁货箱：%s\n港口西侧木桩标记旧石堤。阅读警示牌，低潮前往外礁。"%mark("tidal-cargo" in removed),16)
 text_line("主线 · 三处设施，最后的区域信号\n%s 旧灯塔：金属 ×4，零件 ×2\n%s 旧研究所：先恢复灯塔；工具包 ×1\n%s 山地通讯站：先取得研究数据；电池 ×1，零件 ×4\n\n支线探索\n%s 森林营地：寻找林间补给\n%s 地下水泵站：找到可靠淡水\n%s 沉没港口：探索灰潮遗迹\n\n守岸人的建议：渔村向西是灯塔，向东是仓库。\n工业区带回零件，搭建工作台制造工具包和电池。\n灯塔录音：洋流并未停止，信号来自高地。" % [mark("lighthouse" in repairs),mark("lab" in repairs),mark("tower" in repairs),mark("森林营地" in discovered),mark("地下水泵站" in discovered),mark("沉没港口" in discovered)],17)
 if "tower" in repairs: text_line("章节完成：信号已恢复。\n回答来自海雾之外：保持灯光，我们正在返航。",22)
 text_line("区域记录：%d / 3\n林务员日志：%s\n泵站维修记录：%s\n最后一班撤离：%s"%[story_read.size(),mark("note-camp" in story_read),mark("note-pump" in story_read),mark("note-port" in story_read)],17)
 button("返回世界",close_panel)

func character_status():
 clear_panel("角色与技能")
 text_line("体温 %.1f℃ · 疲劳 %d/100 · 淋湿 %d%%\n中毒剩余 %.0f 秒\n装备：%s"%[temperature,survival.fatigue,survival.wetness,survival.poison,equipped if equipped!="" else "徒手"],18)
 for skill in skill_xp:
  text_line("%s · %d级 · 经验 %d/100"%[skill,skill_level(skill),int(skill_xp[skill])%100],18)
 text_line("生存：熟食恢复提高\n采集：石斧效率提高\n制作：制作时间缩短\n战斗：伤害每级提高5%\n探索：地标发现距离每级增加2米\n\n疲劳会降低体力恢复，超过70限制最大体力。\n淋湿会加剧失温，篝火能烘干；屋顶防雨。\n生肉和河水有中毒风险。净水需要滤芯与河水。\n安全睡眠恢复疲劳，屋顶下休息效果更好。",16)
 button("返回世界",close_panel)

func mark(done: bool) -> String: return "✓" if done else "○"

func onboarding_goal() -> String:
 if "tower" in repairs: return "区域信号已恢复；继续收集日志、探索外礁和扩建营地"
 if "lab" in repairs: return "制作电池并携带零件4，前往北方山地通讯站"
 if "lighthouse" in repairs: return "建工作台制作工具包，前往旧研究所修复控制台"
 if not milestones.get("gather",false): return "绕过残骸，E 搜索漂流物资；收集木材与石头各3份"
 if not milestones.get("axe",false): return "Tab 打开配方，制作石斧；等待完成后按6装备"
 if not milestones.get("fire",false): return "B 选择篝火，在绿色预览处左键放置，右键退出建造"
 if not milestones.get("water",false): return "前往东北渔村搜索净水；按2饮用，或制作滤芯净化河水"
 if not "lighthouse" in repairs: return "向西寻找灯塔；向东仓库搜集金属4、零件2来修复"
 if not "lab" in repairs: return "建工作台制作工具包，前往旧研究所修复控制台"
 if not "tower" in repairs: return "制作电池并携带零件4，前往北方山地通讯站"
 return "区域信号已恢复；继续收集日志、探索外礁和扩建营地"

func map_view():
 clear_panel("北境沉降带 · 区域地图")
 var chart=preload("res://world_map.gd").new()
 chart.game=self; chart.custom_minimum_size=Vector2(580,365)
 content.add_child(chart)
 text_line("金色：已发现地标 · 绿色：营地 · 白色：你\n左键添加标记，右键移除附近标记；最多 20 个。",15)
 text_line("北 ↑     坐标：%d, %d\n海岸在西侧，森林居中，工业区位于东侧。" % [player.position.x,-player.position.z])
 for poi in POIS:
  text_line(("● " if poi[0] in discovered else "◇ ")+poi[0]+"     %dm" % player.position.distance_to(ground(poi[1])),17)
 button("返回世界",close_panel)

func toast(message: String):
 notices.text = message
 toast_time = 7

func interact():
 if target.is_empty(): return
 var e = target
 match e.kind:
  "side-radio": quest_panel("radio")
  "sign":
   clear_panel("浅滩潮汐警示")
   text_line("外礁货箱位于西侧礁石。沿木桩标记穿越浅滩。\n潮位低于 -0.25m 时地面露出。\n高潮时水流危险，勿强行涉水。\n完整潮周期约 12 分钟；观察 HUD 潮位。\n可先探索湿地栈道或泵站，等退潮后返回。",19)
   button("返回",close_panel)
  "note":
   clear_panel(e.title)
   text_line(e.text,19)
   if e.id not in story_read:
    story_read.append(e.id)
    var gift={"箭":6} if e.id=="note-camp" else ({"滤芯":1} if e.id=="note-pump" else {"零件":2})
    for k in gift: inv[k]=inv.get(k,0)+gift[k]
    text_line("首次探索奖励："+str(gift),16)
    save_game()
   button("收起记录",close_panel)
  "resource":
   if harvest_cooldown>0: return
   harvest_cooldown=0.65; attack_time=0.65
   if e.title in ["灰松","石头"]:
    var damage = 2+int(skill_level("采集")/2) if equipped=="石斧" else 1
    e["hits"]=int(e.get("hits",0))+damage
    stamina=max(0,stamina-5); wear_tool(2)
    var needed = 6 if e.title=="灰松" else 3
    beep(200,0.08); soundscape.play_at("chop" if e.title=="灰松" else "stone",e.node.global_position)
    if e.hits<needed:
     toast("%s · 采集 %d/%d"%[e.title,e.hits,needed]); return
   for k in e.gives: inv[k] = inv.get(k,0)+e.gives[k]
   removed.append(e.id)
   gain_skill("采集",12)
   set_collisions(e.node,true)
   navigation.invalidate()
   toast(e.title+"："+str(e.gives))
   if e.title == "灰松":
    var tween = create_tween()
    tween.tween_property(e.node,"rotation:z",1.5,0.8)
    tween.tween_callback(e.node.hide)
   else: e.node.hide()
   beep(240,0.12); soundscape.play_at("pickup",e.node.global_position)
  "repair":
   if e.id in repairs: toast("设施已恢复运行。"); return
   var cost = {"金属":4,"零件":2}
   if e.id == "lab":
    if not "lighthouse" in repairs: toast("先恢复灯塔，取得研究站访问频率。"); return
    cost = {"工具包":1}
   if e.id == "tower":
    if not "lab" in repairs: toast("先前往旧研究所读取通讯校准数据。"); return
    cost = {"电池":1,"零件":4}
   if not can_pay(cost): toast("维修所需："+cost_text(cost)); return
   pay(cost); repairs.append(e.id)
   if e.id == "lab": inv["研究数据"] = 1
   toast("设施恢复："+e.title+"。按 J 查看下一条线索。")
   beep(880,0.4); save_game()
   refresh_signals()
  "water":
   pump_panel()
  "npc":
   clear_panel("守岸人 · 伊莱")
   text_line("“海潮退去的时候，我听见灯塔里有人说话。\n可那地方早就没有人了。”\n\n“别空手进树林。做一支矛。\n想修灯塔，就去东面的仓库找零件。”",20)
   button("交易：3 野果 换 2 布料",func():
    if inv.get("野果",0)>=3:
     inv["野果"]-=3; inv["布料"]=inv.get("布料",0)+2; toast("获得布料 ×2"),inv.get("野果",0)>=3)
   button("药箱援助 · 接受任务 / 交付",func(): quest_panel("aid"))
   button("告别",close_panel)
  "facility":
   match e.title:
    "篝火": fire_menu(e)
    "门框":
     var hinge=e.node.get_node("Door")
     var opened=not e.get("opened",false); e["opened"]=opened
     create_tween().tween_property(hinge,"rotation:y",-PI/2 if opened else 0.0,0.3)
     navigation.invalidate()
     beep(180,0.1)
    "睡袋":
     for enemy in enemies:
      if enemy.hp>0 and enemy.node.position.distance_to(player.position)<15: toast("附近有危险，无法安睡。"); return
     var shelter=is_sheltered(player.position)
     clock=fmod(clock+8,24); health=min(100,health+(30 if shelter else 15)); stamina=100
     hunger=max(0,hunger-10); thirst=max(0,thirst-12)
     survival.rest(shelter); gain_skill("生存",10)
     toast("休息八小时。"+("屋顶遮蔽让你充分恢复。" if shelter else "露宿恢复有限，尝试搭建遮蔽。")); save_game()
    "集雨器":
     for s in structures:
      if s.node==e.node:
       var count=int(s.water)
       if count>0: s.water-=count; inv["净水"]=inv.get("净水",0)+count; toast("收取雨水 ×"+str(count))
       else: toast("容量 5 份；降雨时每 30 秒积存一份。")
    "储物箱": storage(e)
    _: inventory()

func fire_menu(e: Dictionary):
 var fire={}
 for s in structures:
  if s.node==e.node: fire=s; break
 if fire.is_empty(): return
 clear_panel("营地篝火")
 text_line("剩余燃料：%d 秒\n1 木材燃烧 120 秒，最多积存 600 秒。\n露天降雨会加快燃料消耗。"%fire.fuel,18)
 button("添加木材 ×1",func():
  if inv.get("木材",0)>0 and fire.fuel<=480:
   inv["木材"]-=1; fire.fuel=min(600,fire.fuel+120); fire_menu(e),inv.get("木材",0)>0 and fire.fuel<=480)
 button("烹饪与制作",inventory,fire.fuel>0)
 button("返回",close_panel)

func quest_panel(id: String):
 quests.start(id)
 var data=quests.DEFINITIONS[id]
 clear_panel("支线 · "+data.title)
 text_line(data.description,18)
 if quests.states[id]==2:
  text_line("已完成。奖励已领取。",20)
  if id=="radio": text_line("最后的留言：我们已沿北侧山路撤离。\n别放弃灯塔，那里仍是海上唯一的方向。",17)
 else:
  text_line("交付："+cost_text(data.cost),16)
  text_line("奖励："+str(data.reward),16)
  button("交付 / 完成维修",func():
   if quests.complete(id,inv):
    if id=="pump": pump_stock=3
    gain_skill("生存",30); gain_skill("探索",20)
    bag.sync(inv); beep(800,0.25); save_game()
   quest_panel(id),can_pay(data.cost))
 button("返回世界",close_panel)

func pump_panel():
 clear_panel("地下水泵站")
 if quests.states.pump==2:
  text_line("过滤装置已修复。\n每40秒积存一份净水，上限5份。\n当前：%d / 5"%int(pump_stock),18)
  button("领取净水",func():
   var count=int(pump_stock)
   if count>0: pump_stock-=count; inv["净水"]=inv.get("净水",0)+count
   bag.sync(inv); save_game(); pump_panel(),pump_stock>=1)
 else:
  text_line("旧滤芯已失效，泵站只能提供未经处理的河水。",17)
  button("维修过滤装置",func(): quest_panel("pump"))
 button("取河水 ×2"+("（等待 %.0f秒）"%pump_cooldown if pump_cooldown>0 else ""),func():
  if pump_cooldown<=0: inv["河水"]=inv.get("河水",0)+2; pump_cooldown=30; bag.sync(inv); save_game(); pump_panel(),pump_cooldown<=0)
 button("返回",close_panel)

func storage(e: Dictionary):
 clear_panel("储物箱 · "+e.id)
 var data = e.get("stored",{})
 e["stored"] = data
 for k in inv.keys():
  var key = k
  if inv[key]>0:
   button("存入 "+key+" ×"+str(inv[key]),func(): data[key]=data.get(key,0)+inv[key]; inv[key]=0; storage(e))
 for k in data.keys():
  var key = k
  if data[key]>0:
   button("取出 "+key+" ×"+str(data[key]),func(): inv[key]=inv.get(key,0)+data[key]; data[key]=0; storage(e))
 button("关闭",close_panel)

func consume(n: String):
 if inv.get(n,0)<=0: toast("没有"+n); return
 inv[n]-=1
 match n:
  "野果": hunger=min(100,hunger+10)
  "净水": thirst=min(100,thirst+35); milestones["water"]=true
  "绷带": health=min(100,health+30)
  "罐头": hunger=min(100,hunger+35)
  "烤肉": hunger=min(100,hunger+40+skill_level("生存")*2)
  "生肉": hunger=min(100,hunger+20)
  "河水": thirst=min(100,thirst+25)
 survival.food_risk(n,rng.randf())
 if survival.poison>0 and n in ["生肉","河水"]: toast("你感到恶心。中毒会加剧口渴并降低体力恢复。")
 beep(500,0.07)

func attack():
 if attack_time>0 or stamina<12 or death_time>0: return
 var ranged = equipped=="弓" and inv.get("箭",0)>0
 if equipped=="弓" and not ranged: toast("需要箭矢"); return
 attack_time = 0.65; stamina-=12
 beep(130,0.1)
 var reach = 3.0 if equipped=="木矛" else (2.1 if equipped=="石斧" else 1.7)
 var damage = 35 if equipped=="木矛" or ranged else (22 if equipped=="石斧" else 12)
 wear_tool(2)
 if ranged:
  inv["箭"]-=1
  var origin=player.position+Vector3(0,1.35,0)+camera.global_basis.x*0.35
  var aim=camera.global_position-camera.global_basis.z*100
  var ray=PhysicsRayQueryParameters3D.create(camera.global_position,aim); ray.exclude=[player.get_rid()]
  var hit=get_world_3d().direct_space_state.intersect_ray(ray)
  if not hit.is_empty(): aim=hit.position
  launch_arrow(origin,(aim-origin).normalized(),damage*(1+skill_level("战斗")*0.05))
  return
 var chosen={}; var nearest=reach
 for e in enemies:
  var delta = e.node.position-player.position
  if e.hp>0 and delta.length()<nearest and delta.normalized().dot(-camera.global_basis.z)>0.55 and visible_between(player.position+Vector3.UP,e.node.position+Vector3.UP): chosen=e; nearest=delta.length()
 if not chosen.is_empty(): damage_enemy(chosen,damage*(1+skill_level("战斗")*0.05))

func throw_stone():
 if inv.get("石头",0)<=0: toast("需要石头才能制造声响"); return
 inv["石头"]-=1
 var origin=player.position+Vector3(0,1.2,0)
 var forward=-camera.global_basis.z; forward.y=0; forward=forward.normalized()
 var landing=player.position+forward*10
 landing.y=height(landing.x,landing.z)+0.1
 var lure=preload("res://stone_lure.gd").new()
 lure.game=self; lure.origin=origin; lure.destination=landing
 add_child(lure); lure.global_position=origin; lure.add_to_group("stone_lures")
 sphere(lure,Vector3.ZERO,Vector3(0.15,0.15,0.15),Color("7c8581"))

func launch_arrow(origin: Vector3,direction: Vector3,damage: float):
 var arrow=preload("res://arrow.gd").new(); arrow.game=self; arrow.velocity=direction*38; arrow.damage=damage
 add_child(arrow); arrow.global_position=origin
 var shaft=cylinder(arrow,Vector3.ZERO,0.018,0.85,Color("a58a62")); shaft.rotation.x=PI/2
 var tip=cylinder(arrow,Vector3(0,0,-0.45),0.05,0.15,Color("b2bbb5"),0); tip.rotation.x=-PI/2
 return arrow

func damage_enemy(enemy: Dictionary,damage: float):
 if enemy.hp<=0: return
 enemy.hp-=damage; enemy["hurt"]=0.35; gain_skill("战斗",5)
 enemy.state="Retreat" if enemy.hp<25 else "Chase"; enemy.timer=0
 enemy["last_known"]=player.position; enemy["memory"]=6.0; enemy["stimulus"]="player"
 soundscape.play_at("hit",enemy.node.position)
 toast("命中 %s · 剩余生命 %d"%["盐脊犬" if enemy.kind==0 else "沼泽巨蟹",max(0,enemy.hp)])
 if enemy.hp<=0:
  enemy.state="Dead"; set_collisions(enemy.node,true)
  enemy.node.get_node("Indicator").hide()
  create_tween().tween_property(enemy.node,"rotation:z",PI/2,0.4)
  loot(enemy.node.position,"猎物",{"生肉":2,"纤维":2},"enemy"+str(enemies.find(enemy)))

func visible_between(a: Vector3,b: Vector3) -> bool:
 var query = PhysicsRayQueryParameters3D.create(a,b)
 query.exclude = [player.get_rid()]
 var hit = get_world_3d().direct_space_state.intersect_ray(query)
 return hit.is_empty() or hit.position.distance_to(b)<1.2

func set_collisions(n: Node,disabled: bool):
 if n is CollisionShape3D: n.set_deferred("disabled",disabled)
 for child in n.get_children(): set_collisions(child,disabled)

func _unhandled_input(event):
 if event is InputEventMouseMotion and not panel_open:
  if mouse_look_guard>0: return
  yaw -= event.relative.x*sensitivity
  pitch = clamp(pitch-event.relative.y*sensitivity*(-1 if invert_y else 1),-1.1,0.45)
 if event is InputEventKey and event.pressed and not event.echo:
  if event.keycode==KEY_ESCAPE:
   if panel_open and playing: close_panel()
   else: menu()
   return
  if not playing or panel_open or death_time>0: return
  match event.keycode:
   KEY_E: interact()
   KEY_TAB: inventory()
   KEY_B: building_menu()
   KEY_J: journal()
   KEY_M: map_view()
   KEY_C: character_status()
   KEY_R: build_angle+=PI/2
   KEY_G: throw_stone()
   KEY_F5: save_game(); toast("进度已保存")
   KEY_1,KEY_2,KEY_3,KEY_4,KEY_5,KEY_6,KEY_7,KEY_8: use_item(quickbar[event.keycode-KEY_1])
 if event is InputEventMouseButton and event.pressed and playing and not panel_open:
  if event.button_index==MOUSE_BUTTON_RIGHT: build_kind=""
  if event.button_index==MOUSE_BUTTON_LEFT:
   if build_kind!="":
    if valid_build() and can_pay(BUILDS[build_kind]):
     pay(BUILDS[build_kind]); make_structure(build_kind,build_pos,build_angle); beep(350,0.15); save_game()
    else: toast("不能放置：检查材料、支撑和间距。")
   else: attack()

func valid_build() -> bool:
 if build_pos.x < -115 or build_pos.length()>270: return false
 if not visible_between(player.position+Vector3.UP,build_pos+Vector3.UP): return false
 if build_kind=="地基":
  var low=INF; var high=-INF
  for x in [-2,2]:
   for z in [-2,2]:
    var y=height(build_pos.x+x,build_pos.z+z)
    low=min(low,y); high=max(high,y)
  if high-low>1.2 or high>build_pos.y+0.6 or build_pos.y-low>1.2: return false
 for s in structures:
  if s.kind==build_kind and s.node.position.distance_to(build_pos)<1.2: return false
 if build_kind in ["墙","门框","屋顶","楼梯"]:
  for s in structures:
   if s.kind=="地基" and s.node.position.distance_to(build_pos)<(4.0 if build_kind=="楼梯" else 2.5) and abs(s.node.position.y-build_pos.y)<0.15:
    return build_clear()
  return false
 return build_clear()

func collision_rids(n: Node,result: Array):
 if n is CollisionObject3D: result.append(n.get_rid())
 for child in n.get_children(): collision_rids(child,result)

func build_clear() -> bool:
 var size=Vector3(1.4,1,1.2)
 var center=Vector3(0,0.7,0)
 match build_kind:
  "地基": size=Vector3(3.7,0.5,3.7); center.y=0.35
  "楼梯": size=Vector3(1.6,0.5,2.6); center.y=0.3
  "墙","门框": size=Vector3(3.7,2.85,0.18); center.y=1.85
  "屋顶": size=Vector3(4.1,0.18,4.1); center.y=3.4
  "睡袋": size=Vector3(0.9,0.25,2); center.y=0.2
 var exclusions=[player.get_rid()]
 if build_kind in ["墙","门框","屋顶","楼梯"]:
  for s in structures:
   if s.kind=="地基": collision_rids(s.node,exclusions)
  if build_kind=="楼梯": exclusions.append(terrain_body)
 else: exclusions.append(terrain_body)
 var shape=BoxShape3D.new(); shape.size=size
 var query=PhysicsShapeQueryParameters3D.new()
 query.shape=shape; query.transform=Transform3D(Basis(Vector3.UP,build_angle),build_pos+center)
 query.exclude=exclusions
 return get_world_3d().direct_space_state.intersect_shape(query,1).is_empty()

func _physics_process(dt):
 frame_count+=1
 mouse_look_guard=max(0,mouse_look_guard-dt)
 if playing and not navigation.ready: navigation.scan(self)
 damage_flash.color.a=move_toward(damage_flash.color.a,0.0,dt*0.6)
 harvest_cooldown=max(0,harvest_cooldown-dt)
 if not playing or panel_open:
  update_camera(dt)
  return
 if death_time>0:
  death_time=max(0,death_time-dt)
  body.rotation.z=move_toward(body.rotation.z,PI/2,dt*2)
  update_camera(dt)
  if death_time<=0: respawn()
  return
 noise_time=max(0,noise_time-dt)
 for limb in limbs: limb.rotation.x=move_toward(limb.rotation.x,0,dt*5)
 hit_reaction=max(0,hit_reaction-dt); landing_reaction=max(0,landing_reaction-dt)
 var dir = Vector2(float(Input.is_physical_key_pressed(KEY_D))-float(Input.is_physical_key_pressed(KEY_A)),float(Input.is_physical_key_pressed(KEY_S))-float(Input.is_physical_key_pressed(KEY_W))).normalized()
 var moving = dir.length()>0
 var sprint = Input.is_physical_key_pressed(KEY_SHIFT) and stamina>2 and moving
 var crouch = Input.is_physical_key_pressed(KEY_CTRL)
 block_held=Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and build_kind=="" and stamina>3
 var speed = 7.8 if sprint else 4.5
 if crouch: speed=2.2
 if block_held: speed*=0.6
 if weight()>30: speed*=0.55
 if temperature<36: speed*=0.8
 var water_depth=sea.position.y-player.position.y
 if water_depth>0.35: speed*=0.5
 if water_depth>0.75: speed*=0.5
 var motion = Vector3(dir.x,0,dir.y).rotated(Vector3.UP,yaw)
 player.velocity.x=move_toward(player.velocity.x,motion.x*speed,dt*22)
 player.velocity.z=move_toward(player.velocity.z,motion.z*speed,dt*22)
 player.velocity.y-=dt*20
 if player.is_on_floor() and Input.is_physical_key_pressed(KEY_SPACE) and stamina>15:
  player.velocity.y=7; stamina-=15
 var horizontal_step=Vector3(player.velocity.x,0,player.velocity.z)*dt
 if player.is_on_floor() and player.velocity.y<=0 and horizontal_step.length()>0.001 and player.test_move(player.global_transform,horizontal_step):
  var raised=player.global_transform; raised.origin.y+=0.24
  if not player.test_move(raised,horizontal_step): player.position.y+=0.24
 player.move_and_slide()
 if player.is_on_floor():
  if previous_fall_speed< -9:
   health-=max(0,abs(previous_fall_speed)-10)*3
   landing_reaction=0.35; soundscape.play_at("sand",player.position)
  previous_fall_speed=0
 else: previous_fall_speed=min(previous_fall_speed,player.velocity.y)
 player.position.x=clamp(player.position.x,-205,205)
 player.position.z=clamp(player.position.z,-205,205)
 if moving:
  body.rotation.y=lerp_angle(body.rotation.y,atan2(-motion.x,-motion.z),dt*12)
  walk_time+=dt*speed
  for i in range(limbs.size()): limbs[i].rotation.x=sin(walk_time*2.5+i*PI)*0.5
  if fmod(walk_time,2.8)<dt*speed and player.is_on_floor():
   var surface="sand" if player.position.x < -40 else "grass"
   if water_depth>0.05: surface="water"
   elif near_structure("地基") or (in_marsh(player.position) and player.position.y>1): surface="wood"
   elif player.position.x>60: surface="metal"
   soundscape.play_at(surface,player.position)
 body.position.y = -0.35 if crouch else 0.0
 body.position.y-=sin(landing_reaction/0.35*PI)*0.15
 body.rotation.z=sin(hit_reaction*25)*hit_reaction*0.35
 if not moving and player.is_on_floor(): body.position.y+=sin(Time.get_ticks_msec()*0.002)*0.012
 if not player.is_on_floor():
  limbs[0].rotation.x=0.3; limbs[2].rotation.x=-0.25
 if block_held: limbs[1].rotation.x=1.2; limbs[3].rotation.x=1.1
 if attack_time>0 and limbs.size()>3: limbs[3].rotation.x=sin(attack_time/0.65*PI)*1.8
 survival.tick(dt,sprint,weather>=2,is_sheltered(player.position),near_structure("篝火"))
 stamina=clamp(stamina+dt*(-8 if sprint else survival.stamina_recovery()),0,80 if survival.fatigue>70 else 100)
 advance_craft(dt)
 attack_time=max(0,attack_time-dt)
 clock=fmod(clock+dt/60,24)
 weather_time+=dt
 if weather_time>100: weather=(weather+1)%4; weather_time=0
 hunger=max(0,hunger-dt*0.025)
 thirst=max(0,thirst-dt*(0.045 if weather==0 else 0.035))
 var target_temperature=35.5 if weather>=2 else (36.2 if clock<6 or clock>19 else 37.0)
 if player.position.z< -100: target_temperature-=0.5
 target_temperature=min(37,target_temperature+skill_level("生存")*0.06)
 temperature=move_toward(temperature,target_temperature,dt*0.008)
 if near_structure("篝火"): temperature=move_toward(temperature,37,dt*0.1)
 if survival.wetness>50 and not is_sheltered(player.position): temperature=move_toward(temperature,35,dt*0.006)
 if survival.poison>0: thirst=max(0,thirst-dt*0.035)
 if hunger>70 and thirst>70 and survival.poison<=0 and not sprint: health=min(100,health+dt*0.06)
 if hunger<=0 or thirst<=0: health-=dt*0.9
 if temperature<36: stamina=max(0,stamina-dt*2)
 tide_warning=max(0,tide_warning-dt)
 if water_depth>0.75:
  stamina=max(0,stamina-dt*12); health-=dt*6
  if tide_warning<=0: toast("深水与潮流危险！立即退向高处，低潮再穿越浅滩。"); tide_warning=6
 if health<=0: die(); return
 update_enemies(dt,crouch,sprint)
 update_target()
 update_camera(dt)
 update_world(dt)
 update_build()
 bag.sync(inv)
 if equipped!="" and inv.get(equipped,0)<=0: equipped=""; update_held_tool()
 refresh_quickbar()
 autosave+=dt
 if autosave>45: autosave=0; save_game()
 toast_time-=dt
 if toast_time<=0: notices.text=""
 if smoke and frame_count>120:
  if qa_dir!="": get_viewport().get_texture().get_image().save_png(qa_dir.path_join("smoke.png"))
  print("SMOKE_OK frames=",frame_count," fps=",Engine.get_frames_per_second())
  get_tree().quit()
 if gallery and frame_count%60==0:
  var index = frame_count/60-1
  if index>0:
   get_viewport().get_texture().get_image().save_png(qa_dir.path_join("scene-%02d.png"%index))
  if index>=POIS.size():
   print("GALLERY_OK 10 rendered locations")
   get_tree().quit()
  else:
   player.position=ground(POIS[index][1])+Vector3(0,1,12)
   weather=index%4
   clock=8 if index<7 else 20
 if coast_gallery and frame_count%60==0:
  var index=int(frame_count/60)-1
  if index>0: get_viewport().get_texture().get_image().save_png(qa_dir.path_join("coast-%d.png"%index))
  var scenes=[[Vector2(-55,-57),8.0],[Vector2(-113,-96),9.0],[Vector2(-113,-96),15.0],[Vector2(-173,-92),9.0]]
  if index>=scenes.size(): print("COAST_GALLERY_OK"); get_tree().quit()
  else:
   player.position=ground(scenes[index][0])+Vector3.UP; clock=scenes[index][1]; weather=1; yaw=PI/2 if index>0 else 0

func update_camera(dt: float):
 var focus = player.position+Vector3(0,1.5,0)
 var offset = Vector3(0.65,1.0,5.6).rotated(Vector3.RIGHT,pitch).rotated(Vector3.UP,yaw)
 var desired = focus+offset
 var ray = PhysicsRayQueryParameters3D.create(focus,desired)
 ray.exclude=[player.get_rid()]
 var hit = get_world_3d().direct_space_state.intersect_ray(ray)
 if not hit.is_empty(): desired=hit.position+(focus-hit.position).normalized()*0.3
 camera.position=camera.position.lerp(desired,min(1,dt*14)) if camera.position.length()>1 else desired
 camera.look_at(focus)
 camera.fov=fov

func update_target():
 target={}
 var best = 3.4
 for e in entities:
  if not is_instance_valid(e.node) or not e.node.visible or e.id in removed: continue
  var p = e.node.global_position+Vector3.UP
  var d = p.distance_to(player.position+Vector3.UP)
  if d<best and visible_between(player.position+Vector3.UP,p):
   target=e; best=d
 prompt.text = "[E] "+target.action+" · "+target.title if not target.is_empty() else "·"
 if build_kind!="": prompt.text="建造 "+build_kind+" · 左键放置 / R 旋转 / 右键取消"

func update_enemies(dt: float,crouch: bool,sprint: bool):
 for e in enemies:
  if e.hp<=0: continue
  var n = e.node
  var d = n.position.distance_to(player.position)
  var indicator=n.get_node("Indicator")
  indicator.visible=d<20
  indicator.text=("盐脊犬" if e.kind==0 else "沼泽巨蟹")+" · %d"%max(0,e.hp)+( "\n即将攻击！" if e.has("windup") else "")
  e.timer+=dt; e.cooldown=max(0,e.cooldown-dt)
  var awareness = (7 if crouch else 16)+(8 if sprint else 0)
  var front=(player.position-n.position).normalized().dot(-n.global_basis.z)>0.15
  var can_see = d<awareness and (front or e.state in ["Chase","Attack"]) and visible_between(n.position+Vector3.UP,player.position+Vector3.UP)
  var heard=null
  if sprint and d<12: heard=player.position
  if noise_time>0 and n.position.distance_to(noise_position)<18: heard=noise_position
  senses.observe(e,player.position,can_see,heard,dt)
  if (can_see or heard is Vector3) and e.state in ["Idle","Patrol"]: e.state="Alert"; e.timer=0
  if can_see and e.state=="Search": e.state="Alert"; e.timer=0
  if e.state=="Alert" and e.timer>0.8: e.state="Chase"
  if e.state=="Chase" and (e.memory<=0 or d>30): e.state="Search"; e.timer=0
  if e.state=="Search" and e.timer>6: e.state="Patrol"; e.timer=0
  if e.state=="Patrol" and e.timer>10: e.state="Idle"; e.timer=0
  if e.state=="Idle" and e.timer>2: e.state="Patrol"; e.timer=0
  if e.state=="Retreat" and e.timer>8: e.state="Patrol"
  var goal = e.home+Vector3(sin(e.timer*0.2)*5,0,cos(e.timer*0.2)*5)
  var speed = 1.1
  if e.state=="Chase": goal=senses.target(e,e.home); speed=4.8 if e.kind==0 else 2.3
  if e.state=="Search": goal=senses.target(e,e.home); speed=1.6
  if e.state=="Idle": speed=0
  if e.state=="Chase" and e.get("stimulus","")=="noise" and n.position.distance_to(goal)<2: e.state="Search"; e.timer=0
  if e.state=="Retreat": goal=n.position+(n.position-player.position); speed=5
  if d<1.9 and can_see and e.state=="Chase": e.state="Attack"
  if e.state=="Attack" and not can_see:
   e.state="Search"; e.timer=0; e.erase("windup")
  if e.state=="Search" and n.position.distance_to(goal)<1.2:
   speed=0; n.rotation.y+=dt*0.7
  if e.state=="Attack":
   speed=0
   if d>2.5: e.state="Chase"
   elif e.cooldown<=0:
    if not e.has("windup"):
     e.windup=0.7; toast("%s准备攻击！后退或按住右键防御。"%["盐脊犬" if e.kind==0 else "巨蟹"])
    else:
     e.windup-=dt
     if e.windup<=0:
      if d<2.3 and visible_between(n.position+Vector3.UP,player.position+Vector3.UP):
       var incoming=9 if e.kind==0 else 18
       var facing=(n.position-player.position).normalized().dot(-camera.global_basis.z)>0.2
       if block_held and facing:
        stamina=max(0,stamina-18); incoming*=0.25; toast("格挡成功 · 消耗体力")
       health-=incoming; hit_reaction=0.45; damage_flash.color.a=0.24; beep(90,0.15); soundscape.play_at("hit",player.position)
      e.erase("windup"); e.cooldown=1.6
  if e.state=="Alert": speed=0
  var direction=(goal-n.position); direction.y=0
  if speed>0 and not visible_between(n.position+Vector3.UP,goal+Vector3.UP):
   e["path_clock"]=e.get("path_clock",0.0)-dt
   if e.path_clock<=0 or e.get("revision",-1)!=navigation.revision:
    e["path"]=navigation.path(n.position,goal); e.path_clock=1.0; e["revision"]=navigation.revision
   var route=e.get("path",[])
   while not route.is_empty() and Vector2(n.position.x,n.position.z).distance_to(Vector2(route[0].x,route[0].z))<1.2: route.pop_front()
   if not route.is_empty(): direction=route[0]-n.position; direction.y=0
   else: direction=Vector3.ZERO
  var v=direction.normalized()*speed
  # Short collision probes protect coarse navigation at corners and narrow gaps.
  if v.length()>0 and obstacle_ahead(n,v):
   var left=v.rotated(Vector3.UP,PI/3); var right=v.rotated(Vector3.UP,-PI/3)
   if not obstacle_ahead(n,left): v=left
   elif not obstacle_ahead(n,right): v=right
   else: v=Vector3.ZERO
  n.velocity=Vector3(v.x,n.velocity.y-dt*20,v.z)
  n.move_and_slide()
  if v.length()>0.1: n.rotation.y=atan2(-v.x,-v.z)
  for p in e.parts:
   var part=p.node
   part.position=p.position
   part.rotation=p.rotation
   if speed>0 and part.has_meta("phase"): part.rotation.x+=sin(e.timer*10+float(part.get_meta("phase"))*PI)*0.4
   if e.has("windup"): part.position.z+=sin(e.windup*5)*0.15
   if e.get("hurt",0)>0: part.position.x+=sin(e.hurt*40)*0.08
  e["hurt"]=max(0,e.get("hurt",0)-dt)

func refresh_signals():
 signal_signature=str(repairs)
 for id in signal_screens:
  var active=id in repairs
  signal_screens[id].albedo_color=Color("7fc7a1") if active else Color("7c5750")
  signal_screens[id].emission=Color("3a9d77") if active else Color("2b1110")
 for id in signal_lights:
  var active=id in repairs
  signal_lights[id].light_color=Color("f1ce91") if id=="lighthouse" else (Color("a2dbc5") if active else Color("ae5e51"))
  signal_lights[id].light_energy=(5.0 if active else 0.4) if id=="lighthouse" else (3.0 if active else 0.3)

func obstacle_ahead(enemy: CharacterBody3D,direction: Vector3) -> bool:
 var a=enemy.position+Vector3(0,0.8,0)
 var ray=PhysicsRayQueryParameters3D.create(a,a+direction.normalized()*1.1)
 ray.exclude=[enemy.get_rid(),player.get_rid()]
 return not get_world_3d().direct_space_state.intersect_ray(ray).is_empty()

func update_world(dt: float):
 if signal_signature!=str(repairs): refresh_signals()
 pump_cooldown=max(0,pump_cooldown-dt)
 if quests.states.pump==2: pump_stock=min(5,pump_stock+dt/40)
 wet_ground=move_toward(wet_ground,1.0 if weather>=2 else 0.0,dt*0.03)
 terrain_material.set_shader_parameter("wet",wet_ground)
 if inv.get("木材",0)>=3 and inv.get("石头",0)>=3: milestones["gather"]=true
 if inv.get("石斧",0)>0: milestones["axe"]=true
 for s in structures:
  if s.kind=="篝火": milestones["fire"]=true
 for s in structures:
  if s.kind=="篝火":
   var sheltered=is_sheltered(s.node.position)
   s.fuel=max(0,s.fuel-dt*(2.5 if weather>=2 and not sheltered else 1.0))
   s.node.get_node("Flame").visible=s.fuel>0
   s.node.get_node("FireLight").visible=s.fuel>0
  elif s.kind=="集雨器" and weather>=2: s.water=min(5,s.water+dt/30)
 rain.global_position=player.position+Vector3(0,12,0)
 rain.emitting=weather>=2
 var daylight = clamp(sin((clock-6)/24*TAU),0.06,1.0)
 sun.rotation_degrees.x=-(clock-6)*7.5
 sun.light_energy=daylight*1.05
 environment.ambient_light_energy=0.13+daylight*0.43
 sky_update_clock-=dt
 if sky_update_clock<=0:
  sky_update_clock=0.5
  sky_material.sky_top_color=Color("101d30").lerp(Color("405e70"),daylight)
  sky_material.sky_horizon_color=Color("263748").lerp(Color("a4b7b8"),daylight)
  sky_material.ground_horizon_color=sky_material.sky_horizon_color
  environment.fog_light_color=Color("263c4b").lerp(Color("91a9ad"),daylight)
 var density = [0.0035,0.012,0.007,0.018][weather]
 environment.fog_density=lerp(environment.fog_density,float(density),dt*0.15)
 sea.position.y=tide_level(clock)
 var cell=Vector2i(floor((player.position.x+210)/20),floor((player.position.z+210)/20))
 for x in range(-1,2):
  for z in range(-1,2):
   var p=cell+Vector2i(x,z)
   if p.x>=0 and p.x<21 and p.y>=0 and p.y<21: explored[str(p.x)+","+str(p.y)]=true
 var region = "沉没海岸" if player.position.x<-40 else ("锈蚀工业区" if player.position.x>60 else "灰松森林")
 if player.position.z < -100: region="黑岩高地"
 if in_marsh(player.position): region="盐雾湿地"
 for poi in POIS:
  if not poi[0] in discovered and player.position.distance_to(ground(poi[1]))<18+skill_level("探索")*2:
   discovered.append(poi[0]); gain_skill("探索",25); toast("发现："+poi[0]+" · 地图已更新")
 var hud_text="雾线之外   /   北境沉降带\n生命 %03d   饱食 %03d   饮水 %03d   体力 %03d   体温 %.1f℃\n%02d:%02d   %s   ·   %s\n\n1–8 快捷物品  |  Tab 背包制作  B 建造  M 地图  J 任务\n主线信号 %d / 3   ·   探索 %d / 10" % [health,hunger,thirst,stamina,temperature,int(clock),int(fmod(clock,1)*60),["晴","浓雾","小雨","暴风雨"][weather],region,repairs.size(),discovered.size()]
 hud_text+="\n潮位 %+.2fm · %s"%[sea.position.y,"浅滩可通行" if sea.position.y < -0.25 else "浅滩正在淹没"]
 hud_text+="\n疲劳 %d · 淋湿 %d%% · %s   [C 状态]"%[survival.fatigue,survival.wetness,"中毒 %.0f秒"%survival.poison if survival.poison>0 else "健康"]
 if not craft_job.is_empty(): hud_text+="\n制作 %s · %.1f秒%s"%[craft_job.item,craft_job.left,"（设施距离不足，暂停）" if not craft_station(craft_job.item) else ""]
 hud_text+="\n目标 · "+onboarding_goal()
 if hud.text!=hud_text: hud.text=hud_text

func update_build():
 if build_kind=="":
  if is_instance_valid(ghost): ghost.queue_free()
  return
 var forward = -camera.global_basis.z
 forward.y=0
 build_pos=player.position+forward.normalized()*4
 build_pos.x=round(build_pos.x/2)*2; build_pos.z=round(build_pos.z/2)*2
 build_pos.y=height(build_pos.x,build_pos.z)
 snap_build()
 if not is_instance_valid(ghost) or ghost.is_queued_for_deletion() or ghost.get_meta("kind","")!=build_kind:
  if is_instance_valid(ghost): ghost.queue_free()
  ghost=make_structure(build_kind,build_pos,build_angle,false)
  ghost.set_meta("kind",build_kind)
  ghost_material=StandardMaterial3D.new()
  ghost_material.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
  ghost_material.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
  preview_nodes(ghost)
 ghost.position=build_pos; ghost.rotation.y=build_angle
 var color=Color("62d8b1") if valid_build() and can_pay(BUILDS[build_kind]) else Color("e47767")
 color.a=0.4; ghost_material.albedo_color=color

func snap_build():
 var nearest={}; var distance=7.0
 for s in structures:
  if s.kind!="地基": continue
  var d=Vector2(s.node.position.x,s.node.position.z).distance_to(Vector2(build_pos.x,build_pos.z))
  if d<distance: nearest=s; distance=d
 if nearest.is_empty():
  if build_kind=="地基":
   for x in [-2,2]:
    for z in [-2,2]: build_pos.y=max(build_pos.y,height(build_pos.x+x,build_pos.z+z)-0.3)
  return
 var origin=nearest.node.position
 if build_kind=="楼梯":
  var delta=build_pos-origin
  var offset=Vector3(sign(delta.x)*3.5,0,0) if abs(delta.x)>abs(delta.z) else Vector3(0,0,sign(delta.z)*3.5)
  if offset.length()<1: offset=Vector3(0,0,3.5)
  build_pos=origin+offset; build_angle=atan2(offset.x,offset.z)
 if not build_kind in ["地基","墙","门框","屋顶","楼梯"] and distance<1.9:
  build_pos.y=origin.y+0.6
 if build_kind=="屋顶": build_pos=origin; build_angle=nearest.angle
 elif build_kind in ["墙","门框","地基"]:
  var delta=(build_pos-origin).rotated(Vector3.UP,-nearest.angle)
  var along_x=abs(delta.x)>abs(delta.z)
  var step=4.0 if build_kind=="地基" else 2.0
  var offset=Vector3(sign(delta.x)*step,0,0) if along_x else Vector3(0,0,sign(delta.z)*step)
  if offset.length()<1: offset=Vector3(0,0,step)
  build_pos=origin+offset.rotated(Vector3.UP,nearest.angle)
  build_angle=nearest.angle+(PI/2 if along_x and build_kind!="地基" else 0)

func preview_nodes(n: Node):
 for child in n.get_children():
  if child is CollisionObject3D or child is Light3D:
   n.remove_child(child); child.queue_free()
  else:
   if child is GeometryInstance3D: child.material_override=ghost_material
   preview_nodes(child)

func die():
 if death_time>0: return
 death_time=2.3; player.velocity=Vector3.ZERO; build_kind=""
 if is_instance_valid(ghost): ghost.queue_free()
 toast("你失去了意识……")

func respawn():
 body.rotation.z=0; previous_fall_speed=0
 cancel_craft()
 var drops = inv.duplicate()
 for k in bag.overflow: drops[k]=drops.get(k,0)+bag.overflow[k]
 inv.clear()
 bag=Bag.new(); equipped=""; durability.clear(); update_held_tool()
 var id = "death-"+str(Time.get_unix_time_from_system())
 loot(player.position,"遗失的背包",drops,id)
 player.position=ground(Vector2(-65,65))+Vector3.UP
 health=100; hunger=60; thirst=60; stamina=100
 survival=preload("res://survival_state.gd").new(); survival.fatigue=20
 toast("你被潮水带回海岸。物资留在原处，可以返回取回。")

func save_game():
 bag.sync(inv)
 var built = []
 for s in structures: built.append({"kind":s.kind,"pos":s.pos,"angle":s.angle,"fuel":s.get("fuel",0),"water":s.get("water",0)})
 var stored = {}
 for e in entities:
  if is_instance_valid(e.node) and e.has("stored"): stored[e.id]=e.stored
 var enemy_state = []
 for e in enemies: enemy_state.append({"hp":e.hp,"pos":[e.node.position.x,e.node.position.y,e.node.position.z]})
 var data = {"v":1,"position":[player.position.x,player.position.y,player.position.z],"inv":inv,"removed":removed,"repairs":repairs,"discovered":discovered,"built":built,"stored":stored,"clock":clock,"weather":weather,"health":health,"hunger":hunger,"thirst":thirst,"temperature":temperature,"drops":dropped_loot,"enemies":enemy_state}
 data["bag_slots"]=bag.slots; data["overflow"]=bag.overflow; data["quickbar"]=quickbar
 data["equipped"]=equipped; data["durability"]=durability
 var doors={}
 for e in entities:
  if is_instance_valid(e.node) and e.title=="门框": doors[e.id]=e.get("opened",false)
 data["doors"]=doors
 data["story_read"]=story_read; data["map_markers"]=map_markers
 data["explored"]=explored
 data["survival"]=survival.serialize(); data["skill_xp"]=skill_xp; data["craft_job"]=craft_job
 data["milestones"]=milestones
 data["quests"]=quests.states; data["pump_stock"]=pump_stock; data["pump_cooldown"]=pump_cooldown
 if not save_store.write(SAVE,data): toast(save_store.last_error)

func load_game():
 var data=save_store.read(SAVE)
 if data==null: toast(save_store.last_error); return
 start_new()
 inv=data.inv; removed=data.removed; repairs=data.repairs; discovered=data.discovered
 var p = data.position; player.position=Vector3(p[0],p[1],p[2])
 health=clamp(data.health,0,100); hunger=clamp(data.hunger,0,100); thirst=clamp(data.thirst,0,100); clock=fposmod(data.clock,24); weather=clampi(int(data.weather),0,3); temperature=clamp(data.temperature,30,42)
 for e in entities:
  if is_instance_valid(e.node) and e.id in removed: e.node.hide(); set_collisions(e.node,true)
 for drop in data.get("drops",[]):
  if not drop.id in removed: loot(Vector3(drop.pos[0],drop.pos[1],drop.pos[2]),drop.title,drop.gives,drop.id)
 var enemy_state = data.get("enemies",[])
 for i in range(min(enemy_state.size(),enemies.size())):
  var e = enemies[i]; var state = enemy_state[i]
  e.hp=state.hp; e.node.position=Vector3(state.pos[0],state.pos[1],state.pos[2])
  if e.hp<=0: e.node.hide(); e.state="Dead"; set_collisions(e.node,true)
 for s in data.built:
  make_structure(s.kind,Vector3(s.pos[0],s.pos[1],s.pos[2]),s.angle)
  structures.back().fuel=s.get("fuel",120.0 if s.kind=="篝火" else 0.0)
  structures.back().water=s.get("water",0.0)
 for e in entities:
  if not is_instance_valid(e.node) or e.node.is_queued_for_deletion(): continue
  if data.get("stored",{}).has(e.id): e["stored"]=data.stored[e.id]
  if e.title=="门框" and data.get("doors",{}).get(e.id,false):
   e["opened"]=true; e.node.get_node("Door").rotation.y=-PI/2
 if data.has("bag_slots") and data.bag_slots.size()==24: bag.slots=data.bag_slots
 bag.overflow=data.get("overflow",{})
 quickbar=data.get("quickbar",quickbar); equipped=data.get("equipped",""); durability=data.get("durability",{})
 story_read=data.get("story_read",[]); map_markers=data.get("map_markers",[])
 explored=data.get("explored",{})
 survival.restore(data.get("survival",{}))
 skill_xp.merge(data.get("skill_xp",{}),true); craft_job=data.get("craft_job",{})
 milestones=data.get("milestones",{})
 quests.restore(data.get("quests",{})); pump_stock=data.get("pump_stock",0.0); pump_cooldown=data.get("pump_cooldown",0.0)
 bag.sync(inv); update_held_tool(); refresh_quickbar()
 toast("主存档损坏，已从备用存档恢复旅程。" if save_store.last_source.ends_with(".bak") else "已恢复旅程。")

func refresh_quickbar():
 var signature=str(quickbar)+str(inv)+equipped
 if signature==quick_signature: return
 quick_signature=signature
 for child in quick_hud.get_children():
  quick_hud.remove_child(child); child.queue_free()
 for i in range(8):
  var label=Label.new()
  label.custom_minimum_size=Vector2(100,44)
  label.text="%d  %s\n×%d%s"%[i+1,quickbar[i],inv.get(quickbar[i],0)," ◀" if equipped==quickbar[i] else ""]
  label.add_theme_font_size_override("font_size",15)
  label.add_theme_color_override("font_color",Color("ebd5a0") if equipped==quickbar[i] else Color("dae2dc"))
  quick_hud.add_child(label)

func make_audio():
 soundscape=preload("res://soundscape.gd").new(); add_child(soundscape)
 synth=AudioStreamPlayer.new()
 var stream = AudioStreamGenerator.new()
 stream.mix_rate=22050; stream.buffer_length=0.12
 synth.stream=stream; add_child(synth); synth.play()
 audio_playback=synth.get_stream_playback()

func beep(freq: float,duration: float):
 tone=freq; tone_length=duration

func _process(dt):
 if "--settings-preview" in OS.get_cmdline_user_args() and frame_count>120:
  if qa_dir!="": get_viewport().get_texture().get_image().save_png(qa_dir.path_join("settings-v07.png"))
  print("SETTINGS_PREVIEW_OK"); get_tree().quit()
 if soundscape!=null:
  soundscape.master=volume
  soundscape.update_mix(player.position,weather,clock<6 or clock>19,dt)
 if map_preview and frame_count>120:
  if qa_dir!="": get_viewport().get_texture().get_image().save_png(qa_dir.path_join("map-v03.png"))
  print("MAP_PREVIEW_OK"); get_tree().quit()
 if bag_preview and frame_count>120:
  if qa_dir!="": get_viewport().get_texture().get_image().save_png(qa_dir.path_join("inventory-v02.png"))
  print("BAG_PREVIEW_OK"); get_tree().quit()
 if audio_playback==null: return
 var count = audio_playback.get_frames_available()
 var audio_time=float(Time.get_ticks_usec())/1000000.0
 for i in range(count):
  var t = audio_time+float(i)/22050.0
  var sample = sin(t*TAU*tone)*0.15*volume if tone_length>0 else 0.0
  audio_playback.push_frame(Vector2(sample,sample))
  tone_length=max(0,tone_length-1.0/22050)

func test_rules():
 test_bag_rules()
 inv={"木材":30,"石头":20,"纤维":20,"金属":20,"布料":20,"零件":20}
 craft("石斧")
 assert(inv.get("石斧",0)==1)
 assert(inv["木材"]==27)
 assert(not can_pay({"不存在":1}))
 make_structure("工作台",player.position+Vector3(2,0,0),0)
 craft("工具包")
 assert(inv.get("工具包",0)==1)
 make_structure("篝火",player.position+Vector3(-2,0,0),0)
 inv["生肉"]=1; craft("烤肉"); assert(inv.get("烤肉",0)==1)
 thirst=20; inv["净水"]=1; consume("净水"); assert(thirst==55)
 repairs.append("lighthouse")
 save_game()
 inv.clear(); repairs.clear()
 load_game()
 assert(inv.get("石斧",0)==1 and "lighthouse" in repairs)
 assert(structures.size()==2)
 for id in ["lab","tower"]:
  for e in entities:
   if e.id==id:
    target=e
    if id=="tower": inv["电池"]=1; inv["零件"]=4
    interact()
 assert(repairs.size()==3)
 save_game(); load_game(); assert(repairs.size()==3)
 print("RULE_TESTS_OK crafting consumption persistence structures")

func test_signal_visuals():
 refresh_signals()
 assert(signal_lights.lighthouse.light_energy==5.0 and signal_lights.tower.light_energy==3.0)
 assert(signal_screens.lab.emission.g>signal_screens.lab.emission.r)
 var original=repairs.duplicate(); repairs=[]; refresh_signals()
 assert(is_equal_approx(signal_lights.lighthouse.light_energy,0.4) and is_equal_approx(signal_lights.tower.light_energy,0.3))
 repairs=original; refresh_signals()
 print("SIGNALS_OK repaired_lights console_status restore")

func test_bag_rules():
 var test=Bag.new()
 var amounts={"木材":27,"石斧":1}
 test.sync(amounts)
 assert(test.totals()["木材"]==27)
 assert(test.slots[0].count==20 and test.slots[1].count==7)
 assert(test.split(0))
 assert(test.totals()["木材"]==27)
 assert(test.move_stack(3,1))
 assert(test.totals()["木材"]==27)
 assert(test.move_stack(0,2))
 assert(test.slots[0].item=="石斧")
 amounts["木材"]=2; test.sync(amounts)
 assert(test.totals()["木材"]==2)
 var full=Bag.new(); var many={"石头":500}
 full.sync(many)
 assert(many["石头"]==480 and full.overflow["石头"]==20)
 full.sync(many); assert(full.overflow["石头"]==20)
 print("BAG_TESTS_OK split merge swap consume capacity overflow")

func test_extended_rules():
 await get_tree().physics_frame
 await get_tree().physics_frame
 inv["石斧"]=1; equipped="石斧"; durability["石斧"]=40
 quickbar[0]="石斧"
 var pos=player.position+Vector3(9,0,0)
 pos.y=height(pos.x,pos.z)
 var door=make_structure("门框",pos,0)
 var entry=entities.back()
 target=entry; interact()
 assert(entry.opened)
 save_game(); load_game()
 assert(equipped=="石斧" and durability["石斧"]==40 and quickbar[0]=="石斧")
 assert(entities.back().get("opened",false))
 assert(is_equal_approx(entities.back().node.get_node("Door").rotation.y,-PI/2))
 # Harvesting takes three axe strikes; repeated input during cooldown yields nothing.
 var resource={}
 for e in entities:
  if e.title=="灰松" and not e.id in removed: resource=e; break
 target=resource
 var wood_before=int(inv.get("木材",0))
 harvest_cooldown=0; interact()
 assert(resource.hits==2 and inv.get("木材",0)==wood_before)
 interact(); assert(resource.hits==2)
 harvest_cooldown=0; interact()
 harvest_cooldown=0; interact()
 assert(resource.id in removed and inv["木材"]==wood_before+6)
 assert(durability["石斧"]==34)
 wear_tool(40)
 assert(equipped=="" and inv.get("石斧",0)==0)
 await get_tree().physics_frame
 build_kind="地基"; build_pos=pos; build_angle=0
 assert(not valid_build())
 build_kind=""
 print("EXTENDED_TESTS_OK equipment durability harvest cooldown door persistence overlap")

func test_v03_rules():
 for i in range(75): await get_tree().physics_frame
 assert(navigation.ready)
 var route=navigation.path(ground(Vector2(58,16)),ground(Vector2(85,16)))
 assert(route.size()>3)
 var base=ground(Vector2(-52,76))
 make_structure("地基",base,0)
 build_kind="墙"; build_pos=base+Vector3(1.8,0,0.5); snap_build()
 assert(build_pos.is_equal_approx(base+Vector3(2,0,0)))
 assert(is_equal_approx(build_angle,PI/2))
 build_kind="屋顶"; build_pos=base+Vector3(1,0,1); snap_build()
 assert(build_pos.is_equal_approx(base))
 build_kind=""
 var note={}
 for e in entities:
  if e.id=="note-camp": note=e; break
 var before=int(inv.get("箭",0))
 target=note; interact(); close_panel()
 assert(inv.get("箭",0)==before+6)
 target=note; interact(); close_panel()
 assert(inv.get("箭",0)==before+6)
 map_markers=[[-10,20]]
 save_game(); load_game()
 assert("note-camp" in story_read and map_markers.size()==1)
 assert(inv.get("箭",0)==before+6)
 print("V03_TESTS_OK world_navigation foundation_snap roof_support notes_once map_persistence")

func test_v04_rules():
 for i in range(85): await get_tree().physics_frame
 for s in structures:
  if s.kind=="篝火": s.fuel=0
 assert(not near_structure("篝火"))
 make_structure("集雨器",player.position+Vector3(3,0,0),0)
 var collector=structures.back()
 weather=2; update_world(180)
 assert(is_equal_approx(collector.water,5))
 var before=int(inv.get("净水",0))
 target=entities.back(); interact()
 assert(inv.get("净水",0)==before+5 and is_equal_approx(collector.water,0))
 interact(); assert(inv.get("净水",0)==before+5)
 collector.water=1.5
 save_game(); load_game()
 assert(is_equal_approx(structures.back().water,1.5))
 for s in structures:
  if s.kind=="篝火": assert(s.fuel==0)
 print("V04_TESTS_OK extinguished_fire rain_capacity collect_once facility_persistence")

func test_v06_rules():
 for i in range(100): await get_tree().physics_frame
 # Test the exposed channel, excluding the rising, intentionally safe island bank.
 for x in range(-120,-153,-4):
  var y=height(x,-100)
  assert(y>tide_level(9))
  assert(tide_level(3)-y>0.75)
 var query=PhysicsRayQueryParameters3D.create(Vector3(-140,10,-100),Vector3(-140,-10,-100))
 var hit=get_world_3d().direct_space_state.intersect_ray(query)
 assert(not hit.is_empty() and abs(hit.position.y-height(-140,-100))<0.1)
 assert(in_marsh(ground(Vector2(-48,-80))))
 explored["3,4"]=true
 save_game(); load_game()
 assert(explored.has("3,4"))
 var map=make_map_texture()
 assert(map.get_width()==210 and map.get_height()==210)
 print("V06_TESTS_OK low_high_tide physical_shelf marsh exploration_save terrain_map")

func test_audio():
 assert(soundscape.layers.size()==4 and soundscape.effects.size()==9)
 for kind in soundscape.layers:
  var stream=soundscape.layers[kind].stream
  assert(stream.loop_mode==AudioStreamWAV.LOOP_FORWARD and stream.data.size()==529200)
  var peak=0; var total=0.0
  for i in range(0,stream.data.size(),100):
   var sample=abs(stream.data.decode_s16(i))
   peak=max(peak,sample); total+=sample
  assert(peak>100 and peak<32000 and total>0)
 for kind in soundscape.effects:
  assert(soundscape.effects[kind].data.size()>10000)
 var old_volume=soundscape.master
 soundscape.master=0; soundscape.update_mix(Vector3.ZERO,0,false,20)
 for layer in soundscape.layers.values(): assert(layer.volume_db<=-69)
 soundscape.master=old_volume
 print("AUDIO_TESTS_OK loops_pcm signal_peaks effects master_mute")

func test_materials():
 test_perception()
 for id in ["wood_planks","coast_sand_01","forest_ground_04","rusty_metal_02","rock_face_03","concrete_wall_004"]:
  for kind in ["Diffuse","nor_gl","Rough"]:
   var image=material_library.texture(id,kind)
   assert(image!=null and image.get_width()==1024 and image.get_height()==1024)
 assert(terrain_material.get_shader_parameter("sand_tex")!=null)
 print("MATERIALS_OK six_cc0_sets textures_present dimensions terrain_binding")

func test_perception():
 var e={"state":"Chase"}
 var known=Vector3(2,0,3)
 senses.observe(e,known,true,null,0.1)
 senses.observe(e,Vector3(50,0,60),false,null,2)
 assert(senses.target(e,Vector3.ZERO)==known and is_equal_approx(e.memory,4.0))
 senses.observe(e,Vector3(50,0,60),false,null,5)
 assert(e.memory==0 and senses.target(e,Vector3.ZERO)==known)
 e.state="Search"
 var noise=Vector3(-4,0,8)
 senses.observe(e,Vector3.ZERO,false,noise,0.1)
 assert(senses.target(e,Vector3.ZERO)==noise and e.stimulus=="noise")
 print("PERCEPTION_OK last_known no_hidden_tracking memory_decay noise_target")

func test_v08_rules():
 for i in range(110): await get_tree().physics_frame
 var state=preload("res://survival_state.gd").new()
 state.tick(120,true,true,false,false)
 assert(state.fatigue>14 and state.wetness>90 and state.stamina_recovery()<12)
 state.food_risk("生肉",0.0); assert(state.poison==90)
 state.rest(true); assert(state.fatigue==0 and state.poison==30)
 state.tick(40,false,false,true,true); assert(state.poison==0 and state.wetness<50)
 inv={"木材":10,"石头":10}; bag=Bag.new(); bag.sync(inv); craft_job={}
 begin_craft("石斧")
 assert(inv["木材"]==7 and inv.get("石斧",0)==0)
 advance_craft(1); assert(inv.get("石斧",0)==0)
 cancel_craft(); assert(inv["木材"]==10 and inv["石头"]==10)
 begin_craft("石斧"); survival.fatigue=76
 save_game(); load_game()
 assert(not craft_job.is_empty() and survival.fatigue==76)
 advance_craft(10); assert(inv.get("石斧",0)==1)
 advance_craft(10); assert(inv.get("石斧",0)==1)
 var old=craft_duration("石斧"); gain_skill("制作",100); assert(craft_duration("石斧")<old)
 inv["生肉"]=1; inv["木材"]=inv.get("木材",0)+1
 for s in structures:
  if s.kind=="篝火": s.fuel=120
 player.position=structures[1].node.position+Vector3.UP
 begin_craft("烤肉")
 assert(not craft_job.is_empty())
 player.position=ground(Vector2(190,190))+Vector3.UP
 var left=craft_job.left; advance_craft(20)
 assert(craft_job.left==left and inv.get("烤肉",0)==0)
 cancel_craft(); assert(inv.get("生肉",0)==1)
 print("V08_TESTS_OK fatigue wetness poison rest craft_reserve refund resume station_pause skills")

func persistence_fixture():
 start_new()
 inv={"木材":13,"石斧":1,"净水":4}; bag.sync(inv)
 bag.move_stack(0,8)
 equipped="石斧"; durability={"石斧":63}; quickbar[0]="石斧"
 player.position=ground(Vector2(-48,83))+Vector3.UP
 health=71; hunger=64; thirst=59; temperature=36.4; clock=14.25; weather=2
 survival.fatigue=45; survival.wetness=28; survival.poison=36
 skill_xp["制作"]=131
 craft_job={"item":"木矛","left":2.25,"cost":{"木材":4,"纤维":2}}
 repairs=["lighthouse"]; story_read=["note-camp"]; map_markers=[[12,-43]]
 removed=["rock0"]
 make_structure("储物箱",ground(Vector2(-43,83)),0)
 entities.back()["stored"]={"金属":7,"布料":3}
 make_structure("门框",ground(Vector2(-39,83)),0)
 entities.back()["opened"]=true; entities.back().node.get_node("Door").rotation.y=-PI/2
 make_structure("集雨器",ground(Vector2(-35,83)),0)
 structures.back().water=2.5
 loot(ground(Vector2(-46,85)),"测试遗失背包",{"罐头":2},"death-persistence")
 enemies[0].hp=0
 save_game(); save_game()
 if save_store.read(SAVE)==null: push_error("PERSIST_WRITE_FAILED"); get_tree().quit(1); return
 print("PERSIST_WRITE_OK"); get_tree().quit()

func persistence_verify():
 load_game()
 var okay=playing and inv.get("木材",0)==13 and inv.get("石斧",0)==1 and equipped=="石斧" and durability.get("石斧",0)==63
 okay=okay and bag.slots[8].get("item","")=="木材" and quickbar[0]=="石斧"
 okay=okay and structures.size()==3 and is_equal_approx(structures.back().water,2.5)
 okay=okay and health==71 and is_equal_approx(clock,14.25) and weather==2
 okay=okay and survival.fatigue==45 and survival.wetness==28 and survival.poison==36
 okay=okay and skill_xp.get("制作",0)==131 and craft_job.get("item","")=="木矛" and craft_job.get("left",0)==2.25
 okay=okay and repairs==["lighthouse"] and story_read==["note-camp"] and map_markers.size()==1
 okay=okay and removed==["rock0"] and enemies[0].hp==0
 okay=okay and player.position.distance_to(ground(Vector2(-48,83))+Vector3.UP)<0.01
 var chest=false; var door=false; var drop=false
 for e in entities:
  if e.title=="储物箱": chest=e.get("stored",{}).get("金属",0)==7
  if e.title=="门框": door=e.get("opened",false) and is_equal_approx(e.node.get_node("Door").rotation.y,-PI/2)
  if e.id=="death-persistence": drop=e.gives.get("罐头",0)==2
 okay=okay and chest and door and drop
 if "--expect-backup" in OS.get_cmdline_user_args(): okay=okay and save_store.last_source.ends_with(".bak")
 if not okay: push_error("PERSIST_READ_FAILED"); get_tree().quit(1); return
 print("PERSIST_READ_OK source=",save_store.last_source)
 get_tree().quit()
