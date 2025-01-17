# Window Pilot

TODO


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
    moveWindowLeft = { {"alt", "cmd"}, "left" },
    moveWindowRight = { {"alt", "cmd"}, "right" },
    moveWindowTop = { {"alt", "cmd"}, "up" },
    moveWindowBottom = { {"alt", "cmd"}, "down" },
    moveWindowToNextScreen = { { "cmd", "alt" }, "]" },
    moveWindowToPreviousScreen = { { "cmd", "alt" }, "["},
    moveWindowToNextSpace = { {"shift", "alt", "cmd"}, "]" },
    moveWindowToPreviousSpace = { {"shift", "alt", "cmd"}, "[" },
  }
})
```

## Contributing

Contributions are welcome! Feel free to submit issues or pull requests on [GitHub](https://github.com/ticklemynausea/WindowPilot.spoon).

## License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.

