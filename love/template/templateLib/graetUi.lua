local Button = require("templateLib.graetUi.graetUiButton")
local Slider = require("templateLib.graetUi.graetUiSlider")
local Toggle = require("templateLib.graetUi.graetUiToggle")

GraetUi = {}
GraetUi.__index = GraetUi

function GraetUi:New() -- data is a table {{image/path, layer}}
    local obj = setmetatable({}, GraetUi)

    obj.currentLayer = "default"

    obj.layers = {
        default = {}
    }

    return obj
end

function GraetUi:SetLayer(layer)
    self.currentLayer = layer
    if not self.layers[layer] then
        self.layers[layer] = {}
    end
end
function GraetUi:GetButtons(layer)
    return self.layers[layer] or self.layers[self.currentLayer] 
end

function GraetUi:RemoveAll(layer)
    if layer then
        self.layers[layer] = nil
    else
        self.layers[self.currentLayer] = nil

    end
end




function GraetUi:AddButton(name, x, y, sx, sy, layer)
    if layer ~= nil then
        if self.layers[layer] == nil then
            self.layers[layer] = {}
        end
    end
    if self.layers == nil then
        error("NO layers ?!")
    end
    local layer = self.layers[layer] or self.layers[self.currentLayer]

    layer[name] = Button:New(x, y, sx, sy)
end

function GraetUi:AddTextButton(name, text, align, font, x, y, limit, colours, layer)
    if layer ~= nil then
        if self.layers[layer] == nil then
            self.layers[layer] = {}
        end
    end
    local layer = self.layers[layer] or self.layers[self.currentLayer]


    layer[name] = Button:NewText(text, align, font, x, y, limit, colours)
end


function GraetUi:AddSlider(name, x, y, bsx, bsy, rsx, rsy, value, layer)
    if layer ~= nil then
        if self.layers[layer] == nil then
            self.layers[layer] = {}
        end
    end
    local layer = self.layers[layer] or self.layers[self.currentLayer]

    layer[name] = Slider:New(x, y, bsx, bsy, rsx, rsy, value)
end

function GraetUi:AddToggle(name, x, y, sx, sy, value, layer)
    if layer ~= nil then
        if self.layers[layer] == nil then
            self.layers[layer] = {}
        end
    end
    local layer = self.layers[layer] or self.layers[self.currentLayer]

    layer[name] = Toggle:New(x, y, sx, sy, value)
end



function GraetUi:Update(dt, mx, my, layer)
    local elements = self.layers[layer] or self.layers[self.currentLayer]

    for key, value in pairs(elements) do
        value:Update(dt, mx, my)
    end
end

function GraetUi:Click(mx, my, layer)
    local elements = self.layers[layer] or self.layers[self.currentLayer]

    for key, value in pairs(elements) do
        value:Click(mx, my)
    end
end

function GraetUi:Release(mx, my, layer)
    local elements = self.layers[layer] or self.layers[self.currentLayer]

    for key, value in pairs(elements) do
        value:Release(mx, my)
    end
end

function GraetUi:Draw(layer, ox, oy)
    local elements = self.layers[layer] or self.layers[self.currentLayer]

    for key, value in pairs(elements) do
        value:Draw(ox or 0, oy or 0)
    end
end