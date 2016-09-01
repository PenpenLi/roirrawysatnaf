--
-- Author: Hao Liu
-- Date: 2016-08-30 17:00:54
--
--[[
	AttackCommand
]]
local ParticleManager = require("app.controllers.ParticleManager")

cc.exports.AttackManager = List.new()
local function solveAttacks(dt)
    for val = AttackManager.last, AttackManager.first, -1 do
        local attack = AttackManager[val]
        local apos = getPosTable(attack) 
        if attack.mask == EnumRaceType.HERO then
            --if heroes attack, then lets check monsters
            for mkey = MonsterManager.last, MonsterManager.first, -1 do
                --check distance first
                local monster = MonsterManager[mkey]
                local mpos = monster.myPos
                local dist = cc.pGetDistance(apos, mpos)
                if dist < (attack.maxRange + monster.radius) and dist > attack.minRange then
                    --range test passed, now angle test
                    local angle = radNormalize(cc.pToAngleSelf(cc.pSub(mpos,apos)))
                    local afacing = radNormalize(attack.facing)
                    
                    if(afacing + attack.angle/2)>angle and angle > (afacing- attack.angle/2) then
                        attack:onCollide(monster)
                    end
                end
            end
        elseif attack.mask == EnumRaceType.MONSTER then
            --if heroes attack, then lets check monsters
            for hkey = HeroManager.last, HeroManager.first, -1 do
                --check distance first
                local hero = HeroManager[hkey]
                local hpos = hero.myPos
                local dist = cc.pGetDistance(getPosTable(attack), hpos)
                if dist < (attack.maxRange + hero.radius) and dist > attack.minRange then
                    --range test passed, now angle test
                    local angle = cc.pToAngleSelf(cc.pSub(hpos,getPosTable(attack)))
                    if(attack.facing + attack.angle/2)>angle and angle > (attack.facing- attack.angle/2) then
                        attack:onCollide(hero)
                    end
                end
            end
        end
        attack.curDuration = attack.curDuration+dt
        if attack.curDuration > attack.duration then
            attack:onTimeOut()
            List.remove(AttackManager,val)
        else
            attack:onUpdate(dt)
        end
    end
end
cc.exports.solveAttacks = solveAttacks

cc.exports.BasicCollider = class("BasicCollider", function()
    local node = cc.Sprite3D:create()
    node:setCascadeColorEnabled(true)
    return node
end)

function BasicCollider:ctor(pos, facing, attackInfo)
	self.minRange = 0   --the min radius of the fan
	self.maxRange = 150 --the max radius of the fan
	self.angle    = 120 --arc of attack, in radians
	self.knock    = 150 --default knock, knocks 150 units 
	self.mask     = 1   --1 is Heroes, 2 is enemy, 3 ??
	self.damage   = 100
	self.facing    = 0 --this is radians
	self.duration = 0
	self.curDuration = 0
	self.speed = 0 --traveling speed}
	self.criticalChance = 0

	self:initData(pos,facing,attackInfo)

end

function BasicCollider:initData(pos, facing, attackInfo)
    copyTable(attackInfo, self)
    
    self.facing = facing or self.facing
    self:setPosition(pos)
    List.pushlast(AttackManager, self)
    currentLayer:addChild(self, -10)
end

--callback when the collider has being solved by the attack manager, 
--make sure you delete it from node tree, if say you have an effect attached to the collider node
function BasicCollider:onTimeOut()
    self:removeFromParent()
end

function BasicCollider:playHitAudio()
    ccexp.AudioEngine:play2d(CommonAudios.hit, false,0.7)
end

function BasicCollider:hurtEffect(target)    
    local hurtAction = cc.Animate:create(display.getAnimationCache("hurtAnimation"))
    local hurtEffect = cc.BillBoard:create()
    hurtEffect:setScale(1.5)
    hurtEffect:runAction(cc.Sequence:create(hurtAction, cc.RemoveSelf:create()))
    hurtEffect:setPosition3D(cc.vec3(0,0,50))
    hurtEffect:setCameraMask(UserCameraFlagMask)
    target:addChild(hurtEffect)
