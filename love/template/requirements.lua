require("templateLib/quindoc")
require("templateLib/dante")


tweens = require("templateLib/tweens")
buttons = require("templateLib/graetUI")
audioPlayer = require("templateLib/audioManager")

code = {}
code.EntityManager = love.filesystem.load("code/class/entityManager.lua")()
code.Plane = love.filesystem.load("code/class/plane.lua")()
code.Bullet = love.filesystem.load("code/class/bullet.lua")()

code.effect = {}
code.effect.Smoke = love.filesystem.load("code/class/smokeEffect.lua")()
code.effect.Explosion = love.filesystem.load("code/class/explosionEffect.lua")()



image = {
    plane = {
        base = love.graphics.newImage("image/plane/base.png"),
        colour = love.graphics.newImage("image/plane/colour.png"),
        shadow = love.graphics.newImage("image/plane/shadow.png"),
        prop0 = love.graphics.newImage("image/plane/prop1.png"),
        prop1 = love.graphics.newImage("image/plane/prop2.png"),
        prop2 = love.graphics.newImage("image/plane/prop3.png"),
        prop3 = love.graphics.newImage("image/plane/prop4.png"),
    },
    button = {
        bar = love.graphics.newImage("image/button/bar.png"),
        check = love.graphics.newImage("image/button/check.png"),
        empty = love.graphics.newImage("image/button/empty.png"),
        indicator = love.graphics.newImage("image/button/indicator.png"),
    },
    other = {
        bullet = love.graphics.newImage("image/other/bullet.png"),
        smoke = love.graphics.newImage("image/other/smoke.png"),
        fire = love.graphics.newImage("image/other/fire.png"),
    },
    background = {
        defaultBlue = love.graphics.newImage("image/background/defaultBlue.png"),
    },
}

audio = {
    explosion = {
        love.audio.newSource("audio/explosion0.wav", "static"),
        love.audio.newSource("audio/explosion1.wav", "static"),
        love.audio.newSource("audio/explosion2.wav", "static"),
    },
    hit = {
        love.audio.newSource("audio/hit0.wav", "static"),
        love.audio.newSource("audio/hit1.wav", "static"),
        love.audio.newSource("audio/hit2.wav", "static"),
        love.audio.newSource("audio/hit3.wav", "static"),
    },
    shoot = {
        love.audio.newSource("audio/shoot0.wav", "static"),
        love.audio.newSource("audio/shoot1.wav", "static"),
        love.audio.newSource("audio/shoot2.wav", "static"),
        love.audio.newSource("audio/shoot3.wav", "static"),
        love.audio.newSource("audio/shoot4.wav", "static"),
    },
}

font = {
    black = {
        ["15"] = love.graphics.newFont("font/black.ttf", 15),
        ["30"] = love.graphics.newFont("font/black.ttf", 30),
        ["35"] = love.graphics.newFont("font/black.ttf", 35),
        ["40"] = love.graphics.newFont("font/black.ttf", 40),
        ["70"] = love.graphics.newFont("font/black.ttf", 70),

    }
}


settingsMenu = love.filesystem.load("code/settings/settingsMenu.lua")():New()

teams = dante.load("save/teams") or love.filesystem.load("code/settings/defaultTeams.lua")()
dante.printTable(dante.load("save/teams"))

gameModes = {}



local modList = love.filesystem.getDirectoryItems("mods")

function GetModPath(modName)
    return "mods/" .. modName .. "/"
end

mods = {}

for i = 1,#modList do
    mods[modList[i]] = love.filesystem.load("mods/" .. modList[i] .. "/" .. modList[i] .. ".lua")()
    mods[modList[i]].load()

    love.graphics.print("loaded mod: " .. modList[i])
end