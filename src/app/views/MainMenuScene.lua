--
-- Author: Hao Liu
-- Date: 2016-08-24 15:39:40
--

--[[
	loading成功之后现实的主菜单界面
]]

require("app.GlobalVariables")

local res_bg = "mainmenuscene/bg.jpg"
local res_cloud1 = "#cloud1.png"
local res_cloud2 = "#cloud2.png"
local res_logo = "mainmenuscene/logo.png"
local res_logo_normal = "mainmenuscene/logo_normal.png"
local res_light = "#light.png"
local res_swing_l1 = "#swing_l1.png"
local res_swing_l2 = "#swing_l2.png"
local res_swing_r1 = "#swing_r1.png"
local res_swing_r2 = "#swing_r2.png"
local res_btn_start = "start.png"
local res_effect_start_normal = "mainmenuscene/start_normal.png"
local res_effect_start = "mainmenuscene/start.png"

local MainMenuScene = class("MainMenuScene", cc.load("mvc").ViewBase)

function MainMenuScene:onCreate()
	self.size = cc.Director:getInstance():getVisibleSize()
	ccexp.AudioEngine:stopAll()
	AUDIO_ID.MAINMENUBGM = ccexp.AudioEngine:play2d(BGM_RES.MAINMENUBGM, true, 1)

    cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_AUTO)
    
    self:addBg()

    self:addCloud()

    self:addLogo()

    self:addPointLight()

    self:addButton()

    local function onExit(event)
    	if "exit" == event then
    		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.logoSchedule)
    		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleCloudMove)
    	end
    end
    self:registerScriptHandler(onExit)
end

function MainMenuScene:addButton()
	local isTouchButton = false
	local button_callback = function(sender,eventType)
        if isTouchButton == false then
            isTouchButton = true
            if eventType == ccui.TouchEventType.began then
                ccexp.AudioEngine:play2d(BGM_RES.MAINMENUSTART, false, 1)
                ccexp.AudioEngine:stop(AUDIO_ID.MAINMENUBGM)
            end
        end
	end

	local button = ccui.Button:create(res_btn_start, "", "", ccui.TextureResType.plistType)
	button:setPosition(self.size.width*0.5, self.size.height*0.15)
	button:addTouchEventListener(button_callback)
	self:addChild(button,4)

	local effectNormalMapped = cc.EffectNormalMapped:create(res_effect_start_normal)
	effectNormalMapped:setPointLight(self.pointLight)
	effectNormalMapped:setKBump(100)
	
	local effectSprite = cc.EffectSprite:create(res_effect_start)
	effectSprite:setPosition(self.size.width*0.5,self.size.height*0.15)
	self:addChild(effectSprite,5)
	effectSprite:setEffect(effectNormalMapped)

end

function MainMenuScene:getLightSprite()
	self.lightSprite = display.newSprite(res_light)
	self.lightSprite:setBlendFunc({src = gl.ONE, dst = gl.ONE_MINUS_SRC_ALPHA})
	self.lightSprite:setScale(1.2)
	self.lightSprite:setPosition3D(cc.vec3(self.size.width * 0.5, self.size.height * 0.5, 0))

	local light_size = self.lightSprite:getContentSize()
	local rotate_top = cc.RotateBy:create(0.05, 50)
	local rotate_bottom = cc.RotateBy:create(0.05, -50)
    local origin_degree = 20
    local sprite_scale = 0
    local opacity = 100
    local scale_action = cc.ScaleTo:create(0.07,0.7)

    local swing_l1 = display.newSprite(res_swing_l1, light_size.width*0.5, light_size.height*0.5)
    swing_l1:setScale(sprite_scale)
    swing_l1:setAnchorPoint(cc.p(1, 0))
    swing_l1:setRotation(-origin_degree)
    swing_l1:setOpacity(opacity)
    swing_l1:setBlendFunc({src = gl.ONE, dst = gl.ONE})
    self.lightSprite:addChild(swing_l1, 5)

    local swing_l2 = display.newSprite(res_swing_l2, light_size.width*0.5, light_size.height*0.5)
    swing_l2:setAnchorPoint(cc.p(1,1))
    swing_l2:setScale(sprite_scale)
    swing_l2:setRotation(origin_degree)
    swing_l2:setOpacity(opacity)
    self.lightSprite:addChild(swing_l2, 5)
    
    local swing_r1 = display.newSprite(res_swing_r1, light_size.width*0.5, light_size.height*0.5)
    swing_r1:setAnchorPoint(cc.p(0,0))
    swing_r1:setScale(sprite_scale)
    swing_r1:setRotation(origin_degree)
    swing_r1:setOpacity(opacity)
    swing_r1:setBlendFunc({src = gl.ONE, dst = gl.ONE})
    self.lightSprite:addChild(swing_r1, 5)
    
    local swing_r2 = display.newSprite(res_swing_r2, light_size.width*0.5, light_size.height*0.5)
    swing_r2:setAnchorPoint(cc.p(0,1))
    swing_r2:setScale(sprite_scale)
    swing_r2:setRotation(-origin_degree)
    swing_r2:setOpacity(opacity)
    self.lightSprite:addChild(swing_r2, 5)

    local sequence_l1 = cc.Sequence:create(rotate_top,rotate_top:reverse())
    local sequence_r1 = cc.Sequence:create(rotate_top:reverse():clone(),rotate_top:clone())
    local sequence_l2 = cc.Sequence:create(rotate_bottom,rotate_bottom:reverse())
    local sequence_r2 = cc.Sequence:create(rotate_bottom:reverse():clone(),rotate_bottom:clone())
    swing_l1:runAction(cc.RepeatForever:create(cc.Spawn:create(sequence_l1,scale_action)))
    swing_r1:runAction(cc.RepeatForever:create(cc.Spawn:create(sequence_r1,scale_action)))
    swing_l2:runAction(cc.RepeatForever:create(cc.Spawn:create(sequence_l2,scale_action)))
    swing_r2:runAction(cc.RepeatForever:create(cc.Spawn:create(sequence_r2,scale_action)))

