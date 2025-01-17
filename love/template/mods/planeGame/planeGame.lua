local PlaneGame = {}

function PlaneGame.load()
    gameModes["Teams Endless"] = love.filesystem.load(GetModPath("planeGame") .. "gameMode/default.lua")()
end



return PlaneGame