end

function BasicCollider:onCollide(target)
    
    self:hurtEffect(target)
    self:playHitAudio()    
    target:hurt(self)
end

function BasicCollider:onUpdate()
    -- implement this function if this is a projectile
end

---------------------------------------------------------------------------
cc.exports.KnightNormalAttack = class("KnightNormalAttack", BasicCollider)

function KnightNormalAttack:ctor(pos, facing, attackInfo, owner)
	KnightNormalAttack.super.ctor(self, pos, facing, attackInfo)
	self.owner = owner
	self:setCameraMask(UserCameraFlagMask)

end

---------------------------------------------------------------------------
cc.exports.MageNormalAttack = class("MageNormalAttack", BasicCollider)

function MageNormalAttack:ctor(pos, facing, attackInfo, owner, target)
	MageNormalAttack.super.ctor(self, pos, facing, attackInfo)
	self.owner = owner
	self.target = target

	local icebolt = cc.SpriteFrameCache:getInstance():getSpriteFrame("icebolt.png")
	self.sp = cc.BillBoard:create("FX/FX.png", icebolt:getRect(), 0)
	--ret.sp:setCamera(camera)
	self.sp:setPosition3D(cc.vec3(0,0,50))
	self.sp:setScale(2)
	self:addChild(self.sp)

	local smoke = cc.ParticleSystemQuad:create(ParticleManager:getInstance():getPlistData("iceTrail"))
	local magicf = cc.SpriteFrameCache:getInstance():getSpriteFrame("puff.png")
	smoke:setTextureWithRect(magicf:getTexture(), magicf:getRect())
	smoke:setScale(2)
	self:addChild(smoke)
	smoke:setRotation3D({x=90, y=0, z=0})
	smoke:setGlobalZOrder(0)
	smoke:setPositionZ(50)

	local pixi = cc.ParticleSystemQuad:create(ParticleManager:getInstance():getPlistData("pixi"))
	local pixif = cc.SpriteFrameCache:getInstance():getSpriteFrame("particle.png")
	pixi:setTextureWithRect(pixif:getTexture(), pixif:getRect())
	pixi:setScale(2)
	self:addChild(pixi)
	pixi:setRotation3D({x=90, y=0, z=0})
	pixi:setGlobalZOrder(0)
	pixi:setPositionZ(50)

	self.part1 = smoke
	self.part2 = pixi

    self:setCameraMask(UserCameraFlagMask)

end

function MageNormalAttack:onTimeOut()
    self.part1:stopSystem()
    self.part2:stopSystem()
    self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.RemoveSelf:create()))
    
    local magic = cc.ParticleSystemQuad:create(ParticleManager:getInstance():getPlistData("magic"))
    local magicf = cc.SpriteFrameCache:getInstance():getSpriteFrame("particle.png")
    magic:setTextureWithRect(magicf:getTexture(), magicf:getRect())
    magic:setScale(1.5)
    magic:setRotation3D({x=90, y=0, z=0})
    self:addChild(magic)
    magic:setGlobalZOrder(0)
    magic:setPositionZ(0)
    self:setCameraMask(UserCameraFlagMask)
    
    local iceSpike1 = cc.SpriteFrameCache:getInstance():getSpriteFrame("iceSpike1.png")
    self.sp:setTextureRect(iceSpike1:getRect())
    self.sp:runAction(cc.FadeOut:create(1))
    self.sp:setScale(4)

end

function MageNormalAttack:onCollide(target)
    self:hurtEffect(target)
    self:playHitAudio()    
    self.owner.angry = self.owner.angry + target:hurt(self)*0.3
    
    local event = cc.EventCustom:new(MessageType.ANGRY_CHANGE)
    event._usedata = {name = MageValues.name, angry = self.owner.angry, angryMax = self.owner.angryMax}
    self:getEventDispatcher():dispatchEvent(event)

    --set cur duration to its max duration, so it will be removed when checking time out
    self.curDuration = self.duration+1
