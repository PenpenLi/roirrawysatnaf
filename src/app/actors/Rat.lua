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

	self.sprite3d = cc.EffectSprite3D:create(modelFile)
	self.sprite3d:setScale(20)
	self.sprite3d:addEffect(cc.vec3(0,0,0),CelLine, -1)
	self:addChild(self.sprite3d)
	self.sprite3d:setRotation3D({x = 90, y = 0, z = 0})        
	self.sprite3d:setRotation(-90)

end

function Rat:reset()
	table.merge(self, ActorCommonValues)
    table.merge(self, RatValues)
    self:walkMode()
    self:setPositionZ(0)
end

function Rat:dyingMode(knockSource, knockAmount)
    self:setStateType(EnumStateType.DYING)
    self:playAnimation("dead")
    self:playDyingEffects()

    List.removeObj(MonsterManager,self) 
    local function recycle()
       self:removeFromParent()
       if gameMaster ~= nil then
           gameMaster:showVictoryUI()
       end
    end
    
    local function disableHeroAI()
       if List.getSize(HeroManager) ~= 0 then
            for var = HeroManager.first, HeroManager.last do
                 HeroManager[var]:setAIEnabled(false)
                 HeroManager[var]:idleMode()
                HeroManager[var].goRight = false
             end
        end
    end
    self:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(disableHeroAI),cc.MoveBy:create(1.0,cc.V3(0,0,-50)),cc.CallFunc:create(recycle)))
    
    if knockAmount then
        local p = self.myPos
        local angle = cc.pToAngleSelf(cc.pSub(p, knockSource))
        local newPos = cc.pRotateByAngle(cc.pAdd({x=knockAmount,y=0}, p),p,angle)
        self:runAction(cc.EaseCubicActionOut:create(cc.MoveTo:create(self.action.knocked:getDuration()*3,newPos)))
    end
    self.AIEnabled = false
end

function Rat:hurt(collider, dirKnockMode)
    if self.isalive == true then 
        --TODO add sound effect

        local damage = collider.damage
        --calculate the real damage
        local critical = false
        local knock = collider.knock
        if math.random() < collider.criticalChance then
            damage = damage*1.5
            critical = true
            knock = knock*2
        end
        damage = damage + damage * math.random(-1,1) * 0.15        
        damage = damage - self.defense
        damage = math.floor(damage)

        if damage <= 0 then
            damage = 1
        end

        self.hp = self.hp - damage

        if self.hp > 0 then
            if critical == true then
                self:knockMode(collider, dirKnockMode)
                self:hurtSoundEffects()
            else
                self:hurtSoundEffects()
            end
        else
            self.hp = 0
            self.isalive = false
            self:dyingMode(getPosTable(collider),knock)        
        end

        --three param judge if crit
        local blood = self.hpCounter:showBloodLossNum(damage,self,critical)
        blood:setPositionZ(G.winSize.height*0.25)
        blood:setCameraMask(UserCameraFlagMask)
        self:addEffect(blood)

        return damage        
    end
    return 0
end


return Rat
