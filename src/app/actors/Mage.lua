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

return Mage
