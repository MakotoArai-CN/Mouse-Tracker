<div align="center">

<div>

<img src="./icon.png" width="256" height="256" alt="Mouse Tracker Logo" />
</br>
<h1 align="center">Mouse Tracker</h1>
</br>
使用Zig语言开发的现代Windows桌面实时追踪鼠标坐标应用，极致轻量，快速。

</div>
</div>

## 功能特性

### 实时坐标追踪 📍

- 高刷新率实时显示鼠标X/Y坐标
- 坐标百分比显示（相对于屏幕分辨率）
- 运动轨迹可视化图表
- X/Y坐标进度条

### 系统托盘集成 🎯

- 关闭窗口自动最小化到系统托盘
- 托盘图标右键菜单：显示/隐藏窗口、锁定/解锁、跟随/固定、关于、退出
- 双击托盘图标切换窗口显示状态

### 剪贴板复制 📋

- **Space** 键锁定坐标并自动复制到剪贴板
- **C** 键随时复制当前坐标
- 复制格式：`X, Y`（例：`1920, 1080`）
- 复制成功/失败有颜色提示

### 紧凑UI模式 🔽

- **Ctrl+M** 切换紧凑/完整模式
- 紧凑模式仅显示X/Y坐标，窗体大幅缩小
- 布局与完整模式保持一致

### 窗口跟随 🖱️

- **F** 键切换跟随/固定模式
- 跟随模式下窗口自动跟随鼠标移动
- 智能边界检测，窗口不会超出屏幕
- 托盘菜单也可切换

### 全局快捷键 ⌨️

- **Ctrl+H** 全局快捷键显示/隐藏窗口（任何应用中可用）

## 键盘快捷键

| 快捷键     | 功能                            |
| ---------- | ------------------------------- |
| **Space**  | 锁定/解锁坐标（锁定时自动复制） |
| **C**      | 复制当前坐标到剪贴板            |
| **Ctrl+M** | 切换紧凑/完整UI模式             |
| **F**      | 切换窗口跟随/固定模式           |
| **Ctrl+H** | 全局显示/隐藏窗口               |

## 托盘菜单

| 菜单项        | 功能               |
| ------------- | ------------------ |
| 显示/隐藏窗口 | 切换窗口可见性     |
| 锁定/解锁     | 切换坐标锁定状态   |
| 跟随/固定     | 切换窗口跟随模式   |
| 关于(GitHub)  | 打开项目GitHub页面 |
| 退出          | 完全退出应用       |

## 构建与运行

### 环境要求

- Zig 0.14.x
- Windows 10/11

### 编译

```bash
# 确认Zig版本
zig version

# 调试版本
zig build

# 发行版本（体积优化）
zig build release

# 编译并运行
zig build run
```

### 多架构支持

```bash
# 64位 Windows（默认）
zig build

# 32位 Windows
zig build -Dtarget=x86-windows

# ARM64 Windows
zig build -Dtarget=aarch64-windows
```

### 运行

```bash
# 编译后直接运行
zig build run

# 或手动运行
./zig-out/bin/mouse-tracker.exe
```

## 图标配置

将图标文件放在 `resources/icon.ico`。如果只有PNG文件，可以用以下方式转换：

```powershell
# PowerShell转换
Add-Type -AssemblyName System.Drawing
$bmp = [System.Drawing.Bitmap]::FromFile("$PWD\resources\icon.png")
$icon = [System.Drawing.Icon]::FromHandle($bmp.GetHicon())
$stream = [System.IO.File]::Create("$PWD\resources\icon.ico")
$icon.Save($stream)
$stream.Close()
$icon.Dispose()
$bmp.Dispose()
```

```powershell
# ImageMagick转换
magick resources/icon.png resources/icon.ico
```

## 项目结构

```tree
mouse/
├── resources/
│   ├── icon.ico          # 应用图标
│   ├── icon.png          # 图标源文件
│   └── resource.rc       # Windows资源定义
├── src/
│   ├── main.zig          # 主程序（窗口、渲染、事件处理）
│   ├── platform.zig      # 平台抽象层
│   ├── platform_windows.zig  # Windows平台实现
│   └── root.zig          # 库入口
├── build.zig             # 构建脚本
├── build.zig.zon         # 包配置
├── README.md
└── CHANGELOG.md
```

## 技术架构

### 平台抽象

`platform.zig` 提供统一接口，`platform_windows.zig` 实现Windows特定功能：

```bash
copyToClipboard    - 文本复制到剪贴板
createTrayIcon     - 创建系统托盘图标
showTrayMenu       - 显示托盘右键菜单
minimizeToTray     - 最小化到托盘
restoreFromTray    - 从托盘恢复
removeTrayIcon     - 移除托盘图标
isWindowVisible    - 查询窗口可见性
openAboutUrl       - 打开项目页面
loadAppIcon        - 加载应用图标
```

### 渲染

- 双缓冲GDI绘制，无闪烁
- 两种渲染模式：`renderUI`（完整）和 `renderUICompact`（紧凑）
- 圆角窗口，深色主题
- ClearType字体渲染

### 界面元素

| 组件     | 说明                             |
| -------- | -------------------------------- |
| 标题栏   | 应用名称 + 状态指示灯 + 关闭按钮 |
| 坐标卡片 | X/Y大字坐标 + 百分比             |
| 轨迹图表 | 60帧历史X/Y运动曲线              |
| 信息卡片 | 逻辑分辨率 + 物理分辨率          |
| 进度条   | X/Y坐标进度可视化                |
| 状态栏   | 锁定状态 + 复制提示 + 跟随模式   |

## 许可证

MIT License

## 项目地址

[https://github.com/MakotoArai-CN/mouse-tracker](https://github.com/MakotoArai-CN/mouse-tracker)
