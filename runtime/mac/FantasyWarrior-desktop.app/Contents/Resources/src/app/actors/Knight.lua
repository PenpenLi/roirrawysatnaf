--
-- Author: Hao Liu
-- Date: 2016-08-25 16:37:19
--
--[[
	骑士，选择角色界面
]]

local Actor = require("app.actors.Actor")

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

	table.merge(self, KnightValues)

	self:init3D()
	self:initActions()

	self:idleMode()

	local function update(dt)

	end
	self:scheduleUpdate(update)

end

function Knight:initActions()
	self.action = KnightActions
	self:initAttackEffect()    

end

function Knight:initAttackEffect()

end

function Knight:init3D()
	self:initShadow()

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

return Knight

