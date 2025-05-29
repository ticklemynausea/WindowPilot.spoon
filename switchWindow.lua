local function switchWindow(wp)
  local currentWindowIndex = 1
  local visibleWindows = {}

  local function updateVisibleWindows()
    local focusedWindow = hs.window.focusedWindow()
    if not focusedWindow then
      return
    end

    local currentScreen = focusedWindow:screen()
    local allWindows = hs.window.visibleWindows()
    visibleWindows = {}

    for _, window in ipairs(allWindows) do
      if window:isVisible() and not window:isMinimized() and window:screen() == currentScreen then
        table.insert(visibleWindows, window)
      end
    end
  end

  local function switchWindowForward()
    updateVisibleWindows()
    if #visibleWindows == 0 then
      return
    end

    currentWindowIndex = currentWindowIndex + 1
    if currentWindowIndex > #visibleWindows then
      currentWindowIndex = 1
    end

    local nextWindow = visibleWindows[currentWindowIndex]
    nextWindow:focus()
  end

  local function switchWindowBackward()
    updateVisibleWindows()
    if #visibleWindows == 0 then
      return
    end

    currentWindowIndex = currentWindowIndex - 1
    if currentWindowIndex < 1 then
      currentWindowIndex = #visibleWindows
    end

    local prevWindow = visibleWindows[currentWindowIndex]
    prevWindow:focus()
  end

  local function switchToApp(name)
    print("Switching to: " .. name)

    local app = hs.application.get(name)
    if app then
      local win = app:mainWindow()
      if win and win:isStandard() and not win:isMinimized() then
        print("Fallback: focusing main window of app " .. name)
        win:focus()
        return
      end
    end

    hs.alert("Window or app not found: " .. name)
  end

  return {
    forward = switchWindowForward,
    backward = switchWindowBackward,
    toApp = switchToApp,
  }
end

return switchWindow
