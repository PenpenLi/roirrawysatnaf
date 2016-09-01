--
-- Author: Hao Liu
-- Date: 2016-08-19 16:34:10
-- 
--[[
	人物基类
]]

local HPCounter = require("app.views.HPCounter")
require("app.controllers.AttackCommand")

local Actor = class("Actor", function()
	local node = cc.Sprite3D:create()
	node:setCascadeColorEnabled(true)
	return node
	end)

function Actor:ctor()
	self.action = {}

    copyTable(ActorDefaultValues, self)
    copyTable(ActorCommonValues, self)

    self.hpCounter = HPCounter.new()
    self:addChild(self.hpCounter)

    self.effectNode = cc.Node:create()
    self.monsterHeight = 70
    self.heroHeight = 150
    if uiLayer ~= nil then
        currentLayer:addChild(self.effectNode)
    end

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

function Actor:idleMode() --switch into idle mode
    self:setStateType(EnumStateType.IDLE)
    self:playAnimation("idle", true)
end

function Actor:walkMode() --switch into walk mode
    self:setStateType(EnumStateType.WALKING)
    self:playAnimation("walk", true)
end

function Actor:attackMode() --switch into walk mode
    self:setStateType(EnumStateType.ATTACKING)
    self:playAnimation("idle", true)
    self.attackTimer = self.attackFrequency*3/4
end

function Actor:dyingMode(knockSource, knockAmount)
    self:setStateType(EnumStateType.DYING)
    self:playAnimation("dead")
    self:playDyingEffects()

    if self.racetype == EnumRaceType.HERO then
        uiLayer:heroDead(self)
        List.removeObj(HeroManager,self) 
        self:runAction(cc.Sequence:create(
            cc.DelayTime:create(3),
            cc.MoveBy:create(1.0,cc.vec3(0,0,-50)),
            cc.RemoveSelf:create()))
        
        self.angry = 0
        local anaryChange = {name = self.name, angry = self.angry, angryMax = self.angryMax}
        local event = cc.EventCustom:new(MessageType.ANGRY_CHANGE)
        event._usedata = anaryChange
        local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:dispatchEvent(event)
          
    else
        List.removeObj(MonsterManager,self) 
        local function recycle()
            self:setVisible(false)
            List.pushlast(getPoolByName(self.name),self)
        end
        self:runAction(cc.Sequence:create(
            cc.DelayTime:create(3),
            cc.MoveBy:create(1.0,cc.vec3(0,0,-50)),
            cc.CallFunc:create(recycle)))
    end

end

function Actor:knockMode(collider, dirKnockMode)
    self:setStateType(EnumStateType.KNOCKING)
    self:playAnimation("knocked")
    self.timeKnocked = self.aliveTime
    local p = self.myPos
    local angle 
    if dirKnockMode then
        angle = collider.facing
    else
        angle = cc.pToAngleSelf(cc.pSub(p, getPosTable(collider)))
    end
    local newPos = cc.pRotateByAngle(cc.pAdd({x=collider.knock,y=0}, p),p,angle)
    self:runAction(cc.EaseCubicActionOut:create(cc.MoveTo:create(self.action.knocked:getDuration()*3,newPos)))
--    self:setCascadeColorEnabled(true)--if special attack is interrupted then change the value to true      
end

function Actor:getStateType()
    return self.statetype
end

function Actor:setStateType(type)
	self.statetype = type
end

function Actor:setFacing(degrees)
    self.curFacing = math.rad(degrees)
    self.targetFacing = self.curFacing
    self:setRotation(degrees)
end

function Actor:getAIEnabled()
    return self.AIEnabled
end

function Actor:setAIEnabled(enable)
    self.AIEnabled = enable
end

function Actor:baseUpdate(dt)
    self.myPos = getPosTable(self)
    self.aliveTime = self.aliveTime+dt
    if self.AIEnabled then
        self.AITimer = self.AITimer+dt
        if self.AITimer > self.AIFrequency then
            self.AITimer = self.AITimer-self.AIFrequency
            self:AI()
        end
    end

end

