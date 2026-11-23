extends RefCounted

const CONSUMABLES=["野果","净水","绷带","罐头","烤肉","河水","生肉"]
const DETAILS={
 "木材":["材料","建造与制作的主要木料，也用于烹饪和给篝火添柴。"],
 "石头":["材料","制作石斧、箭和滤芯；G投掷一块石头，用落点声响引开未发现你的敌人。"],
 "纤维":["材料","制作绳索、木矛、火把、滤芯和雨具。采集灌木或芦苇获得。"],
 "金属":["材料","制造工具包、电池、工作台和加固背心。可在仓库和工业区搜索。"],
 "布料":["材料","制作绷带、睡袋和衣物。远行前在医疗用品与保暖装备间分配材料。"],
 "零件":["维修","修复设施与制作电池。是主线和支线的维修材料，不能直接使用。"],
 "绳索":["材料","由纤维制成，用来制作弓和衣物。"],
 "野果":["食物","食用恢复10饱食度。适合早期补充，不能代替饮水。"],
 "罐头":["食物","食用恢复35饱食度。无需烹饪的远行食品。"],
 "生肉":["食物","恢复20饱食度，但有30%概率中毒90秒。建议在有燃料的篝火旁烹饪。"],
 "烤肉":["食物","恢复40饱食度；每级生存技能额外增加2点。"],
 "河水":["饮水","恢复25饮水值，但有40%概率中毒90秒。使用滤芯制作净水更安全。"],
 "净水":["饮水","安全恢复35饮水值。可搜索获得，或用河水和滤芯制作。"],
 "绷带":["医疗","恢复30生命。由2份布料制作；出发前预留医疗物资。"],
 "石斧":["工具","装备后提高木材采集效率，也可近战攻击。使用会消耗耐久。"],
 "木矛":["武器","近战距离比徒手更远，攻击消耗体力和耐久。按住右键正面格挡。"],
 "弓":["武器","装备后左键发射实际飞行箭矢，消耗箭、体力与耐久；墙体会挡住箭。"],
 "箭":["弹药","每次射箭消耗一支。需要先装备弓；不是可直接使用的消耗品。"],
 "火把":["工具","装备后提供随身照明。可用数字快捷键切换，适合夜间探索。"],
 "滤芯":["净水","与河水一起制作净水，每次制作消耗一份。需要工作台制作滤芯。"],
 "工具包":["维修","用于修复灯塔、研究所和其他设备。按设备提示靠近交互，不能在背包直接使用。"],
 "电池":["维修","主线与营地电台的供电用品。由金属和零件在工作台制作。"],
 "研究数据":["任务","研究所取得的关键信息。主线进度保存在任务日志中。"],
 "急救箱":["任务","渔村守岸人需要的封装医疗箱。用于援助支线交付，不能当作普通绷带使用。"],
 "防雨外套":["衣物","上身装备：降低75%淋湿速度，提高目标体温1℃（不超过37℃）。与背心共用一个装备位。"],
 "加固背心":["衣物","上身装备：受到的敌人攻击伤害降低25%，略微保暖。不能降低坠落或溺水伤害。"]
}
var textures={}

func description(item: String) -> String:
 return DETAILS.get(item,["物品","用于探索与制作。"])[1]

func category(item: String) -> String:
 return DETAILS.get(item,["物品",""])[0]

func usable(item: String) -> bool:
 return item in CONSUMABLES or item in ["石斧","木矛","弓","火把","防雨外套","加固背心"]

