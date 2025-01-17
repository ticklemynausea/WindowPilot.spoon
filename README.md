# Window Pilot

TODO


```lua
local wp = hs.loadSpoon("WindowPilot")

wp:initialize()

wp:bindKeys({
  switchWindow = {
    forward = { { "alt" }, "tab" },
    backward = { { "alt", "shift" }, "tab" },
  },
  mouseCursor = {
    moveToNextScreen = { { "ctrl", "shift"}, "left" },
    moveToPreviousScreen = { { "ctrl", "shift" }, "right" },
  },
})
```

## Contributing

Contributions are welcome! Feel free to submit issues or pull requests on [GitHub](https://github.com/ticklemynausea/WindowPilot.spoon).

## License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.