function Actor:findEnemy(HeroOrMonster)
    local shortest = self.searchDistance
    local target = nil
    local allDead = true
    local manager = nil
    if HeroOrMonster == EnumRaceType.MONSTER then
        manager = HeroManager
    else
        manager = MonsterManager
    end
    for val = manager.first, manager.last do
        local temp = manager[val]
        local dis = cc.pGetDistance(self.myPos,temp.myPos)
        if temp.isalive then
            if dis < shortest then
                shortest = dis
                target = temp
            end
            allDead = false
        end
    end
    return target, allDead
end

function Actor:inRange()
    if not self.target then
        return false
    elseif self.target.isalive then
        local attackDistance = self.attackRange + self.target.radius -1
        local p1 = self.myPos
        local p2 = self.target.myPos
        return (cc.pGetDistance(p1,p2) < attackDistance)
    end
end

--AI function does not run every tick
function Actor:AI()
    if self.isalive then
        local state = self:getStateType()
        local allDead
        self.target, allDead = self:findEnemy(self.racetype)
        --if i can find a target
        if self.target then
            local p1 = self.myPos
            local p2 = self.target.myPos
            self.targetFacing =  cc.pToAngleSelf(cc.pSub(p2, p1))
            local isInRange = self:inRange()
            -- if im (not attacking, or not walking) and my target is not in range
            if (not self.cooldown or state ~= EnumStateType.WALKING) and not isInRange then
                self:walkMode()
                return
            --if my target is in range, and im not already attacking
            elseif isInRange and state ~= EnumStateType.ATTACKING then
                self:attackMode()
                return
--            else 
--                --Since im attacking, i cant just switch to another mode immediately
--                --print( self.name, "says : what should i do?", self.statetype)
            end
        elseif self.statetype ~= EnumStateType.WALKING and self.goRight == true then
            self:walkMode()
            return
        --i did not find a target, and im not attacking or not already idle
        elseif not self.cooldown or state ~= EnumStateType.IDLE then
            self:idleMode()
            return
        end
    else
        -- logic when im dead 
    end
end

function Actor:stateMachineUpdate(dt)
    local state = self:getStateType()
    if state == EnumStateType.WALKING  then
        self:walkUpdate(dt)
    elseif state == EnumStateType.IDLE then
        --do nothing :p
    elseif state == EnumStateType.ATTACKING then
        --I am attacking someone, I probably has a target
        self:attackUpdate(dt)
    elseif state == EnumStateType.DEFENDING then
        --I am trying to defend from an attack, i need to finish my defending animation
        --TODO: update for defending
    elseif state == EnumStateType.KNOCKING then
        --I got knocked from an attack, i need time to recover
        self:knockingUpdate(dt)
    elseif state == EnumStateType.DYING then
        --I am dying.. there is not much i can do right?
        
    end

end

function Actor:knockingUpdate(dt)
    if self.aliveTime - self.timeKnocked > self.recoverTime then
        --i have recovered from a knock
        self.timeKnocked = nil
        if self:inRange() then
            self:attackMode()
        else
            self:walkMode()
        end
    end
end

function Actor:walkUpdate(dt)
    --Walking state, switch to attack state when target in range
    if self.target and self.target.isalive then
        local attackDistance = self.attackRange + self.target.radius -1
        local p1 = self.myPos
        local p2 = self.target.myPos
        self.targetFacing = cc.pToAngleSelf(cc.pSub(p2, p1))
        --print(RADIANSTODEGREES(self.targetFacing))
        if cc.pGetDistance(p1,p2) < attackDistance then
            --we are in range, lets switch to attack state
            self:attackMode()
        end
    else
        --our hero doesn't have a target, lets move
        --self.target = self:findEnemy(self.raceType)
        local curx,cury = self:getPosition()
        if self.goRight then
            self.targetFacing = 0
        else
            self:idleMode()
        end
    end
end

function Actor:normalAttackSoundEffects()
-- to override
end

--======attacking collision check
function Actor:doNormalAttack()
    BasicCollider.create(self.myPos, self.curFacing, self.normalAttack)
    self:normalAttackSoundEffects()
end