end

function MainMenuScene:addPointLight()
	self.pointLight = cc.PointLight:create(cc.vec3(0, 0, -100), cc.c3b(255, 255, 255), 10000)
	self.pointLight:setCameraMask(1)
	self.pointLight:setEnabled(true)

	self:getLightSprite()
	self.lightSprite:addChild(self.pointLight)
	self:addChild(self.lightSprite, 10)
	self.lightSprite:setPositionZ(100)

	local effectNormalMapped = cc.EffectNormalMapped:create(res_logo_normal);
	effectNormalMapped:setPointLight(self.pointLight)
	effectNormalMapped:setKBump(50)
	self.logo:setEffect(effectNormalMapped)

	local function getBezierAction()
	    local bezierConfig1 = {
	        cc.p(self.size.width*0.9,self.size.height*0.4),
	        cc.p(self.size.width*0.9,self.size.height*0.8),
	        cc.p(self.size.width*0.5,self.size.height*0.8)
	    }
	    local bezierConfig2 = {
	        cc.p(self.size.width*0.1,self.size.height*0.8),
	        cc.p(self.size.width*0.1,self.size.height*0.4),
	        cc.p(self.size.width*0.5,self.size.height*0.4)
	    }
	    local bezier1 = cc.BezierTo:create(5,bezierConfig1)
	    local bezier2 = cc.BezierTo:create(5,bezierConfig2)
	    local bezier = cc.Sequence:create(bezier1,bezier2)

	    return bezier
	end
	self.lightSprite:runAction(cc.RepeatForever:create(getBezierAction()))

	local function onTouchBegin(touch, event)
		self.lightSprite:stopAllActions()

		local location = touch:getLocation()
		self.prePosition = location

		local function movePoint(dt)
			local lightSpritePos = cc.p(self.lightSprite:getPositionX(), self.lightSprite:getPositionY())
			local point = cc.pLerp(lightSpritePos, self.prePosition, dt*2)
			self.lightSprite:setPosition(point)
		end
		self.scheduleMove = cc.Director:getInstance():getScheduler():scheduleScriptFunc(movePoint,0,false)

		return true
	end

	local function onTouchMoved(touch, event)
	    local location = touch:getLocation()
        self.prePosition = location

	end

	local function onTouchEnded(touch, event)
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleMove)
        self.lightSprite:stopAllActions()
        self.lightSprite:runAction(cc.RepeatForever:create(getBezierAction()))      

	end

    local touchEventListener = cc.EventListenerTouchOneByOne:create()
    touchEventListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN)
    touchEventListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED)
    touchEventListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(touchEventListener, self)
end

function MainMenuScene:addLogo()
	local logo = cc.EffectSprite:create(res_logo)
	logo:setPosition(self.size.width * 0.53, self.size.height * 0.55)
	self:addChild(logo, 4)
	logo:setScale(0.1)
	self.logo = logo

	local action = cc.EaseElasticOut:create(cc.ScaleTo:create(2, 1.1))
	logo:runAction(action)

	local time = 0
	local function logoShake()
		--rand_n = range * math.sin(math.rad(time*speed+offset))
		local rand_x = 0.1*math.sin(math.rad(time*0.5+4356))
		local rand_y = 0.1*math.sin(math.rad(time*0.37+5436)) 
		local rand_z = 0.1*math.sin(math.rad(time*0.2+54325))
		logo:setRotation3D({x=math.deg(rand_x), y=math.deg(rand_y), z=math.deg(rand_z)})
		time = time+1
	end

	self.logoSchedule = cc.Director:getInstance():getScheduler():scheduleScriptFunc(logoShake,0,false)

end

function MainMenuScene:addCloud()
	local scale = 2

	local cloud1 = display.newSprite(res_cloud1, self.size.width * 1.1, self.size.height * 0.9)
	self:addChild(cloud1, 2)
	cloud1:setScale(scale)

	local cloud2 = display.newSprite(res_cloud1, self.size.width * 0.38, self.size.height * 0.6)
	self:addChild(cloud2, 2)
	cloud2:setScale(scale)

	local cloud3 = display.newSprite(res_cloud2, self.size.width * 0.95, self.size.height * 0.5)
	self:addChild(cloud3, 2)
	cloud3:setScale(scale)

	local clouds = {cloud1, cloud2, cloud3}

	local function cloud_move()
		local offset = {-0.5, -1.0, -1.2}
		local count = #clouds
		for i=1,count do
			local sp = clouds[i]
			local point = sp:getPositionX() + offset[i]
			if point < -sp:getContentSize().width*scale/2 then
				point = self.size.width + sp:getContentSize().width * scale / 2
			end
			sp:setPositionX(point)
		end
	end
    self.scheduleCloudMove = cc.Director:getInstance():getScheduler():scheduleScriptFunc(cloud_move,1/60,false)
end

function MainMenuScene:addBg()
	local bg_back = display.newSprite(res_bg, self.size.width/2, self.size.height/2)
	self:addChild(bg_back, 1)
end

return MainMenuScene