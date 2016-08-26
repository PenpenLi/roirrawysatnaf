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

-- play2d id
cc.exports.AUDIO_ID = {
	MAINMENUBGM,
	CHOOSEROLECHAPTERBGM,
}

---------------------------------------------------------
-- enum
local EnumRaceType = { 
    "HERO",  --only this
    "MONSTER", --and this
}
cc.exports.EnumRaceType = CreateEnumTable(EnumRaceType) 

-- Actor animation state
local EnumStateType = {
    "IDLE",
    "WALKING",
    "ATTACKING",
    "DEFENDING",
    "KNOCKING",
    "DYING",
    "DEAD"
}
cc.exports.EnumStateType = CreateEnumTable(EnumStateType) 

local EnumItemType = {
    "WEAPON",
    "ARMOUR",
    "HELMET",
}
cc.exports.EnumItemType = CreateEnumTable(EnumItemType, 0)

---------------------------------------------------------
-- data
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

cc.exports.ReSkin = {
    knight = {0, 0, 0},
    archer = {0, 0, 0},
    mage = {0, 0, 0}
}
