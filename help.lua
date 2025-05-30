local function wpHelp(wp)
  local function keyList()
    local rows = {}

    -- Collect and sort
    for name, data in pairs(wp.hotkeys) do
      local mods, key = table.unpack(data.keys or {})
      if mods and key then
        local combo = table.concat(mods, "+") .. "+" .. key
        table.insert(rows, { combo = combo, action = name })
      end
    end

    table.sort(rows, function(a, b)
      return a.action < b.action
    end)

    -- Find max combo width
    local maxComboLen = 0
    for _, row in ipairs(rows) do
      if #row.combo > maxComboLen then
        maxComboLen = #row.combo
      end
    end

    -- Format lines with manual padding
    local lines = { "📘 WindowPilot Hotkeys\n" }
    for _, row in ipairs(rows) do
      local paddedCombo = row.combo .. string.rep(" ", maxComboLen - #row.combo)
      table.insert(lines, string.format("  %s   %s", paddedCombo, row.action))
    end

    hs.alert.show(
      hs.styledtext.new(table.concat(lines, "\n"), {
        font = { name = "Menlo", size = 14 },
        color = { white = 1 },
        paragraphStyle = { lineSpacing = 4 },
      }),
      8
    )
  end

  return {
    keyList = keyList,
  }
end

return wpHelp
