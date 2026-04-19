# TopmostToggle

一个轻量的 Windows 窗口置顶托盘小工具。

这个工具只做一件事：切换当前窗口的“始终置顶”。  
如果你只需要这个功能，不想为了一个点状需求常驻整套大型工具，它会更合适。

## 功能

- 切换当前活动窗口置顶
- 取消所有由本工具置顶过的窗口
- 托盘菜单控制提示音、开机启动、重新加载
- 使用微软同款提示音：
  - `C:\Windows\Media\Speech On.wav`
  - `C:\Windows\Media\Speech Sleep.wav`

## 依赖

- Windows
- [AutoHotkey v2](https://www.autohotkey.com/)

## 用法

1. 安装 AutoHotkey v2
2. 运行 `TopmostToggle.ahk`
3. 默认快捷键：

```text
Win + Ctrl + T
```

## 配置

可参考 `TopmostToggle.example.ini`，自行创建或修改 `TopmostToggle.ini`。

当前支持的配置项：

- `Hotkey`
- `Sound`
- `Startup`

修改 `TopmostToggle.ini` 后，需要在托盘菜单里点击 `重新加载` 才会生效。

## 快捷键写法

示例：

```text
#^t = Win + Ctrl + T
#!t = Win + Alt + T
^!q = Ctrl + Alt + Q
```

## 文件说明

- `TopmostToggle.ahk`：主脚本
- `TopmostToggle.example.ini`：示例配置

## 许可证

MIT
