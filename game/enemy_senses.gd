extends RefCounted

func observe(enemy: Dictionary,player_position: Vector3,seen: bool,heard,dt: float):
 enemy["memory"]=max(0.0,float(enemy.get("memory",0.0))-dt)
 if seen:
  enemy["last_known"]=player_position
  enemy["memory"]=6.0
  enemy["stimulus"]="player"
 elif heard is Vector3 and (enemy.state in ["Idle","Patrol","Search","Alert"] or enemy.memory<=0):
  enemy["last_known"]=heard
  enemy["memory"]=4.0
  enemy["stimulus"]="noise"

func target(enemy: Dictionary,home: Vector3) -> Vector3:
 return enemy.get("last_known",home)
