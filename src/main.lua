
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")

require "config"
require "cocos.init"
require("app.utility.GlobalFunctions")
require("app.utility.GlobalVariables")
require("app.utility.List")

local function main()
	collectgarbage("collect")
	collectgarbage("setpause", 100)
	collectgarbage("setstepmul", 5000)

	local director = cc.Director:getInstance()
	director:setClearColor({r = 1, g = 1, b = 1, a = 1})

	local targetScene = "BattleScene"

	if targetScene == "MainScene" then

	elseif targetScene == "ChooseRoleScene" then
		display.loadSpriteFrames("FX/FX.plist", "FX/FX.png")
		display.loadSpriteFrames("chooseRole/chooserole.plist", "chooseRole/chooserole.png")
	
	elseif targetScene == "BattleScene" then
		display.loadSpriteFrames("FX/FX.plist", "FX/FX.png")
		display.loadSpriteFrames("battlefieldUI/battleFieldUI.plist", "battlefieldUI/BattlefieldUI.png")
	
	end

	require("app.MyApp"):create():run(targetScene)
	
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
