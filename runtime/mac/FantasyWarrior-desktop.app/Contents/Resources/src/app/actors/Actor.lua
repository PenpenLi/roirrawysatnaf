--
-- Author: Hao Liu
-- Date: 2016-08-19 16:34:10
-- 
--[[
	人物基类
]]

local Actor = class("Actor", function()
	local node = cc.Sprite3D:create()
	node:setCascadeColorEnabled(true)
	return node
	end)

-- common value is used to reset an actor
local ActorCommonValues = {
	aliveTime		= 0, -- time the actor is alive in seconds
	curSpeed		= 0, -- current speed the actor is traveling in units/seconds
	curAnimation	= nil,
	curAnimation3d	= nil,

	-- runtime modified values
	curFacing		= 0, -- current direction the actor is facing, in radians, 0 is to the right
	isalive			= true,
	AITimer			= 0, -- accumulated timer before AI will execute, in seconds
	AIEnabled		= false, -- if false, AI will not run
	attackTimer		= 0, -- accumulated timer to decide when to attack, in seconds
	timeKnocked		= 0, -- accumulated timer to recover from knock, in seconds
	cooldown		= false, -- if its true, then you are currently playing attacking animation
	hp				= 1000, -- current hit point
	goRight			= true,

	-- target variables
	targetFacing	= 0, -- direction the actor Wants to turn to
	target			= nil, -- the enemy actor
	myPos			= cc.p(0, 0),
	angry			= 0,
	angryMax		= 500,
}

local ActorDefaultValues = {
	
	sprite3d = nil, -- place to hold 3d model

	shadowSize = 70, -- the size of the shadow under the actor
}

function Actor:ctor()
	self.action = {}

	table.merge(self, ActorDefaultValues)
	table.merge(self, ActorCommonValues)
end

function Actor:initShadow()
	local circle = display.newSprite("#shadow.png")
	circle:setScale(self.shadowSize/16)
	circle:setOpacity(255*0.7)
	self:addChild(circle)
end

function Actor:playAnimation(name, loop)
    if self.curAnimation ~= name then --using name to check which animation is playing
        self.sprite3d:stopAllActions()
        if loop then
            self.curAnimation3d = cc.RepeatForever:create(self.action[name]:clone())
        else
            self.curAnimation3d = self.action[name]:clone()
        end
        self.sprite3d:runAction(self.curAnimation3d)
        self.curAnimation = name
    end
end

function Actor:initPuff()

end

function Actor:idleMode() --switch into idle mode
    self:setStateType(EnumStateType.IDLE)
    self:playAnimation("idle", true)
end

function Actor:getStateType()
    return self.statetype
end

function Actor:setStateType(type)
	self.statetype = type
end

function Actor:getAIEnabled()
    return self._AIEnabled
end

function Actor:setAIEnabled(enable)
    self._AIEnabled = enable
end

return Actor
