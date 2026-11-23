extends RefCounted
var fatigue=0.0
var poison=0.0
var wetness=0.0

func tick(dt: float,sprinting: bool,raining: bool,shelter: bool,warm: bool,rain_exposure: float=1.0):
 fatigue=clamp(fatigue+dt*(0.12 if sprinting else 0.035),0,100)
 poison=max(0,poison-dt)
 wetness=move_toward(wetness,100 if raining and not shelter else 0,dt*(0.8*rain_exposure if raining and not shelter else (1.5 if warm else 0.08)))

func stamina_recovery() -> float:
 return 12.0*(1.0-fatigue*0.006)*(0.55 if poison>0 else 1.0)

func food_risk(item: String,roll: float):
 if (item=="生肉" and roll<0.3) or (item=="河水" and roll<0.4): poison=max(poison,90)

func rest(sheltered: bool):
 fatigue=max(0,fatigue-(85 if sheltered else 45))
 poison=max(0,poison-60)

func serialize() -> Dictionary:
 return {"fatigue":fatigue,"poison":poison,"wetness":wetness}

func restore(data: Dictionary):
 fatigue=clamp(data.get("fatigue",0.0),0,100)
 poison=clamp(data.get("poison",0.0),0,300)
 wetness=clamp(data.get("wetness",0.0),0,100)
