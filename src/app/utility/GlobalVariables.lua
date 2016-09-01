--
-- Author: Hao Liu
-- Date: 2016-08-24 16:03:22
--

--[[
	全局变量，尽量不要添加全局变量
]]

cc.exports.CelLine = 0.009

---------------------------------------------------------
-- resources
cc.exports.font_actor = "chooseRole/actor_param.ttf"
cc.exports.UserCameraFlagMask = 2
cc.exports.UIZorder = 2000
cc.exports.FXZorder = 1999

-- Audios
cc.exports.BGM_RES = {
	MAINMENUBGM = "audios/01 Beast Hunt.mp3",
    MAINMENUSTART= "audios/effects/magical_3.mp3",
    CHOOSEROLESCENEBGM = "audios/Imminent Threat Beat B FULL Loop.mp3"
}

--Warroir property
cc.exports.WarriorProperty =
{
    normalAttack1 = "audios/effects/knight/swish-1.mp3",
    normalAttack2 = "audios/effects/knight/swish-2.mp3",
    specialAttack1 = "audios/effects/knight/swish-3.mp3",
    specialAttack2 = "audios/effects/knight/swish-4.mp3",
    kickit = "audios/effects/knight/kickit.mp3",
    normalAttackShout = "audios/effects/knight/normalAttackShout.mp3",
    specialAttackShout = "audios/effects/knight/specialAttackShout.mp3",
    wounded = "audios/effects/knight/wounded.mp3",
    dead = "audios/effects/knight/dead.mp3"
}

--Archer property
cc.exports.Archerproperty =
{
    attack1 = "audios/effects/archer/swish-3.mp3",
    attack2 = "audios/effects/archer/swish-4.mp3",
    iwillfight = "audios/effects/archer/iwillfight.mp3",
    wounded = "audios/effects/archer/hurt.mp3",
    normalAttackShout = "audios/effects/archer/normalAttackShout.mp3",
    specialAttackShout = "audios/effects/archer/specialAttackShout.mp3",
    wounded = "audios/effects/archer/hurt.mp3",
    dead = "audios/effects/archer/dead.mp3"
}

--Monster Dragon
cc.exports.MonsterDragonValues = 
{
    fileName = "model/dragon/dragon.c3b",
    attack = "audios/effects/dragon/Fire.mp3",
    fireHit = "audios/effects/dragon/fireHit.mp3",
    wounded="audios/effects/dragon/hurt.mp3",
    dead="audios/effects/dragon/dead.mp3"
}

--Some common audios
cc.exports.CommonAudios =
{
    hit = "audios/effects/hit20.mp3"
}

-- play2d id
cc.exports.AUDIO_ID = {
	MAINMENUBGM,
	CHOOSEROLECHAPTERBGM,
    KNIGHTNORMALATTACK,
}

cc.exports.MessageType = {}
MessageType = {
    BLOOD_MINUS = "BLOOD_MINUS",
    REDUCE_SCORE = "REDUCE_SCORE",
    KNOCKED = "KNOCKED",
    KNOCKEDAOE = "KNOCKEDAOE",
    SPECIAL_PERSPECTIVE = "SPECIAL_PERSPECTIVE",
    SPECIAL_KNIGHT = "SPECIAL_KNIGHT",
    SPECIAL_ARCHER = "SPECIAL_ARCHER",
    SPECIAL_MAGE = "SPECIAL_MAGE",
    ANGRY_CHANGE = "ANGRY_CHANGE",
}

---------------------------------------------------------
-- enum
local _EnumRaceType = { 
    "HERO",  --only this
    "MONSTER", --and this
}
cc.exports.EnumRaceType = CreateEnumTable(_EnumRaceType) 

-- Actor animation state
local _EnumStateType = {
    "IDLE",
    "WALKING",
    "ATTACKING",
    "DEFENDING",
    "KNOCKING",
    "DYING",
    "DEAD"
}
cc.exports.EnumStateType = CreateEnumTable(_EnumStateType) 

local _EnumItemType = {
    "WEAPON",
    "ARMOUR",
    "HELMET",
}
cc.exports.EnumItemType = CreateEnumTable(_EnumItemType, 0)

---------------------------------------------------------
-- data

