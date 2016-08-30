--
-- Author: Hao Liu
-- Date: 2016-08-26 17:56:13
--
--[[
	BattleScene 战斗界面
]]

local BattlefieldUI = require("app.views.BattlefieldUI")
local GameMaster = require("app.controllers.GameMaster")
require("app.controllers.Manager")

local res_model_bg = "model/scene/changing.c3b"
local res_water = {"shader3D/water.png", "shader3D/wave1.jpg", "shader3D/18.jpg"}

local specialCamera = {valid = false, position = cc.p(0,0)}
local cameraOffset =  cc.vec3(150, 0, 0)
local cameraOffsetMin = {x=-300, y=-400}
local cameraOffsetMax = {x=300, y=400}

local BattleScene = class("BattleScene", cc.load("mvc").ViewBase)

function BattleScene:onCreate()
	self:setCascadeColorEnabled(true)
	cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RG_B565)

	self:enableTouch()
	self:createBackground()
	self:initUILayer()

	self:setCamera()

	self.gameMaster = GameMaster.new(self)

	local function gameController(dt)
		self.gameMaster:update(dt)
		-- collisionDetect(dt)
		-- solveAttacks(dt)
		self:moveCamera(dt)
	end

	self.gameControllerScheduleID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(gameController, 0, false)

end

function BattleScene:enableTouch()
	local function onTouchBegin(touch,event)
	    --cclog("onTouchBegin: %0.2f, %0.2f", touch:getLocation())        
	    return true
	end
	
	local function onTouchMoved(touch,event)

	end
	
	local function onTouchEnded(touch,event)

	end

	local touchEventListener = cc.EventListenerTouchOneByOne:create()
	touchEventListener:registerScriptHandler(onTouchBegin, cc.Handler.EVENT_TOUCH_BEGAN)
	touchEventListener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	touchEventListener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(touchEventListener, self)        

end

function BattleScene:moveCamera(dt)
    --cclog("moveCamera")
    if self.camera == nil then return end

    local cameraPosition = getPosTable(self.camera)
    local focusPoint = getFocusPointOfHeros()
    if specialCamera.valid == true then
        local position = cc.pLerp(cameraPosition, cc.p(specialCamera.position.x, (cameraOffset.y + focusPoint.y-display.height*3/4)*0.5), 5*dt)
        
        self.camera:setPosition(position)
        self.camera:lookAt(cc.vec3(position.x, specialCamera.position.y, 50.0), cc.vec3(0.0, 1.0, 0.0))
    elseif List.getSize(HeroManager) > 0 then
        local temp = cc.pLerp(cameraPosition, cc.p(focusPoint.x+cameraOffset.x, cameraOffset.y + focusPoint.y-display.height*3/4), 2*dt)
        local position = cc.vec3(temp.x, temp.y, display.height/2-100)
        self.camera:setPosition3D(position)
        self.camera:lookAt(cc.vec3(position.x, focusPoint.y, 50.0), cc.vec3(0.0, 0.0, 1.0))
        --cclog("\ncalf %f %f %f \ncalf %f %f 50.000000", position.x, position.y, position.z, focusPoint.x, focusPoint.y)            
    end
end


function BattleScene:UIcontainsPoint(position)

end

function BattleScene:setCamera()
	self.camera = cc.Camera:createPerspective(60.0, display.width/display.height, 10.0, 4000.0)
	self.camera:setGlobalZOrder(10)
	self.camera:setCameraFlag(UserCameraFlagMask)
	self:addChild(self.camera)
	self:setCameraMask(UserCameraFlagMask)

	-- for val = HeroManager.first, HeroManager.last do
	--     local sprite = HeroManager[val]
	--     if sprite._puff then
	--         sprite._puff:setCamera(camera)
	--     end
	-- end      
	
	self.uiLayer:setCameraMask(UserCameraFlagMask)
	self.camera:addChild(self.uiLayer)

end

function BattleScene:initUILayer()
	self.uiLayer = BattlefieldUI.new()
	self.uiLayer:setPositionZ(-cc.Director:getInstance():getZEye()/4)
	self.uiLayer:setScale(0.25)
	self.uiLayer:setIgnoreAnchorPointForPosition(false)
	self.uiLayer:setGlobalZOrder(3000)

end

function BattleScene:createBackground()
	local spriteBg = cc.Sprite3D:create(res_model_bg)
	self:addChild(spriteBg)
	spriteBg:setScale(2.65)
	spriteBg:setPosition3D(cc.vec3(-2300, -1000, 0))
	spriteBg:setRotation3D(cc.vec3(90, 0, 0))
	spriteBg:setGlobalZOrder(-10)

	local water = cc.Water:create(res_water[1], res_water[2], res_water[3], 
		{width=5500, height=400}, 0.77, 0.3797, 1.2)
	self:addChild(water)
	water:setPosition3D(cc.vec3(-3500, -580, -110))
	water:setAnchorPoint(0,0)
	water:setGlobalZOrder(-10)

end

return BattleScene