func icon(item: String) -> Texture2D:
 if textures.has(item): return textures[item]
 var art=""
 match item:
  "木材": art='<path d="M15 42L40 14 52 25 27 53Z" fill="#887350"/><path d="M21 45L44 21M25 50L49 26"/>'
  "石头": art='<path d="M12 43L17 23 34 14 50 26 54 45 30 52Z" fill="#8f9e9c"/><path d="M17 23L32 35 50 26M32 35L30 52"/>'
  "纤维": art='<path d="M31 52Q12 34 18 13Q38 21 31 52ZM32 52Q31 23 50 15Q56 36 32 52Z" fill="#8f9e68"/><path d="M31 51L22 24M33 49L45 26"/>'
  "布料": art='<path d="M13 20L46 15 52 44 19 51Z" fill="#b4ae8f"/><path d="M19 22L25 44M25 21L31 43M31 20L37 42M37 19L43 41" stroke-dasharray="2 3"/>'
  "金属": art='<path d="M11 28L40 17 53 30 24 43Z" fill="#8b9c9a"/><path d="M11 28V38L24 51 53 39V30M24 43V51"/>'
  "零件": art='<path d="M27 12H37L39 21 48 23 52 32 45 39 44 48 34 52 27 45 18 44 12 35 19 28 19 19Z" fill="#859491"/><circle cx="32" cy="32" r="9" fill="#243b3f"/>'
  "绳索": art='<ellipse cx="32" cy="31" rx="18" ry="21" fill="#a4936b"/><ellipse cx="32" cy="31" rx="10" ry="13" fill="#243b3f"/><path d="M22 18L40 43M18 27L34 50M32 11L48 35" stroke-dasharray="3 4"/>'
  "野果": art='<path d="M29 28Q34 9 46 12"/><path d="M33 21Q18 7 16 21Q24 29 33 21Z" fill="#8fa46d"/><circle cx="24" cy="36" r="10" fill="#b36958"/><circle cx="41" cy="35" r="10" fill="#a5594d"/><circle cx="32" cy="47" r="9" fill="#b86958"/>'
  "罐头": art='<path d="M16 17V47Q32 57 48 47V17" fill="#a7aaa0"/><ellipse cx="32" cy="17" rx="16" ry="6" fill="#b6b9aa"/><path d="M16 29H48V41H16" fill="#8f7055"/>'
  "生肉","烤肉":
   var color="#ad6a60" if item=="生肉" else "#906346"
   art='<path d="M13 37Q10 18 30 16Q50 10 53 31Q57 46 40 50Q23 56 13 37Z" fill="'+color+'"/><path d="M23 25Q32 20 43 26M20 35Q32 29 46 36M28 44L41 42"/>'
  "河水","净水": art='<path d="M26 11H38V21L46 28V50H18V28L26 21Z" fill="'+('#849382' if item=="河水" else '#7ca5ac')+'"/><path d="M18 34Q25 28 32 34T46 34M26 16H38"/>'
  "绷带": art='<path d="M11 26L26 11 53 38 38 53Z" fill="#c5b998"/><path d="M23 23L41 41M28 18L46 36M18 28L36 46" stroke-dasharray="2 4"/>'
  "石斧": art='<path d="M22 54L37 13" stroke="#b29b70" stroke-width="6"/><path d="M25 18L44 12 54 24 42 35 31 28Z" fill="#9aa4a0"/>'
  "木矛": art='<path d="M14 54L43 21" stroke="#b29b70" stroke-width="5"/><path d="M35 20L53 10 46 30Z" fill="#a6b3ae"/>'
  "箭": art='<path d="M13 53L47 17M13 43L23 43 23 53"/><path d="M39 16L54 9 49 25Z" fill="#b5c0b5"/>'
  "弓": art='<path d="M20 10Q62 32 20 54" stroke="#b39a6c" stroke-width="5"/><path d="M20 10V54M19 32H52"/><path d="M44 26L52 32 44 38"/>'
  "火把": art='<path d="M28 55L33 29" stroke="#a48b64" stroke-width="7"/><path d="M29 33Q12 24 32 8Q31 20 43 23Q48 37 29 33Z" fill="#d6a36b"/>'
  "滤芯": art='<path d="M20 13H44V48L32 54 20 48Z" fill="#a4aea4"/><path d="M25 20V43M32 20V47M39 20V43M20 17H44"/>'
  "工具包": art='<path d="M12 25H52V50H12Z" fill="#a2885d"/><path d="M24 25V16H40V25M12 33H52M29 30H35V39H29Z"/>'
  "电池": art='<path d="M17 17H47V51H17Z" fill="#889e8c"/><path d="M25 17V11H39V17M38 25L27 36H37L28 46"/>'
  "研究数据": art='<path d="M17 11H38L48 21V53H17Z" fill="#b7b49d"/><path d="M38 11V22H48M24 29H40M24 37H40M24 45H35"/>'
  "急救箱": art='<rect x="12" y="20" width="40" height="32" rx="5" fill="#9da695"/><path d="M24 20V12H40V20M27 28H37V33H42V43H37V48H27V43H22V33H27Z" fill="#aa6c5a"/>'
  "防雨外套": art='<path d="M24 17L18 21 9 38 18 43 23 33V54H43V33L48 43 57 38 48 21 40 17Q32 9 24 17Z" fill="#8c9c79"/><path d="M32 20V54M23 43H28M37 43H43M24 17L28 25 32 20 36 25 40 17"/>'
  "加固背心": art='<path d="M22 13L12 22 20 34V52H46V34L54 22 44 13 37 23H29Z" fill="#959184"/><path d="M22 33H44V43H22ZM32 24V51M21 47H45"/>'
  _: art='<circle cx="32" cy="32" r="19" fill="#9ca68e"/>'
 var svg='<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64"><g stroke="#283d3e" stroke-width="2.3" stroke-linejoin="round" stroke-linecap="round" fill="none">'+art+'</g></svg>'
 var image=Image.new()
 if image.load_svg_from_string(svg)!=OK: return null
 var texture=ImageTexture.create_from_image(image); textures[item]=texture
 return texture
