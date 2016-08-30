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

cc.exports.DragonValues = {
    _racetype       = EnumRaceType.MONSTER,
    _name           = "Dragon",
    _radius         = 50,
    _mass           = 100,
    _shadowSize     = 70,

    _hp             = 600,
    _maxhp          = 600,
    _defense        = 130,
    _attackFrequency = 5.2,
    _recoverTime    = 0.8,
    _AIFrequency    = 1.337,
    _attackRange    = 350,
    
    _speed          = 300,
    _turnSpeed      = math.rad(180),
    _acceleration   = 250,
    _decceleration  = 750*1.7,

    _normalAttack   = {
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
    _racetype       = EnumRaceType.MONSTER,
    _name           = "Piglet",
    _radius         = 50,
    _mass           = 69,
    _shadowSize     = 60,

    _hp             = 400,
    _maxhp          = 400,
    _defense        = 65,
    _attackFrequency = 4.73,
    _recoverTime    = 0.9,
    _AIFrequency    = 2.3,
    _attackRange    = 120,

    _speed          = 350,
    _turnSpeed      = math.rad(270),

    _normalAttack   = {
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
    _racetype       = EnumRaceType.MONSTER,
    _name           = "Rat",
    _radius         = 70,
    _mass           = 990,
    _shadowSize     = 90,

    _hp             = 2800,
    _maxhp          = 2800,
    _defense        = 200,
    _attackFrequency = 3.0,
    _recoverTime    = 0.4,
    _AIFrequency    = 5.3,
    _AITimer        = 5.0,
    _attackRange    = 150,

    _speed          = 400,
    _turnSpeed      = math.rad(180),
    _acceleration   = 200,
    _decceleration  = 750*1.7,

    _normalAttack   = {
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
