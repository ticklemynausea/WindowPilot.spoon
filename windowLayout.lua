local function windowLayout(wp)
  local margin = wp.configuration.windowMargin

  local function getVisibleWindowsInCurrentSpace()
    local allWindows = hs.window.visibleWindows()
    local currentScreen = hs.screen.mainScreen()

    local currentSpaceWindows = {}
    for _, win in ipairs(allWindows) do
      if win:screen() == currentScreen and win:isStandard() and not win:isMinimized() then
        table.insert(currentSpaceWindows, win)
      end
    end

    return currentSpaceWindows
  end

  local function prioritizeFocusedWindow(windows)
    local focusedWindow = hs.window.focusedWindow()
    if not focusedWindow then
      return windows
    end

    for i, win in ipairs(windows) do
      if win == focusedWindow then
        table.remove(windows, i)
        table.insert(windows, 1, focusedWindow)
        break
      end
    end

    return windows
  end

  local function getScreenOrientation()
    local screen = hs.screen.mainScreen()
    local frame = screen:frame()

    if frame.h > frame.w then
      return "portrait"
    else
      return "landscape"
    end
  end

  local function bspTile(windows, frame, depth, orientation)
    if #windows == 1 then
      return { { win = windows[1], frame = frame } }
    end

    local isHorizontal = (orientation == "portrait" and depth % 2 == 0)
      or (orientation == "landscape" and depth % 2 ~= 0)
    local mid = math.floor(#windows / 2)

    local f1 = hs.geometry.copy(frame)
    local f2 = hs.geometry.copy(frame)

    if isHorizontal then
      f1.h = math.ceil(frame.h * mid / #windows) - margin
      f2.y = f1.y + f1.h + margin
      f2.h = frame.h - f1.h - margin
    else
      f1.w = math.ceil(frame.w * mid / #windows) - margin
      f2.x = f1.x + f1.w + margin
      f2.w = frame.w - f1.w - margin
    end

    local left = bspTile({ table.unpack(windows, 1, mid) }, f1, depth + 1, orientation)
    local right = bspTile({ table.unpack(windows, mid + 1) }, f2, depth + 1, orientation)

    return hs.fnutils.concat(left, right)
  end

  local function layoutTiledBSP()
    local screen = hs.screen.mainScreen()
    local screenFrame = screen:frame()
    local windows = getVisibleWindowsInCurrentSpace()
    local numWindows = #windows

    if numWindows == 0 then
      hs.alert.show("No windows to tile in the current space.")
      return
    end

    windows = prioritizeFocusedWindow(windows)

    local orientation = getScreenOrientation()

    screenFrame.x = screenFrame.x + margin
    screenFrame.y = screenFrame.y + margin
    screenFrame.w = screenFrame.w - 2 * margin
    screenFrame.h = screenFrame.h - 2 * margin

    local tiles = bspTile(windows, screenFrame, 0, orientation)

    for _, tile in ipairs(tiles) do
      tile.win:setFrame(tile.frame, 0)
    end
  end

  local function layoutFullScreen()
    local windows = getVisibleWindowsInCurrentSpace()
    if #windows == 0 then
      hs.alert.show("No windows to tile in the current space.")
      return
    end

    local screenFrame = hs.screen.mainScreen():frame()

    screenFrame.x = screenFrame.x + margin
    screenFrame.y = screenFrame.y + margin
    screenFrame.w = screenFrame.w - 2 * margin
    screenFrame.h = screenFrame.h - 2 * margin

    for _, win in ipairs(windows) do
      win:setFrame(screenFrame, 0)
    end
  end

  local function layoutCascading()
    local screen = hs.screen.mainScreen()
    local screenFrame = screen:frame()
    local windows = getVisibleWindowsInCurrentSpace()

    if #windows == 0 then
      hs.alert.show("No windows to cascade in the current space.")
      return
    end

    local cascadeWidth = screenFrame.w * 0.9
    local cascadeHeight = screenFrame.h * 0.9
    local offsetX = margin * 5
    local offsetY = margin * 5
    local maxOffsetCount = math.min(#windows, math.floor((screenFrame.w - cascadeWidth) / offsetX))
    local totalOffsetX = math.min((#windows - 1) * offsetX, maxOffsetCount * offsetX)
    local totalOffsetY = math.min((#windows - 1) * offsetY, maxOffsetCount * offsetY)

    for i = #windows, 1, -1 do
      local win = windows[i]
      local xOffset = math.min((#windows - i) * offsetX, maxOffsetCount * offsetX)
      local yOffset = math.min((#windows - i) * offsetY, maxOffsetCount * offsetY)

      local winFrame = hs.geometry.rect(
        screenFrame.x + xOffset + (screenFrame.w - cascadeWidth) / 2 - totalOffsetX / 2,
        screenFrame.y + yOffset + (screenFrame.h - cascadeHeight) / 2 - totalOffsetY / 2,
        cascadeWidth,
        cascadeHeight
      )

      win:setFrame(winFrame, 0)
    end
  end

  local function layoutMainAndStack()
    local screen = hs.screen.mainScreen()
    local screenFrame = screen:frame()
    local orientation = getScreenOrientation()
    local windows = getVisibleWindowsInCurrentSpace()

    if #windows == 0 then
      hs.alert.show("No windows to arrange.")
      return
    end

    local mainWindow = hs.window.focusedWindow()

    if not mainWindow or not hs.fnutils.contains(windows, mainWindow) then
      mainWindow = windows[1]
    end

    local stackedWindows = {}
    for _, win in ipairs(windows) do
      if win ~= mainWindow then
        table.insert(stackedWindows, win)
      end
    end

    local isLandscape = orientation == "landscape"
    local mainSize = {
      w = isLandscape and (screenFrame.w * 2 / 3 - margin) or (screenFrame.w - margin * 2),
      h = isLandscape and (screenFrame.h - margin * 2) or (screenFrame.h * 2 / 3 - margin),
    }
    local mainPosition = {
      x = screenFrame.x + margin,
      y = screenFrame.y + margin,
    }

    if not isLandscape then
      mainPosition.y = screenFrame.y + margin
    end

    local stackSize = {
      w = isLandscape and (screenFrame.w / 3 - margin * 2) or (screenFrame.w - margin * 2),
      h = isLandscape and (screenFrame.h - margin * 2) or (screenFrame.h / 3 - margin * 2),
    }
    local stackPosition = {
      x = isLandscape and (screenFrame.x + mainSize.w + margin * 2) or screenFrame.x + margin,
      y = isLandscape and (screenFrame.y + margin) or (screenFrame.y + mainSize.h + margin * 2),
    }

    mainWindow:setFrame(hs.geometry.rect(mainPosition.x, mainPosition.y, mainSize.w, mainSize.h), 0)

    for _, win in ipairs(stackedWindows) do
      win:setFrame(hs.geometry.rect(stackPosition.x, stackPosition.y, stackSize.w, stackSize.h), 0)
    end
  end

  local function layoutHalves()
    local screen = hs.screen.mainScreen()
    local screenFrame = screen:frame()
    local orientation = getScreenOrientation()
    local windows = getVisibleWindowsInCurrentSpace()

    if #windows == 0 then
      hs.alert.show("No windows to arrange.")
      return
    end

    local mainWindow = hs.window.focusedWindow()
    if not mainWindow or not hs.fnutils.contains(windows, mainWindow) then
      mainWindow = windows[1]
    end

    -- Ensure mainWindow is the first in the list
    local orderedWindows = {mainWindow}
    for _, win in ipairs(windows) do
      if win ~= mainWindow then
        table.insert(orderedWindows, win)
      end
    end

    local isLandscape = orientation == "landscape"
    local sectionSize = {
      w = isLandscape and ((screenFrame.w - margin * 3) / 2) or (screenFrame.w - margin * 2),
      h = isLandscape and (screenFrame.h - margin * 2) or ((screenFrame.h - margin * 3) / 2),
    }

    local positions = {
      {
        x = screenFrame.x + margin,
        y = screenFrame.y + margin,
      },
      {
        x = isLandscape and (screenFrame.x + sectionSize.w + margin * 2) or screenFrame.x + margin,
        y = isLandscape and screenFrame.y + margin or (screenFrame.y + sectionSize.h + margin * 2),
      }
    }

    -- Place first two windows in their respective positions
    for i = 1, math.min(2, #orderedWindows) do
      orderedWindows[i]:setFrame(hs.geometry.rect(positions[i].x, positions[i].y, sectionSize.w, sectionSize.h), 0)
    end

    -- Stack remaining windows in the second section
    local stackedWindows = {}
    for i = 3, #orderedWindows do
      table.insert(stackedWindows, orderedWindows[i])
    end

    if #stackedWindows > 0 then
      for _, win in ipairs(stackedWindows) do
        win:setFrame(hs.geometry.rect(positions[2].x, positions[2].y, sectionSize.w, sectionSize.h), 0)
      end
    end
  end

  local function layoutThrees()
    local screen = hs.screen.mainScreen()
    local screenFrame = screen:frame()
    local orientation = getScreenOrientation()
    local windows = getVisibleWindowsInCurrentSpace()

    if #windows == 0 then
      hs.alert.show("No windows to arrange.")
      return
    end

    local mainWindow = hs.window.focusedWindow()
    if not mainWindow or not hs.fnutils.contains(windows, mainWindow) then
      mainWindow = windows[1]
    end

    -- Ensure mainWindow is the first in the list
    local orderedWindows = {mainWindow}
    for _, win in ipairs(windows) do
      if win ~= mainWindow then
        table.insert(orderedWindows, win)
      end
    end

    local isLandscape = orientation == "landscape"
    local sectionSize = {
      w = isLandscape and ((screenFrame.w - margin * 4) / 3) or (screenFrame.w - margin * 2),
      h = isLandscape and (screenFrame.h - margin * 2) or ((screenFrame.h - margin * 4) / 3),
    }

    local positions = {
      {
        x = screenFrame.x + margin,
        y = screenFrame.y + margin,
      },
      {
        x = isLandscape and (screenFrame.x + sectionSize.w + margin * 2) or screenFrame.x + margin,
        y = isLandscape and screenFrame.y + margin or (screenFrame.y + sectionSize.h + margin * 2),
      },
      {
        x = isLandscape and (screenFrame.x + sectionSize.w * 2 + margin * 3) or screenFrame.x + margin,
        y = isLandscape and screenFrame.y + margin or (screenFrame.y + sectionSize.h * 2 + margin * 3),
      }
    }

    -- Place first two windows in their respective positions
    for i = 1, math.min(2, #orderedWindows) do
      orderedWindows[i]:setFrame(hs.geometry.rect(positions[i].x, positions[i].y, sectionSize.w, sectionSize.h), 0)
    end

    -- Stack remaining windows in the third section
    local stackedWindows = {}
    for i = 3, #orderedWindows do
      table.insert(stackedWindows, orderedWindows[i])
    end

    if #stackedWindows > 0 then
      for _, win in ipairs(stackedWindows) do
        win:setFrame(hs.geometry.rect(positions[3].x, positions[3].y, sectionSize.w, sectionSize.h), 0)
      end
    end
  end

  return {
    layoutTiledBSP = layoutTiledBSP,
    layoutFullScreen = layoutFullScreen,
    layoutCascading = layoutCascading,
    layoutMainAndStack = layoutMainAndStack,
    layoutThrees = layoutThrees,
    layoutHalves = layoutHalves,
  }
end

return windowLayout
