extends Node

var layers={}
var effects={}
var master=0.5
var rng=RandomNumberGenerator.new()

func _ready():
 rng.seed=9861
 for kind in ["wind","sea","rain","forest"]:
  var player=AudioStreamPlayer.new()
  player.stream=generate(kind,12.0,true)
  player.volume_db=-70
  add_child(player); player.play(); layers[kind]=player
 for kind in ["sand","grass","wood","water","metal","chop","stone","pickup","hit"]:
  effects[kind]=generate(kind,0.28,false)

func generate(kind: String,duration: float,looping: bool) -> AudioStreamWAV:
 var rate=22050; var count=int(rate*duration)
 var data=PackedByteArray(); data.resize(count*2)
 var low=0.0; var previous=0.0
 for i in range(count):
  var t=float(i)/rate; var white=rng.randf_range(-1,1)
  low=lerp(low,white,0.06)
  var sample=0.0
  match kind:
   "wind": sample=low*(0.3+0.2*sin(TAU*t/12))*0.7
   "sea": sample=(low*0.7+white*0.06)*(0.5+0.5*sin(TAU*t/6-PI/2))*0.65
   "rain": sample=(white-previous*0.3)*0.11
   "forest":
    var phase=fmod(t,3.0)
    if phase>1.4 and phase<1.7:
     var envelope=sin((phase-1.4)/0.3*PI)
     sample=sin(TAU*(2300*t+60*sin(t*34)))*envelope*0.08
    sample+=low*0.07
   _:
    var envelope=pow(max(0.0,1.0-t/duration),3)
    match kind:
     "sand": sample=white*0.18*envelope
     "grass": sample=(white*0.12+low*0.8)*envelope
     "water": sample=(white*0.18+sin(t*TAU*(220-t*300))*0.2)*envelope
     "wood": sample=(sin(t*TAU*140)+sin(t*TAU*310)*0.3+white*0.2)*0.28*envelope
     "metal","stone": sample=(sin(t*TAU*640)+sin(t*TAU*1037)*0.4+white*0.2)*0.19*envelope
     "chop": sample=(white*0.8+sin(t*TAU*100)*0.6)*0.3*envelope
     "hit": sample=(white*0.6+sin(t*TAU*70))*0.27*envelope
     _: sample=sin(t*TAU*(540+t*500))*0.18*envelope
  # Fade ambient loop boundaries to avoid a discontinuity click.
  if looping: sample*=min(1.0,min(t,duration-t)*15)
  previous=white
  data.encode_s16(i*2,int(clamp(sample,-1,1)*32760))
 var stream=AudioStreamWAV.new()
 stream.format=AudioStreamWAV.FORMAT_16_BITS; stream.mix_rate=rate
 stream.data=data
 if looping:
  stream.loop_mode=AudioStreamWAV.LOOP_FORWARD; stream.loop_begin=0; stream.loop_end=count
 return stream

func update_mix(position: Vector3,weather: int,night: bool,dt: float,rain_amount: float=-1,wind_amount: float=-1):
 var coast=clamp((-position.x-15)/90.0,0,1)
 var forest=clamp(1.0-abs(position.x-25)/70.0,0,1)
 var levels={"wind":0.6 if weather==3 else 0.28,"sea":coast*0.9,"rain":0.75 if weather==3 else (0.4 if weather==2 else 0.0),"forest":forest*(0.3 if night else 0.8)}
 if rain_amount>=0:
  levels.rain=rain_amount*0.75
  levels.forest*=1-rain_amount*0.7
 if wind_amount>=0:
  levels.wind=0.18+wind_amount*0.21
  levels.sea=min(1.0,levels.sea*(1+wind_amount*0.1))
 for kind in layers:
  layers[kind].stream_paused=master<=0
  var linear=float(levels[kind])*master
  var desired=linear_to_db(linear) if linear>0.001 else -70.0
  layers[kind].volume_db=lerp(layers[kind].volume_db,desired,min(1.0,dt*0.7))

func play_at(kind: String,position: Vector3):
 if master<=0 or not effects.has(kind): return
 var sound=AudioStreamPlayer3D.new()
 sound.stream=effects[kind]; sound.position=position
 sound.volume_db=linear_to_db(max(0.001,master)); sound.max_distance=28
 sound.unit_size=4; sound.pitch_scale=rng.randf_range(0.92,1.08)
 get_parent().add_child(sound)
 sound.finished.connect(sound.queue_free); sound.play()
