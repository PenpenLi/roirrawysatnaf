--
-- Author: Hao Liu
-- Date: 2016-08-25 16:37:27
--
--[[
	射手，选择角色界面
]]

local Actor = require("app.actors.Actor")

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

local Archer = class("Archer", Actor)

function Archer:ctor()
	Archer.super.ctor(self)
	
	self.items = {0, 0, 0}

	table.merge(self, ArcherValues)

	self:init3D()
	self:initActions()

	self:idleMode()

	local function update(dt)

	end
	self:scheduleUpdate(update)

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

return Archer