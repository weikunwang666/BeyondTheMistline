extends RefCounted

var last_source=""
var last_error=""

func number(value) -> bool:
 return (value is int or value is float) and is_finite(float(value))

func vector(value) -> bool:
 return value is Array and value.size()==3 and number(value[0]) and number(value[1]) and number(value[2])

func counts(value) -> bool:
 if not value is Dictionary: return false
 for key in value:
  if not key is String or not number(value[key]) or value[key]<0 or value[key]>1000000: return false
 return true

func valid(data) -> bool:
 if not data is Dictionary or data.get("v",0)!=1 or not vector(data.get("position")): return false
 if not counts(data.get("inv")): return false
 for key in ["health","hunger","thirst","temperature","clock","weather"]:
  if not number(data.get(key)): return false
 for key in ["removed","repairs","discovered"]:
  if not data.get(key) is Array: return false
  for value in data[key]:
   if not value is String: return false
 if not data.get("built") is Array: return false
 for entry in data.built:
  if not entry is Dictionary or not entry.get("kind") in ["篝火","睡袋","工作台","储物箱","地基","墙","门框","屋顶","集雨器","楼梯"]: return false
  if not vector(entry.get("pos")) or not number(entry.get("angle")): return false
  for key in ["fuel","water"]:
   if entry.has(key) and not number(entry[key]): return false
 for key in ["stored","doors","durability","overflow","explored","survival","skill_xp","craft_job","milestones","quests"]:
  if data.has(key) and not data[key] is Dictionary: return false
 for entry in data.get("stored",{}).values():
  if not counts(entry): return false
 if not counts(data.get("durability",{})) or not counts(data.get("overflow",{})): return false
 if not counts(data.get("survival",{})) or not counts(data.get("skill_xp",{})): return false
 if not counts(data.get("quests",{})): return false
 for key in ["pump_stock","pump_cooldown"]:
  if data.has(key) and (not number(data[key]) or data[key]<0): return false
 if data.has("survivors"):
  if not data.survivors is Array or data.survivors.size()>8: return false
  for npc in data.survivors:
   if not npc is Dictionary or not vector(npc.get("position")): return false
 if data.has("climate") and not counts(data.climate): return false
 if data.has("resource_hits") and not counts(data.resource_hits): return false
 if data.has("weather_time") and (not number(data.weather_time) or data.weather_time<0 or data.weather_time>100): return false
 var job=data.get("craft_job",{})
 if not job.is_empty():
  if not job.get("item") in ["防雨外套","加固背心","石斧","木矛","绷带","火把","绳索","箭","弓","滤芯","净水","烤肉","工具包","电池"]: return false
  if not number(job.get("left")) or job.left<0 or not counts(job.get("cost")): return false
 for key in ["drops","enemies","story_read","map_markers"]:
  if data.has(key) and not data[key] is Array: return false
 for note in data.get("story_read",[]):
  if not note is String: return false
 for value in data.get("doors",{}).values():
  if not value is bool: return false
 for entry in data.get("drops",[]):
  if not entry is Dictionary or not vector(entry.get("pos")) or not counts(entry.get("gives")) or not entry.get("id") is String or not entry.get("title") is String: return false
 for entry in data.get("enemies",[]):
  if not entry is Dictionary or not vector(entry.get("pos")) or not number(entry.get("hp")): return false
 for marker in data.get("map_markers",[]):
  if not marker is Array or marker.size()!=2 or not number(marker[0]) or not number(marker[1]): return false
 if data.has("quickbar"):
  if not data.quickbar is Array or data.quickbar.size()!=8: return false
  for item in data.quickbar:
   if not item is String: return false
 if data.has("equipped") and not data.equipped is String: return false
 if data.has("outfit") and (not data.outfit is String or not data.outfit in ["","防雨外套","加固背心"]): return false
 if data.has("bag_slots"):
  if not data.bag_slots is Array or data.bag_slots.size()!=24: return false
  for slot in data.bag_slots:
   if not slot is Dictionary: return false
   if not slot.is_empty() and (not slot.get("item") is String or not number(slot.get("count")) or slot.count<=0): return false
   if not slot.is_empty():
    var cap=1 if slot.item in ["石斧","木矛","弓","火把","防雨外套","加固背心"] else 20
    if slot.count>cap: return false
 return true

func read_one(path: String):
 var file=FileAccess.open(path,FileAccess.READ)
 if file==null: return null
 var parsed=JSON.new()
 if parsed.parse(file.get_as_text())!=OK: return null
 return parsed.data if valid(parsed.data) else null

func read(path: String):
 last_source=""; last_error=""
 for candidate in [path,path+".bak"]:
  var data=read_one(candidate)
  if data!=null: last_source=candidate; return data
 last_error="存档及备用存档均无法读取。原文件已保留。"
 return null

func write(path: String,data: Dictionary) -> bool:
 last_error=""
 if not valid(data): last_error="存档数据校验失败，未覆盖已有进度。"; return false
 var file=FileAccess.open(path+".tmp",FileAccess.WRITE)
 if file==null: last_error="无法写入临时存档。"; return false
 file.store_string(JSON.stringify(data)); file.flush()
 var result=file.get_error(); file.close()
 if result!=OK or read_one(path+".tmp")==null: last_error="临时存档校验失败。"; return false
 if read_one(path)!=null:
  if DirAccess.copy_absolute(path,path+".bak")!=OK: last_error="无法保留备用存档，未覆盖进度。"; return false
 if DirAccess.rename_absolute(path+".tmp",path)!=OK: last_error="无法替换存档。"; return false
 return true
