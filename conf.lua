function love.conf(t)
    t.version       = "0.10.2"

--    t.window.fullscreen = false -- for web release

    t.window.fullscreen = true
    t.window.fullscreentype = "exclusive"
--    t.window.fullscreentype = "desktop" -- recording

    t.window.title  = "defendroids"
--    t.window.width  = 1280 -- for web release
--    t.window.height = 800 -- for web release
--    t.window.width  = 1280 -- recording
--    t.window.height = 800 -- recording

    t.window.width  = 2560
    t.window.height = 1600

    t.window.vsync  = true
end
