extends Button

var index = 0
var item = ""
var source_kind = "bag"
var receiver: Callable

func _get_drag_data(_pos):
 if item=="": return null
 var preview = Label.new()
 preview.text=item
 set_drag_preview(preview)
 return {"index":index,"item":item,"kind":source_kind}

func _can_drop_data(_pos,data):
 return data is Dictionary and data.get("kind","")=="bag" and (source_kind=="quick" or source_kind=="bag")

func _drop_data(_pos,data):
 receiver.call(data,index,source_kind)
