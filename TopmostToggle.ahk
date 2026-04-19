#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

SetWinDelay(-1)

global AppName := "窗口置顶"
global ConfigPath := A_ScriptDir "\TopmostToggle.ini"
global StartupShortcut := A_Startup "\Topmost Toggle.lnk"
global Settings := LoadSettings()
global PinnedWindows := Map()

ApplyHotkey()
BuildTray()
RefreshTrayChecks()
ShowStartupStatus()
return

ToggleActiveWindow(*) {
    hwnd := WinExist("A")
    if !hwnd {
        Notify("没有活动窗口")
        return
    }

    title := WinGetTitle("ahk_id " hwnd)
    if (title = "")
        title := "未命名窗口"

    WinSetAlwaysOnTop(-1, "ahk_id " hwnd)
    Sleep(30)

    isTopmost := (WinGetExStyle("ahk_id " hwnd) & 0x8) != 0
    TrackPinnedWindow(hwnd, isTopmost)
    if Settings["sound"]
        PlayToggleSound(isTopmost)

    Notify((isTopmost ? "已置顶: " : "已取消置顶: ") TruncateTitle(title))
}

ToggleSound(*) {
    Settings["sound"] := !Settings["sound"]
    SaveSettings()
    RefreshTrayChecks()
    Notify("提示音" (Settings["sound"] ? "已开启" : "已关闭"))
}

ToggleStartup(*) {
    Settings["startup"] := !Settings["startup"]
    UpdateStartupShortcut()
    SaveSettings()
    RefreshTrayChecks()
    Notify("开机启动" (Settings["startup"] ? "已开启" : "已关闭"))
}

EditHotkey(*) {
    MsgBox(
        "请在配置文件里修改 Hotkey 这一行，然后托盘右键点“重新加载”。`n`n"
        . "常用写法：`n"
        . "#^t = Win + Ctrl + T`n"
        . "#!t = Win + Alt + T`n"
        . "^!q = Ctrl + Alt + Q",
        "修改快捷键",
        "OK Iconi"
    )
    OpenConfig()
}

ClearAllPinned(*) {
    count := 0
    stale := []

    for hwnd in PinnedWindows {
        if !WinExist("ahk_id " hwnd) {
            stale.Push(hwnd)
            continue
        }

        if (WinGetExStyle("ahk_id " hwnd) & 0x8) != 0 {
            WinSetAlwaysOnTop(0, "ahk_id " hwnd)
            count += 1
        }
        stale.Push(hwnd)
    }

    for hwnd in stale {
        if PinnedWindows.Has(hwnd)
            PinnedWindows.Delete(hwnd)
    }

    if Settings["sound"] && count > 0
        PlayToggleSound(false)

    Notify(count > 0 ? "已取消 " count " 个置顶窗口" : "没有可取消的置顶窗口")
}

OpenConfig(*) {
    if !FileExist(ConfigPath)
        SaveSettings()
    Run(ConfigPath)
}

ReloadScript(*) {
    Reload()
}

ExitScript(*) {
    ExitApp()
}

BuildTray() {
    A_TrayMenu.Delete()
    A_TrayMenu.Add("切换当前窗口置顶 (" HumanHotkey(Settings["hotkey"]) ")", ToggleActiveWindow)
    A_TrayMenu.Add("取消所有置顶", ClearAllPinned)
    A_TrayMenu.Add()
    A_TrayMenu.Add("修改快捷键", EditHotkey)
    A_TrayMenu.Add("提示音", ToggleSound)
    A_TrayMenu.Add("开机启动", ToggleStartup)
    A_TrayMenu.Add("打开配置", OpenConfig)
    A_TrayMenu.Add("重新加载", ReloadScript)
    A_TrayMenu.Add()
    A_TrayMenu.Add("退出", ExitScript)
    A_IconTip := AppName
}

RefreshTrayChecks() {
    try {
        if Settings["sound"]
            A_TrayMenu.Check("提示音")
        else
            A_TrayMenu.Uncheck("提示音")

        if Settings["startup"]
            A_TrayMenu.Check("开机启动")
        else
            A_TrayMenu.Uncheck("开机启动")
    }
}

ApplyHotkey() {
    Hotkey(Settings["hotkey"], ToggleActiveWindow, "On")
}

LoadSettings() {
    settings := Map()
    settings["hotkey"] := IniRead(ConfigPath, "Settings", "Hotkey", "#^t")
    settings["sound"] := ToBool(IniRead(ConfigPath, "Settings", "Sound", "1"))
    settings["startup"] := ToBool(IniRead(ConfigPath, "Settings", "Startup", FileExist(StartupShortcut) ? "1" : "0"))
    SaveSettingsMap(settings)
    return settings
}

SaveSettings() {
    SaveSettingsMap(Settings)
}

SaveSettingsMap(settings) {
    IniWrite(settings["hotkey"], ConfigPath, "Settings", "Hotkey")
    IniWrite(settings["sound"] ? "1" : "0", ConfigPath, "Settings", "Sound")
    IniWrite(settings["startup"] ? "1" : "0", ConfigPath, "Settings", "Startup")
}

UpdateStartupShortcut() {
    if Settings["startup"] {
        FileCreateShortcut(
            A_AhkPath,
            StartupShortcut,
            A_ScriptDir,
            '"' A_ScriptFullPath '"',
            "窗口置顶热键工具"
        )
    } else if FileExist(StartupShortcut) {
        FileDelete(StartupShortcut)
    }
}

ShowStartupStatus() {
    UpdateStartupShortcut()
    Notify("已就绪，热键: " HumanHotkey(Settings["hotkey"]))
}

TrackPinnedWindow(hwnd, isPinned) {
    if isPinned
        PinnedWindows[hwnd] := true
    else if PinnedWindows.Has(hwnd)
        PinnedWindows.Delete(hwnd)
}

PlayToggleSound(isPinned) {
    filePath := "C:\\Windows\\Media\\" (isPinned ? "Speech On.wav" : "Speech Sleep.wav")
    SoundPlay(filePath, 0)
}

Notify(message) {
    ToolTip(message)
    SetTimer(HideToolTip, -1200)
}

HideToolTip() {
    ToolTip()
}

HumanHotkey(hotkey) {
    readable := ""
    rest := hotkey
    while StrLen(rest) {
        ch := SubStr(rest, 1, 1)
        if (ch = "#")
            readable .= "Win+"
        else if (ch = "^")
            readable .= "Ctrl+"
        else if (ch = "!")
            readable .= "Alt+"
        else if (ch = "+")
            readable .= "Shift+"
        else
            return readable rest
        rest := SubStr(rest, 2)
    }
    return readable
}

ToBool(value) {
    value := Trim(String(value))
    return !(value = "" || value = "0" || StrLower(value) = "false")
}

TruncateTitle(title) {
    return StrLen(title) > 48 ? SubStr(title, 1, 45) "..." : title
}
