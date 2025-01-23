local function menuItem(wp)
  local menubar = hs.menubar.new()

  local function updateMenu()
    if menubar then
      menubar:setTitle("")
      local image = hs.image.imageFromName("NSStatusAvailable")
      menubar:setIcon(image)

      menubar:setMenu({
        {
          title = "Binary Space Partitioning",
          fn = function()
            wp.commands.windowLayout.layoutTiledBSP()
            updateMenu()
          end,
        },
        {
          title = "Main and Stack",
          fn = function()
            wp.commands.windowLayout.layoutMainAndStack()
            updateMenu()
          end,
        },
        {
          title = "Threes",
          fn = function()
            wp.commands.windowLayout.layoutThrees()
            updateMenu()
          end,
        },
        {
          title = "Full Screen",
          fn = function()
            wp.commands.windowLayout.layoutFullScreen()
            updateMenu()
          end,
        },
        {
          title = "Cascading",
          fn = function()
            wp.commands.windowLayout.layoutCascading()
            updateMenu()
          end,
        },
      })
    end
  end

  updateMenu()
end

return menuItem
