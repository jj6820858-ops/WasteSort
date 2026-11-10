# 归序 · 垃圾分类工作台

原生 Windows 桌面上位机界面，使用 **C++17 + Qt 6.8 / Qt Quick / QML**。这是可交互的界面原型，含本地登录、四类分类监控、运行日志及设置；设备通信和视觉识别尚未接入。

## 启动

双击 `启动归序.cmd`，或运行 `dist/WasteSort/WasteSort.exe`。发布文件夹已经附带 Qt 运行依赖，复制程序时需保留整个 `dist/WasteSort` 文件夹。

首次使用可创建本机账号；用户名为 3–24 位字母、数字、下划线或短横线，密码为 8–128 位。没有预设密码。也可点击“进入演示工作台”直接预览。

## 页面和操作

- **登录**：首次创建本机账号、密码登录、显示密码、独立演示访客入口。
- **分类监控**：回收、不可回收、厨余垃圾、湿垃圾四张卡片；本次运行累计数量、桶体余量、分拣示意、最近识别、最近三条日志。
- **运行日志**：信息 / 警告 / 错误筛选，按内容、模块或日期搜索，导出当前筛选结果为 UTF-8 BOM CSV，可用 Excel 打开。
- **工作台设置**：演示周期、深浅主题、模拟清空桶体、本机数据目录。
- **软件图标**：原创薄荷绿叶片，嵌入 Windows EXE，同时用于窗口和任务栏；ICO 包含 16/24/32/48/64/128/256 像素版本。

“模拟投放”每次产生一条分类事件；“启动演示”按设定周期自动投放，“暂停演示”和退出登录都会停止自动投放。桶体使用率达到 80% 记录警告，100% 时停止投放；在设置中模拟清空后可继续，累计数量不清零。

**所有识别名称、置信度、数量与桶体余量来自内置模拟器。** 未访问串口、摄像头，也未向硬件发送控制指令。数量和余量随进程重启归零，日志跨次启动保留。演示访客拥有原型内的模拟操作权限，不代表生产环境账号权限模型。

四类名称按需求保留；“厨余”和“湿垃圾”的区分规则尚未定义，湿垃圾显示为自定义样本。后续接入设备时，应先统一类别编号和分类规则。

## 设计参考

参考用户本地 `githup_lreaning/ui-design-reference/qt/` 中的：

- `QtIndustrialWidgets`：深色工业仪表底色、清晰状态、分组信息。
- `DevicePilotHMI`：监控 / 日志 / 设置结构，C++ 状态与 QML 展示分离。
- `Smarton`：侧边导航、账号入口、集中主题变量。

界面及图标为本项目重新实现，没有复制参考项目的源代码、字体或图片。默认窗口 1440×920，紧凑窗口 1120×760；主语言中文，支持鼠标与键盘 Tab 导航。原生 DPI 缩放在 Windows 窗口创建后应用。

## 构建与验证

已适配本机 `D:/Qt/6.8.3/mingw_64`、MinGW 13.1、CMake 和 Ninja：

```powershell
.\build.ps1 -Deploy
```

脚本会编译、运行 Qt Test，再调用 `windeployqt`。Qt Creator 可直接打开 `CMakeLists.txt`，选择 Qt 6.8.3 MinGW 64-bit Kit。

测试覆盖本机账号重启登录、错误密码、密码不明文保存、损坏账号保护、未登录操作保护、退出停止定时器、四类统计一致性、日志持久化 / 搜索 / CSV 导出、满桶停止和清空恢复。

截图可复现，使用临时数据目录，不写入实际账号和日志：

```powershell
.\dist\WasteSort\WasteSort.exe --preview --capture captures/dashboard.png
.\dist\WasteSort\WasteSort.exe --capture captures/login.png
.\dist\WasteSort\WasteSort.exe --preview --logs --capture captures/logs.png
.\dist\WasteSort\WasteSort.exe --preview --compact --capture captures/compact.png
```

`--preview` 注入 29 次模拟投放；`--capture` 使用 1:1 像素渲染并自动退出。正常启动保留系统 DPI 缩放。

## 文件结构

```text
src/controller.*       本地账号、模拟器、统计、日志与导出
src/main.cpp           Qt 启动、窗口 DPI、图标、截图入口
qml/                   登录、监控、日志、设置、复用控件与主题
assets/                原创 PNG / SVG / ICO 图标、Windows 版本资源
tests/                 Qt Test 回归测试
tools/make_icon.py      图标生成源程序（仅生成图标时需要 Pillow）
build.ps1              构建、测试和打包
```

账号和日志实际路径由 Qt `QStandardPaths::AppLocalDataLocation` 决定，设置页可复制。账号采用随机盐 + PBKDF2-HMAC-SHA256（120,000 轮）保存摘要，不记录明文密码；实现使用 [Qt QPasswordDigestor](https://doc.qt.io/qt-6/qpassworddigestor.html)。这是单机原型登录，不提供云端账号、角色权限或找回密码。

日志采用原子写入，最多保留 2,000 条；导出前需登录，写入失败有可见提示，禁止覆盖账号和内部日志文件。界面里的日志记录来自当前设备上的演示及账号操作。

后续设备集成入口是 `Controller`：用实际接收的设备事件替换 `sample()` 数据源，再分别接入相机画面、串口 / 网络协议和设备确认反馈。当前界面不显示虚假的硬件在线状态。
