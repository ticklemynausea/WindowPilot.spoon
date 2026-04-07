local function windowPopup(wp)
  local popup = {}
  local currentCanvas = nil
  local hideTimer = nil

  function popup.show(text, duration, icon)
    -- Cancel any existing popup and timer
    popup.hide()

    -- Get screen frame
    local screen = hs.screen.mainScreen()
    local screenFrame = screen:frame()

    -- Set up text styling
    local textStyle = {
      font = { name = "Helvetica Neue", size = 18 },
      color = { white = 1, alpha = 1 },
      paragraphStyle = { alignment = "center" }
    }

    -- Create styled text
    local styledText = hs.styledtext.new(text, textStyle)

    -- Calculate sizes
    local textSize = hs.drawing.getTextDrawingSize(text, textStyle)
    local padding = 12
    local iconSize = 32
    local iconPadding = 8

    -- Calculate width including icon if present
    local contentWidth = textSize.w
    if icon then
      contentWidth = contentWidth + iconSize + iconPadding
    end

    local popupWidth = math.min(contentWidth + padding * 2, screenFrame.w * 0.8)
    local popupHeight = math.max(textSize.h, iconSize) + padding * 2

    -- Calculate position (centered horizontally, bottom tenth vertically)
    local xPosition = screenFrame.x + (screenFrame.w - popupWidth) / 2
    local yPosition = screenFrame.y + (screenFrame.h * 0.9) -- Bottom tenth

    -- Create canvas
    currentCanvas = hs.canvas.new({
      x = xPosition,
      y = yPosition,
      w = popupWidth,
      h = popupHeight
    })

    -- Add background with rounded corners
    local elements = {
      {
        type = "rectangle",
        action = "fill",
        roundedRectRadii = { xRadius = 8, yRadius = 8 },
        fillColor = { white = 0.1, alpha = 0.9 }
      },
      {
        type = "rectangle",
        action = "stroke",
        roundedRectRadii = { xRadius = 8, yRadius = 8 },
        strokeColor = { white = 0.3, alpha = 0.8 },
        strokeWidth = 1
      }
    }

    -- Add icon if present
    local textXOffset = padding
    if icon then
      table.insert(elements, {
        type = "image",
        image = icon,
        frame = {
          x = padding,
          y = padding + (popupHeight - padding * 2 - iconSize) / 2,
          w = iconSize,
          h = iconSize
        }
      })
      textXOffset = padding + iconSize + iconPadding
    end

    -- Add text (vertically centered with icon)
    table.insert(elements, {
      type = "text",
      text = styledText,
      frame = {
        x = textXOffset,
        y = padding + (popupHeight - padding * 2 - textSize.h) / 2,
        w = popupWidth - textXOffset - padding,
        h = textSize.h
      }
    })

    currentCanvas:appendElements(elements)

    -- Show the canvas
    currentCanvas:show()

    -- Set up timer to hide the popup
    hideTimer = hs.timer.doAfter(duration or 0.75, function()
      popup.hide()
    end)
  end

  function popup.hide()
    if hideTimer then
      hideTimer:stop()
      hideTimer = nil
    end
    if currentCanvas then
      currentCanvas:delete()
      currentCanvas = nil
    end
  end

  return popup
end

return windowPopup