end

function MageNormalAttack:onUpdate(dt)
    local nextPos
    if self.target and self.target.isalive then
        local selfPos = getPosTable(self)
        local tpos = self.target.myPos
        local angle = cc.pToAngleSelf(cc.pSub(tpos,selfPos))
        nextPos = cc.pRotateByAngle(cc.pAdd({x=self.speed*dt, y=0},selfPos),selfPos,angle)
    else
        local selfPos = getPosTable(self)
        nextPos = cc.pRotateByAngle(cc.pAdd({x=self.speed*dt, y=0},selfPos),selfPos,self.facing)
    end
    self:setPosition(nextPos)
end

---------------------------------------------------------------------------
cc.exports.MageIceSpikes = class("ArcherNormalAttack", BasicCollider)

function MageIceSpikes:ctor(pos, facing, attackInfo, owner)
    MageIceSpikes.super.ctor(self, pos, facing, attackInfo)

    self.sp = cc.ShadowSprite:createWithSpriteFrameName("shadow.png")
    self.sp:setGlobalZOrder(-self:getPositionY()+FXZorder)
    self.sp:setOpacity(100)
    self.sp:setPosition3D(cc.vec3(0,0,1))
    self.sp:setScale(self.maxRange/12)
    self.sp:setGlobalZOrder(-1)
    self:addChild(self.sp)
    self.owner = owner

    ---========
    --create 3 spikes
    local x = cc.Node:create()
    self.spikes = x
    self:addChild(x)
    for var=0, 10 do
        local rand = math.ceil(math.random()*3)
        local spike = cc.Sprite:createWithSpriteFrameName(string.format("iceSpike%d.png",rand))
        spike:setAnchorPoint(0.5,0)
        spike:setRotation3D(cc.vec3(90,0,0))
        x:addChild(spike)
        if rand == 3 then
            spike:setScale(1.5)
        else
            spike:setScale(2)
        end
        spike:setOpacity(165)
        spike:setFlippedX(not(math.floor(math.random()*2)))
        spike:setPosition3D(cc.vec3(math.random(-self.maxRange/1.5, self.maxRange/1.5),math.random(-self.maxRange/1.5, self.maxRange/1.5),1))
        spike:setGlobalZOrder(0)
        x:setScale(0)
        x:setPositionZ(-210)
    end
    x:runAction(cc.EaseBackOut:create(cc.MoveBy:create(0.3,cc.vec3(0,0,200))))
    x:runAction(cc.EaseBounceOut:create(cc.ScaleTo:create(0.4, 1)))
    
    -- local magic = cc.BillboardParticleSystem:create(ParticleManager:getInstance():getPlistData("magic"))
    -- local magicf = cc.SpriteFrameCache:getInstance():getSpriteFrame("particle.png")
    -- magic:setTextureWithRect(magicf:getTexture(), magicf:getRect())
    -- magic:setCamera(camera)
    -- magic:setScale(1.5)
    -- ret:addChild(magic)
    -- magic:setGlobalZOrder(-ret:getPositionY()*2+FXZorder)
    -- magic:setPositionZ(0)
    self:setCameraMask(UserCameraFlagMask)

end

function MageIceSpikes:playHitAudio()
    ccexp.AudioEngine:play2d(MageProperty.ice_specialAttackHit, false,0.7)
end

