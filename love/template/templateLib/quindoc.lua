quindoc = {}
drawDebugRuler = false
debug = love.graphics.newFont(16)

--Some stuff that i wished the math library had, and also some lazy tools.

function quindoc.pythag(x,y)
    return math.sqrt(x^2+y^2)
end

function quindoc.round(num,digits)
    num = num * 10^(digits or 0)
    num = math.floor(num + 0.5)
    num = num / 10^(digits or 0)
    return num
end

function quindoc.dist(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

function quindoc.sign(x)
    return x > 0 and 1 or x < 0 and -1 or 0
end

function quindoc.numberLength(num)
    if num > 0 then
        return math.floor(math.log10(num)+1)
    else 
        return 1
    end
end

function quindoc.clamp(val, min, max)
    return math.max(min, math.min(val, max))
end

--Lazy tools

function quindoc.drawRuler()
    love.graphics.setFont(debug)
    love.graphics.setColor(1, 1, 1,0.2)

    for w = 0, 1920, 50 do
        love.graphics.line(w, 0, w, 1080) 
    end
    
    for h = 0, 1080, 50 do
        love.graphics.line(0, h, 1920, h) 
    end
    
    love.graphics.setColor(1, 1, 1,0.3)
    for w = 0, 1920, 100 do
        love.graphics.line(w, 0, w, 1080) 
        love.graphics.print(w, w+2, 0, 0, 1, 1) 
    end
    
    for h = 0, 1080, 100 do
        love.graphics.line( 0, h, 1920, h)
        if h ~= 0 then love.graphics.print(h, 0, h+2 , 0, 1, 1) end 
    end

    love.graphics.setColor(1, 1, 1, 1) 
end

function quindoc.drawBar(x, y, width, height, fill, colour, r1, r2)
    local fillWidth = math.abs(width * fill)
    local temp = x

    if fill < 0 then
        temp = temp - fillWidth
    end

    if fillWidth > 0 then
        if colour then love.graphics.setColor(colour) else love.graphics.setColor(0.9,0.9,0.9,1) end
        love.graphics.rectangle("fill", temp, y, fillWidth, height, r1)
        love.graphics.setColor(1,1,1)
    end
end

function quindoc.hexcode(hex,alpha)

    local hex = hex:gsub("#", "") --remove pesky hashtag

    local r = tonumber(hex:sub(1, 2), 16) /255
    local g = tonumber(hex:sub(3, 4), 16) /255
    local b = tonumber(hex:sub(5, 6), 16) /255
    
    if alpha then 
        return {r,g,b,alpha}
    else
        return {r,g,b}
    end

end

function quindoc.runIfFunc(func,args) --if you want multiple arguements then put a table in "args". the function will then have to unpack that table itself though.
    if type(func) == "function" then return func(args)
    else return func end
end
    