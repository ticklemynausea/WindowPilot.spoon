# WindowPilot

Window management utilities for macOS using Hammerspoon.

## Installation

1. Install Hammerspoon: [https://www.hammerspoon.org/](https://www.hammerspoon.org/)
2. Clone and move the Spoon:
   ```sh
   git clone https://github.com/ticklemynausea/WindowPilot.spoon.git
   mv WindowPilot.spoon ~/.hammerspoon/Spoons/
   ```
3. Add to `~/.hammerspoon/init.lua`:
   ```lua
   local wp = hs.loadSpoon("WindowPilot")

   wp:initialize({ windowMargin = 6 })

   wp:bindKeys({
     switchWindow = {
       forward = { { "alt" }, "tab" },
       backward = { { "alt", "shift" }, "tab" },
     },
     mouseCursor = {
       moveToNextScreen = { { "ctrl", "shift"}, "right" },
       moveToPreviousScreen = { { "ctrl", "shift" }, "left" },
     },
     windowLayout = {
       layoutTiledBSP = { { "alt", "cmd" }, "Z" },
       layoutFullScreen = { { "alt", "cmd" }, "F" },
       layoutCascading = { { "alt", "cmd" }, "X" },
       layoutMainAndStack = { { "alt", "cmd" }, "S" },
       layoutThrees = { { "alt", "cmd" }, "D" },
       layoutHalves = { { "alt", "cmd" }, "A" },
     },
     windowMovement = {
       moveWindowLeft = { {"alt", "cmd"}, "left" },
       moveWindowRight = { {"alt", "cmd"}, "right" },
       moveWindowTop = { {"alt", "cmd"}, "up" },
       moveWindowBottom = { {"alt", "cmd"}, "down" },
       moveWindowCenter = { {"alt", "cmd"}, "C" },
       moveWindowToNextScreen = { { "cmd", "alt" }, "]" },
       moveWindowToPreviousScreen = { { "cmd", "alt" }, "["},
       moveWindowToNextSpace = { {"shift", "alt", "cmd"}, "]" },
       moveWindowToPreviousSpace = { {"shift", "alt", "cmd"}, "[" },
     },
     wpHelp = {
       keyList = { { "alt", "cmd" }, "H" }
     },
   })

   wp:bindShortcuts({
     { name = "Alacritty", keys = {  { "cmd" }, "1" } },
     { name = "Google Chrome", keys = {  { "cmd" }, "2" } },
     { name = "Slack", keys = {  { "cmd" }, "3" } },
     { name = "Obsidian", keys = {  { "cmd" }, "4" } },
     { name = "Zoom", keys = {  { "cmd" }, "5" } },
     { name = "Safari", keys = {  { "cmd" }, "7" } },
     { name = "Podcasts", keys = {  { "cmd" }, "8" } },
     { name = "Spotify", keys = {  { "cmd" }, "9" } },
     { name = "Gmail", keys = {  { "shift", "cmd" }, "1" } },
     { name = "Google Calendar", keys = {  { "shift", "cmd" }, "2" } },
   })
   ```
4. Reload Hammerspoon:
   ```lua
   hs.reload()
   ```

## Features

- Keyboard window switching
- Tiling layouts (BSP, fullscreen, cascading, main & stack)
- Move windows to screen edges
- Move windows between screens/spaces
- Keyboard-controlled cursor movement

## Keybindings

These are intuitively fully costumizable

| Action                        | Shortcut                |
|-------------------------------|-------------------------|
| Switch to next window         | Alt + Tab              |
| Switch to previous window     | Alt + Shift + Tab      |
| Move window to next screen    | Cmd + Alt + ]          |
| Move window to previous screen| Cmd + Alt + [          |
| Move window to next space     | Shift + Alt + Cmd + ]  |
| Move window to previous space | Shift + Alt + Cmd + [  |
| Layout: BSP Tiling            | Alt + Cmd + Z          |
| Layout: Fullscreen            | Alt + Cmd + F          |
| Layout: Cascading             | Alt + Cmd + X          |
| Layout: Main & Stack          | Alt + Cmd + S          |
| Layout: Threes                | Alt + Cmd + D          |
| Layout: Halves                | Alt + Cmd + A          |
| Move window left              | Alt + Cmd + Left       |
| Move window right             | Alt + Cmd + Right      |
| Move window up                | Alt + Cmd + Up         |
| Move window down              | Alt + Cmd + Down       |
| Move window center            | Alt + Cmd + C          |
| Show key list/help            | Alt + Cmd + H          |
| Alacritty                     | Cmd + 1                |
| Google Chrome                 | Cmd + 2                |
| Slack                         | Cmd + 3                |
| Obsidian                      | Cmd + 4                |
| Zoom                          | Cmd + 5                |
| Safari                        | Cmd + 7                |
| Podcasts                      | Cmd + 8                |
| Spotify                       | Cmd + 9                |
| Gmail                         | Shift + Cmd + 1        |
| Google Calendar               | Shift + Cmd + 2        |

Change keybindings in `bindKeys` and `bindShortcuts` as needed.

## License

MIT License. See [LICENSE](./LICENSE).
