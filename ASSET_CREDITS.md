# 素材与技术鸣谢

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
