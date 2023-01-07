package flixel.system;
 
import flixel.FlxSprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.FlxSprite;
import flash.Lib;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.system.FlxSound;
import flixel.system.FlxBasePreloader;
 
class FlxSplash extends FlxBasePreloader
{
    public function new(MinDisplayTime:Float= 5, ?AllowedURLs:Array<String>) 
    {
        super(MinDisplayTime, AllowedURLs);
    }
     
    var logo:FlxSprite;
    var LogoBG:FlxSprite;
    var LogoText:FlxSprite;
    var StartSong:FlxSound;
     
    override function create():Void 
    {
        this._width = Lib.current.stage.stageWidth;
        this._height = Lib.current.stage.stageHeight;
         
        var ratio:Float = this._width / 2560; //This allows us to scale assets depending on the size of the screen.
         
        LogoBG = new FlxSprite(0,0).makeGraphic(FlxG.width, FlxG.height, 0xFFffffff);
        LogoBG.screenCenter(X);
        addChild(LogoBG);
        logo = new FlxSprite(-1900,0);
        logo.loadGraphic(Paths.image('Haxe Logo'));
        logo.scrollFactor.set();
        addChild(logo);
        LogoText = new FlxSprite(1700,0);
        LogoText.loadGraphic(Paths.image('Haxe Text'));
        LogoText.scrollFactor.set();
        addChild(LogoText);
        StartSong = new FlxSound().loadEmbedded(Paths.sound('start'));
		FlxG.sound.list.add(StartSong);
        super.create();
    }
     
    override function update(elapsed:Float):Void 
    {
    FlxTween.tween(logo, {x: 400}, 5, {
	ease: FlxEase.backInOut,
	onComplete: function(twn:FlxTween) {
	FlxTween.tween(logo, {x: -1900}, 5, {ease: FlxEase.backInOut});
	}
	});
	FlxTween.tween(LogoText, {x: 700}, 5, {
	ease: FlxEase.backInOut,
	onComplete: function(twn:FlxTween) {
	FlxTween.tween(LogoText, {x: 1700}, 5, {ease: FlxEase.backInOut});
	}
	});
        super.update(elapsed);
    }
}
