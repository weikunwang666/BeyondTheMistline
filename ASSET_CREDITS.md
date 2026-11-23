# 素材与技术鸣谢

0.18本地：26种物品图标由本项目绘制为原创SVG形状并在运行时栅格化；衣物、NPC雨棚和新增程序动作由本项目制作。没有复制游戏截图或第三方图标包。

地形、程序几何、植被、人物与动物模型、建筑几何、材质噪声、水面着色器、UI、文本和合成音效：本项目自行生成。0.13 起使用下列外部 CC0 贴图。

Godot Engine 4.5.2 stable：Godot contributors，MIT License，https://godotengine.org/license/ ，下载自 https://github.com/godotengine/godot/releases/tag/4.5.2-stable ，2026-11-22。未修改引擎。运行时采用引擎内置和系统字体回退，不复制分发 Windows 字体文件。

视觉参考（仅研究构图、配色及灯塔剪影；未下载、复制或分发页面图片）：

- Lighthouse Production Guide，https://80.lv/articles/001agt-005cg-lighthouse-production-guide-substance-tools-workflow ，研究海雾层次、冷暖与灯塔结构。
- Devil's Island Abandoned Lighthouse，https://carte-urbex.com/en/blogs/information-1/top-5-abandoned-islands-in-canada-forgotten-island-sites ，研究荒废海岸地标与植被关系。

当前没有采购付费素材。外部素材逐项记录如下。

0.7 音频：soundscape.gd 使用确定性噪声、滤波、正弦振荡与包络自主生成风、海浪、雨、林间鸟声、脚步和操作音效；未复制或采样外部录音。当前为合成声景，最终听感尚未验收。

## Poly Haven 材质

下载日期：2026-11-23。Powered by Poly Haven。授权：CC0 1.0；官方说明 https://polyhaven.com/license ，允许商业使用与随产品再分发。作者从官方 /info 元数据读取，完整来源和下载地址、MD5 清单见 docs/material-sources。

| 材质 | 作者 | 来源 | 用途 |
| --- | --- | --- | --- |
| Wood Planks | Amal Kumar | https://polyhaven.com/a/wood_planks | 木地板、箱体、工作台和工具木件 |
| Coast Sand 01 | Rob Tuytel | https://polyhaven.com/a/coast_sand_01 | 海岸地表 |
| Forest Ground 04 | Rob Tuytel，Rico Cilliers | https://polyhaven.com/a/forest_ground_04 | 内陆森林地表 |
| Rusty Metal 02 | Rob Tuytel | https://polyhaven.com/a/rusty_metal_02 | 铁皮、屋顶、工业设备 |
| Rock Face 03 | Dario Barresi，Rico Cilliers | https://polyhaven.com/a/rock_face_03 | 岩石及高地地表 |
| Concrete Wall 004 | Charlotte Baglioni，Dario Barresi | https://polyhaven.com/a/concrete_wall_004 | 灯塔、墙面与混凝土地板 |

每组采用 1K JPG 漫反射、OpenGL 法线和粗糙度文件；下载后逐文件与官方 MD5 匹配。原始图片未修改，运行时进行三平面投射、平铺、染色和区域混合。地形使用三组漫反射混合，物件使用 PBR 贴图。未集成网站预览图、模型、HDRI 或付费素材。素材全部随离线游戏打包，不在运行时调用 API。

## 0.18 中文字体

Noto Sans SC variable，Google Fonts官方仓库：https://github.com/google/fonts/tree/main/ofl/notosanssc 。版权：2014–2021 Adobe，保留字体名称Source；Google Fonts元数据设计者Google。SIL Open Font License 1.1。下载于2026-11-23，字体内容未修改，仅本地文件名改为NotoSansSC.ttf；官方Git blob SHA-1 fb0637bafbcd804fe32152370a1225990745b4bc，下载后已核对。用于全部UI、地图与3D中文标签，关闭系统字体回退。源码版权/授权位于game/assets/fonts/OFL.txt，发行包同时提供FONT_LICENSE.txt；未复制Windows字体。此前关于只使用系统字体回退的描述为历史状态。

## 2026-11-23 角色与动画评估资源

Quaternius，Universal Animation Library Standard 与 Universal Base Characters Standard，CC0 1.0。官方来源：https://quaternius.com/packs/universalanimationlibrary.html 、https://quaternius.com/packs/universalbasecharacters.html ；免费文件分别来自 https://quaternius.itch.io/universal-animation-library 和 https://quaternius.itch.io/universal-base-characters 。动画官网另鸣谢 Gonzalo Furnier 的动画贡献。仅下载免费Standard档，未购买付费资源。

动画采用Unreal-Godot/UAL1_Standard.glb（无根运动），43段动作、65骨骼；角色采用Base Characters/Godot - UE/Superhero_Male_FullBody.gltf、bin及引用贴图。glTF中两个法线文件引用含_png后缀，与原包文件名不符，提取时将对应原始PNG内容按引用文件名复制；像素及glTF内容未改。许可证随源码位于game/assets/characters/UAL_License.txt及base/License_Standard.txt。完整包与提取文件SHA256见docs/character-sources.json。

本轮仅在源码评估场景中接入，未替换正常玩家/NPC，当前0.20发行包未包含这些新增资源。衣装蒙皮外壳、动作重定向代码和石斧挂点样件由本项目制作。两套资源不代表最终生存者造型已完成；不要将评估照片视作正常实玩截图。

## 0.21简略试玩版更新

2026-11-23：前述角色“仅评估”的描述属于0.20阶段历史。0.21已把Quaternius CC0男性蒙皮身体、引用贴图和43段离线转换动作接入普通玩家与伊莱；新增蒙皮衣装外壳、帽子、背包及衣兜/拉链等本项目制作部分。发行包提供CHARACTER_LICENSE.txt和ANIMATION_LICENSE.txt。皮肤文件未修改；动作重定向衍生资源为survivor_motion.res。完整最终角色美术仍未验收。
