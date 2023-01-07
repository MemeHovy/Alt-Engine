package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flixel.ui.FlxBar;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;
import openfl.Lib;
import openfl.display.FPS;

using StringTools;

class GPUSubState extends BaseOptionsMenu
{
    public var Frames(default,null):Int;
    
	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;

	public function new()
	{
		title = 'GPU Info';
		rpcTitle = 'GPU Info'; //for Discord Rich Presence
	   super();
	   
	    Frames = 0;
	   	cacheCount = 0;
		currentTime = 0;
		times = [];

		#if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			var time = Lib.getTimer();
			__enterFrame(time - currentTime);
		});
		#end
	}
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
		{
			times.shift();
		}

		var currentCount = times.length;
		Frames = Math.round((currentCount + cacheCount) / 2);
		if (Frames > ClientPrefs.framerate) Frames = ClientPrefs.framerate;
    }

    override function update(elapsed:Float)
    {
        
        var FPSBar:FlxBar;
        FPSBar = new FlxBar(0, 620, LEFT_TO_RIGHT, Std.int(1280 / 2), 20, this, 'Frames', 0, ClientPrefs.framerate);
		FPSBar.scrollFactor.set();
		FPSBar.screenCenter(X);
		FPSBar.createFilledBar(0xFF000000, 0xFF80FF00);
		FPSBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		FPSBar.visible = true;
        add(FPSBar);
        super.update();
    }
}
