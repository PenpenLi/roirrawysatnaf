--
-- Author: Hao Liu
-- Date: 2016-08-29 10:19:09
--
--[[
	怪，小猪
]]

local Actor = require("app.actors.Actor")

local Piglet = class("Piglet", Actor)

local modelFile = "model/piglet/piglet.c3b"
local modelFilePng = "model/piglet/zhu0928.jpg"

local PigletActions = {
	idle = createAnimation(file,0,40,0.7),
	walk = createAnimation(file,135,147,1.5),
	attack1 = createAnimation(file,45,60,0.7),
	attack2 = createAnimation(file,60,75,0.7),
	defend = createAnimation(file,92,96,0.7),
	knocked = createAnimation(file,81,87,0.7),
	dead = createAnimation(file,95,127,1)
}

function Piglet:ctor()
	Piglet.super.ctor(self)

	table.merge(self, PigletValues)

	self:init3D()
	self:initActions()

	local function update(dt)

	end
	self:scheduleUpdate(update)

end

function Piglet:initActions()
	self.action = PigletActions

end

function Piglet:init3D()
	self:initShadow()

	self.sprite3d = cc.EffectSprite3D:create(modelFile)
	self.sprite3d:setTexture(modelFilePng)
	self.sprite3d:setScale(1.3)
	self.sprite3d:addEffect(cc.vec3(0,0,0),CelLine, -1)
	self:addChild(self.sprite3d)
	self.sprite3d:setRotation3D({x = 90, y = 0, z = 0})        
	self.sprite3d:setRotation(-90)

end


return Piglet
