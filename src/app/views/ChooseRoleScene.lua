--
-- Author: Hao Liu
-- Date: 2016-08-25 14:19:03
--

--[[
	选择角色界面
]]

local Knight = require("app.actors.Knight")
local Archer = require("app.actors.Archer")
local Mage = require("app.actors.Mage")

local ChooseRoleScene = class("ChooseRoleScene", cc.load("mvc").ViewBase)

local sortorder = {1,2,3} --hero's tag
local rtt = {{x = -90, y = -60, z = 0}, 
			{x = -90, y = -70, z = 0}, 
			{x = -90, y = -60, z = 0}}

local pos = {{x = display.width * 0.14, y = display.height * 0.35, z = -180},
			{x = display.width * 0.34, y = display.height * 0.25, z = -40},
			{x = display.width * 0.5, y = display.height * 0.35, z = -180}}

local weapon_item_pos = {x=832, y=280}
local armour_item_pos = {x=916, y=280}
local helmet_item_pos = {x=1000, y=280}

local heroSize = cc.rect(155,120,465,420)
local isMoving = false

local res_bg = "chooseRole/cr_bk.jpg"
local res_button1 = "button1.png"
local res_button2 = "button2.png"
local res_bag = "#cr_bag.png"
local res_knight = "#knight.png"
local res_archer = "#archer.png"
local res_mage = "#mage.png"

local res_bag_items = {
	Knight = {
		weapon = {
			"knight_w_0.png",
			"knight_w_1.png",
		},
		armour = {
			"knight_a_0.png",
			"knight_a_1.png",
		},
		helmet = {
			"knight_h_0.png",
			"knight_h_1.png",
		},
	},
	Archer = {
		weapon = {
			"archer_w_0.png",
			"archer_w_1.png",
		},
		armour = {
			"archer_a_0.png",
			"archer_a_1.png",
		},
		helmet = {
			"archer_h_0.png",
			"archer_h_1.png",
		},
	},
	Mage = {
		weapon = {
			"mage_w_0.png",
			"mage_w_1.png",
		},
		armour = {
			"mage_a_0.png",
			"mage_a_1.png",
		},
		helmet = {
			"mage_h_0.png",
			"mage_h_1.png",
		},
	},
}

function ChooseRoleScene:onCreate()
	cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_AUTO)    
    AUDIO_ID.CHOOSEROLECHAPTERBGM = ccexp.AudioEngine:play2d(BGM_RES.CHOOSEROLESCENEBGM, true, 1)

    self:addBackground()

    self:addHeros()

    self:addButton()

    self:addBag()

    self:initTouchDispatcher()
end

function ChooseRoleScene:switchTextWhenRotate()
	local hero = self:getChildByTag(sortorder[2])
	local size = self.bag:getContentSize()
	local actor = self.bag:getChildByTag(101)
	if actor ~= nil then
		self.bag:removeChildByTag(101)
		self.bag:removeChildByTag(102)
	end

	local point = 0

	local ttfconfig = {outlineSize = 0, fontSize = 15, fontFilePath = font_actor}
	local text = "LEVEL".."\n".."ATT".."\n".."HP".."\n".."DEF".."\n".."AGI".."\n".."CRT".."\n".."S.ATT"
	local attr = nil

	if hero.name == "Knight" then
		actor = display.newSprite(res_knight)
		point = cc.p(size.width * 0.395, size.height * 0.9)
		attr = "23".."\n"..KnightValues.normalAttack.damage.."\n"..KnightValues.hp.."\n"..KnightValues.defense.."\n"..(KnightValues.AIFrequency*100).."\n"..KnightValues.specialAttack.damage.."\n"..KnightValues.specialAttack.damage
	elseif hero.name == "Archer" then
		actor = display.newSprite(res_archer)
		point = cc.p(size.width * 0.4, size.height * 0.905)
		attr = "23".."\n"..ArcherValues.normalAttack.damage.."\n"..ArcherValues.hp.."\n"..ArcherValues.defense.."\n"..(ArcherValues.AIFrequency*100).."\n"..ArcherValues.specialAttack.damage.."\n"..ArcherValues.specialAttack.damage
	elseif hero.name == "Mage" then
		actor = display.newSprite(res_mage)
		point = cc.p(size.width * 0.38, size.height * 0.9)
		attr = "23".."\n"..MageValues.normalAttack.damage.."\n"..MageValues.hp.."\n"..MageValues.defense.."\n"..(MageValues.AIFrequency*100).."\n"..MageValues.specialAttack.damage.."\n"..MageValues.specialAttack.damage
	end

	actor:setPosition(point)
	local text_label = cc.Label:createWithTTF(ttfconfig, text, cc.TEXT_ALIGNMENT_CENTER, 400)
	text_label:setPosition(cc.p(size.width*0.45, size.height*0.68))
	text_label:enableShadow(cc.c4b(92,50,31,255), cc.size(1,-2),0)
	
	local attr_label = cc.Label:createWithTTF(ttfconfig, attr, cc.TEXT_ALIGNMENT_CENTER, 400)
	attr_label:setPosition(cc.p(size.width*0.65, size.height*0.68))
	attr_label:enableShadow(cc.c4b(92,50,31,255), cc.size(1,-2), 0)

	self.bag:addChild(actor, 1, 101)
	self.bag:addChild(text_label, 1)
	self.bag:addChild(attr_label, 1, 102)

