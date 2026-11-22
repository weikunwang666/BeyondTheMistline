# 从源码运行和构建

当前版本为0.17早期可玩原型，使用固定的Godot 4.5.2 stable、Windows x64、Compatibility渲染。完整验收状态见 KNOWN_ISSUES.md 与 TEST_REPORT.md。

直接体验请下载本仓库GitHub Releases中的Windows ZIP，解压后运行BeyondTheMistline.exe，保留同目录PCK文件。

## 编辑器运行

从[Godot官方归档](https://godotengine.org/download/archive/)获取4.5.2 stable Windows x64。导入game/project.godot并运行主场景。素材已随源码提供，第一次打开会在本机生成导入缓存。

## Windows命令行构建

将同版本官方文件放入tools目录（引擎主程序与console程序需同时存在）：

- Godot_v4.5.2-stable_win64.exe
- Godot_v4.5.2-stable_win64_console.exe
- windows_release_x86_64.exe
- windows_debug_x86_64.exe

后两者从同版本官方导出模板压缩包提取。不要把引擎、模板、Godot缓存或用户存档提交到源码仓库。

从仓库根目录运行PowerShell：

```powershell
New-Item -ItemType Directory -Force build | Out-Null
./tools/test.ps1
./tools/build.ps1
./tools/test-ai.ps1 -Executable "$PWD/build/BeyondTheMistline.exe"
./tools/test-journey.ps1 -Executable "$PWD/build/BeyondTheMistline.exe"
./tools/package.ps1 -Version 0.17
```

package.ps1只保留当前版本的发布目录和ZIP，删除仓库根目录下按同一命名规则生成的旧版发行文件。源码、工具、视频和存档不在其删除范围内。

自动测试使用tools下隔离的QA用户数据目录；正常游玩进度位于Windows用户数据目录。引擎输入测试不替代人工盲测。视频录制和编码入口另见 GAMEPLAY_VIDEO.md，其中编码工具路径需要适配本机FFmpeg安装。

第三方素材与许可见根目录 ASSET_CREDITS.md。该文件仅说明素材来源，不为整个项目额外授予开源许可。
