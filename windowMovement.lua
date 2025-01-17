local function windowMovement(wp)
  local margin = wp.configuration.windowMargin
  local moveWindowSizes = {0.5, 0.3335, 0.669}

  local function nextWindowPosition(current, presets)
      local closest = presets[1]
      local minDiff = math.abs(current - closest)

      for _, preset in ipairs(presets) do
          local diff = math.abs(current - preset)
          if diff < minDiff then
              closest = preset
              minDiff = diff
          end
      end

      local index = hs.fnutils.indexOf(presets, closest)
      return presets[(index % #presets) + 1]
  end

  local function moveWindow(direction)
      local win = hs.window.focusedWindow()
      if not win then
          hs.alert.show("No focused window!")
          return
      end

      local screen = win:screen()
      local screenFrame = screen:frame()
      local winFrame = win:frame()

      local x, y, w, h = screenFrame.x, screenFrame.y, screenFrame.w, screenFrame.h

      if direction == "left" then
          local currentWidthPercentage = winFrame.w / w
          local nextWidth = nextWindowPosition(currentWidthPercentage, moveWindowSizes)
          win:setFrame({
              x = x + margin,
              y = y + margin,
              w = (w * nextWidth) - (2 * margin),
              h = h - (2 * margin)
          }, 0)

      elseif direction == "right" then
          local currentWidthPercentage = winFrame.w / w
          local nextWidth = nextWindowPosition(currentWidthPercentage, moveWindowSizes)
          win:setFrame({
              x = x + w - (w * nextWidth) + margin,
              y = y + margin,
              w = (w * nextWidth) - (2 * margin),
              h = h - (2 * margin)
          }, 0)

      elseif direction == "top" then
          local currentHeightPercentage = winFrame.h / h
          local nextHeight = nextWindowPosition(currentHeightPercentage, moveWindowSizes)
          win:setFrame({
              x = x + margin,
              y = y + margin,
              w = w - (2 * margin),
              h = (h * nextHeight) - (2 * margin)
          }, 0)

      elseif direction == "bottom" then
          local currentHeightPercentage = winFrame.h / h
          local nextHeight = nextWindowPosition(currentHeightPercentage, moveWindowSizes)
          win:setFrame({
              x = x + margin,
              y = y + h - (h * nextHeight) + margin,
              w = w - (2 * margin),
              h = (h * nextHeight) - (2 * margin)
          }, 0)

      else
          hs.alert.show("Invalid direction! Use 'left', 'right', 'top', or 'bottom'")
      end
  end

  local function moveWindowToScreen(direction)
      local win = hs.window.focusedWindow()
      if not win then return end

      local currentScreen = win:screen()
      local targetScreen = (direction == "next") and currentScreen:next() or currentScreen:previous()

      if targetScreen then
          win:moveToScreen(targetScreen, false, true, 0)
      end
  end

  local function moveWindowToSpace(direction)
      local win = hs.window.focusedWindow()
      if not win then
          hs.alert.show("No focused window to move.")
          return
      end

      local screen = win:screen()
      local currentSpace = hs.spaces.windowSpaces(win:id())[1]
      if not currentSpace then
          hs.alert.show("Unable to determine the current space.")
          return
      end

      local spaces = hs.spaces.spacesForScreen(screen)
      local spaceIndex = hs.fnutils.indexOf(spaces, currentSpace)

      if not spaceIndex then
          hs.alert.show("Space not found.")
          return
      end

      local targetSpace
      if direction == "next" then
          targetSpace = spaces[spaceIndex + 1]
      elseif direction == "previous" then
          targetSpace = spaces[spaceIndex - 1]
      else
          return
      end

      if not targetSpace then
        return
      end

      hs.spaces.moveWindowToSpace(win:id(), targetSpace)
      hs.timer.doAfter(0.05, function()
          local ctrlKey = 0x3B
          local rightArrow = 0x7C
          local leftArrow = 0x7B

          hs.eventtap.event.newKeyEvent(ctrlKey, true):post()
          if direction == "next" then
              hs.eventtap.event.newKeyEvent(rightArrow, true):post()
              hs.eventtap.event.newKeyEvent(rightArrow, false):post()
          elseif direction == "previous" then
              hs.eventtap.event.newKeyEvent(leftArrow, true):post()
              hs.eventtap.event.newKeyEvent(leftArrow, false):post()
          end
          hs.eventtap.event.newKeyEvent(ctrlKey, false):post()
      end)
  end

  return {
    moveWindowLeft = function() moveWindow("left") end,
    moveWindowRight = function() moveWindow("right") end,
    moveWindowTop = function() moveWindow("top") end,
    moveWindowBottom = function() moveWindow("bottom") end,
    moveWindowToNextScreen = function() moveWindowToScreen("next") end,
    moveWindowToPreviousScreen = function() moveWindowToScreen("previous") end,
    moveWindowToNextSpace = function() moveWindowToSpace("next") end,
    moveWindowToPreviousSpace = function() moveWindowToSpace("previous") end,
  }
end

return windowMovement
