--[[
	loading界面
]]

local ParticleManager = require("app.controllers.ParticleManager")
local Slime = require("app.actors.Slime")

local MainScene = class("MainScene", cc.load("mvc").ViewBase)

local particleRes = {
	{"FX/iceTrail.plist", "iceTrail"},
	{"FX/magic.plist", "magic"},
	{"FX/pixi.plist", "pixi"},
	{"FX/puffRing.plist", "puffRing"},
	{"FX/puffRing2.plist", "puffRing2"},
	{"FX/walkingPuff.plist", "walkpuff"},
}

local spriteFrameRes = {
	{"FX/FX.plist", "FX/FX.png"},
	{"chooseRole/chooserole.plist", "chooseRole/chooserole.png"},
	{"battlefieldUI/battleFieldUI.plist", "battlefieldUI/battleFieldUI.png"},
	{"mainmenuscene/mainmenuscene.plist", "mainmenuscene/mainmenuscene.png"}
}

local res_bg = "loadingscene/bg.jpg"
local res_slider = "loadingscene/sliderProgress.png"

function MainScene:onCreate()
	self.num = table.nums(particleRes) + table.nums(spriteFrameRes)
	self.totalResource = self.num
	self.pm = ParticleManager:getInstance()

	local background = display.newSprite(res_bg, display.cx, display.cy)
	background:setScale(1.5)
	self:addChild(background)
    background:setGlobalZOrder(-1)
    -- background:setPositionZ(-250)

	local loadingbar = ccui.LoadingBar:create(res_slider)
	self:addChild(loadingbar)
	loadingbar:setPosition(display.cx, display.height * 0.2)
	loadingbar:setScale(3, 2)
	loadingbar:setColor(cc.c3b(0, 0, 0))
	loadingbar:setOpacity(70)
	loadingbar:setPercent(100)
	local loadingbarSize = loadingbar:getContentSize().width*3

	self:addLoadingText()

	self:slimeAction()

	local update = function(dt)
		self.num = self.num - 1
		loadingbar:setPercent((self.totalResource-self.num)/self.totalResource*100)

		local loadingAction = cc.JumpBy:create(dt, cc.p(0, 0), 50, 1)
		local loadingIndex = (self.totalResource-self.num)%(table.nums(self.loading)+1)
		self.loading[loadingIndex > 1 and loadingIndex or 1]:runAction(loadingAction)
		
		if self.slime then
			self.slime:runAction(cc.MoveTo:create(dt, 
				cc.p(self.slimeOriginX+loadingbarSize*loadingbar:getPercent()/100,
					self.slimeOriginY)))
		end

		if self.totalResource - self.num > table.nums(spriteFrameRes) then
			self:cachedParticleRes()
		else
			self:cachedTextureRes()
		end

		if self.num == -1 then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleID)
			self:getApp():run("MainMenuScene")
		end
	end
	self.scheduleID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0.1, false)

	-- printInfo(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())

end

function MainScene:slimeAction()
	display.loadSpriteFrames("FX/FX.plist", "FX/FX.png")

	local slime = Slime.new()
	self.slimeOriginX = display.width * 0.2
	self.slimeOriginY = display.height * 0.3
	slime:setPosition(self.slimeOriginX, self.slimeOriginY)
	self.slime = slime
	self:addChild(slime)
	slime:setRotation3D({x = -90, y = -90, z = 0})

	local dur = 0.6
	local bsc = 27

	slime.sprite3d:runAction(cc.RepeatForever:create(
		cc.Spawn:create(
				cc.Sequence:create(
					cc.DelayTime:create(dur/8),
					cc.JumpBy3D:create(dur*7/8, cc.p(0, 0), 30, 1)
					),
				cc.Sequence:create(
	                cc.EaseSineOut:create(cc.ScaleTo:create(dur/8, bsc*1.4, bsc*1.4, bsc*0.75)),
	                cc.EaseSineOut:create(cc.ScaleTo:create(dur/8, bsc*0.85, bsc*0.85, bsc*1.3)),
	                cc.EaseSineOut:create(cc.ScaleTo:create(dur/8, bsc*1.2, bsc*1.2, bsc*0.9)),
	                cc.EaseSineOut:create(cc.ScaleTo:create(dur/8, bsc*0.95, bsc*0.95, bsc*1.1)),
	                cc.EaseSineOut:create(cc.ScaleTo:create(dur*4/8, bsc, bsc, bsc))
					)
			)
		))
end

function MainScene:addLoadingText()
	local ttfconfig = {
		outlineSize = 5,
		fontSize = 55,
		fontFilePath = font_actor
	}
	local loading = {}
	local textArr = {"l", "o", "a", "d", "i", "n", "g"}
	local textCount = #textArr
	for i = 1, textCount do
		loading[i] = cc.Label:createWithTTF(ttfconfig, textArr[i])
		loading[i]:enableOutline(cc.c4b(104, 151, 161, 255))
        loading[i]:setPosition(display.width*0.1+display.width*0.1*i,
        	display.height*0.6)
        self:addChild(loading[i])
	end
	self.loading = loading
end

function MainScene:cachedParticleRes()
	if self.num < 0 then
		return
	end
    local resName = particleRes[self.totalResource-self.num-table.nums(spriteFrameRes)]
    self.pm:AddPlistData(resName[1], resName[2])

end

function MainScene:cachedTextureRes()
	if self.num < 0 then
		return
	end
	local resName = spriteFrameRes[self.totalResource-self.num] 
	display.loadSpriteFrames(resName[1], resName[2])
end

return MainScene
