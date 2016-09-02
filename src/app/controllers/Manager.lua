--
-- Author: Hao Liu
-- Date: 2016-08-29 15:44:31
--
--[[
	Manager
]]

cc.exports.HeroPool = List.new()
cc.exports.DragonPool = List.new()
cc.exports.SlimePool = List.new()
cc.exports.PigletPool = List.new()
cc.exports.RatPool = List.new()
cc.exports.BossPool = List.new()

--getPoolByName
function cc.exports.getPoolByName(name)
    if name == "Piglet" then
        return PigletPool
    elseif name == "Slime" then
        return SlimePool
    elseif name == "Rat" then
        return RatPool
    elseif name == "Dragon" then
        return DragonPool
    elseif name == "Boss" then
        return BossPool
    else
        return HeroPool
    end
end

cc.exports.HeroManager = List.new()
cc.exports.MonsterManager = List.new()

local function getFocusPointOfHeros()
    local ptFocus ={x=0, y=0}
    for var = HeroManager.last, HeroManager.first, -1 do
        ptFocus.x = ptFocus.x + HeroManager[var]:getPositionX()
        ptFocus.y = ptFocus.y + HeroManager[var]:getPositionY()
    end
    ptFocus.x = ptFocus.x / List.getSize(HeroManager)
    ptFocus.y = ptFocus.y / List.getSize(HeroManager)
    return ptFocus
end

cc.exports.getFocusPointOfHeros = getFocusPointOfHeros

local function solveCollision(object1, object2)
    local miniDistance = object1._radius + object2._radius
    local obj1Pos = cc.p(object1:getPosition())
    local obj2Pos = cc.p(object2:getPosition())
    local tempDistance = cc.pGetDistance(obj1Pos, obj2Pos)
    
    if tempDistance < miniDistance then
        local angle = cc.pToAngleSelf(cc.pSub(obj1Pos, obj2Pos))
        local distance = miniDistance - tempDistance + 1 -- Add extra 1 to avoid 'tempDistance < miniDistance' is always true
        local distance1 = (1 - object1._mass / (object1._mass + object2._mass) ) * distance
        local distance2 = distance - distance1

        object1:setPosition(cc.pRotateByAngle(cc.pAdd(cc.p(distance1,0),obj1Pos), obj1Pos, angle))
        object2:setPosition(cc.pRotateByAngle(cc.pAdd(cc.p(-distance2,0),obj2Pos), obj2Pos, angle))
    end  
end

local function collision(object)
    for val = HeroManager.first, HeroManager.last do
        local sprite = HeroManager[val]
        if sprite._isalive and sprite ~= object then
            solveCollision(sprite, object)
        end
    end

    for val = MonsterManager.first, MonsterManager.last do
        local sprite = MonsterManager[val]
        if sprite._isalive == true and sprite ~= object then
            solveCollision(sprite, object)
        end                  
    end      
end

local activearea = {left = -2800, right = 1000, bottom = 100, top = 700}

local function isOutOfBound(object)
    local currentPos = cc.p(object:getPosition());

    if currentPos.x < activearea.left then
        currentPos.x = activearea.left
    end    

    if currentPos.x > activearea.right then
        currentPos.x = activearea.right
    end

    if currentPos.y < activearea.bottom then
        currentPos.y = activearea.bottom
    end

    if currentPos.y > activearea.top then
        currentPos.y = activearea.top
    end

    object:setPosition(currentPos)
end

local function collisionDetect(dt)
    --cclog("collisionDetect")
    for val = HeroManager.last, HeroManager.first, -1 do
        local sprite = HeroManager[val]
        if sprite.isalive == true then
            collision(sprite)
            isOutOfBound(sprite)
            sprite.effectNode:setPosition(sprite.myPos)
        else
            List.remove(HeroManager, val)
        end
    end

    for val = MonsterManager.last, MonsterManager.first, -1 do
        local sprite = MonsterManager[val]
        if sprite.isalive == true then
            collision(sprite)
            isOutOfBound(sprite)          
        else
            List.remove(MonsterManager, val)
        end
    end           
end

cc.exports.collisionDetect = collisionDetect