-- common value is used to reset an actor
cc.exports.ActorCommonValues = {
    aliveTime       = 0, -- time the actor is alive in seconds
    curSpeed        = 0, -- current speed the actor is traveling in units/seconds
    curAnimation    = nil,
    curAnimation3d  = nil,

    -- runtime modified values
    curFacing       = 0, -- current direction the actor is facing, in radians, 0 is to the right
    isalive         = true,
    AITimer         = 0, -- accumulated timer before AI will execute, in seconds
    AIEnabled       = false, -- if false, AI will not run
    attackTimer     = 0, -- accumulated timer to decide when to attack, in seconds
    timeKnocked     = 0, -- accumulated timer to recover from knock, in seconds
    cooldown        = false, -- if its true, then you are currently playing attacking animation
    hp              = 1000, -- current hit point
    goRight         = true,

    -- target variables
    targetFacing    = 0, -- direction the actor Wants to turn to
    target          = nil, -- the enemy actor
    myPos           = cc.p(0, 0),
    angry           = 0,
    angryMax        = 500,
}

cc.exports.ActorDefaultValues =
{
    racetype       = EnumRaceType.HERO, --type of the actor
    statetype      = nil, -- AI state machine
    sprite3d       = nil, --place to hold 3d model
    
    radius         = 50, --actor collider size
    mass           = 100, --weight of the role, it affects collision
    shadowSize     = 70, --the size of the shadow under the actor

    --character strength
    maxhp          = 1000,
    defense        = 100,
    specialAttackChance = 0, 
    recoverTime    = 0.8,--time takes to recover from knock, in seconds
    
    speed          = 500, --actor maximum movement speed in units/seconds
    turnSpeed      = math.rad(225), --actor turning speed in radians/seconds
    acceleration   = 750, --actor movement acceleration, in units/seconds
    decceleration  = 750*1.7, --actor movement decceleration, in units/seconds
    
    AIFrequency    = 1.0, --how often AI executes in seconds
    attackFrequency = 0.01, --an attack move every few seconds
    searchDistance = 5000, --distance which enemy can be found

    attackRange    = 100, --distance the actor will stop and commence attack
    
    --attack collider info, it can be customized
    normalAttack   = {--data for normal attack
        minRange = 0, -- collider inner radius
        maxRange = 130, --collider outer radius
        angle    = math.rad(30), -- collider angle, 360 for full circle, other wise, a fan shape is created
        knock    = 50, --attack knock back distance
        damage   = 800, -- attack damage
        mask     = EnumRaceType.HERO, -- who created this attack collider
        duration = 0, -- 0 duration means it will be removed upon calculation
        speed    = 0, -- speed the collider is traveling
        criticalChance=0
    }, 
}

cc.exports.KnightValues = {
    racetype            = EnumRaceType.HERO,
    name                = "Knight",
    radius              = 50,
    mass                = 1000,
    shadowSize          = 70,

    hp                  = 1850,
    maxhp               = 1850,
    defense             = 180,
    attackFrequency     = 2.2,
    recoverTime         = 0.4,
    AIFrequency         = 1.1,
    attackRange         = 140,
    specialAttackChance = 0,
    specialSlowTime     = 1, 

    normalAttack        = {
        minRange        = 0,
        maxRange        = 130,
        angle           = math.rad(70),
        knock           = 60,
        damage          = 250,
        mask            = EnumRaceType.HERO,
        duration        = 0,
        speed           = 0,
        criticalChance  = 0.15
    }, 
    specialAttack       = {
        minRange        = 0,
        maxRange        = 250,
        angle           = math.rad(160),
        knock           = 150,
        damage          = 350,
        mask            = EnumRaceType.HERO,
        duration        = 0,
        speed           = 0,
        criticalChance  = 0.35
    }, 

}

cc.exports.ArcherValues = {
    racetype       = EnumRaceType.HERO,
    name           = "Archer",
    radius         = 50,
    mass           = 800,
    shadowSize     = 70,

    hp             = 1200,
    maxhp          = 1200,
    defense        = 130,
    attackFrequency = 2.5,
    recoverTime    = 0.4,
    AIFrequency    = 1.3,
    attackRange    = 450,
    specialAttackChance = 0,
    turnSpeed      = math.rad(360), --actor turning speed in radians/seconds
    specialSlowTime = 0.5, 

    normalAttack   = {
        minRange = 0,
        maxRange = 30,
        angle    = math.rad(360),
        knock    = 100,
        damage   = 200,
        mask     = EnumRaceType.HERO,
        duration = 1.3,
        speed    = 900,
        criticalChance = 0.33
    }, 
    specialAttack   = {
        minRange = 0,
        maxRange = 75,
        angle    = math.rad(360),
        knock    = 100,
        damage   = 200,
        mask     = EnumRaceType.HERO,
        duration = 1.5,
        speed    = 850,
        criticalChance = 0.5,
        DOTTimer = 0.3,
        curDOTTime = 0.3,
        DOTApplied = false
    }, 
}

