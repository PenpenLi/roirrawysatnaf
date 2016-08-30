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

    copyTable(SlimeValues, self)

	self:init3D()
	self:initActions()

    self.AIEnabled = true

    local function update(dt)
        self:baseUpdate(dt)
        self:stateMachineUpdate(dt)
        self:movementUpdate(dt)
    end
    self:scheduleUpdate(update, 0.5) 

    self:play3DAnim()

end

function Slime:play3DAnim()
    self.sprite3d:runAction(cc.RepeatForever:create(createAnimation(modelFile,0,22,0.7)))
 
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

-- init Slime animations=============================
do
    local dur = 0.6
    local bsc = 17
    local walk = cc.Spawn:create(
            cc.Sequence:create(
                cc.DelayTime:create(dur/8),
                cc.JumpBy3D:create(dur*7/8, cc.vec3(0,0,0),30,1)
            ),
            cc.Sequence:create(
                cc.EaseSineOut:create(cc.ScaleTo:create(dur/8, bsc*1.4, bsc*1.4, bsc*0.75)),
                cc.EaseSineOut:create(cc.ScaleTo:create(dur/8, bsc*0.85, bsc*0.85, bsc*1.3)),
                cc.EaseSineOut:create(cc.ScaleTo:create(dur/8, bsc*1.2, bsc*1.2, bsc*0.9)),
                cc.EaseSineOut:create(cc.ScaleTo:create(dur/8, bsc*0.95, bsc*0.95, bsc*1.1)),
                cc.EaseSineOut:create(cc.ScaleTo:create(dur*4/8, bsc, bsc, bsc))
            )
        )
    walk:retain()
    local idle = cc.Sequence:create(
        cc.ScaleTo:create(dur/2, bsc*1.1, bsc*1.1, bsc*0.8),
        cc.ScaleTo:create(dur/2, bsc,bsc,bsc)
    )
    idle:retain()
    local attack1 = cc.Spawn:create(
            cc.MoveBy:create(dur/2, cc.vec3(0,0,20)),
            cc.RotateBy:create(dur/2, cc.vec3(70,0,0)),
            cc.EaseBounceOut:create(cc.MoveTo:create(dur/2, cc.p(40, 0)))
        )
    local attack2 = cc.Spawn:create(
            cc.MoveTo:create(dur, cc.vec3(0,0,0)),
                cc.RotateBy:create(dur*3/4, cc.vec3(-70,0,0)),
                cc.EaseBackOut:create(cc.MoveTo:create(dur, cc.p(0,0)))
        )
    attack1:retain()
    attack2:retain()
    local die =         cc.Spawn:create(
        cc.Sequence:create(
            cc.JumpBy3D:create(dur/2, cc.vec3(0,0,0), 30, 1),
            cc.ScaleBy:create(dur, 2, 2, 0.1)
        ),
        cc.RotateBy:create(dur, cc.vec3(-90,0,0))
    )
    die:retain()
    local knock = cc.Sequence:create(
        cc.EaseBackInOut:create(cc.RotateBy:create(dur/3, cc.vec3(-60,0,0))),
        cc.RotateBy:create(dur/2, cc.vec3(60,0,0))
    )
    knock:retain()
    Slime.action = {
        idle = idle,
        walk = walk,
        attack1 = attack1,
        attack2 = attack2,
        dead = die,
        knocked = knock
    }
end

function Slime:initActions()
	self.action = Slime.action
end

function Slime:reset()
	table.merge(self, ActorCommonValues)
    table.merge(self, SlimeValues)
    self:walkMode()
    self:setPositionZ(0)
end

return Slime
