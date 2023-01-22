package;

import flixel.graphics.FlxGraphic;
import flixel.FlxCamera;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import openfl.system.System;
import cpp.vm.Gc;
import openfl.utils.AssetCache;

//crash handler stuff
#if CRASH_HANDLER
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
#if desktop
import Discord.DiscordClient;
#end
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
#end

using StringTools;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions. (Removed from Flixel 5.0.0)
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = false; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets
	public static var fpsVar:FPS;
	public static var focusMusicTween:FlxTween;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

        var res = ClientPrefs.screenRes.split('x');
		gameWidth = Std.parseInt(res[0]);
		gameHeight = Std.parseInt(res[1]);

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		SUtil.check();
	
		ClientPrefs.loadDefaultKeys();

		#if cpp 
		Gc.enable(true);
		#end

		addChild(new FlxGame(gameWidth, gameHeight, initialState, #if (flixel < "5.0.0") zoom, #end framerate, framerate, skipSplash, startFullscreen));
		FlxGraphic.defaultPersist = false;
				     
		FlxG.signals.gameResized.add(onResizeGame);
		FlxG.signals.preStateSwitch.add(function () {
			Paths.clearStoredMemory(true);
			FlxG.bitmap.dumpCache();

			var cache = cast(Assets.cache, AssetCache);
			for (key in cache.font.keys())
				cache.removeFont(key);
			for (key in cache.sound.keys())
				cache.removeSound(key);

			gc();
		});
		FlxG.signals.postStateSwitch.add(function () {
			Paths.clearUnusedMemory();
			gc();

			trace(System.totalMemory);
		});

		fpsVar = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		if(fpsVar != null) {
			fpsVar.visible = ClientPrefs.showFPS;
		}

		#if html5
		FlxG.mouse.visible = false;
		FlxG.autoPause = false;
		#end
			
		#if cpp
		cpp.NativeGc.enable(true);
		cpp.NativeGc.run(true);
		#end

		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end
			
		#if desktop
		if (!DiscordClient.isInitialized) {
			DiscordClient.initialize();
			Application.current.window.onClose.add(function() {
				DiscordClient.shutdown();
			});
		}
		#end
			
		/*Application.current.window.onFocusOut.add(onWindowFocusOut);
		Application.current.window.onFocusIn.add(onWindowFocusIn);*/
	}
	
	function onResizeGame(w:Int, h:Int) {
		if (FlxG.cameras == null)
			return;

		for (cam in FlxG.cameras.list) {
			@:privateAccess
			if (cam != null && (cam._filters != null || cam._filters/*.length > 0*/ != []))
				fixShaderSize(cam);
		}	
	}

	function fixShaderSize(camera:FlxCamera) // Shout out to Ne_Eo for bringing this to my attention
		{
			@:privateAccess {
				var sprite:Sprite = camera.flashSprite;
	
				if (sprite != null)
				{
					sprite.__cacheBitmap = null;
					sprite.__cacheBitmapData = null;
					sprite.__cacheBitmapData2 = null;
					sprite.__cacheBitmapData3 = null;
					sprite.__cacheBitmapColorTransform = null;
				}
			}
		}

	public static function gc() {
			#if cpp
			Gc.run(true);
			#else
			openfl.system.System.gc();
			#end
	}

	// Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!
	// very cool person for real they don't get enough credit for their work
	#if CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = SUtil.getPath() + "Crash/" + "Alt Engine [" + dateNow + "].txt";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error + "\nPlease report this error to the GitHub page: https://github.com/Fearester/Alt-Engine\n\n> Crash Handler written by: Sqirra-Rng";

		if (!FileSystem.exists(SUtil.getPath() + "crash/"))
			FileSystem.createDirectory(SUtil.getPath() + "crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		Application.current.window.alert(errMsg, "Error!");
		#if desktop
		DiscordClient.shutdown();
		#end
		Sys.exit(1);
	}
	#end
}
