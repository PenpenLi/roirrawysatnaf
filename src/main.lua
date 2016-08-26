
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")

require "config"
require "cocos.init"
require("app.GlobalFunctions")
require("app.GlobalVariables")

local function main()
	collectgarbage("collect")
	collectgarbage("setpause", 100)
	collectgarbage("setstepmul", 5000)

	local director = cc.Director:getInstance()
	director:setClearColor({r = 1, g = 1, b = 1, a = 1})

	local test = true

	if test == true then
		display.loadSpriteFrames("FX/FX.plist", "FX/FX.png")
		display.loadSpriteFrames("chooseRole/chooserole.plist", "chooseRole/chooserole.png")
		require("app.MyApp"):create():run("ChooseRoleScene")

	else
		require("app.MyApp"):create():run("MainScene")
	end
	
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
