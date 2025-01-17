local function switchWindow(wp)
  local currentWindowIndex = 1
  local visibleWindows = {}

  local function updateVisibleWindows()
      local focusedWindow = hs.window.focusedWindow()
      if not focusedWindow then return end

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
      if #visibleWindows == 0 then return end

      currentWindowIndex = currentWindowIndex + 1
      if currentWindowIndex > #visibleWindows then
          currentWindowIndex = 1
      end

      local nextWindow = visibleWindows[currentWindowIndex]
      nextWindow:focus()
  end

  local function switchWindowBackward()
      updateVisibleWindows()
      if #visibleWindows == 0 then return end

      currentWindowIndex = currentWindowIndex - 1
      if currentWindowIndex < 1 then
          currentWindowIndex = #visibleWindows
      end

      local prevWindow = visibleWindows[currentWindowIndex]
      prevWindow:focus()
  end

  return {
    forward = switchWindowForward,
    backward = switchWindowBackward,
  }
end

return switchWindow
