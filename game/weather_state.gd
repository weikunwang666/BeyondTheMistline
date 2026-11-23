extends RefCounted

# Preserve the original four save indices; append the new weather types.
const PRESETS=[
 {"name":"晴天","rain":0.0,"wind":0.4,"cloud":0.0,"fog":0.0035,"temperature":37.0},
 {"name":"浓雾","rain":0.0,"wind":0.25,"cloud":0.65,"fog":0.012,"temperature":36.5},
 {"name":"小雨","rain":0.35,"wind":0.7,"cloud":0.6,"fog":0.007,"temperature":35.5},
 {"name":"暴风雨","rain":1.0,"wind":2.0,"cloud":1.0,"fog":0.018,"temperature":35.0},
 {"name":"多云","rain":0.0,"wind":0.8,"cloud":0.5,"fog":0.005,"temperature":36.5},
 {"name":"大雨","rain":0.75,"wind":1.3,"cloud":0.85,"fog":0.011,"temperature":35.2}
]
const ORDER=[0,4,2,5,3,1]
var rain=0.0
var wind=0.4
var cloud=0.0
var fog=0.0035

func preset(kind: int) -> Dictionary:
 return PRESETS[clampi(kind,0,5)]

func raining(kind: int) -> bool:
 return preset(kind).rain>0

func next(kind: int) -> int:
 return ORDER[(ORDER.find(kind)+1)%ORDER.size()]

func tick(dt: float,kind: int):
 var target=preset(kind)
 rain=move_toward(rain,target.rain,dt*0.08)
 wind=move_toward(wind,target.wind,dt*0.15)
 cloud=move_toward(cloud,target.cloud,dt*0.08)
 fog=move_toward(fog,target.fog,dt*0.0015)

func snap(kind: int):
 var target=preset(kind)
 rain=target.rain; wind=target.wind; cloud=target.cloud; fog=target.fog

func serialize() -> Dictionary:
 return {"rain":rain,"wind":wind,"cloud":cloud,"fog":fog}

func restore(data: Dictionary,kind: int):
 snap(kind)
 rain=clamp(data.get("rain",rain),0,1)
 wind=clamp(data.get("wind",wind),0,2)
 cloud=clamp(data.get("cloud",cloud),0,1)
 fog=clamp(data.get("fog",fog),0.001,0.03)
