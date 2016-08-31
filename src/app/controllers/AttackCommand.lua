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
	self:setCameraMask(UserCameraFlagMask)
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