end

function ChooseRoleScene:addBag()
	local bag = display.newSprite(res_bag)
	bag:setTag(10)
	self.bag = bag
	self:switchTextWhenRotate()

	local bagSize = bag:getContentSize()
	weapon_item_pos = {x = bagSize.width * 0.36, y = bagSize.height * 0.4}
	armour_item_pos = {x = bagSize.width * 0.54, y = bagSize.height * 0.4}
	helmet_item_pos = {x = bagSize.width * 0.72, y = bagSize.height * 0.4}

	self.weaponItem = display.newSprite()
	self.weaponItem:setTag(11)
	self.weaponItem:setScale(1)
	self.weaponItem:setPosition(weapon_item_pos)
	bag:addChild(self.weaponItem, 2)
	
	self.armourItem = display.newSprite()
	self.armourItem:setTag(12)
	self.armourItem:setScale(1)
	self.armourItem:setPosition(armour_item_pos)
	bag:addChild(self.armourItem, 2)
	
	self.helmetItem = display.newSprite()
	self.helmetItem:setTag(13)
	self.helmetItem:setScale(1)
	self.helmetItem:setPosition(helmet_item_pos)
	bag:addChild(self.helmetItem, 2)

	bag:setPosition({x=0.75*display.width,y=0.5*display.height})
	
	self:addChild(bag)

	self:switchItemtextureWhenRotate()
end

function ChooseRoleScene:addButton()
	local touch_next = false
	local function touchEvent_next(sender,eventType)
	    if touch_next == false then
	        touch_next = true
	        if eventType == TOUCH_EVENT_BEGAN then
	        	ReSkin.knight = {weapon = self:getChildByTag(2):getItemId(EnumItemType.WEAPON),
	        	                 armour = self:getChildByTag(2):getItemId(EnumItemType.ARMOUR),
	        	                 helmet = self:getChildByTag(2):getItemId(EnumItemType.HELMET)}
	        	ReSkin.arhcer = {weapon = self:getChildByTag(1):getItemId(EnumItemType.WEAPON),
	        	                 armour = self:getChildByTag(1):getItemId(EnumItemType.ARMOUR),
	        	                 helmet = self:getChildByTag(1):getItemId(EnumItemType.HELMET)}
	        	ReSkin.mage = {weapon = self:getChildByTag(3):getItemId(EnumItemType.WEAPON),
	        	                 armour = self:getChildByTag(3):getItemId(EnumItemType.ARMOUR),
	        	                 helmet = self:getChildByTag(3):getItemId(EnumItemType.HELMET)}

	        	ccexp.AudioEngine:play2d(BGM_RES.MAINMENUSTART,false,1)
	        	--stop schedule
	        	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedule_rotate)

	        	self:getApp():run("BattleScene")
	        end
	    end
	end

	local button = ccui.Button:create(res_button1, res_button2, "", ccui.TextureResType.plistType)
    button:setPosition({x=0.34*display.width, y=0.13*display.height})
	button:addTouchEventListener(touchEvent_next)
	self:addChild(button)

end

