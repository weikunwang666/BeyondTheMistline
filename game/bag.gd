extends RefCounted

const SIZE = 24
const TOOLS = ["石斧","木矛","弓","火把"]
var slots = []
var overflow = {}

func _init():
 for i in range(SIZE): slots.append({})

func limit(item: String) -> int:
 return 1 if item in TOOLS else 20

func totals() -> Dictionary:
 var result = {}
 for s in slots:
  if not s.is_empty(): result[s.item]=result.get(s.item,0)+int(s.count)
 return result

# Preserve the player's arrangement while reconciling gameplay transactions.
func sync(amounts: Dictionary):
 var remaining = amounts.duplicate()
 for i in range(SIZE):
  var s = slots[i]
  if s.is_empty(): continue
  var count = mini(int(remaining.get(s.item,0)),int(s.count))
  remaining[s.item]=int(remaining.get(s.item,0))-count
  if count>0: s.count=count
  else: slots[i]={}
 for item in remaining:
  var count = int(remaining[item])
  for s in slots:
   if count<=0: break
   if not s.is_empty() and s.item==item:
    var take = mini(limit(item)-int(s.count),count)
    s.count+=take; count-=take
  for i in range(SIZE):
   if count<=0: break
   if slots[i].is_empty():
    var take = mini(limit(item),count)
    slots[i]={"item":item,"count":take}; count-=take
  if count>0: overflow[item]=overflow.get(item,0)+count
 var actual = totals()
 amounts.clear()
 amounts.merge(actual)

func move_stack(source: int,destination: int) -> bool:
 if source<0 or source>=SIZE or destination<0 or destination>=SIZE or source==destination: return false
 var a = slots[source]; var b = slots[destination]
 if a.is_empty(): return false
 if not b.is_empty() and a.item==b.item:
  var take = mini(limit(a.item)-int(b.count),int(a.count))
  if take==0: return false
  b.count+=take; a.count-=take
  if a.count==0: slots[source]={}
 else:
  slots[source]=b; slots[destination]=a
 return true

func split(source: int) -> bool:
 if source<0 or source>=SIZE or slots[source].is_empty() or slots[source].count<2: return false
 for i in range(SIZE):
  if slots[i].is_empty():
   var take = int(slots[source].count)/2
   slots[source].count-=take
   slots[i]={"item":slots[source].item,"count":take}
   return true
 return false
