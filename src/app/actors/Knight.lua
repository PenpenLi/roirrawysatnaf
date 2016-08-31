--
-- Author: Hao Liu
-- Date: 2016-08-25 16:37:19
--
--[[
	骑士，选择角色界面
]]

local Actor = require("app.actors.Actor")
require("app.controllers.AttackCommand")

local Knight = class("Knight", Actor)

local modelFile = "model/knight/knight.c3b"

local KnightActions = {
    idle = createAnimation(modelFile, 267, 283, 0.7),
    walk = createAnimation(modelFile, 227, 246, 0.7),
    attack1 = createAnimation(modelFile, 103, 129, 0.7),
    attack2 = createAnimation(modelFile, 130, 154, 0.7),
    specialattack1 = createAnimation(modelFile, 160, 190, 1),
    specialattack2 = createAnimation(modelFile, 191, 220, 1),
    defend = createAnimation(modelFile, 92, 96, 0.7),
    knocked = createAnimation(modelFile, 254, 260, 0.7),
    dead = createAnimation(modelFile, 0, 77, 1)
}

local mesh_names = {
	{
		"zhanshi_wuqi01",
		"zhanshi_wuqi02",
	},
	{	
		"zhanshi_shenti01",
		"zhanshi_shenti02",
	},
	{
		"zhanshi_tou01",
		"zhanshi_tou02",
	},
}

function Knight:ctor()
	Knight.super.ctor(self)

	self.items = {0, 0, 0}

	copyTable(KnightValues, self)

	if uiLayer~=nil then
	    self.bloodBar = uiLayer.KnightBlood
	    self.bloodBarClone = uiLayer.KnightBloodClone
	    self.avatar = uiLayer.KnightPng
	end

	self:init3D()
	self:initActions()

	self:idleMode()
	self.AIEnabled = true

	local function update(dt)
		self:baseUpdate(dt)
		self:stateMachineUpdate(dt)
		self:movementUpdate(dt)
	end
	self:scheduleUpdate(update)

	local function specialAttack()
	    if self.specialAttackChance == 1 then return end
	    self.specialAttackChance = 1
	end
	local eventDispatcher = self:getEventDispatcher()
	local listener = cc.EventListenerCustom:create(MessageType.SPECIAL_KNIGHT, specialAttack)
	eventDispatcher:addEventListenerWithFixedPriority(listener, 1)

end

function Knight:initActions()
	self.action = KnightActions
	self:initAttackEffect()    

end

function Knight:initAttackEffect()
	local speed = 0.15
	local startRotate = 145
	local rotate = -60
	local scale = 0.01
	local sprite = cc.Sprite:createWithSpriteFrameName("specialAttack.jpg")
	sprite:setVisible(false)
	sprite:setBlendFunc(gl.ONE,gl.ONE)
	sprite:setScaleX(scale)
	sprite:setRotation(startRotate)
	sprite:setOpacity(0)
	sprite:setAnchorPoint(cc.p(0.5, -0.5))    
	sprite:setPosition3D(cc.vec3(10, 0, 50))
	self:addChild(sprite)

	local scaleAction = cc.ScaleTo:create(speed, 2.5, 2.5)
	local rotateAction = cc.RotateBy:create(speed, rotate)
	local fadeAction = cc.FadeIn:create(0)
	local attack = cc.Spawn:create(scaleAction, rotateAction, fadeAction)

	
	local fadeAction2 = cc.FadeOut:create(0.5)
	local scaleAction2 = cc.ScaleTo:create(0, scale, 2.5)
	local rotateAction2 = cc.RotateTo:create(0, startRotate)
	local restore = cc.Sequence:create(fadeAction2, scaleAction2, rotateAction2)

	self.sprite = sprite
	self.action.attackEffect = cc.Sequence:create(cc.Show:create(), attack, restore)    
	self.action.attackEffect:retain()

end

function Knight:init3D()
	self:initShadow()
	self:initPuff()
	self.sprite3d = cc.EffectSprite3D:create(modelFile)
	self.sprite3d:setScale(25)
	self.sprite3d:addEffect(cc.vec3(0, 0, 0), CelLine, -1)
	self:addChild(self.sprite3d)
	self.sprite3d:setRotation3D({x = 90, y = 0, z = 0})        
	self.sprite3d:setRotation(-90)

	self:setDefaultEqt()
end