function MageIceSpikes:onTimeOut()
    self.spikes:setVisible(false)
    -- local puff = cc.BillboardParticleSystem:create(ParticleManager:getInstance():getPlistData("puffRing"))
    -- --local puff = cc.ParticleSystemQuad:create("FX/puffRing.plist")
    -- local puffFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("puff.png")
    -- puff:setTextureWithRect(puffFrame:getTexture(), puffFrame:getRect())
    -- puff:setCamera(camera)
    -- puff:setScale(3)
    -- self:addChild(puff)
    -- puff:setGlobalZOrder(-self:getPositionY()+FXZorder)
    -- puff:setPositionZ(20)
    
    -- local magic = cc.BillboardParticleSystem:create(ParticleManager:getInstance():getPlistData("magic"))
    -- local magicf = cc.SpriteFrameCache:getInstance():getSpriteFrame("particle.png")
    -- magic:setTextureWithRect(magicf:getTexture(), magicf:getRect())
    -- magic:setCamera(camera)
    -- magic:setScale(1.5)
    -- self:addChild(magic)
    -- magic:setGlobalZOrder(-self:getPositionY()+FXZorder)
    -- magic:setPositionZ(0)
    self:setCameraMask(UserCameraFlagMask)
        
    self.sp:runAction(cc.FadeOut:create(1))
    self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.RemoveSelf:create()))
end

function MageIceSpikes:onCollide(target)
    if self.curDOTTime > self.DOTTimer then
        self:hurtEffect(target)
        self:playHitAudio()    
        self.owner.angry = self.owner.angry + target:hurt(self)*0.1
        
        local event = cc.EventCustom:new(MessageType.ANGRY_CHANGE)
        event._usedata = {name = MageValues.name, angry = self.owner.angry, angryMax = self.owner.angryMax}
        self:getEventDispatcher():dispatchEvent(event)


        self.DOTApplied = true
    end
end

function MageIceSpikes:onUpdate(dt)
-- implement this function if this is a projectile
    self.curDOTTime = self.curDOTTime + dt
    if self.DOTApplied then
        self.DOTApplied = false
        self.curDOTTime = 0
    end
end


---------------------------------------------------------------------------
cc.exports.ArcherNormalAttack = class("ArcherNormalAttack", BasicCollider)

function ArcherNormalAttack:ctor(pos, facing, attackInfo, owner)
    ArcherNormalAttack.super.ctor(self, pos, facing, attackInfo)

    self.owner = owner
    local sprite3d = cc.Sprite3D:create("model/archer/arrow.obj")
    sprite3d:setTexture("model/archer/hunter01_tex_head.jpg")
    sprite3d:setScale(2)
    sprite3d:setPosition3D(cc.vec3(0,0,50))
    sprite3d:setRotation3D({x = -90, y = 0, z = 0})        
    sprite3d:setRotation(math.deg(-facing)-90)
    self.sp = sprite3d
    self:setCameraMask(UserCameraFlagMask)

end

function ArcherNormalAttack:onTimeOut()
    self:runAction(cc.RemoveSelf:create())
end

function ArcherNormalAttack:onCollide(target)
    self:hurtEffect(target)
    self:playHitAudio()    
    self.owner.angry = self.owner.angry + target:hurt(self, true)*0.3
    
    local event = cc.EventCustom:new(MessageType.ANGRY_CHANGE)
    event._usedata = {name = ArcherValues.name, angry = self.owner.angry, angryMax = self.owner.angryMax}
    self:getEventDispatcher():dispatchEvent(event)

    --set cur duration to its max duration, so it will be removed when checking time out
    self.curDuration = self.duration+1
end

function ArcherNormalAttack:onUpdate(dt)
    local selfPos = getPosTable(self)
    local nextPos = cc.pRotateByAngle(cc.pAdd({x=self.speed*dt, y=0},selfPos),selfPos,self.facing)
    self:setPosition(nextPos)
end

---------------------------------------------------------------------------
cc.exports.ArcherSpecialAttack = class("ArcherSpecialAttack", BasicCollider)

