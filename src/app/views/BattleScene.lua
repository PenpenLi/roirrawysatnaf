--
-- Author: Hao Liu
-- Date: 2016-08-26 17:56:13
--
--[[
	BattleScene 战斗界面
]]

local res_model_bg = "model/scene/changing.c3b"
local res_water = {"shader3D/water.png", "shader3D/wave1.jpg", "shader3D/18.jpg"}

local BattleScene = class("BattleScene", cc.load("mvc").ViewBase)


function BattleScene:onCreate()
	self:setCascadeColorEnabled(true)
	cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RG_B565)

	self:enableTouch()
	self:createBackground()
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

function BattleScene:UIcontainsPoint(position)

end

function BattleScene:createBackground()
	local spriteBg = cc.Sprite3D:create(res_model_bg)
	self:addChild(spriteBg)
	spriteBg:setScale(2.65)
	spriteBg:setPosition3D(cc.vec3(-2300, -1000, 0))
	spriteBg:setRotation3D(cc.vec3(90, 0, 0))
	spriteBg:setGlobalZOrder(-10)

end

return BattleScene
