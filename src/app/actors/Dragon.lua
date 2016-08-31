--
-- Author: Hao Liu
-- Date: 2016-08-29 10:18:34
--
--[[
	怪，龙
]]

local Actor = require("app.actors.Actor")
require("app.controllers.AttackCommand")

local Dragon = class("Dragon", Actor)

local modelFile = "model/dragon/dragon.c3b"

local DragonActions = {
    idle = createAnimation(modelFile,0,24,0.7),
    knocked = createAnimation(modelFile,30,37,0.7),
    dead = createAnimation(modelFile,42,80,1),
    attack1 = createAnimation(modelFile,85,100,0.7),
    attack2 = createAnimation(modelFile,100,115,0.7),
    walk = createAnimation(modelFile,120,140,1),
}

function Dragon:ctor()
	Dragon.super.ctor(self)

    copyTable(DragonValues, self)

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

function Dragon:initActions()
	self.action = DragonActions

end

function Dragon:init3D()
	self:initShadow()

    self.sprite3d = cc.EffectSprite3D:create(modelFile)
    self.sprite3d:setScale(10)
    self.sprite3d:addEffect(cc.vec3(0,0,0),CelLine, -1)
    self:addChild(self.sprite3d)
    self.sprite3d:setRotation3D({x = 90, y = 0, z = 0})        
    self.sprite3d:setRotation(-90)

end

function Dragon:reset()
    copyTable(ActorCommonValues, self)
    copyTable(DragonValues, self)

    self:walkMode()
    self:setPositionZ(0)
end

function Dragon:doNormalAttack()
    self:normalAttackSoundEffects()
    DragonAttack.new(getPosTable(self), self.curFacing, self.normalAttack)
end

function Dragon:normalAttackSoundEffects()
    ccexp.AudioEngine:play2d(MonsterDragonValues.attack, false,1)
end


return Dragon