function ArcherSpecialAttack:ctor(pos, facing, attackInfo, owner)
    ArcherSpecialAttack.super.ctor(self, pos, facing, attackInfo)

    self.owner = owner
    local sprite3d = cc.Sprite3D:create("model/archer/arrow.obj")
    sprite3d:setTexture("model/archer/hunter01_tex_head.jpg")
    sprite3d:setScale(2)
    sprite3d:setPosition3D(cc.vec3(0,0,50))
    sprite3d:setRotation3D({x = -90, y = 0, z = 0})        
    sprite3d:setRotation(math.deg(-facing)-90)
    self.sp = sprite3d
    self:setCameraMask(UserCameraFlagMask)

end

function ArcherSpecialAttack:onTimeOut()
    self:runAction(cc.RemoveSelf:create())
end

function ArcherSpecialAttack:onCollide(target)
    if self.curDOTTime >= self.DOTTimer then
        self:hurtEffect(target)
        self:playHitAudio()    
        self.owner.angry = self.owner.angry + target:hurt(self, true)*0.3
        
        local event = cc.EventCustom:new(MessageType.ANGRY_CHANGE)
        event._usedata = {name = ArcherValues.name, angry = self.owner.angry, angryMax = self.owner.angryMax}
        self:getEventDispatcher():dispatchEvent(event)
        
        self.DOTApplied = true
    end
end

function ArcherSpecialAttack:onUpdate(dt)
    local selfPos = getPosTable(self)
    local nextPos = cc.pRotateByAngle(cc.pAdd({x=self.speed*dt, y=0},selfPos),selfPos,self.facing)
    self:setPosition(nextPos)
    self.curDOTTime = self.curDOTTime + dt
    if self.DOTApplied then
        self.DOTApplied = false
        self.curDOTTime = 0
    end
end

---------------------------------------------------------------------------
cc.exports.DragonAttack = class("DragonAttack", BasicCollider)

function DragonAttack:ctor(pos,facing,attackInfo)
	DragonAttack.super.ctor(self, pos, facing, attackInfo)

	local fireBall = cc.SpriteFrameCache:getInstance():getSpriteFrame("fireball1.png")
	self.sp = cc.BillBoard:create("FX/FX.png", fireBall:getRect(), cc.BillBoard_Mode.VIEW_POINT_ORIENTED)
	self.sp:setPosition3D(cc.vec3(0,0,48))
	self.sp:setScale(1.7)
	self:addChild(self.sp)
	self:setCameraMask(UserCameraFlagMask)

end

function DragonAttack:onTimeOut()
    self:runAction(cc.Sequence:create(
    	cc.DelayTime:create(0.5),
    	cc.RemoveSelf:create()))

    local magic = cc.ParticleSystemQuad:create(ParticleManager:getInstance():getPlistData("magic"))
    local magicf = cc.SpriteFrameCache:getInstance():getSpriteFrame("particle.png")
    magic:setTextureWithRect(magicf:getTexture(), magicf:getRect())
    magic:setScale(1.5)
    magic:setRotation3D({x=90, y=0, z=0})
    self:addChild(magic)
    magic:setGlobalZOrder(-self:getPositionY()*2+FXZorder)
    magic:setPositionZ(0)
    magic:setEndColor({r=1,g=0.5,b=0})
    self:setCameraMask(UserCameraFlagMask)

    local fireballAction = cc.Animate:create(display.getAnimationCache("fireBallAnim"))
    self.sp:runAction(fireballAction)
    self.sp:setScale(2)
    
end

function DragonAttack:playHitAudio()
    ccexp.AudioEngine:play2d(MonsterDragonValues.fireHit, false,0.6)    
end

function DragonAttack:onCollide(target)
    self:hurtEffect(target)
    self:playHitAudio()    
    target:hurt(self)
    --set cur duration to its max duration, so it will be removed when checking time out
    self.curDuration = self.duration+1
end

function DragonAttack:onUpdate(dt)
    local selfPos = getPosTable(self)
    local nextPos = cc.pRotateByAngle(cc.pAdd({x=self.speed*dt, y=0},selfPos),selfPos,self.facing)
    self:setPosition(nextPos)
end


