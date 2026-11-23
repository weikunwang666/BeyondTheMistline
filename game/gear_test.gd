extends Node
var game
var driver

func check(value: bool,message: String) -> bool:
 if not value:
  if game.qa_dir!="": game.get_viewport().get_texture().get_image().save_png(game.qa_dir.path_join("gear-failure.png"))
  push_error("GEAR_FAILED "+message); get_tree().quit(1)
 return value

func click(prefix: String) -> bool:
 var control=driver.find_button(game.content,prefix)
 if not check(control!=null and not control.disabled,"button missing/disabled "+prefix): return false
 await driver.frames(10)
 game.content.get_parent().ensure_control_visible(control)
 await driver.frames(8)
 await driver.click(control.get_global_rect().get_center())
 return true

func run():
 await get_tree().physics_frame
 driver=preload("res://journey_test.gd").new(); driver.game=game; add_child(driver)
 game.start_new()
 for enemy in game.enemies:
  enemy.hp=0; enemy.node.hide(); game.set_collisions(enemy.node,true)
 game.inv={"布料":10,"纤维":4,"绳索":3,"金属":6,"木材":1}
 game.inventory()
 if not await click("防雨外套  ·"): return
 await driver.frames(300)
 if not check(game.inv.get("防雨外套",0)==1 and game.inv.get("布料",0)==4,"timed outfit recipe cost/output"): return
 game.inventory()
 for i in range(24):
  if game.bag.slots[i].get("item","")=="防雨外套": game.selected_slot=i
 game.inventory()
 if not await click("装备 / 使用 防雨外套"): return
 if not check(game.gear.worn=="防雨外套" and is_instance_valid(game.outfit_visual),"coat equipment/visual"): return
 game.close_panel(); game.weather=2; game.climate.snap(2); game.weather_time=0; game.temperature=36; game.survival.wetness=0
 await driver.frames(120)
 var coated_wet=game.survival.wetness; var coated_temp=game.temperature
 game.use_item("防雨外套"); game.temperature=36; game.survival.wetness=0
 await driver.frames(120)
 if not check(abs(game.survival.wetness-coated_wet*4)<0.1 and coated_temp>36 and game.temperature<36,"actual rain and temperature did not respond to coat"): return
 game.use_item("木材")
 game.consume("零件")
 if not check(game.inv.get("木材",0)==1,"quickbar consumed non-consumable material"): return
 game.make_structure("工作台",game.player.position+Vector3(2,0,0),0)
 game.inventory()
 if not await click("加固背心  ·"): return
 await driver.frames(300)
 if not check(game.inv.get("加固背心",0)==1 and game.inv.get("布料",0)==0 and game.inv.get("金属",0)==0,"vest recipe cost/output inv=%s job=%s panel=%s station=%s"%[game.inv,game.craft_job,game.panel_open,game.near_structure("工作台")]): return
 game.use_item("加固背心")
 var crab=game.enemies[0]
 crab.hp=100; crab.node.show(); game.set_collisions(crab.node,false)
 crab.node.position=game.player.position+Vector3(0,0,-1.4)
 crab.state="Attack"; crab["windup"]=0.01; crab.cooldown=0
 game.health=100
 await driver.frames(3)
 if not check(abs(game.health-86.5)<0.2,"vest did not reduce actual crab damage: "+str(game.health)): return
 crab.hp=0; crab.node.hide(); game.set_collisions(crab.node,true)
 game.save_game()
 var data=game.save_store.read(game.SAVE)
 if not check(data!=null and data.outfit=="加固背心","outfit save"): return
 var old=data.duplicate(true); old.erase("outfit")
 if not check(game.save_store.valid(old),"old saves without outfit rejected"): return
 var bad=data.duplicate(true); bad.outfit="unknown"
 if not check(not game.save_store.valid(bad),"invalid outfit accepted"): return
 var unique={}
 for item in game.ITEMS:
  var icon=game.catalog.icon(item)
  if not check(icon!=null and game.catalog.DETAILS.has(item),"missing icon/details "+item): return
  unique[hash(icon.get_image().get_data())]=true
 if not check(unique.size()==game.ITEMS.size(),"item icons not distinct"): return
 for item in game.ITEMS: game.inv[item]=1
 game.inventory(); game.selected_slot=0; game.inventory()
 game.content.get_parent().scroll_vertical=0
 await driver.frames(12)
 var grid=game.content.find_child("BagGrid",true,false)
 var visible_rect=game.content.get_parent().get_global_rect()
 if not check(visible_rect.encloses(grid.get_global_rect()),"inventory grid clipped"): return
 if game.qa_dir!="": game.get_viewport().get_texture().get_image().save_png(game.qa_dir.path_join("inventory-equipment.png"))
 print("GEAR_OK UI_craft costs equip actual_rain temperature enemy_protection non_consumable_guard schema icons grid_layout")
 get_tree().quit()
