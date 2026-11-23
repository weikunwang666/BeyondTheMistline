extends Control
var game
var elapsed=0.0
var region="沉没海岸"
var objective: Label
var location: Label
var condition: Label

func line(rect: Rect2,font_size: int) -> Label:
 var label=Label.new(); label.position=rect.position; label.size=rect.size
 label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 label.add_theme_font_size_override("font_size",font_size)
 label.add_theme_color_override("font_color",Color("e0e8df"))
 label.mouse_filter=Control.MOUSE_FILTER_IGNORE; add_child(label)
 return label

func _ready():
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 objective=line(Rect2(42,38,340,94),16)
 location=line(Rect2(962,38,280,90),16)
 condition=line(Rect2(42,458,300,42),15)

func _process(dt):
 visible=game.playing and not game.panel_open
 game.quick_hud.visible=visible; game.prompt.visible=visible; game.notices.visible=visible
 if not visible: return
 elapsed+=dt
 if elapsed<0.12: return
 elapsed=0
 objective.text="寻找最后的信号 · %d/3\n%s"%[game.repairs.size(),game.onboarding_goal()]
 location.text="%s\n%02d:%02d  ·  %s\n潮位 %+.2fm · %s"%[region,int(game.clock),int(fmod(game.clock,1)*60),game.climate.preset(game.weather).name,game.sea.position.y,"低潮可通行" if game.sea.position.y< -0.25 else "浅滩淹没"]
 condition.text="体温 %.1f℃  ·  疲劳 %d  ·  淋湿 %d%%\n%s"%[game.temperature,game.survival.fatigue,game.survival.wetness,"中毒：%.0f秒"%game.survival.poison if game.survival.poison>0 else "Tab 行囊   J 任务   M 地图   C 状态"]
 if not game.craft_job.is_empty(): condition.text="制作 %s · %.1f秒\n%s"%[game.craft_job.item,game.craft_job.left,"请返回制作设施附近" if not game.craft_station(game.craft_job.item) else "保持在设施附近，Tab可取消"]
 queue_redraw()

func plate(rect: Rect2):
 var style=StyleBoxFlat.new(); style.bg_color=Color(0.035,0.075,0.08,0.84)
 style.border_color=Color("53675e"); style.set_border_width_all(1); style.set_corner_radius_all(6)
 draw_style_box(style,rect)

func _draw():
 plate(Rect2(24,24,376,118)); plate(Rect2(944,24,312,112))
 if game.notices.text!="": plate(Rect2(24,150,376,max(36,game.notices.size.y+16)))
 plate(Rect2(24,446,320,174)); plate(Rect2(210,648,850,64))
 var names=["生命","饱食","饮水","体力"]
 var values=[game.health,game.hunger,game.thirst,game.stamina]
 var colors=[Color("c17b69"),Color("bba06d"),Color("75a6ad"),Color("a6b985")]
 for i in range(4):
  var y=520+i*24
  draw_string(game.ui_font,Vector2(42,y),names[i],HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("dbe5dc"))
  draw_rect(Rect2(94,y-11,180,7),Color("273b3c"))
  draw_rect(Rect2(94,y-11,180*clamp(float(values[i])/100,0,1),7),colors[i])
  draw_string(game.ui_font,Vector2(286,y),str(int(values[i])),HORIZONTAL_ALIGNMENT_LEFT,-1,14,colors[i])
 draw_circle(Vector2(640,360),2,Color(0.9,0.95,0.9,0.75))
