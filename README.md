# TopmostToggle

A lightweight Windows tray utility for toggling "always on top" on the active window.

It exists for one reason: if you only need window pinning, you may not want a larger utility suite running all the time.

## Features

- Toggle always-on-top for the active window
- Clear all windows pinned by this tool
- Tray menu with sound and startup toggles
- Microsoft-style toggle sounds using:
  - `C:\Windows\Media\Speech On.wav`
  - `C:\Windows\Media\Speech Sleep.wav`

## Requirements

- Windows
- [AutoHotkey v2](https://www.autohotkey.com/)

## Usage

1. Install AutoHotkey v2.
2. Run `TopmostToggle.ahk`.
3. Use the default hotkey:

```text
Ctrl + Alt + Q
```

## Configuration

Copy `TopmostToggle.example.ini` to `TopmostToggle.ini` if needed, then edit the values.

Current options:

- `Hotkey`
- `Sound`
- `Startup`

After editing `TopmostToggle.ini`, use the tray menu item `重新加载` to apply changes.

## Hotkey Format

Examples:

```text
#^t = Win + Ctrl + T
#!t = Win + Alt + T
^!q = Ctrl + Alt + Q
```

## Files

- `TopmostToggle.ahk` - main script
- `TopmostToggle.example.ini` - example config

## License

MIT
