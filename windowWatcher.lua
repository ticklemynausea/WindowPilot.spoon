local function windowWatcher(wp)
  local watcher = {}
  local popup = require("windowPopup")(wp)
  local windowFilter = nil
  local lastFocusedWindow = nil
  local ignoreNextChange = false

  -- Track if we should show popups (can be toggled)
  local showPopups = true

  function watcher.setIgnoreNext()
    ignoreNextChange = true
  end

  function watcher.enablePopups()
    showPopups = true
    wp:logMessage("INFO", "Window switch popups enabled")
  end

  function watcher.disablePopups()
    showPopups = false
    popup.hide()
    wp:logMessage("INFO", "Window switch popups disabled")
  end

  function watcher.togglePopups()
    if showPopups then
      watcher.disablePopups()
    else
      watcher.enablePopups()
    end
    return showPopups
  end

  local function onWindowFocused(window, appName)
    -- Skip if popups are disabled
    if not showPopups then
      return
    end

    -- Skip if we should ignore this change (e.g., from our own switching)
    if ignoreNextChange then
      ignoreNextChange = false
      return
    end

    -- Skip if it's the same window
    if lastFocusedWindow and window and lastFocusedWindow:id() == window:id() then
      return
    end

    lastFocusedWindow = window

    if window then
      local app = window:application()
      local title = window:title()
      local displayText = appName or (app and app:name()) or "Unknown"

      -- Add title on same line with em dash separator if meaningful and different
      if title and title ~= "" and title ~= displayText and string.len(title) < 50 then
        displayText = displayText .. " — " .. title
      end

      -- Get app icon using bundleID
      local appIcon = nil
      if app then
        local bundleID = app:bundleID()
        if bundleID then
          appIcon = hs.image.imageFromAppBundle(bundleID)
        end
      end

      popup.show(displayText, nil, appIcon)
    end
  end

  function watcher.start()
    -- Create window filter for all windows
    windowFilter = hs.window.filter.new()
    windowFilter:setDefaultFilter({})
    windowFilter:setSortOrder(hs.window.filter.sortByFocusedLast)

    -- Subscribe to window focus events
    windowFilter:subscribe(hs.window.filter.windowFocused, onWindowFocused)

    -- Get initial focused window
    lastFocusedWindow = hs.window.focusedWindow()

    wp:logMessage("INFO", "Window watcher started")
  end

  function watcher.stop()
    if windowFilter then
      windowFilter:unsubscribeAll()
      windowFilter = nil
    end
    popup.hide()
    wp:logMessage("INFO", "Window watcher stopped")
  end

  return watcher
end

return windowWatcher