local wp = {}
wp.__index = wp

wp.name = "WindowPilot"
wp.version = "1.0"
wp.author = "Mário Carneiro"
wp.license = "MIT - https://opensource.org/licenses/MIT"
wp.homepage = "https://github.com/ticklemynausea/WindowPilot.spoon"

function wp:initialize(configuration)
  local resourcePath = hs.spoons.resourcePath("")
  package.path = resourcePath .. "/?.lua;" .. package.path

  wp.hotkeys = {}

  wp.configuration = {
    windowMargin = 6,
  }

  for key, value in pairs(configuration) do
    wp.configuration[key] = value
  end

  print("[WindowPilot] Configured")

  wp.commands = {
    switchWindow = require("switchWindow")(wp),
    mouseCursor = require("mouseCursor")(wp),
    windowLayout = require("windowLayout")(wp),
    windowMovement = require("windowMovement")(wp),
  }

  require("menuItem")(wp)

  print("[WindowPilot] Initialized")
end

function wp:bindKeys(mapping, prefix)
  for key, value in pairs(mapping) do
    local actionPath = prefix and (prefix .. "." .. key) or key

    if type(value[1]) == "table" then
      local command = wp.commands
      for part in actionPath:gmatch("[^.]+") do
        command = command and command[part]
      end

      if type(command) == "function" then
        if wp.hotkeys[actionPath] then
          wp.hotkeys[actionPath]:delete()
        end
        wp.hotkeys[actionPath] = hs.hotkey.bind(value[1], value[2], function()
          command(wp)
        end)
        print("[WindowPilot] Bound key for " .. actionPath)
      else
        print("[WindowPilot] Error: Command not found for " .. actionPath)
      end
    else
      self:bindKeys(value, actionPath)
    end
  end
end

function wp:bindShortcuts(bindings)
  for _, binding in ipairs(bindings) do
    local mods, key = table.unpack(binding.keys)
    local name = binding.name
    local actionPath = "focusWindow:" .. name

    if wp.hotkeys[actionPath] then
      wp.hotkeys[actionPath]:delete()
    end

    wp.hotkeys[actionPath] = hs.hotkey.bind(mods, key, function()
      wp.commands.switchWindow.toApp(name)
    end)

    print("[WindowPilot] Bound window shortcut for " .. name)
  end
end

return wp