-- set default equipments
function Knight:setDefaultEqt()
    self:updateItem(EnumItemType.WEAPON)
    self:updateItem(EnumItemType.ARMOUR)
    self:updateItem(EnumItemType.HELMET)
end

function Knight:getItemId(itemType)
	return self.items[itemType]
end

function Knight:updateItem(itemType)
	local itemId = self.items[itemType]
	local oldItemId = (itemId + 1) % 2
	local newMeshName = mesh_names[itemType][itemId+1]
	local oldMeshName = mesh_names[itemType][oldItemId+1]
	local mesh = self.sprite3d:getMeshByName(newMeshName)
	mesh:setVisible(true)
	mesh = self.sprite3d:getMeshByName(oldMeshName)
	mesh:setVisible(false)
 
end

function Knight:switchItem(itemType)
	local itemId = self.items[itemType]
    itemId = itemId + 1
    self.items[itemType] = itemId % 2

    self:updateItem(itemType)
end

function Knight:doNormalAttack()
    ccexp.AudioEngine:play2d(WarriorProperty.normalAttackShout, false, 0.6)
    KnightNormalAttack.new(getPosTable(self), self.curFacing, self.normalAttack, self)
    --self._sprite:runAction(self._action.attackEffect:clone()) 

    AUDIO_ID.KNIGHTNORMALATTACK = ccexp.AudioEngine:play2d(WarriorProperty.normalAttack1, false,1)

    local function KnightNormalAttackCallback(audioID,filePath)
        ccexp.AudioEngine:play2d(WarriorProperty.normalAttack2, false,1)
    end

    ccexp.AudioEngine:setFinishCallback(AUDIO_ID.KNIGHTNORMALATTACK, KnightNormalAttackCallback)
end

function Knight:hurt(collider, dirKnockMode)
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
        blood:setCameraMask(UserCameraFlagMask)
        self:addEffect(blood)

        local eventDispatcher = self:getEventDispatcher()
        local bloodMinus = {
        	name = self.name, 
        	maxhp= self.maxhp, 
        	hp = self.hp, 
        	bloodBar = self.bloodBar, 
        	bloodBarClone = self.bloodBarClone,
        	avatar = self.avatar}
        local event = cc.EventCustom:new(MessageType.BLOOD_MINUS)
        event._usedata = bloodMinus
        eventDispatcher:dispatchEvent(event)

        local anaryChange = {
        	name = self.name, 
        	angry = self.angry*10, 
        	angryMax = self.angryMax}
        event = cc.EventCustom:new(MessageType.ANGRY_CHANGE)
        event._usedata = anaryChange
        eventDispatcher:dispatchEvent(event)

        self.angry = self.angry + damage
        return damage        
    end
    return 0
end

function Knight:doSpecialAttack()
    self.specialAttackChance = KnightValues.specialAttackChance
    self.angry = ActorCommonValues.angry
    local anaryChange = {name = self.name, angry = self.angry, angryMax = self.angryMax}
    local event = cc.EventCustom:new(MessageType.ANGRY_CHANGE)
    event._usedata = anaryChange
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:dispatchEvent(event)

    -- knight will create 2 attacks one by one  
    local attack = self.specialAttack
    attack.knock = 0
    ccexp.AudioEngine:play2d(WarriorProperty.specialAttackShout, false,0.7)
    KnightNormalAttack.new(getPosTable(self), self.curFacing, attack, self)
    self.sprite:runAction(self.action.attackEffect:clone())

    local pos = getPosTable(self)
    pos.x = pos.x+50
    pos = cc.pRotateByAngle(pos, self.myPos, self.curFacing)    

    AUDIO_ID.KNIGHTSPECIALATTACK = ccexp.AudioEngine:play2d(WarriorProperty.specialAttack1, false,1)
    local function KninghtSpecialAttackCallback(audioID, filePatch)
        ccexp.AudioEngine:play2d(WarriorProperty.specialAttack2, false,1)  
    end
    ccexp.AudioEngine:setFinishCallback(AUDIO_ID.KNIGHTSPECIALATTACK, KninghtSpecialAttackCallback)
    
    local function punch()
        KnightNormalAttack.new(pos, self.curFacing, self.specialAttack, self)
        self.sprite:runAction(self.action.attackEffect:clone())                
    end
    delayExecute(self,punch,0.2)
end

return Knight

