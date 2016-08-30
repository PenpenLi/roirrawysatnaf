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
