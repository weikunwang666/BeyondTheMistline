extends Node
var game
var scenes=[
 {"name":"coast","point":Vector2(-65,72),"hour":8.0,"weather":0},
 {"name":"forest","point":Vector2(38,82),"hour":12.0,"weather":0},
 {"name":"wetland_rain","point":Vector2(-55,-57),"hour":12.0,"weather":3},
 {"name":"industry","point":Vector2(100,-6),"hour":12.0,"weather":0},
 {"name":"warehouse_interior","point":Vector2(72,16),"hour":12.0,"weather":0},
 {"name":"highlands","point":Vector2(20,-132),"hour":12.0,"weather":1},
 {"name":"night_camp","point":Vector2(-65,76),"hour":22.0,"weather":0}]
var index=-1
var start=0
var times=[]
var rows=[]
var cpu_samples=[]
var physics_samples=[]
var last_frame=0

func _ready():
 game.start_new()
 DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
 DisplayServer.window_set_size(Vector2i(1920,1080))
 game.get_window().content_scale_mode=Window.CONTENT_SCALE_MODE_VIEWPORT
 game.get_window().content_scale_size=Vector2i(1920,1080)
 DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 await get_tree().process_frame
 await get_tree().process_frame
 var rendered=game.get_viewport().get_texture()
 if rendered.get_width()!=1920 or rendered.get_height()!=1080:
  push_error("BENCHMARK_RENDER_SIZE_FAILED %dx%d"%[rendered.get_width(),rendered.get_height()])
  get_tree().quit(1); return
 game.make_structure("篝火",game.ground(Vector2(-62,74)),0)
 next_scene()

func next_scene():
 index+=1
 if index>=scenes.size():
  var texture=game.get_viewport().get_texture()
  var report={"requested_resolution":[1920,1080],"window_size":[DisplayServer.window_get_size().x,DisplayServer.window_get_size().y],"render_texture":[texture.get_width(),texture.get_height()],"logical_ui_size":[game.get_viewport().get_visible_rect().size.x,game.get_viewport().get_visible_rect().size.y],"vsync":false,"seconds_per_scene":10,"warmup_seconds":2,"gpu":RenderingServer.get_video_adapter_name(),"scenes":rows}
  var output=FileAccess.open(game.qa_dir.path_join("benchmark.json"),FileAccess.WRITE)
  output.store_string(JSON.stringify(report,"  "))
  print("BENCHMARK_OK ",JSON.stringify(report))
  get_tree().quit(); return
 var scene=scenes[index]
 game.player.position=game.ground(scene.point)+Vector3.UP
 game.player.velocity=Vector3.ZERO; game.previous_fall_speed=0
 game.clock=scene.hour; game.weather=scene.weather; game.yaw=0; game.weather_time=0
 game.health=100; game.death_time=0
 times=[]; cpu_samples=[]; physics_samples=[]; start=Time.get_ticks_usec(); last_frame=start

func _process(dt):
 if index<0 or index>=scenes.size(): return
 var now=Time.get_ticks_usec()
 var frame_seconds=float(now-last_frame)/1000000
 last_frame=now
 var elapsed=float(now-start)/1000000
 game.yaw=sin(elapsed*0.18)*0.6
 if elapsed>=2:
  times.append(frame_seconds)
  cpu_samples.append(Performance.get_monitor(Performance.TIME_PROCESS))
  physics_samples.append(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS))
 if elapsed>=10:
  times.sort()
  var total=0.0
  for value in times: total+=value
  var row={"scene":scenes[index].name,"samples":times.size(),"mean_fps":times.size()/total,"p95_ms":times[int(times.size()*0.95)]*1000,"max_ms":times.back()*1000,"process_ms":average(cpu_samples)*1000,"physics_ms":average(physics_samples)*1000,"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"objects":Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME),"health":game.health,"position":[game.player.position.x,game.player.position.y,game.player.position.z]}
  rows.append(row); print("BENCHMARK_SCENE ",JSON.stringify(row))
  next_scene()

func average(values: Array) -> float:
 var sum=0.0
 for value in values: sum+=value
 return sum/max(1,values.size())
