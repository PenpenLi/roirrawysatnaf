--
-- Author: Hao Liu
-- Date: 2016-08-27 17:56:46
--
--[[
	GameMaster
]]

local Archer = require("app.actors.Archer")
local Dragon = require("app.actors.Dragon")
local Knight = require("app.actors.Knight")
local Mage = require("app.actors.Mage")
local Piglet = require("app.actors.Piglet")
local Rat = require("app.actors.Rat")
local Slime = require("app.actors.Slime")


local battleSiteX = {-2800,-1800,-800}
local monsterCount = {dragon=1,slime=7,piglet=2,rat = 0} --rat count must be 0.

local GameMaster = class("GameMaster")

function GameMaster:ctor(layer)
	self.currentLayer = layer
	self.totaltime = 0
	self.logicFrq = 1.0

	self:addHeros()
	self:addMonsters()
    self.stage = 0
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    for i=1,4 do
        self:randomshowMonster(true)
    end
    self.stage = 1

end

function GameMaster:randomshowMonster(isFront)

end

function GameMaster:addHeros()
	local knight = Knight.new()
   	knight:setPosition(battleSiteX[1], 10)
    self.currentLayer:addChild(knight)
    knight:idleMode()
    List.pushlast(HeroManager, knight)

	local mage = Mage.new()
   	mage:setPosition(battleSiteX[1], 100)
   	self.currentLayer:addChild(mage)
   	mage:idleMode()
   	List.pushlast(HeroManager, mage)
   	
    local archer = Archer.new()
    archer:setPosition(battleSiteX[1], -80)
    self.currentLayer:addChild(archer)
    archer:idleMode()
    List.pushlast(HeroManager, archer)

end

function GameMaster:addMonsters()
	self:addDragon()
	self:addSlime()
	self:addPiglet()
	self:addRat()
end

function GameMaster:addDragon()
    for var=1, monsterCount.dragon do
        local dragon = Dragon.new()
        self.currentLayer:addChild(dragon)
        dragon:setVisible(false)
        dragon:setAIEnabled(false)
        List.pushlast(DragonPool,dragon)
    end   
end

function GameMaster:addSlime()
    for var=1, monsterCount.slime do
        local slime = Slime.new()
        self.currentLayer:addChild(slime)
        slime:setVisible(false)
        slime:setAIEnabled(false)
        List.pushlast(SlimePool,slime)
    end 
end

function GameMaster:addPiglet()
    for var=1, monsterCount.piglet do
    	local piglet = Piglet.new()
    	self.currentLayer:addChild(piglet)
    	piglet:setVisible(false)
    	piglet:setAIEnabled(false)
    	List.pushlast(PigletPool,piglet)
    end   
end

function GameMaster:addRat()
    for var=1, monsterCount.rat do
        local rat = Rat.new()
        self.currentLayer:addChild(rat)
        rat:setVisible(false)
        rat:setAIEnabled(false)
        List.pushlast(RatPool,rat)
    end  
end

function GameMaster:update(dt)
    self.totaltime = self.totaltime + dt
	if self.totaltime > self.logicFrq then
		self.totaltime = self.totaltime - self.logicFrq
		self:logicUpdate()
	end

end

function GameMaster:logicUpdate()    

end

return GameMaster