function ChooseRoleScene:addHeros()
	local knight = Knight.new()
	knight:setTag(2)
	knight:setRotation3D(rtt[2])
	knight:setPosition3D(pos[2])
	knight:setScale(1.3)
	knight:setAIEnabled(false)
	self:addChild(knight)

	local archer = Archer.new()
	archer:setTag(1)
	archer:setRotation3D(rtt[1])
	archer:setPosition3D(pos[1])
	archer:setScale(1.3)
	archer:setAIEnabled(false)
	self:addChild(archer)

	local mage = Mage.create()
	mage:setTag(3)
	mage:setRotation3D(rtt[3])
	mage:setPosition3D(pos[3])
	mage:setScale(1.3)
	mage:setAIEnabled(false)
	self:addChild(mage)

	--hero rotate
	local rotate = 0.5
	local function hero_rotate()
	    local rotation = self:getChildByTag(sortorder[2]):getRotation3D()
	    self:getChildByTag(sortorder[2]):setRotation3D({x = rotation.x, y = rotation.y + rotate, z=0})
	end
	self.schedule_rotate = cc.Director:getInstance():getScheduler():scheduleScriptFunc(hero_rotate, 0, false)

end

function ChooseRoleScene:addBackground()
	local background = display.newSprite(res_bg, display.cx, display.cy)
    background:setPositionZ(-250)
    background:setScale(1.5)
    background:setGlobalZOrder(-1)
    self:addChild(background)

end

function ChooseRoleScene:initTouchDispatcher()
	local isRotateavaliable = false
	local isWeaponItemavaliable = false
	local isArmourItemavaliable = false
	local isHelmetItemavaliable = false
	local touchbeginPt

	local listenner = cc.EventListenerTouchOneByOne:create()
	listenner:setSwallowTouches(true)

	listenner:registerScriptHandler(function(touch, event)
		touchbeginPt = touch:getLocation()
		if cc.rectContainsPoint(heroSize, touchbeginPt) then --rotate
		    isRotateavaliable = true
		    return true
		end

		touchbeginPt = self.bag:convertToNodeSpace(touchbeginPt)

		if cc.rectContainsPoint(self.weaponItem:getBoundingBox(), touchbeginPt) then --weapon
		    isWeaponItemavaliable = true
		    self.weaponItem:setScale(1.7)
		    self.weaponItem:setOpacity(150)

		elseif cc.rectContainsPoint(self.armourItem:getBoundingBox(), touchbeginPt) then --armour
		    isArmourItemavaliable = true
		    self.armourItem:setScale(1.7)
		    self.armourItem:setOpacity(150)

		elseif cc.rectContainsPoint(self.helmetItem:getBoundingBox(), touchbeginPt) then --helmet
		    isHelmetItemavaliable = true
		    self.helmetItem:setScale(1.7)
		    self.helmetItem:setOpacity(150)

		end

		return true
		end, cc.Handler.EVENT_TOUCH_BEGAN)

	listenner:registerScriptHandler(function(touch, event)
		if isRotateavaliable == true and isMoving == false then --rotate
		    local dist = touch:getLocation().x - touchbeginPt.x
		    if dist > 50 then
		        --right
		        self:rotate3Heroes(true)
		        isRotateavaliable = false	
		    elseif dist<-50 then
		        --left
		        self:rotate3Heroes(false)
		        isRotateavaliable = false
		    else
		
		    end
		elseif isWeaponItemavaliable then --weapon
		    self.weaponItem:setPosition(self.bag:convertToNodeSpace(touch:getLocation()))
		elseif isArmourItemavaliable then --armour
		    self.armourItem:setPosition(self.bag:convertToNodeSpace(touch:getLocation()))
		elseif isHelmetItemavaliable then --helmet
		    self.helmetItem:setPosition(self.bag:convertToNodeSpace(touch:getLocation()))
		end

		end, cc.Handler.EVENT_TOUCH_MOVED)

	listenner:registerScriptHandler(function(touch, event)
		if isRotateavaliable then --rotate
		    isRotateavaliable = false
		elseif isWeaponItemavaliable then
		    isWeaponItemavaliable = false
		    self.weaponItem:setPosition(weapon_item_pos)
		    self.weaponItem:setScale(1)
		    self.weaponItem:setOpacity(255)
		    self:getChildByTag(sortorder[2]):switchItem(EnumItemType.WEAPON)
		    self:switchItemtextureWhenRotate()
		elseif isArmourItemavaliable then
		    isArmourItemavaliable = false
		    self.armourItem:setPosition(armour_item_pos)
		    self.armourItem:setScale(1)
		    self.armourItem:setOpacity(255)
		    self:getChildByTag(sortorder[2]):switchItem(EnumItemType.ARMOUR)
		    self:switchItemtextureWhenRotate()
		elseif isHelmetItemavaliable then
		    isHelmetItemavaliable = false
		    self.helmetItem:setPosition(helmet_item_pos)
		    self.helmetItem:setScale(1)
		    self.helmetItem:setOpacity(255)
		    self:getChildByTag(sortorder[2]):switchItem(EnumItemType.HELMET)
		    self:switchItemtextureWhenRotate()
		end
		end, cc.Handler.EVENT_TOUCH_ENDED)

	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listenner, self)

