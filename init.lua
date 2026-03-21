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
    logLevel = "INFO", -- DEBUG, INFO, WARN, ERROR
    windowSizes = {
      move = { 0.5, 0.3335, 0.669 },
      center = { 0.6, 0.75, 0.9 }
    },
    cascadeOffset = 5,
    notificationDuration = 2
  }

  wp.log = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4
  }

  function wp:logMessage(level, message)
    local levels = { "DEBUG", "INFO", "WARN", "ERROR" }
    local configLevel = self.log[self.configuration.logLevel] or self.log.INFO
    local messageLevel = self.log[level] or self.log.INFO

    if messageLevel >= configLevel then
      print(string.format("[WindowPilot %s] %s", level, message))
    end
  end

  function wp:showNotification(message, duration)
    if not message or type(message) ~= "string" then
      wp:logMessage("ERROR", "showNotification called with invalid message")
      return
    end
    duration = duration or wp.configuration.notificationDuration
    hs.alert.show(message, duration)
  end

  function wp:validateConfiguration()
    if not self.configuration.windowMargin or type(self.configuration.windowMargin) ~= "number" then
      self.configuration.windowMargin = 6
      wp:logMessage("WARN", "Invalid windowMargin, using default: 6")
    end

    if not self.configuration.windowSizes or not self.configuration.windowSizes.move then
      self.configuration.windowSizes = {
        move = { 0.5, 0.3335, 0.669 },
        center = { 0.6, 0.75, 0.9 }
      }
      wp:logMessage("WARN", "Invalid windowSizes, using defaults")
    end
  end

  for key, value in pairs(configuration) do
    wp.configuration[key] = value
  end

  wp:validateConfiguration()
  wp:logMessage("INFO", "Configured")

  wp.commands = {
    switchWindow = require("switchWindow")(wp),
    mouseCursor = require("mouseCursor")(wp),
    windowLayout = require("windowLayout")(wp),
    windowMovement = require("windowMovement")(wp),
    wpHelp = require("help")(wp),
  }

  require("menuItem")(wp)

  wp:logMessage("INFO", "Initialized")
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
        wp.hotkeys[actionPath] = {
          keys = value,
          action = hs.hotkey.bind(value[1], value[2], function()
            command(wp)
          end),
        }
        wp:logMessage("DEBUG", "Bound key for " .. actionPath)
      else
        wp:logMessage("ERROR", "Command not found for " .. actionPath)
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

    wp.hotkeys[actionPath] = {
      keys = { mods, key },
      action = hs.hotkey.bind(mods, key, function()
        wp.commands.switchWindow.toApp(name)
      end),
    }

    wp:logMessage("DEBUG", "Bound window shortcut for " .. name)
  end
end

return wp
