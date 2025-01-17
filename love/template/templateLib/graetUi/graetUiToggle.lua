local Text = require("templateLib.graetUi.graetUiTextElement")
local Rect = require("templateLib.graetUi.graetUiRectElement")
local Image = require("templateLib.graetUi.graetUiImageElement")
local Button = require("templateLib.graetUi.graetUiButton")


local GraetToggle = {}
GraetToggle.__index = GraetToggle

local drawHitboxes = false

function GraetToggle.toglehitboxes()
    drawHitboxes = not drawHitboxes
end

function GraetToggle:New(x, y, sx, sy, value) -- data is a table {{image/path, layer}}
    local obj = setmetatable({}, GraetToggle)

    obj.x = x
    obj.y = y
    obj.sx = sx
    obj.sy = sy

    obj.graphics = {}

    obj.value = value
    obj.button1 = Button:New(x, y, sx, sy)
    obj.button2 = Button:New(x, y, sx, sy)

    obj.func = {}

    return obj
end

function GraetToggle:AddText(text, align, font, x, y, limit, pos)
    table.insert(self.graphics, pos or #self.graphics+1, Text:New(text, align, font, x, y, limit))
end
function GraetToggle:AddRect(x, y, sx, sy, fill, curve, pos)
    table.insert(self.graphics, pos or #self.graphics+1, Rect:New(x, y, sx or self.sx, sy or self.sy, fill or "fill", curve or 0))
end
function GraetToggle:AddImage(x, y, image, sx, sy, pos)
    table.insert(self.graphics, pos or #self.graphics+1, Image:New(x, y, image, sx, sy))
end

function GraetToggle:SetElementColour(c1, c2, c3, elementNo)
    self.graphics[elementNo or #self.graphics]:SetColour(c1, c2, c3)
end


function GraetToggle:Update(dt, mx, my)
    self.button1:Update(dt, mx, my)
    self.button2:Update(dt, mx, my)
end

function GraetToggle:Click(mx, my)
    if self.value then
        self.button1:Click(mx, my)
    else
        self.button2:Click(mx, my)
    end
end

function GraetToggle:Release(mx, my)
    if self.button1.mouseMode == "click" or self.button2.mouseMode == "click"  then
        self.value = not self.value
        if #self.func > 0 then
            self.func[1](self.value, self.func[2])
        end
    end
    self.button1:Release(mx, my)
    self.button2:Release(mx, my)
end



function GraetToggle:Draw(ox, oy)
    if self.value then
        self.button1:Draw(ox, oy)
    else
        self.button2:Draw(ox, oy)
    end
end



return GraetToggle