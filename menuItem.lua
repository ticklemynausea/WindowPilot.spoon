local function menuItem(wp)
  local menubar = hs.menubar.new()

  -- Action name mapping for user-friendly menu titles
  local actionNames = {
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
  local categoryRules = {
    { name = "Layouts", pattern = "^windowLayout%." },
    { name = "Screen & Space", pattern = "^windowMovement%..*Screen$" },
    { name = "Screen & Space", pattern = "^windowMovement%..*Space$" },
    { name = "Window Movement", pattern = "^windowMovement%." },
    { name = "Window Switching", pattern = "^switchWindow%." },
    { name = "Mouse Cursor", pattern = "^mouseCursor%." },
    { name = "Help", pattern = "^wpHelp%." }
  }

  -- Define category display order
  local categoryOrder = {
    "Layouts",
    "Window Movement",
    "Screen & Space",
    "Window Switching",
    "Mouse Cursor",
    "Help"
  }

  local function getActionCommand(actionPath)
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

  local function categorizeAction(actionPath)
    -- Find category for action
    for _, rule in ipairs(categoryRules) do
      if actionPath:match(rule.pattern) then
        return rule.name
      end
    end
    return "Other"
  end

  local function createMenuItem(actionName, shortcut, command)
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

  local function buildMenuItems()
    local menuItems = {}

    -- Count and log hotkeys
    local hotkeyCount = 0
    if wp.hotkeys then
      for _ in pairs(wp.hotkeys) do
        hotkeyCount = hotkeyCount + 1
      end
    end
    wp:logMessage("DEBUG", "Building menu items from " .. hotkeyCount .. " hotkeys")

    -- First, collect all actions by category
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
        local actionName = actionNames[actionPath]
        local shortcut = wp:formatKeyShortcut(hotkeyData.keys)
        local command = getActionCommand(actionPath)

        wp:logMessage("DEBUG", "Processing action: " .. actionPath .. " -> " .. (actionName or "UNKNOWN"))

        if actionName and command then
          local category = categorizeAction(actionPath)
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

    -- Build menu in category order
    for _, categoryName in ipairs(categoryOrder) do
      local actions = categorizedActions[categoryName]
      if actions and #actions > 0 then
        -- Add separator if not first category
        if #menuItems > 0 then
          table.insert(menuItems, { title = "-" })
        end

        -- Add all actions in this category
        for _, action in ipairs(actions) do
          table.insert(menuItems, createMenuItem(action.name, action.shortcut, action.command))
        end
      end
    end

    -- Add app shortcuts at the end
    if #appShortcuts > 0 then
      if #menuItems > 0 then
        table.insert(menuItems, { title = "-" })
      end
      for _, app in ipairs(appShortcuts) do
        table.insert(menuItems, createMenuItem(app.name, app.shortcut, app.fn))
      end
    end

    return menuItems
  end

  local function updateMenu()
    if menubar then
      menubar:setTitle("")
      local image = hs.image.imageFromName("NSStatusAvailable")
      menubar:setIcon(image)

      local menuItems = buildMenuItems()
      menubar:setMenu(menuItems)
    end
  end

  updateMenu()
  return { updateMenu = updateMenu }
end

return menuItem
