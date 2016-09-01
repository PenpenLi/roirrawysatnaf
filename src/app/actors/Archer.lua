--
-- Author: Hao Liu
-- Date: 2016-08-25 16:37:27
--
--[[
	射手，选择角色界面
]]

local Actor = require("app.actors.Actor")
require("app.controllers.AttackCommand")

local modelFile = "model/archer/archer.c3b"

local ArcherActions = {
    idle = createAnimation(modelFile, 208, 253, 0.7),
    walk = createAnimation(modelFile, 110, 130, 0.7),
    attack1 = createAnimation(modelFile, 0, 12, 0.7),
    attack2 = createAnimation(modelFile, 12, 24, 0.7),
    specialattack1 = createAnimation(modelFile, 30, 43, 1),
    specialattack2 = createAnimation(modelFile, 44, 56, 1),
    defend = createAnimation(modelFile, 70, 95, 0.7),
    knocked = createAnimation(modelFile, 135, 145, 0.7),
    dead = createAnimation(modelFile, 150, 196, 0.7)
}

local mesh_names = {
	{
		"gongjianshou_gong01",
		"gongjianshou_gong02",
	},
	{	
		"gongjianshou_shenti01",
		"gonjianshou_shenti02",
	},
	{
		"gongjianshou_tou01",
		"gonajingshou_tou02",
	},
}

local function ArcherlAttackCallback(audioID,filePath)
    ccexp.AudioEngine:play2d(Archerproperty.attack2, false,1)
end

local Archer = class("Archer", Actor)

function Archer:ctor()
	Archer.super.ctor(self)
	
	self.items = {0, 0, 0}

	copyTable(ArcherValues, self)

	if uiLayer~=nil then
	    self.bloodBar = uiLayer.ArcherBlood
	    self.bloodBarClone = uiLayer.ArcherBloodClone
	    self.avatar = uiLayer.ArcherPng
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
	local listener = cc.EventListenerCustom:create(MessageType.SPECIAL_ARCHER, specialAttack)
	self:getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)

end

function Archer:init3D()
	self:initShadow()

	self.sprite3d = cc.EffectSprite3D:create(modelFile)
	self.sprite3d:setScale(1.6)
	self.sprite3d:addEffect(cc.vec3(0,0,0),CelLine, -1)
	self:addChild(self.sprite3d)
	self.sprite3d:setRotation3D({x = 90, y = 0, z = 0})        
	self.sprite3d:setRotation(-90)

	self:setDefaultEqt()
end

function Archer:initActions()
	self.action = ArcherActions
end

-- set default equipments
function Archer:setDefaultEqt()
    self:updateItem(EnumItemType.WEAPON)
    self:updateItem(EnumItemType.ARMOUR)
    self:updateItem(EnumItemType.HELMET)
end

function Archer:getItemId(itemType)
	return self.items[itemType]
end

function Archer:updateItem(itemType)
	local itemId = self.items[itemType]
	local oldItemId = (itemId + 1) % 2
	local newMeshName = mesh_names[itemType][itemId+1]
	local oldMeshName = mesh_names[itemType][oldItemId+1]
	local mesh = self.sprite3d:getMeshByName(newMeshName)
	mesh:setVisible(true)
	mesh = self.sprite3d:getMeshByName(oldMeshName)
	mesh:setVisible(false)
 
end

function Archer:switchItem(itemType)
	local itemId = self.items[itemType]
    itemId = itemId + 1
    self.items[itemType] = itemId % 2

    self:updateItem(itemType)
end

function Archer:playDyingEffects()
    ccexp.AudioEngine:play2d(Archerproperty.dead, false,1)
end

function Archer:hurtSoundEffects()
    ccexp.AudioEngine:play2d(Archerproperty.wounded, false,1)
end

function Archer:hurt(collider, dirKnockMode)
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
        if self.name == "Rat" then
            blood:setPositionZ(G.winSize.height*0.25)
        end
        blood:setCameraMask(UserCameraFlagMask)
        self:addEffect(blood)

        local eventDispatcher = self:getEventDispatcher()
        local event = cc.EventCustom:new(MessageType.BLOOD_MINUS)
        event._usedata = {
        	name = self.name, 
        	maxhp= self.maxhp, 
        	hp = self.hp, 
        	bloodBar = self.bloodBar, 
        	bloodBarClone = self.bloodBarClone,
        	avatar = self.avatar}
        eventDispatcher:dispatchEvent(event)

        event = cc.EventCustom:new(MessageType.ANGRY_CHANGE)
        event._usedata = {
        	name = self.name, 
        	angry = self.angry, 
        	angryMax = self.angryMax}
        eventDispatcher:dispatchEvent(event)

        self.angry = self.angry + damage
        return damage        
    end
    return 0
end

function Archer:doNormalAttack()
    ArcherNormalAttack.new(getPosTable(self), self.curFacing, self.normalAttack, self)
    ccexp.AudioEngine:play2d(Archerproperty.normalAttackShout, false,1)
    AUDIO_ID.ARCHERATTACK = ccexp.AudioEngine:play2d(Archerproperty.attack1, false,1)
--    ccexp.AudioEngine:play2d(Archerproperty.wow, false,1)
    ccexp.AudioEngine:setFinishCallback(AUDIO_ID.ARCHERATTACK,ArcherlAttackCallback)
end

function Archer:doSpecialAttack()
    self.specialAttackChance = ArcherValues.specialAttackChance
    self.angry = ActorCommonValues.angry
    
    local event = cc.EventCustom:new(MessageType.ANGRY_CHANGE)
    event._usedata = {
    	name = self.name, 
    	angry = self.angry, 
    	angryMax = self.angryMax}
    self:getEventDispatcher():dispatchEvent(event)

    ccexp.AudioEngine:play2d(Archerproperty.specialAttackShout, false,1)
    AUDIO_ID.ARCHERATTACK = ccexp.AudioEngine:play2d(Archerproperty.attack1, false,1)
    ccexp.AudioEngine:setFinishCallback(AUDIO_ID.ARCHERATTACK,ArcherlAttackCallback)
    
    local attack = self.specialAttack
    attack.knock = 80
    
    local pos1 = getPosTable(self)
    local pos2 = getPosTable(self)
    local pos3 = getPosTable(self)
    pos1.x = pos1.x
    pos2.x = pos2.x
    pos3.x = pos3.x
    pos1 = cc.pRotateByAngle(pos1, self.myPos, self.curFacing)
    pos2 = cc.pRotateByAngle(pos2, self.myPos, self.curFacing)
    pos3 = cc.pRotateByAngle(pos3, self.myPos, self.curFacing)
    ArcherSpecialAttack.new(pos1, self.curFacing, attack, self)
    local function spike2()
        ArcherSpecialAttack.new(pos2, self.curFacing, attack,self)
        AUDIO_ID.ARCHERATTACK = ccexp.AudioEngine:play2d(Archerproperty.attack1, false,1)
        ccexp.AudioEngine:setFinishCallback(AUDIO_ID.ARCHERATTACK,ArcherlAttackCallback)
    end
    local function spike3()
        ArcherSpecialAttack.new(pos3, self.curFacing, attack,self)
        AUDIO_ID.ARCHERATTACK = ccexp.AudioEngine:play2d(Archerproperty.attack1, false,1)
        ccexp.AudioEngine:setFinishCallback(AUDIO_ID.ARCHERATTACK,ArcherlAttackCallback)
    end
    delayExecute(self,spike2,0.2)
    delayExecute(self,spike3,0.4)
end


return Archer


