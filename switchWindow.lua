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
    if not app then
      hs.alert("Window or app not found: " .. name)
      return
    end

    local focused = hs.window.focusedWindow()
    local focusedApp = focused and focused:application()
    if not focusedApp or focusedApp:name() ~= name then
      local mainWin = app:mainWindow()
      if mainWin and mainWin:isStandard() and not mainWin:isMinimized() then
        mainWin:focus()
        return
      end
      -- Fallback: focus any standard, non-minimized window
      for _, win in ipairs(app:allWindows()) do
        if win:isStandard() and not win:isMinimized() then
          win:focus()
          return
        end
      end
      hs.alert("No windows found for app: " .. name)
      return
    end

    local windows = {}
    for _, win in ipairs(app:allWindows()) do
      if win:isStandard() and not win:isMinimized() then
        table.insert(windows, win)
      end
    end

    if #windows == 0 then
      hs.alert("No windows found for app: " .. name)
      return
    end

    table.sort(windows, function(a, b) return a:id() < b:id() end)

    local idx = 1
    for i, win in ipairs(windows) do
      if focused and win:id() == focused:id() then
        idx = i % #windows + 1
        break
      end
    end

    windows[idx]:focus()
  end

  return {
    forward = switchWindowForward,
    backward = switchWindowBackward,
    toApp = switchToApp,
  }
end

return switchWindow
