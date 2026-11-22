extends Node
var game
var driver

func check(value: bool,message: String) -> bool:
 if not value:
  print("QUEST_DIAGNOSTIC title=",game.content.get_child(0).text," inventory=",game.inv," states=",game.quests.states)
  if game.qa_dir!="": game.get_viewport().get_texture().get_image().save_png(game.qa_dir.path_join("quest-failure.png"))
  push_error("QUEST_FAILED "+message); get_tree().quit(1)
 return value

func press(prefix: String):
 var button=driver.find_button(game.content,prefix)
 if not check(button!=null and not button.disabled,"button unavailable: "+prefix): return
 game.content.get_parent().ensure_control_visible(button)
 await driver.frames(10)
 await driver.click(button.get_global_rect().get_center())

func run():
 game.start_new()
 driver=preload("res://journey_test.gd").new(); driver.game=game; add_child(driver)
 var empty={}; var log=preload("res://quest_log.gd").new(); log.start("aid")
 if not check(not log.complete("aid",empty) and log.states.aid==1 and empty.is_empty(),"missing materials mutated quest"): return
 game.inv={"急救箱":1}; game.bag.sync(game.inv)
 await driver.frames(15)
 for e in game.entities:
  if e.id=="npc": game.target=e; break
 game.interact(); await driver.frames(3)
 await press("药箱援助")
 await press("交付 / 完成维修")
 if not check(game.quests.states.aid==2 and game.inv.get("急救箱",0)==0 and game.inv.get("净水",0)==2,"aid delivery failed"): return
 if not check(not game.quests.complete("aid",game.inv) and game.inv.get("净水",0)==2,"aid duplicate reward"): return
 game.inv["金属"]=3; game.inv["滤芯"]=1
 game.pump_panel(); await driver.frames(3)
 await press("维修过滤装置"); await press("交付 / 完成维修")
 if not check(game.quests.states.pump==2 and game.pump_stock==3 and game.inv.get("金属",0)==0,"pump repair failed"): return
 game.update_world(1000)
 if not check(game.pump_stock==5,"pump capacity did not clamp"): return
 var before=game.inv.get("净水",0)
 game.pump_panel(); await driver.frames(3); await press("领取净水")
 if not check(game.pump_stock==0 and game.inv.get("净水",0)==before+5,"pump collection failed"): return
 var collect=driver.find_button(game.content,"领取净水")
 if not check(collect.disabled,"empty pump enabled repeated collection"): return
 game.inv["电池"]=1; game.inv["零件"]=2
 for e in game.entities:
  if e.id=="camp-radio": game.target=e; break
 game.interact(); await driver.frames(3); await press("交付 / 完成维修")
 if not check(game.quests.states.radio==2 and game.inv.get("箭",0)==8 and game.inv.get("绷带",0)==2,"radio reward failed"): return
 game.save_game(); game.load_game()
 if not check(game.quests.states.aid==2 and game.quests.states.pump==2 and game.quests.states.radio==2 and game.pump_stock==0,"quest progress did not reload"): return
 game.journal(); await driver.frames(4)
 if game.qa_dir!="": game.get_viewport().get_texture().get_image().save_png(game.qa_dir.path_join("quests-journal.png"))
 print("QUEST_OK UI_delivery cost rewards_once pump_capacity collection radio save_load")
 get_tree().quit()
