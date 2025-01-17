--=======================================================================================================--
--                                                                                                       --
--      88888888ba,                                                     88                               --
--      88      `"8b                             ,d         _,.         88                               --
--      88        `8b                            88       ""'           88                               --
--      88         88  ,adPPYYba,  8b,dPPYba,  MM88MMM  ,adPPYba,       88  88       88  ,adPPYYba,      --
--      88         88  ""     `Y8  88P'   `"8a   88    a8P_____88       88  88       88  ""     `Y8      --
--      88         8P  ,adPPPPP88  88       88   88    8PP"""""""       88  88       88  ,adPPPPP88      --
--      88      .a8P   88,    ,88  88       88   88,   "8b,   ,aa  888  88  "8a,   ,a88  88,    ,88      --
--      88888888Y"'    `"8bbdP"Y8  88       88   "Y888  `"Ybbd8"'  888  88   `"YbbdP'Y8  `"8bbdP"Y8      --
--                                                                                                       --
--                                                                                                       --
--  ┌─┐┌─┐┬  ┬┬┌┐┌┌─┐   ┬  ┌─┐┌─┐┌┬┐┬┌┐┌┌─┐   ┌─┐┌┐┌┌┬┐  ┌─┐┌─┐┌┬┐┌─┐  ┌─┐┌┬┐┬ ┬┌─┐┬─┐  ┌─┐┌┬┐┬ ┬┌─┐┌─┐  --
--  └─┐├─┤└┐┌┘│││││ ┬   │  │ │├─┤ │││││││ ┬   ├─┤│││ ││  └─┐│ ││││├┤   │ │ │ ├─┤├┤ ├┬┘  └─┐ │ │ │├┤ ├┤   --
--  └─┘┴ ┴ └┘ ┴┘└┘└─┘┘  ┴─┘└─┘┴ ┴─┴┘┴┘└┘└─┘┘  ┴ ┴┘└┘─┴┘  └─┘└─┘┴ ┴└─┘  └─┘ ┴ ┴ ┴└─┘┴└─  └─┘ ┴ └─┘└  └    --
--                                                                                                       --
--=======================================================================================================--
--  ChangeLog:                                                                                      V4.0 --
--    -> I changed the saving/loading system so it uses lua files or whatever                            --
--    -> Updated printTable function                                                                     --
--    -> added varToString function                                                                      --
--                                                                                                  V4.1 --
--    -> support for no folder when saving                                                               --
--=======================================================================================================--

dante = {}
local debugText = false

function dante.toggleDebugText()
    debugText = not debugText
    if debugText then
        print("[Dante.lua]: Enabled Debug Text")
    else
        print("[Dante.lua]: Disabled Debug Text")
    end
end



function dante.save(data, folder, fileName)
    local saveData = "return " .. dante.dataToString(data)

    if folder then
        if love.filesystem.getInfo(folder, "directory") then
        else
            love.filesystem.createDirectory(folder)
        end
        love.filesystem.write(folder .. "/" .. fileName .. ".lua", saveData)
    else
        love.filesystem.write(fileName .. ".lua", saveData)
    end
end


function dante.load(file)
    if love.filesystem.getInfo(file .. ".lua", "file") then

        local fileContents = love.filesystem.load(file .. ".lua")

        if debugText then
            print("[Dante.lua]: Found " .. file .. ".lua")
        end

        return fileContents()
    else
        if debugText then
            print("[Dante.lua]: Can't Find " .. file .. ".lua")
        end
    end
end


function dante.varToString(var)
    if var == nil then
        return "nil"
    elseif type(var) == "function" then
        return "function"
    elseif type(var) == "image" then
        return "image"
    elseif type(var) == "string" then
        return '"' .. var .. '"'
    elseif type(var) == "number" then
        return tostring(var)
    elseif type(var) == "boolean" then
        if var then
            return "true"
        else
            return "false"
        end
    end
end

function dante.dataToString(data, indent)
    local indent = indent or 0
    local indentString = string.rep("    ", indent)

    local string = ""

    if type(data) == "table" then
        string = string .. "{\n"

        for key, value in pairs(data) do
            local name = tostring(key)



            if type(key) == "number" then
                name = "[" .. key .. "]"
            elseif tostring(name):find("[/:]") then
                name = "['" .. key .. "']"
            end
            if type(data) == "table" then
                local cocatString = dante.dataToString(value, indent + 1)
                if cocatString then
                    string = string .. indentString .. "    " .. name .. " = " .. cocatString  .. ",\n"
                end
            else
                string = string .. indentString .. name .. " = " .. dante.varToString(data) .. ",\n"
            end
        end

        string = string .. indentString .. "}"

    else
        string = dante.varToString(data)
    end

    return string
end


function dante.printTable(t)

    -- this is her so we dont break anything
    print(dante.dataToString(t))

    --[[indent = indent or 0
    for key, value in pairs(t) do
        local formatting = string.rep("  ", indent)

        if type(key) == "number" then
            formatting = formatting .. "[" .. key .. "]: "
        else
            formatting = formatting .. key .. ": "
        end

        if type(value) == "table" then
            print(formatting)
            dante.printTable(value, indent + 1)
        else
            print(formatting .. tostring(value))
        end
    end]]
end

function dante.formatNnumber(num, decimals)

    local num = num

    local ends = {
        "",
        "k",
        "m",
        "b",
        "t",
        "q",
    }
    for i = 1,#ends do
        if num < 1000 then
            local finalNumber = math.floor(num * (math.pow(10, decimals)))/(math.pow(10, decimals))
            return tostring(finalNumber) .. ends[i]
        else


            num = num / 1000

        end
    end
end

function dante.noQuantumEntanglememt(table)
    if debugText then
        print("[Dante.lua]: Re-building " .. table)
    end
    local temp = {}
    for key, value in pairs(table) do
        if type(table[key]) == "table" then
            temp[key] = noQuantumEntanglememt(table[key])
        else
            temp[key] = value
        end
    end

    return temp
end