#基于cocos2d-x 3.12开发FantasyWarrior3D

FantasyWarrior3D是cocos官网上面的一个3Ddemo，是基于cocos2d-x 3.4开发的。现在我打算基于cocos2d-x 3.12重新写这个demo，希望可以借此熟悉3.12的引擎以及3d的相关使用。  

####1.5
		
		Camera通过setCameraFlag和Node的setCameraMask来来关联。

####1.4
1. 完成`AttackCommand.lua`,`HPCounter.lua`。
2. 攻击方通过`AttackCommand`来对目标造成伤害。
3. `NotificationCenter`已经被弃用，使用`EventListenerCustom`和`EventCustom`来替换。
4. `BattalefieldUI`和`Manager`做为全局变量使用，相当于c++的单例，算是lua的方便之处。

		lua类成员变量前面加`_`的作用是防止和成员方法重名。

####1.3
1. 基本完成`BattleScene.lua`, `BattlefieldUI.lua`, `GameMaster.lua`, `Manager.lua`, `Dragon.lua`, `Rat.lua`, `Piglet.lua`, `GlobalFunction.lua`, `List.lua`.
2. 战斗的UI部分都放在`BattlefieldUI`中，`GameMaster`用于控制hero和monster在战场中的投放，`Manager`作为全局变量存放战场中各种类的容器。
3. `cc.Camera`的使用在3D中很重要，第一次接触，还有待进一步了解。
4. `GlobalFunction`存放全局的方法，`CreateEnumTable`使用的时候注意参数名字不要跟枚举名字相同，防止在定义枚举的方法下面用到枚举。
5. `List`是基于table的重新封装，类似队列，但是比队列更开放。
6. 游戏中人物的逻辑基本都在`Actor`中实现，通过`update`,其中AI部分，不同的人物AI计算的时间间隔是不一样的。

		rad	角度转弧度	math.rad(180)	3.1415926535898     DEGREES_TO_RADIANS       
		deg	弧度转角度	math.deg(math.pi)	180    RADIANS_TO_DEGREES


####1.2
1. 完成`ChooseRoleScene.lua`，将自定义类`EffectSprite3D`绑定到lua中。
2. 修改simulator的大小，在sublime的quick插件中。
3. 涉及到model中的数据结构，效率、可读性、代码简略性的平衡，有些地方还是需要通过字符串来作为关键字，不能全部是使用Enum。

		error:
		cc.RotateTo:create argument #3 is 'table'; 'number' expected.
		这个报错并不是代码有问题，而是luabingding代码中的逻辑判断产生的。



####1.1
1. 完成`MainMenuScene.lua`，将自定义类`EffectSprite`绑定到lua中。
2. 通过`EffectSprite`和`cc.PointLight`实现点光源效果。
3. 将simulator放到工程文件中，修改引擎的时候方便更新。
4. 修改sublime的quick插件，实现右键点击`Run With Simulator`来运行simulator。

		更新simlator的脚本：cocos gen-simulator -e /Volumes/D/GitHub/FantasyWarrior/frameworks/cocos2d-x -o /Volumes/D/GitHub/FantasyWarrior/simulator -p mac


####1.0  
1. 通过Cocos创建空工程，FantasyWarrior3D的资源整体都拷贝进去；  
2. LoadingScene界面的完成，这个界面主要涉及到一个软泥怪的模型，会用到GlobalVariables.lua这个存放全局变量对的lua文件，考虑到全局变量的效率低下，尽量不适用全局变量，Actor的相关全局变量都改成局部变量，个别没办法改成局部变量的全局变量先暂时放在config.lua中。
3. Slime有使用自定义的c++类`JumpBy3D`，需要通过`genbindings.py`脚本完成lua绑定。
4. 因为引擎增加了自定义的c++类，所以simulator也需要做相应的修改。直接使用命令行`cocos gen-simulator -e -o -p`报错，因为simulator工程文件中还包含`cocos2d_js_bindings.xcodeproj`，而新建工程是lua工程，不包含js部分。解决办法是，在`AppDelegage.cpp`中删除`RuntimeJsImpl`相关代码。

		重点说明一个bug，新建文件之后，经常会遇到编译错误，Undefined symbols for architecture x86_64:......, 这个bug在simlator和genbingdings都遇到了，是因为新加的文件没有把对应的引用勾选上。