extends RefCounted

const DEFINITIONS={
 "aid":{"title":"守岸人的药箱","description":"伊莱的补给已经用尽。到东侧废弃仓库内部寻找急救箱，带回渔村交给他。","cost":{"急救箱":1},"reward":{"布料":4,"净水":2},"target":Vector2(72,16)},
 "pump":{"title":"重新流动的淡水","description":"泵站旧滤芯已失效。携带金属3与滤芯1修复过滤装置；修复后可缓慢积存安全饮水。维修记录可能留下可用滤芯。","cost":{"金属":3,"滤芯":1},"reward":{"净水":2},"target":Vector2(26,-65)},
 "radio":{"title":"林间最后的呼叫","description":"森林营地电台仍在发出断续噪声。用电池1与零件2恢复供电，读取最后一段求救记录。电池需要工作台制作。","cost":{"电池":1,"零件":2},"reward":{"箭":8,"绷带":2},"target":Vector2(38,70)}}
var states={"aid":0,"pump":0,"radio":0}

func start(id: String):
 if states.get(id,0)==0: states[id]=1

func complete(id: String,inventory: Dictionary) -> bool:
 if states.get(id,0)!=1 or not DEFINITIONS.has(id): return false
 var data=DEFINITIONS[id]
 for key in data.cost:
  if inventory.get(key,0)<data.cost[key]: return false
 for key in data.cost: inventory[key]-=data.cost[key]
 for key in data.reward: inventory[key]=inventory.get(key,0)+data.reward[key]
 states[id]=2
 return true

func restore(data: Dictionary):
 for id in states:
  if data.get(id) is int or data.get(id) is float: states[id]=clampi(int(data[id]),0,2)