end

function ChooseRoleScene:rotate3Heroes(isRight)
	--stop hero rotate
	if isRight then
	    self:getChildByTag(sortorder[2]):runAction(cc.RotateTo:create(0.1, rtt[3]))
	else
	    self:getChildByTag(sortorder[2]):runAction(cc.RotateTo:create(0.1, rtt[1]))
	end

	local rotatetime = 0.6
	if isRight then
		local middle = self:getChildByTag(sortorder[2])
		middle:runAction(cc.Sequence:create(
		    cc.CallFunc:create(function() isMoving = true end), 
		    cc.Spawn:create(
		        cc.EaseCircleActionInOut:create(cc.MoveTo:create(rotatetime, pos[3]))
		    ),
		    cc.CallFunc:create(function() 
		        isMoving = false
		        self:playAudioWhenRotate()
		    end)))
		local left = self:getChildByTag(sortorder[1])
		left:runAction(cc.EaseCircleActionInOut:create(cc.MoveTo:create(rotatetime, pos[2])))
		local right = self:getChildByTag(sortorder[3])
		right:runAction(cc.EaseCircleActionInOut:create(cc.MoveTo:create(rotatetime, pos[1])))
		local t = sortorder[3]
		sortorder[3]=sortorder[2]
		sortorder[2]=sortorder[1]
		sortorder[1]=t
	else
		local middle = self:getChildByTag(sortorder[2])
		middle:runAction(cc.Sequence:create(
		    cc.CallFunc:create(function() 
		        isMoving = true
		    end), 
		    cc.Spawn:create(
		        cc.EaseCircleActionInOut:create(cc.MoveTo:create(rotatetime, pos[1]))
		    ),
		    cc.CallFunc:create(function()
		        isMoving = false 
		        self:playAudioWhenRotate()
		    end)))
		local left = self:getChildByTag(sortorder[1])
		left:runAction(cc.EaseCircleActionInOut:create(cc.MoveTo:create(rotatetime, pos[3])))
		local right = self:getChildByTag(sortorder[3])
		right:runAction(cc.EaseCircleActionInOut:create(cc.MoveTo:create(rotatetime, pos[2])))
		local t = sortorder[1]
		sortorder[1]=sortorder[2]
		sortorder[2]=sortorder[3]
		sortorder[3]=t
	end

	self:switchItemtextureWhenRotate()
	self:switchTextWhenRotate()

end

function ChooseRoleScene:switchItemtextureWhenRotate()
	local hero = self:getChildByTag(sortorder[2])
	local items = res_bag_items[hero.name]
    self.weaponItem:setSpriteFrame(items["weapon"][hero:getItemId(EnumItemType.WEAPON)+1])
    self.armourItem:setSpriteFrame(items["armour"][hero:getItemId(EnumItemType.ARMOUR)+1])
    self.helmetItem:setSpriteFrame(items["helmet"][hero:getItemId(EnumItemType.HELMET)+1])
end

function ChooseRoleScene:playAudioWhenRotate()
	local hero = self:getChildByTag(sortorder[2])
	if hero._name == "Knight" then
	    ccexp.AudioEngine:play2d(WarriorProperty.kickit, false, 1)
	elseif hero._name == "Archer" then
	    ccexp.AudioEngine:play2d(Archerproperty.iwillfight, false, 1)
	elseif hero._name == "Mage" then
	    ccexp.AudioEngine:play2d(MageProperty.letstrade, false, 1)
	end

end

return ChooseRoleScene
