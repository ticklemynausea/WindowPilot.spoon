local function mouseCursor(wp)
  local function getWindowUnderMouse()
    local mousePos = hs.mouse.absolutePosition()
    local windows = hs.window.visibleWindows()

    for _, window in ipairs(windows) do
      local frame = window:frame()

      if
        (mousePos.x >= frame.x)
        and (mousePos.x <= frame.x + frame.w)
        and (mousePos.y >= frame.y)
        and (mousePos.y <= frame.y + frame.h)
      then
        return window
      end
    end
    return nil
  end

  local function focusMouseWindow()
    local windowUnderMouse = getWindowUnderMouse()

    if windowUnderMouse then
      windowUnderMouse:focus()
    end
  end

  local function moveToNextScreen()
    local screen = hs.mouse.getCurrentScreen()
    local nextScreen = screen:next()
    local rect = nextScreen:fullFrame()
    local center = hs.geometry.rectMidPoint(rect)
    hs.mouse.absolutePosition(center)
    focusMouseWindow()
  end

  local function moveToPreviousScreen()
    local screen = hs.mouse.getCurrentScreen()
    local nextScreen = screen:previous()
    local rect = nextScreen:fullFrame()
    local center = hs.geometry.rectMidPoint(rect)
    hs.mouse.absolutePosition(center)
    focusMouseWindow()
  end

  return {
    moveToNextScreen = moveToNextScreen,
    moveToPreviousScreen = moveToPreviousScreen,
  }
end

return mouseCursor
