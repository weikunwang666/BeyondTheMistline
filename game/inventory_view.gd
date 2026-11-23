extends RefCounted

const Slot=preload("res://bag_slot.gd")

func label(parent: Node,text: String,width: float,size: int=16):
 var control=Label.new(); control.text=text
 control.custom_minimum_size.x=width
 control.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 control.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 control.add_theme_font_size_override("font_size",size)
 parent.add_child(control)
 return control

func action(parent: Node,title: String,callback: Callable,enabled: bool=true):
 var control=Button.new(); control.text=title; control.disabled=not enabled
 control.custom_minimum_size.y=40; control.clip_text=true; control.tooltip_text=title
 control.pressed.connect(callback); parent.add_child(control)
 return control

func draw(game):
 game.panel.position=Vector2(70,30); game.panel.size=Vector2(1140,660)
 game.content.get_parent().custom_minimum_size=Vector2(1080,600)
 game.text_line("负重 %.1f / 30 kg · 拖拽交换 / 合并 · 右键拆分 · 拖至快捷栏分配"%game.weight(),16)
 var row=HBoxContainer.new(); row.add_theme_constant_override("separation",18)
 game.content.add_child(row)
 var equipment=VBoxContainer.new(); equipment.custom_minimum_size.x=170; row.add_child(equipment)
 label(equipment,"出发准备",170,20)
 label(equipment,"手持工具",170,14)
 label(equipment,game.equipped if game.equipped!="" else "徒手",170,18)
 if game.equipped!="":
  label(equipment,"耐久 %d / 100"%game.durability.get(game.equipped,100),170,14)
  action(equipment,"收起手持工具",func(): game.use_item(game.equipped); game.inventory())
 label(equipment,"上身装备",170,14)
 var portrait=TextureRect.new(); portrait.name="OutfitIcon"
 portrait.texture=game.catalog.icon(game.gear.worn if game.gear.worn!="" else "防雨外套")
 portrait.custom_minimum_size=Vector2(64,64); portrait.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 portrait.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 portrait.modulate.a=0.35 if game.gear.worn=="" else 1.0
 equipment.add_child(portrait)
 label(equipment,game.gear.worn if game.gear.worn!="" else "未穿戴",170,18)
 if game.gear.worn!="": action(equipment,"脱下上身装备",func(): game.use_item(game.gear.worn); game.inventory())
 label(equipment,"保暖 +%.2f℃\n淋雨速度 %d%%\n敌人伤害 %d%%"%[game.gear.insulation(),game.gear.rain_exposure()*100,game.gear.damage_multiplier()*100],170,14)
 var center=VBoxContainer.new(); row.add_child(center)
 label(center,"行囊 · 24格",548,20)
 var grid=GridContainer.new(); grid.name="BagGrid"; grid.columns=6
 grid.add_theme_constant_override("h_separation",4); grid.add_theme_constant_override("v_separation",4)
 center.add_child(grid)
 for i in range(24):
  var slot=Slot.new(); var data=game.bag.slots[i]
  slot.index=i; slot.item=data.get("item",""); slot.receiver=game.drop_slot
  slot.text="—" if data.is_empty() else data.item+"\n×"+str(data.count)
  slot.custom_minimum_size=Vector2(88,68)
  slot.add_theme_font_size_override("font_size",13)
  if not data.is_empty():
   slot.icon=game.catalog.icon(data.item); slot.expand_icon=true
   slot.add_theme_constant_override("icon_max_width",22)
   slot.tooltip_text=data.item+"\n"+game.catalog.description(data.item)
  var style=StyleBoxFlat.new()
  style.bg_color=Color("334a48") if i==game.selected_slot else Color("17292d")
  style.border_color=Color("b5a47e") if not data.is_empty() else Color("365054")
  style.set_border_width_all(1); style.set_corner_radius_all(4)
  slot.add_theme_stylebox_override("normal",style)
  var index=i
  slot.pressed.connect(func(): game.selected_slot=index; game.inventory())
  slot.gui_input.connect(func(event):
   if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_RIGHT:
    game.bag.split(index); game.inventory())
  grid.add_child(slot)
 var details=VBoxContainer.new(); details.custom_minimum_size.x=250; row.add_child(details)
 label(details,"物品详情",250,20)
 if game.selected_slot<0 or game.bag.slots[game.selected_slot].is_empty():
  label(details,"选择物品查看用途、效果和来源。\n\n上身只能装备一件衣物。装备仍占用背包格，丢弃后会自动卸下。",250)
  return
 var item=game.bag.slots[game.selected_slot].item
 label(details,item,250,22)
 label(details,game.catalog.category(item)+" · 单件 %.2f kg"%game.ITEMS.get(item,0.2),250,14)
 label(details,game.catalog.description(item),250)
 var verb="脱下 " if game.gear.worn==item else ("收起 " if game.equipped==item else "装备 / 使用 ")
 action(details,verb+item,func(): game.use_item(item); game.inventory(),game.catalog.usable(item))
 action(details,"丢弃所选堆叠",func():
  var stack=game.bag.slots[game.selected_slot].duplicate()
  game.bag.slots[game.selected_slot]={}; game.inv=game.bag.totals()
  var old=game.gear.worn; game.gear.reconcile(game.inv)
  if old!=game.gear.worn: game.update_outfit()
  if game.equipped!="" and game.inv.get(game.equipped,0)<=0: game.equipped=""; game.update_held_tool()
  game.loot(game.player.position+Vector3(1,0,0),"丢下的物品",{stack.item:stack.count},"death-drop-"+str(Time.get_ticks_usec()))
  game.inventory())
