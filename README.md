# **WindowPilot** 🛩️
_Window management utilities for macOS using Hammerspoon._

WindowPilot is a **keyboard-driven** window manager for macOS, designed to provide powerful yet intuitive window management capabilities. It brings **window switching, layout management, movement controls, and cursor positioning** under a unified, easy-to-configure system. Inspired by Rectangle.

---

## **Installation** ⚙️

### **1. Install Hammerspoon**
If you haven’t installed Hammerspoon yet, [download it here](https://www.hammerspoon.org/) and place it in your Applications folder.

### **2. Install WindowPilot Spoon**
Clone the repository and move the Spoon to your Hammerspoon Spoons directory:

```sh
git clone https://github.com/ticklemynausea/WindowPilot.spoon.git
mv WindowPilot.spoon ~/.hammerspoon/Spoons/
```

### **3. Load WindowPilot in Hammerspoon**
Add the following to your `~/.hammerspoon/init.lua`:

```lua
local wp = hs.loadSpoon("WindowPilot")

wp:initialize({
  windowMargin = 6
})

wp:bindKeys({
  switchWindow = {
    forward = { { "alt" }, "tab" },
    backward = { { "alt", "shift" }, "tab" },
  },
  mouseCursor = {
    moveToNextScreen = { { "ctrl", "shift"}, "left" },
    moveToPreviousScreen = { { "ctrl", "shift" }, "right" },
  },
  windowLayout = {
    layoutTiledBSP = { { "alt", "cmd" }, "T" },
    layoutFullScreen = { { "alt", "cmd" }, "F" },
    layoutCascading = { { "alt", "cmd" }, "C" },
    layoutMainAndStack = { { "alt", "cmd" }, "S" },
  },
  windowMovement = {
    moveWindowLeft = { { "alt", "cmd" }, "left" },
    moveWindowRight = { { "alt", "cmd" }, "right" },
    moveWindowTop = { { "alt", "cmd" }, "up" },
    moveWindowBottom = { { "alt", "cmd" }, "down" },
    moveWindowToNextScreen = { { "cmd", "alt" }, "]" },
    moveWindowToPreviousScreen = { { "cmd", "alt" }, "[" },
    moveWindowToNextSpace = { { "shift", "alt", "cmd" }, "]" },
    moveWindowToPreviousSpace = { { "shift", "alt", "cmd" }, "[" },
  }
})
```

### **4. Reload Hammerspoon**
Run this command in the Hammerspoon console (`Cmd + Shift + R` to open it):

```lua
hs.reload()
```

---

## **Features** ✨
- **Fast window switching** (`Alt + Tab`, `Alt + Shift + Tab`)
- **Tiling window layouts** (BSP, full-screen, cascading, main & stack)
- **Throw windows to screen margins** (`Alt + Cmd + Arrow keys`)
- **Move windows between screens/spaces**
- **Keyboard-controlled cursor movement**

---

## **Keybindings** ⌨️

| Action                        | Shortcut |
|--------------------------------|----------|
| Switch to next window         | `Alt + Tab` |
| Switch to previous window     | `Alt + Shift + Tab` |
| Move window to next screen    | `Cmd + Alt + ]` |
| Move window to previous screen | `Cmd + Alt + [` |
| Move window to next space     | `Shift + Alt + Cmd + ]` |
| Move window to previous space | `Shift + Alt + Cmd + [` |
| Layout: BSP Tiling            | `Alt + Cmd + T` |
| Layout: Fullscreen            | `Alt + Cmd + F` |
| Layout: Cascading             | `Alt + Cmd + C` |
| Layout: Main & Stack          | `Alt + Cmd + S` |

> 📝 **Tip:** You can change the keybindings in `bindKeys` to suit your preferences.

---

## **Contributing** 🛠️
Contributions are welcome! Feel free to submit issues or pull requests on [GitHub](https://github.com/ticklemynausea/WindowPilot.spoon).

---

## **License** 📜
This project is licensed under the **MIT License**. See the [LICENSE](./LICENSE) file for details.
