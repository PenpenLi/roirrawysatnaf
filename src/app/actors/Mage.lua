--
-- Author: Hao Liu
-- Date: 2016-08-25 16:37:39
--
--[[
	法师，选择角色界面
]]

local Actor = require("app.actors.Actor")

local modelFile = "model/mage/mage.c3b"

local MageActions = {
    idle = createAnimation(modelFile, 206, 229, 0.7),
    walk = createAnimation(modelFile, 99, 119, 0.7),
    attack1 = createAnimation(modelFile, 12, 30, 0.7),
    attack2 = createAnimation(modelFile, 31, 49, 0.7),
    specialattack1 = createAnimation(modelFile, 56, 74, 1),
    specialattack2 = createAnimation(modelFile, 75, 92, 1),
    defend = createAnimation(modelFile, 1, 5, 0.7),
    knocked = createAnimation(modelFile, 126, 132, 0.7),
    dead = createAnimation(modelFile, 139, 199, 0.7)
}

local mesh_names = {
	{
		"fashi_wuqi01",
		"fashi_wuqi2",
	},
	{	
		"fashi_shenti01",
		"fashi_shenti2",
	},
	{
		"fashi_tou01",
		"fashi_tou2",
	},
}

local Mage = class("Mage", Actor)

function Mage:ctor()
	Mage.super.ctor(self)

	self.items = {0, 0, 0}

	copyTable(MageValues, self)

	if uiLayer~=nil then
	    self.bloodBar = uiLayer.MageBlood
	    self.bloodBarClone = uiLayer.MageBloodClone
	    self.avatar = uiLayer.MagePng
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
	local listener = cc.EventListenerCustom:create(MessageType.SPECIAL_MAGE, specialAttack)
	self:getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)

end

function Mage:init3D()
	self:initShadow()

	self.sprite3d = cc.EffectSprite3D:create(modelFile)
	self.sprite3d:setScale(1.9)
	self.sprite3d:addEffect(cc.vec3(0,0,0), CelLine, -1)
	self:addChild(self.sprite3d)
	self.sprite3d:setRotation3D({x = 90, y = 0, z = 0})        
	self.sprite3d:setRotation(-90)

	self:setDefaultEqt()
end

function Mage:initActions()
	self.action = MageActions
end

-- set default equipments
function Mage:setDefaultEqt()
    self:updateItem(EnumItemType.WEAPON)
    self:updateItem(EnumItemType.ARMOUR)
    self:updateItem(EnumItemType.HELMET)
end

function Mage:getItemId(itemType)
	return self.items[itemType]
end

function Mage:updateItem(itemType)
	local itemId = self.items[itemType]
	local oldItemId = (itemId + 1) % 2
	local newMeshName = mesh_names[itemType][itemId+1]
	local oldMeshName = mesh_names[itemType][oldItemId+1]
	local mesh = self.sprite3d:getMeshByName(newMeshName)
	mesh:setVisible(true)
	mesh = self.sprite3d:getMeshByName(oldMeshName)
	mesh:setVisible(false)
 
end

function Mage:switchItem(itemType)
	local itemId = self.items[itemType]
    itemId = itemId + 1
    self.items[itemType] = itemId % 2

    self:updateItem(itemType)
end

function Mage:doNormalAttack()
    ccexp.AudioEngine:play2d(MageProperty.normalAttackShout, false,0.4)
    ccexp.AudioEngine:play2d(MageProperty.ice_normal, false,0.8)
    MageNormalAttack.new(getPosTable(self), self.curFacing, self.normalAttack, self, self.target)
end

function Mage:doSpecialAttack()
    self.specialAttackChance = MageValues.specialAttackChance
    self.angry = ActorCommonValues.angry
    local event = cc.EventCustom:new(MessageType.ANGRY_CHANGE)
    event._usedata = {name = self.name, angry = self.angry, angryMax = self.angryMax}
    self:getEventDispatcher():dispatchEvent(event)

    --mage will create 3 ice spikes on the ground
    --get 3 positions
    ccexp.AudioEngine:play2d(MageProperty.specialAttackShout, false,0.5)
    ccexp.AudioEngine:play2d(MageProperty.ice_special, false,1)
    local pos1 = getPosTable(self)
    local pos2 = getPosTable(self)
    local pos3 = getPosTable(self)
    pos1.x = pos1.x+130
    pos2.x = pos2.x+330
    pos3.x = pos3.x+530
    pos1 = cc.pRotateByAngle(pos1, self.myPos, self.curFacing)
    pos2 = cc.pRotateByAngle(pos2, self.myPos, self.curFacing)
    pos3 = cc.pRotateByAngle(pos3, self.myPos, self.curFacing)
    MageIceSpikes.new(pos1, self.curFacing, self.specialAttack, self)
    local function spike2()
        MageIceSpikes.new(pos2, self.curFacing, self.specialAttack, self)
    end
    local function spike3()
        MageIceSpikes.new(pos3, self.curFacing, self.specialAttack, self)
    end
    delayExecute(self,spike2,0.25)
    delayExecute(self,spike3,0.5)
end

function Mage:hurtSoundEffects()
    ccexp.AudioEngine:play2d(MageProperty.wounded, false,1)
end

function Mage:playDyingEffects()
    ccexp.AudioEngine:play2d(MageProperty.dead, false,1)
end

function Mage:hurt(collider, dirKnockMode)
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

return Mage
