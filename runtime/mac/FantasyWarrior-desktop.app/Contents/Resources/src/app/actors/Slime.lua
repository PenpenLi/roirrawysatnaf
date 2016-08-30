--
-- Author: Hao Liu
-- Date: 2016-08-19 16:36:40
-- 
--[[
	软泥怪, loading界面有使用
]]

local Actor = require("app.actors.Actor")

local Slime = class("Slime", Actor)

local modelFile = "model/slime/slime.c3b"
local pngFile = "model/slime/baozi.jpg"
local png2File = "model/slime/baozi2.jpg"

function Slime:ctor()
	Slime.super.ctor(self)

	table.merge(self, SlimeValues)

	self:init3D()
	self:initActions()

end

function Slime:init3D()
	self:initShadow()

	self.sprite3d = cc.EffectSprite3D:create(modelFile)
	self.sprite3d:setTexture(pngFile)
	self.sprite3d:setScale(17)
	self.sprite3d:addEffect(cc.vec3(0,0,0), CelLine, -1)
	self:addChild(self.sprite3d)
	self.sprite3d:setRotation3D({x = 90, y = 0, z = 0})        
	self.sprite3d:setRotation(-90)

end

function Slime:initActions()

end

return Slime
