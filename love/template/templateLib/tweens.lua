local tweens = {}

function tweens.linear(percent, pos1, pos2)
    local pos1, pos2 = pos1 or 0, pos2 or 1

    local diff = pos1 - pos2
    return pos1 + diff*percent
end


--verticle linerive
function tweens.mid(percent, pos1, pos2)
    if percent > 0.5 then return pos2 or 1 end
    return pos1 or 0
end

function tweens.min(percent, pos1, pos2)
    if percent > 0 then return pos2 or 1 end
    return pos1 or 0
end

function tweens.max(percent, pos1, pos2)
    if percent < 1 then return pos1 or 0 end
    return pos2 or 1
end


--Sine
function tweens.sineInOut(percent, pos1, pos2)
    local pos1, pos2 = pos1 or 0, pos2 or 1

    local diff = pos1 - pos2
    local amt = (math.sin((percent-0.5)*math.pi))/2+0.5
    return pos1 + amt*pos2
end

function tweens.sineOut(percent, pos1, pos2)
    local pos1, pos2 = pos1 or 0, pos2 or 1

    local diff = pos1 - pos2
    local amt = (math.sin((percent/2)*math.pi))
    return pos1 + amt*pos2
end

function tweens.sineIn(percent, pos1, pos2)
    local pos1, pos2 = pos1 or 0, pos2 or 1

    local diff = pos1 - pos2
    local amt = (math.sin((percent-1)*math.pi/2))+1
    return pos1 + amt*pos2
end

--Cubic
function tweens.cubicOut(percent,pos1,pos2)
    local pos1, pos2 = pos1 or 0, pos2 or 1

    local diff = pos1 - pos2
    local amt = 1 - (1 - percent)^3
    return pos1+amt*pos2
end



return tweens