cc.exports.MageValues = {
    racetype       = EnumRaceType.HERO,
    name           = "Mage",
    radius         = 50,
    mass           = 800,
    shadowSize     = 70,

    hp             = 1100,
    maxhp          = 1100,
    defense        = 120,
    attackFrequency = 2.67,
    recoverTime    = 0.8,
    AIFrequency    = 1.33,
    attackRange    = 400,
    specialAttackChance = 0,
    specialSlowTime = 0.67,

    normalAttack   = {
        minRange = 0,
        maxRange = 50,
        angle    = math.rad(360),
        knock    = 10,
        damage   = 280,
        mask     = EnumRaceType.HERO,
        duration = 2,
        speed    = 400,
        criticalChance = 0.05
    }, 
    specialAttack   = {
        minRange = 0,
        maxRange = 140,
        angle    = math.rad(360),
        knock    = 75,
        damage   = 250,
        mask     = EnumRaceType.HERO,
        duration = 4.5,
        speed    = 0,
        criticalChance = 0.05,
        DOTTimer = 0.75, --it will be able to hurt every 0.5 seconds
        curDOTTime = 0.75,
        DOTApplied = false
    }, 
}

cc.exports.SlimeValues = {
    racetype       = EnumRaceType.MONSTER,
    name           = "Slime",
    radius         = 35,
    mass           = 20,
    shadowSize     = 45,

    hp             = 300,
    maxhp          = 300,
    defense        = 65,
    attackFrequency = 1.5,
    recoverTime    = 0.7,
    AIFrequency    = 3.3,
    AITimer        = 2.0,
    attackRange    = 50,
    
    speed          = 150,
    turnSpeed      = math.rad(270),
    acceleration   = 9999,
    decceleration  = 9999,

    normalAttack   = {
        minRange = 0,
        maxRange = 50,
        angle    = math.rad(360),
        knock    = 0,
        damage   = 135,
        mask     = EnumRaceType.MONSTER,
        duration = 0,
        speed    = 0,
        criticalChance = 0.13
    }, 
}

cc.exports.DragonValues = {
    racetype       = EnumRaceType.MONSTER,
    name           = "Dragon",
    radius         = 50,
    mass           = 100,
    shadowSize     = 70,

    hp             = 600,
    maxhp          = 600,
    defense        = 130,
    attackFrequency = 5.2,
    recoverTime    = 0.8,
    AIFrequency    = 1.337,
    attackRange    = 350,
    
    speed          = 300,
    turnSpeed      = math.rad(180),
    acceleration   = 250,
    decceleration  = 750*1.7,

    normalAttack   = {
        minRange = 0,
        maxRange = 40,
        angle    = math.rad(360),
        knock    = 50,
        damage   = 400,
        mask     = EnumRaceType.MONSTER,
        duration = 1,
        speed    = 350,
        criticalChance = 0.15
    }, 
}

cc.exports.PigletValues = {
    racetype       = EnumRaceType.MONSTER,
    name           = "Piglet",
    radius         = 50,
    mass           = 69,
    shadowSize     = 60,

    hp             = 400,
    maxhp          = 400,
    defense        = 65,
    attackFrequency = 4.73,
    recoverTime    = 0.9,
    AIFrequency    = 2.3,
    attackRange    = 120,

    speed          = 350,
    turnSpeed      = math.rad(270),

    normalAttack   = {
        minRange = 0,
        maxRange = 120,
        angle    = math.rad(50),
        knock    = 0,
        damage   = 150,
        mask     = EnumRaceType.MONSTER,
        duration = 0,
        speed    = 0,
        criticalChance = 0.15
    }, 
}

cc.exports.RatValues = {
    racetype       = EnumRaceType.MONSTER,
    name           = "Rat",
    radius         = 70,
    mass           = 990,
    shadowSize     = 90,

    hp             = 2800,
    maxhp          = 2800,
    defense        = 200,
    attackFrequency = 3.0,
    recoverTime    = 0.4,
    AIFrequency    = 5.3,
    AITimer        = 5.0,
    attackRange    = 150,

    speed          = 400,
    turnSpeed      = math.rad(180),
    acceleration   = 200,
    decceleration  = 750*1.7,

    normalAttack   = {
        minRange = 0,
        maxRange = 150,
        angle    = math.rad(100),
        knock    = 250,
        damage   = 210,
        mask     = EnumRaceType.MONSTER,
        duration = 0,
        speed    = 0,
        criticalChance =1
    }, 
}

cc.exports.ReSkin = {
    knight = {0, 0, 0},
    archer = {0, 0, 0},
    mage = {0, 0, 0}
}
