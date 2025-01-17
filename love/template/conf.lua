VERSION = "V0.1"
DEV = true  

lockedAspectRatio = true
screenBarColour = {0,0,0}

function love.conf(t)
    t.title = "Top Secret Jaraph Game " .. VERSION
    t.window.icon = "image/icon/icon256.png"

    t.window.width = 1920/2
    t.window.height = 1080/2

    t.window.resizable = true
    t.console = DEV
end