function Actor:attackUpdate(dt)   
    self.attackTimer = self.attackTimer + dt
    if self.attackTimer > self.attackFrequency then
        self.attackTimer = self.attackTimer - self.attackFrequency
        local function playIdle()
            self:playAnimation("idle", true)
            self.cooldown = false
        end
        --time for an attack, which attack should i do?
        local random_special = math.random()
        if random_special > self.specialAttackChance then
            local function createCol()
                self:doNormalAttack()
            end
            local attackAction = cc.Sequence:create(self.action.attack1:clone(),
                cc.CallFunc:create(createCol),
                self.action.attack2:clone(),
                cc.CallFunc:create(playIdle))
            self.sprite3d:stopAction(self.curAnimation3d)
            self.sprite3d:runAction(attackAction)
            self.curAnimation = attackAction
            self.cooldown = true
        else
            self:setCascadeColorEnabled(false)--special attack does not change color affected by its parent node    
            local function createCol()        
                self:doSpecialAttack()
            end
            local messageParam = {speed = 0.2, pos = self.myPos, dur = self.specialSlowTime, target = self}                
            local event = cc.EventCustom:new(MessageType.SPECIAL_PERSPECTIVE)
            event._usedata = messageParam
            local eventDispatcher = self:getEventDispatcher()
            eventDispatcher:dispatchEvent(event)

            local attackAction = cc.Sequence:create(self.action.specialattack1:clone(),
                cc.CallFunc:create(createCol), 
                self.action.specialattack2:clone(),
                cc.CallFunc:create(playIdle))
            self.sprite3d:stopAction(self.curAnimation3d)
            self.sprite3d:runAction(attackAction)
            self.curAnimation = attackAction
            self.cooldown = true
        end
    end
end

function Actor:movementUpdate(dt)
    --Facing
    if self.curFacing ~= self.targetFacing then
        local angleDt = self.curFacing - self.targetFacing
--            if angleDt >= math.pi then angleDt = angleDt-2*math.pi
--            elseif angleDt <=-math.pi then angleDt = angleDt+2*math.pi end
        angleDt = angleDt % (math.pi*2)
        local turnleft = (angleDt - math.pi)<0
        local turnby = self.turnSpeed*dt
        
        --right
        if turnby > angleDt then
            self.curFacing = self.targetFacing
        elseif turnleft then
            self.curFacing = self.curFacing - turnby
        else
        --left
            self.curFacing = self.curFacing + turnby
        end

        self:setRotation(-math.deg(self.curFacing))
    end
    --position update
    if self:getStateType() ~= EnumStateType.WALKING then
        --if I am not walking, i need to slow down
        self.curSpeed = cc.clampf(self.curSpeed - self.decceleration*dt, 0, self.speed)
    elseif self.curSpeed < self.speed then
        --I am in walk mode, if i can speed up, then speed up
        self.curSpeed = cc.clampf(self.curSpeed + self.acceleration*dt, 0, self.speed)
    end
    if self.curSpeed > 0 then
        local p1 = self.myPos
        local targetPosition = cc.pRotateByAngle(cc.pAdd({x=self.curSpeed*dt,y=0},p1),p1,self.curFacing)
        self:setPosition(targetPosition)
    end
end

function Actor:hurt(collider, dirKnockMode)
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
            if collider.knock and damage ~= 1 then
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
        blood:setCameraMask(UserCameraFlagMask)
        self:addEffect(blood)
        return damage        
    end
    return 0

end

function Actor:doSpecialAttack()
    BasicCollider.create(self.myPos, self.curFacing, self.specialAttack)
    self:specialAttackSoundEffects()
end

function Actor:hurtSoundEffects()
-- to override
end

function Actor:playDyingEffects()
   -- override
end

function Actor:specialAttackSoundEffects()
-- to override
end

function Actor:addEffect(effect)
    effect:setPosition(cc.pAdd(getPosTable(self),getPosTable(effect)))
    if self.racetype ~= EnumRaceType.MONSTER then
        effect:setPositionZ(self:getPositionZ()+self.heroHeight)
    else
        effect:setPositionZ(self:getPositionZ()+self.monsterHeight+effect:getPositionZ())
    end
    currentLayer:addChild(effect)
end

function Actor:initPuff()
    -- local puff = cc.BillboardParticleSystem:create(ParticleManager:getInstance():getPlistData("walkpuff"))
    -- local puffFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("walkingPuff.png")
    -- puff:setTextureWithRect(puffFrame:getTexture(), puffFrame:getRect())
    -- puff:setScale(1.5)
    -- puff:setGlobalZOrder(0)
    -- puff:setPositionZ(10)
    -- self.puff = puff
    -- self.effectNode:addChild(puff)
end


return Actor
