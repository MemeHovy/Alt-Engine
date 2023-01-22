package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
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
#if android
import android.Tools;
#end

using StringTools;

class GameplaySettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
        if(ClientPrefs.language == 'English')
        {
		title = 'Gameplay Settings';
		rpcTitle = 'Gameplay Settings Menu'; //for Discord Rich Presence
        } else {
        title = 'Настройка Игры';
		rpcTitle = 'Меню Настройки Игры';
        }
		var option:Option = new Option('Controller Mode',
		    if(ClientPrefs.language == 'English')
		    {
			'Check this if you want to play with\na controller instead of using your Keyboard.',
			} else {
			'Проверьте это, если вы хотите играть с контроллером \nвместо использования клавиатуры.',
			}
			'controllerMode',
			'bool',
			#if android true #else false #end);
		addOption(option);

		//I'd suggest using "Downscroll" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Downscroll', //Name
		    if(ClientPrefs.language == 'English')
		    {
			'If checked, notes go Down instead of Up, simple enough.', //Description
		    } else {
		    'Если флажок установлен, стрелки идут вниз, а не вверх, достаточно просто.', //Описание
		    }
			'downScroll', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);

		var option:Option = new Option('Middlescroll',
		    if(ClientPrefs.language == 'English')
		    {
			'If checked, your notes get centered.',
		    } else {
		    "Если флажок установлен, ваши ноты будут центрированы.",
		    }
			'middleScroll',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Opponent Notes',
		if(ClientPrefs.language == 'English'){
			'If unchecked, opponent notes get hidden.',
		} else {
		"Если флажок снят, ноты противника будут скрыты.",
		}
			'opponentStrums',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Ghost Tapping',
		    if(ClientPrefs.language == 'English'){
			"If checked, you won't get misses from pressing keys\nwhile there are no notes able to be hit.",
		    } else {
		    "Если флажок установлен, вы не будете получать промахи при нажатии клавиш \n, пока нет заметок, которые можно нажать.",
		    }
			'ghostTapping',
			'bool',
			true);
		addOption(option);
                #if !android
		var option:Option = new Option('Disable Reset Button',
		if(ClientPrefs.language == 'English'){
			"If checked, pressing Reset won't do anything.",
		} else {
		    "Если флажок установлен, нажатие кнопки перезапуска ничего не сделает",
		}
			'noReset',
			'bool',
			false);
		addOption(option);
                #end
		var option:Option = new Option('Hitsound Volume',
		if(ClientPrefs.language == 'English'){
			'Funny notes does \"Tick!\" when you hit them."',
		} else {
		    "Забавные заметки \"тикают\", когда вы нажимаете на них.",
		}
			'hitsoundVolume',
			'percent',
			0);
		addOption(option);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		option.onChange = onChangeHitsoundVolume;

		var option:Option = new Option('Rating Offset',
		if(ClientPrefs.language == 'English')
		{
			'Changes how late/early you have to hit for a "Sick!"\nHigher values mean you have to hit later.',
		} else {
		"Изменяет, как поздно/рано вы нажали на |Sick| \nБолее высокие значения означают, что вы нажали на ноту позже.",
		}
			'ratingOffset',
			'int',
			0);
		option.displayFormat = '%vms';
		option.scrollSpeed = 20;
		option.minValue = -30;
		option.maxValue = 30;
		addOption(option);

		var option:Option = new Option('Sick! Hit Window',
		if(ClientPrefs.language == 'English'){
			'Changes the amount of time you have\nfor hitting a "Sick!" in milliseconds.',
		} else {
		"Изменяет количество времени, которое у вас есть для нажатия кнопки |Sick!| в миллисекундах.",
		}
			'sickWindow',
			'int',
			45);
		option.displayFormat = '%vms';
		option.scrollSpeed = 15;
		option.minValue = 15;
		option.maxValue = 45;
		addOption(option);

		var option:Option = new Option('Good Hit Window',
		if(ClientPrefs.language == 'English'){
			'Changes the amount of time you have\nfor hitting a "Good!" in milliseconds.',
		} else {
		"Изменяет количество времени, которое у вас есть для нажатия кнопки |Good!| в миллисекундах.",
		}			'goodWindow',
			'int',
			90);
		option.displayFormat = '%vms';
		option.scrollSpeed = 30;
		option.minValue = 15;
		option.maxValue = 90;
		addOption(option);

		var option:Option = new Option('Bad Hit Window',
		if(ClientPrefs.language == 'English'){
			'Changes the amount of time you have\nfor hitting a "Bad!" in milliseconds.',
		} else {
		"Изменяет количество времени, которое у вас есть для нажатия кнопки |Bad!| в миллисекундах.",
		}
		'badWindow',
			'int',
			135);
		option.displayFormat = '%vms';
		option.scrollSpeed = 60;
		option.minValue = 15;
		option.maxValue = 135;
		addOption(option);

		var option:Option = new Option('Safe Frames',
		if(ClientPrefs.language == 'English'){
			'Changes how many frames you have for\nhitting a note earlier or late.',
		} else {
		   "Изменяет количество кадров, которые у вас есть для отправки ноты раньше или позже".,
		}
			'safeFrames',
			'float',
			10);
		option.scrollSpeed = 5;
		option.minValue = 2;
		option.maxValue = 10;
		option.changeValue = 0.1;
		addOption(option);

                var option:Option = new Option('Health Drain',
             if(ClientPrefs.language == 'English'){
			'Add Draining health when opponent hit in note.',
             } else {
             "Добавляeт истощающее здоровье, когда противник попадает в ноту.",
             }
			'healthDrain',
			'float',
			0);
		option.scrollSpeed = 1.6;
		option.minValue = 0;
		option.maxValue = 5;
		option.changeValue = 0.1;
		addOption(option);

		super();
	}

	function onChangeHitsoundVolume()
	{
		FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
	}
}
