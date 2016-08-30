--
-- Author: Hao Liu
-- Date: 2016-08-29 10:19:42
--
--[[
	怪，大老鼠
]]

local Actor = require("app.actors.Actor")

local Rat = class("Rat", Actor)

local modelFile = "model/rat/rat.c3b"

local RatActions = {
	idle = createAnimation(modelFile,0,23,1),
	knocked = createAnimation(modelFile,30,37,0.5),
	dead = createAnimation(modelFile,41,76,0.2),
	attack1 = createAnimation(modelFile,81,99,0.7),
	attack2 = createAnimation(modelFile,99,117,0.7),
	walk = createAnimation(modelFile,122,142,0.4)
}

function Rat:ctor()
	Rat.super.ctor(self)

	copyTable(RatValues, self)

	self:init3D()
	self:initActions()
	self.AIEnabled = true

	local function update(dt)
		self:baseUpdate(dt)
		self:stateMachineUpdate(dt)
		self:movementUpdate(dt)

	end
	self:scheduleUpdate(update)

end

function Rat:initActions()
	self.action = RatActions

end

function Rat:init3D()
	self:initShadow()

	self._sprite3d = cc.EffectSprite3D:create(modelFile)
	self._sprite3d:setScale(20)
	self._sprite3d:addEffect(cc.vec3(0,0,0),CelLine, -1)
	self:addChild(self._sprite3d)
	self._sprite3d:setRotation3D({x = 90, y = 0, z = 0})        
	self._sprite3d:setRotation(-90)

end

function Rat:reset()
	table.merge(self, ActorCommonValues)
    table.merge(self, RatValues)
    self:walkMode()
    self:setPositionZ(0)
end


return Rat
