local function menuItem(wp)
  -- Public API (exposed to the module consumer)
  local public = {}

  -- Private variables and functions (internal to the module)
  local private = {}

  -- Module state
  private.menubar = hs.menubar.new()
  private.customIcon = nil -- Cache the icon

  -- Public functions
  public.updateMenu = function()
    if private.menubar then
      -- Use custom WindowPilot icon
      local icon = private.getOrCreateIcon()
      if icon then
        private.menubar:setIcon(icon)
        private.menubar:setTitle("")
        wp:logMessage("DEBUG", "Using custom WindowPilot icon")
      else
        -- Fallback to text symbol
        private.menubar:setTitle("⌘")
        private.menubar:setIcon(nil)
        wp:logMessage("WARN", "Could not create custom icon, using text fallback")
      end

      local menuItems = private.buildMenuItems()
      private.menubar:setMenu(menuItems)
    end
  end

  -- Private data and configuration
  private.actionNames = {
    -- Window Layout
    ["windowLayout.layoutTiledBSP"] = "Binary Space Partitioning",
    ["windowLayout.layoutMainAndStack"] = "Main and Stack",
    ["windowLayout.layoutHalves"] = "Halves",
    ["windowLayout.layoutThrees"] = "Threes",
    ["windowLayout.layoutFullScreen"] = "Full Screen",
    ["windowLayout.layoutCascading"] = "Cascading",

    -- Window Movement
    ["windowMovement.moveWindowLeft"] = "Move Window Left",
    ["windowMovement.moveWindowRight"] = "Move Window Right",
    ["windowMovement.moveWindowTop"] = "Move Window Up",
    ["windowMovement.moveWindowBottom"] = "Move Window Down",
    ["windowMovement.moveWindowCenter"] = "Move Window Center",
    ["windowMovement.moveWindowToNextScreen"] = "Move Window to Next Screen",
    ["windowMovement.moveWindowToPreviousScreen"] = "Move Window to Previous Screen",
    ["windowMovement.moveWindowToNextSpace"] = "Move Window to Next Space",
    ["windowMovement.moveWindowToPreviousSpace"] = "Move Window to Previous Space",

    -- Window Switching
    ["switchWindow.forward"] = "Switch to Next Window",
    ["switchWindow.backward"] = "Switch to Previous Window",

    -- Mouse Cursor
    ["mouseCursor.moveToNextScreen"] = "Move Cursor to Next Screen",
    ["mouseCursor.moveToPreviousScreen"] = "Move Cursor to Previous Screen",

    -- Help
    ["wpHelp.keyList"] = "Show Keyboard Shortcuts"
  }

  -- Category organization with specific patterns first
  private.categoryRules = {
    { name = "Layouts", pattern = "^windowLayout%." },
    { name = "Screen & Space", pattern = "^windowMovement%..*Screen$" },
    { name = "Screen & Space", pattern = "^windowMovement%..*Space$" },
    { name = "Window Movement", pattern = "^windowMovement%." },
    { name = "Window Switching", pattern = "^switchWindow%." },
    { name = "Mouse Cursor", pattern = "^mouseCursor%." },
    { name = "Help", pattern = "^wpHelp%." }
  }

  -- Define category display order
  private.categoryOrder = {
    "Layouts",
    "Window Movement",
    "Screen & Space",
    "Window Switching",
    "Mouse Cursor",
    "Help"
  }

  -- Private helper functions
  private.getActionCommand = function(actionPath)
    local parts = {}
    for part in actionPath:gmatch("[^.]+") do
      table.insert(parts, part)
    end

    if #parts >= 2 then
      local category, action = parts[1], parts[2]
      return wp.commands[category] and wp.commands[category][action]
    end
    return nil
  end

  private.categorizeAction = function(actionPath)
    -- Find category for action
    for _, rule in ipairs(private.categoryRules) do
      if actionPath:match(rule.pattern) then
        return rule.name
      end
    end
    return "Other"
  end

  private.createMenuItem = function(actionName, shortcut, command)
    local menuItem = {
      fn = function()
        command()
      end
    }

    if shortcut and shortcut ~= "" then
      local styledText = hs.styledtext.new(actionName .. "\t" .. shortcut, {
        font = { name = "Helvetica", size = 14 },
        paragraphStyle = {
          tabStops = {
            { location = 300, alignment = "right" }
          }
        }
      })
      menuItem.title = styledText
    else
      menuItem.title = actionName
    end

    return menuItem
  end

  private.parseShortcut = function(shortcut)
    -- Count modifier symbols at the beginning
    local modCount = 0
    local key = shortcut

    -- Count each modifier symbol
    for _, mod in ipairs({"⌘", "⇧", "⌥", "⌃"}) do
      local _, count = shortcut:gsub(mod, "")
      modCount = modCount + count
      key = key:gsub(mod, "")
    end

    -- Extract numeric key if present
    local numKey = tonumber(key) or 999  -- Non-numeric keys go to the end

    return modCount, numKey, key
  end

  private.sortAppShortcuts = function(shortcuts)
    table.sort(shortcuts, function(a, b)
      local aModCount, aNumKey, aKey = private.parseShortcut(a.shortcut)
      local bModCount, bNumKey, bKey = private.parseShortcut(b.shortcut)

      -- First sort by modifier count (fewer modifiers first)
      if aModCount ~= bModCount then
        return aModCount < bModCount
      end

      -- Then by numeric key value
      if aNumKey ~= bNumKey then
        return aNumKey < bNumKey
      end

      -- Finally by key string (for non-numeric keys)
      return aKey < bKey
    end)
  end

  private.collectHotkeyActions = function()
    local categorizedActions = {}
    local appShortcuts = {}

    for actionPath, hotkeyData in pairs(wp.hotkeys or {}) do
      if actionPath:match("^focusWindow:") then
        -- Handle app shortcuts separately
        local appName = actionPath:match("^focusWindow:(.+)")
        local shortcut = wp:formatKeyShortcut(hotkeyData.keys)
        if appName and shortcut then
          table.insert(appShortcuts, {
            name = appName,
            shortcut = shortcut,
            fn = function() wp.commands.switchWindow.toApp(appName) end
          })
        end
      else
        -- Handle regular actions
        local actionName = private.actionNames[actionPath]
        local shortcut = wp:formatKeyShortcut(hotkeyData.keys)
        local command = private.getActionCommand(actionPath)

        wp:logMessage("DEBUG", "Processing action: " .. actionPath .. " -> " .. (actionName or "UNKNOWN"))

        if actionName and command then
          local category = private.categorizeAction(actionPath)
          if not categorizedActions[category] then
            categorizedActions[category] = {}
          end
          table.insert(categorizedActions[category], {
            name = actionName,
            shortcut = shortcut,
            command = command
          })
        end
      end
    end

    return categorizedActions, appShortcuts
  end

  private.addCategorizedActions = function(menuItems, categorizedActions)
    for _, categoryName in ipairs(private.categoryOrder) do
      local actions = categorizedActions[categoryName]
      if actions and #actions > 0 then
        -- Add separator if not first category
        if #menuItems > 0 then
          table.insert(menuItems, { title = "-" })
        end

        -- Add all actions in this category
        for _, action in ipairs(actions) do
          table.insert(menuItems, private.createMenuItem(action.name, action.shortcut, action.command))
        end
      end
    end
  end

  private.addAppShortcuts = function(menuItems, appShortcuts)
    if #appShortcuts > 0 then
      private.sortAppShortcuts(appShortcuts)

      if #menuItems > 0 then
        table.insert(menuItems, { title = "-" })
      end
      for _, app in ipairs(appShortcuts) do
        table.insert(menuItems, private.createMenuItem(app.name, app.shortcut, app.fn))
      end
    end
  end

  private.buildMenuItems = function()
    local menuItems = {}

    -- Count and log hotkeys
    local hotkeyCount = 0
    if wp.hotkeys then
      for _ in pairs(wp.hotkeys) do
        hotkeyCount = hotkeyCount + 1
      end
    end
    wp:logMessage("DEBUG", "Building menu items from " .. hotkeyCount .. " hotkeys")

    -- Collect all actions and app shortcuts
    local categorizedActions, appShortcuts = private.collectHotkeyActions()

    -- Build menu in category order
    private.addCategorizedActions(menuItems, categorizedActions)

    -- Add sorted app shortcuts at the end
    private.addAppShortcuts(menuItems, appShortcuts)

    return menuItems
  end

  private.createCustomIcon = function()
    -- Create a professional window manager icon
    local size = 22
    local canvas = hs.canvas.new({ x = 0, y = 0, w = size, h = size })

    -- Modern window tiling icon design
    -- Background (subtle)
    canvas[1] = {
      type = "rectangle",
      frame = { x = 1, y = 1, w = size-2, h = size-2 },
      fillColor = { white = 0, alpha = 0 },
      strokeColor = { white = 0, alpha = 0 }
    }

    -- Main window (left side)
    canvas[2] = {
      type = "rectangle",
      frame = { x = 2, y = 3, w = 8, h = 16 },
      fillColor = { white = 0.1, alpha = 0.7 },
      strokeColor = { white = 0.3 },
      strokeWidth = 0.5,
      roundedRectRadii = { xRadius = 1, yRadius = 1 }
    }

    -- Secondary windows (right side, stacked)
    canvas[3] = {
      type = "rectangle",
      frame = { x = 12, y = 3, w = 8, h = 7 },
      fillColor = { white = 0.1, alpha = 0.5 },
      strokeColor = { white = 0.3 },
      strokeWidth = 0.5,
      roundedRectRadii = { xRadius = 1, yRadius = 1 }
    }

    canvas[4] = {
      type = "rectangle",
      frame = { x = 12, y = 12, w = 8, h = 7 },
      fillColor = { white = 0.1, alpha = 0.5 },
      strokeColor = { white = 0.3 },
      strokeWidth = 0.5,
      roundedRectRadii = { xRadius = 1, yRadius = 1 }
    }

    -- Title bars (small rectangles on top)
    canvas[5] = {
      type = "rectangle",
      frame = { x = 2, y = 3, w = 8, h = 2 },
      fillColor = { white = 0.4, alpha = 0.8 },
      roundedRectRadii = { xRadius = 1, yRadius = 1 }
    }

    canvas[6] = {
      type = "rectangle",
      frame = { x = 12, y = 3, w = 8, h = 2 },
      fillColor = { white = 0.4, alpha = 0.6 },
      roundedRectRadii = { xRadius = 1, yRadius = 1 }
    }

    canvas[7] = {
      type = "rectangle",
      frame = { x = 12, y = 12, w = 8, h = 2 },
      fillColor = { white = 0.4, alpha = 0.6 },
      roundedRectRadii = { xRadius = 1, yRadius = 1 }
    }

    return canvas:imageFromCanvas()
  end

  private.getOrCreateIcon = function()
    -- Return cached icon if we already created it
    if private.customIcon then
      return private.customIcon
    end

    -- Create custom icon in memory (no file saving)
    private.customIcon = private.createCustomIcon()
    if private.customIcon then
      wp:logMessage("INFO", "Created custom WindowPilot icon in memory")
      return private.customIcon
    end

    wp:logMessage("WARN", "Failed to create custom icon")
    return nil
  end

  -- Initialize the menu on module load
  public.updateMenu()

  -- Return public API
  return public
end

return menuItem
