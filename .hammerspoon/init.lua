-- section window manipulation

hs.window.animationDuration = 0

function reloadConfig(files)
  local doReload = false
  for _,file in pairs(files) do
    if file:sub(-4) == ".lua" then
      doReload = true
    end
  end
  if doReload then
    hs.reload()
    hs.alert.show('Config Reloaded')
  end
end
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()

function bindKey(key, fn)
  hs.hotkey.bind({"cmd", "ctrl"}, key, fn)
end

positions = {
  maximized = hs.layout.maximized,
  centered = {x=0.10, y=0.10, w=0.8, h=0.8},

  left34 = {x=0, y=0, w=0.34, h=1},
  left50 = hs.layout.left50,
  left66 = {x=0, y=0, w=0.66, h=1},
  left70 = hs.layout.left70,

  right30 = hs.layout.right30,
  right34 = {x=0.66, y=0, w=0.34, h=1},
  right50 = hs.layout.right50,
  right66 = {x=0.34, y=0, w=0.66, h=1},

  upper50 = {x=0, y=0, w=1, h=0.5},
  upper50Left50 = {x=0, y=0, w=0.5, h=0.5},
  upper50Right15 = {x=0.85, y=0, w=0.15, h=0.5},
  upper50Right30 = {x=0.7, y=0, w=0.3, h=0.5},
  upper50Right50 = {x=0.5, y=0, w=0.5, h=0.5},

  lower50 = {x=0, y=0.5, w=1, h=0.5},
  lower50Left50 = {x=0, y=0.5, w=0.5, h=0.5},
  lower50Right50 = {x=0.5, y=0.5, w=0.5, h=0.5},

  chat = {x=0.5, y=0, w=0.35, h=0.5},

  -- these paired together fill the right half of the screen
  right50top70 = {x=0.5, y=0, w=0.5, h=0.7},
  terminalLarge = {x=0.5, y=0.7, w=0.5, h=0.3},

  -- these paried together fill the left half of the screen
  left50top50 = {x=0, y=0, w=0.5, h=0.5},
  left50bottom50 = {x=0, y=0.5, w=0.5, h=0.5},

  brokenscreenright = {x=0.5, y=0, w=0.40, h=1},
  brokenscreencentered = {x=0.05, y=0.05, w=0.8, h=.95}
}

--
-- Layouts
--

layouts = {
  {
    name="Sublime (General)",
    description="Sublime, Chrome, Terminal",
    small={
      {"Sublime Text", nil, screen, positions.left50, nil, nil},
      {"Google Chrome", nil, screen, positions.brokenscreencentered, nil, nil},
      {"Terminal", nil, screen, positions.brokenscreenright, nil, nil},
      {"Spotify", nil, screen, positions.brokenscreencentered, nil, nil},
      {"Evernote", nil, screen, positions.brokenscreencentered, nil, nil},
    },
    large={
      {"Sublime Text", nil, screen, positions.left50, nil, nil},
      {"Google Chrome", nil, screen, positions.right50top70, nil, nil},
      {"Terminal", nil, screen, positions.terminalLarge, nil, nil},
      {"Spotify", nil, screen, positions.centered, nil, nil},
      {"Evernote", nil, screen, positions.centered, nil, nil},
    }
  },
  {
    name="Sublime (Learning Ember.js)",
    description="Sublime, Chrome, Terminal, Ember-CLI pdf",
    large={
      {"Sublime Text", nil, screen, positions.right50top70, nil, nil},
      {"Google Chrome", nil, screen, positions.left50top50, nil, nil},
      {"Terminal", nil, screen, positions.terminalLarge, nil, nil},
      {"Preview", nil, screen, positions.left50bottom50}
    }
  },
  {
    name="Emacs",
    description="Emacs, Chrome, Terminal",
    small={
      {"Emacs", nil, screen, positions.left50, nil, nil},
      {"Google Chrome", nil, screen, positions.brokenscreencentered, nil, nil},
      {"Terminal", nil, screen, positions.brokenscreenright, nil, nil},
      {"Spotify", nil, screen, positions.brokenscreencentered, nil, nil},
      {"Evernote", nil, screen, positions.brokenscreencentered, nil, nil},
    },
    large={
      {"Emacs", nil, screen, positions.left50, nil, nil},
      {"Google Chrome", nil, screen, positions.right50top70
      , nil, nil},
      {"Terminal", nil, screen, positions.terminalLarge, nil, nil},
      {"Spotify", nil, screen, positions.centered, nil, nil},
      {"Evernote", nil, screen, positions.centered, nil, nil},
    }
  },

}
currentLayout = null

function applyLayout(layout)
  local screen = hs.screen.mainScreen()

  local layoutSize = layout.small
  if layout.large and screen:currentMode().w > 1500 then
    layoutSize = layout.large
  end

  currentLayout = layout
  hs.layout.apply(layoutSize, function(windowTitle, layoutWindowTitle)
    return string.sub(windowTitle, 1, string.len(layoutWindowTitle)) == layoutWindowTitle
  end)
end

layoutChooser = hs.chooser.new(function(selection)
  if not selection then return end

  applyLayout(layouts[selection.index])
end)
i = 0
layoutChooser:choices(hs.fnutils.imap(layouts, function(layout)
  i = i + 1

  return {
    index=i,
    text=layout.name,
    subText=layout.description
  }
end))
layoutChooser:rows(#layouts)
layoutChooser:width(20)
layoutChooser:subTextColor({red=0, green=0, blue=0, alpha=0.4})

bindKey(';', function()
  layoutChooser:show()
end)

hs.screen.watcher.new(function()
  if not currentLayout then return end

  applyLayout(currentLayout)
end):start()

--
-- Grid
--

grid = {
  {key="u", units={positions.upper50Left50}},
  {key="i", units={positions.upper50}},
  {key="o", units={positions.upper50Right50}},

  {key="j", units={positions.left50, positions.left66, positions.left34}},
  {key="k", units={positions.centered, positions.maximized}},
  {key="l", units={positions.right50, positions.right66, positions.right34}},

  {key="m", units={positions.lower50Left50}},
  {key=",", units={positions.lower50}},
  {key=".", units={positions.lower50Right50}}
}
hs.fnutils.each(grid, function(entry)
  bindKey(entry.key, function()
    local units = entry.units
    local screen = hs.screen.mainScreen()
    local window = hs.window.focusedWindow()
    local windowGeo = window:frame()

    local index = 0
    hs.fnutils.find(units, function(unit)
      index = index + 1
      local geo = hs.geometry.new(unit):fromUnitRect(screen:frame()):floor()
      return windowGeo:equals(geo)
    end)
    if index == #units then index = 0 end

    currentLayout = null
    window:moveToUnit(units[index + 1])
  end)
end)

-- end section window manipulation

-- section screen manipulation

function moveWindowRight()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = s or win:screen()
  local max = screen:next():frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w
  f.h = max.h
  win:setFrame(f)
end

function moveWindowLeft()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = s or win:screen()
  local max = screen:previous():frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w
  f.h = max.h
  win:setFrame(f)
end

hs.hotkey.bind({"cmd", "ctrl", "alt"}, "right", moveWindowRight)
hs.hotkey.bind({"cmd", "ctrl", "alt"}, "left", moveWindowLeft)

-- end section screen manipulation

-- section Spotify controller

hs.hotkey.bind({}, 'f1', hs.spotify.previous)
hs.hotkey.bind({}, 'f2', hs.spotify.playpause)
hs.hotkey.bind({}, 'f3', hs.spotify.next)
hs.hotkey.bind({}, 'f4', hs.spotify.displayCurrentTrack)

-- end section Spotify controller


