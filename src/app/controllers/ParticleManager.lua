--
-- Author: Hao Liu
-- Date: 2016-08-19 14:42:49
-- 
--[[ 
	控制粒子效果
]]

local ParticleManager = class("ParticleManager")

function ParticleManager:ctor()
	self.tag = 1
	self.plistMap = {}
end

function ParticleManager:getInstance()
	if self.instance == nil then
		self.instance = self:new()
	end
	return self.instance
end

function ParticleManager:AddPlistData(fileName, keyName)
	fileName = fileName or ""
	keyName = keyName or ""
	if fileName == "" or keyName == "" then 
		return 
	end
	for k in pairs(self.plistMap) do
		if keyName == k then
			printInfo("the keyName is exit already.")
			return
		end
	end
	local plistData = cc.FileUtils:getInstance():getValueMapFromFile(fileName)
	self.plistMap[keyName] = plistData
end

function ParticleManager:getPlistData(keyName)
	keyName = keyName or ""
	if keyName == "" then
		return
	end
	for k in pairs(self.plistMap) do
		if keyName == k then
			return self.plistMap[keyName]
		end
	end
	printInfo("can't find plistData by the specified keyName")
end

return ParticleManager
