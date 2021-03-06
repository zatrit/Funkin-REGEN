package;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

#if mobile
import mobile.MobileButton;
import mobile.MobileControls;
#end

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', #if !mobile "Charting editor", #end 'Exit to menu'];

	var curSelected:Int = 0;
	var pauseMusic:FlxSound;

	final DIST_BEETWEN_ITEMS = #if !mobile 1 #else 0.9 #end;

	var isChangeDiffMenu:Bool=false;

	public function new(x:Float, y:Float)
	{
		super();

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var blueBalled:FlxText = new FlxText(20, 15 +64, 0, "", 32);
		blueBalled.text += "Blue balled: "+PlayState.attempt;
		blueBalled.scrollFactor.set();
		blueBalled.setFormat(Paths.font("vcr.ttf"), 32);
		blueBalled.updateHitbox();
		add(blueBalled);

		blueBalled.x = FlxG.width - (blueBalled.width + 20);
		blueBalled.alpha = 0;
		FlxTween.tween(blueBalled, {alpha: 1, y: blueBalled.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});

		#if (mobile&&debug)
		var controlTypeID:Int=1;
		
		if(FlxG.save.data.mobileControlsType!=null)
			controlTypeID=FlxG.save.data.mobileControlsType;

		var controlType:FlxText = new FlxText(20, 15 +96, 0, "", 32);
		controlType.text += "Control type: "+controlTypeID;
		controlType.scrollFactor.set();
		controlType.setFormat(Paths.font("vcr.ttf"), 32);
		controlType.updateHitbox();
		add(controlType);

		controlType.x = FlxG.width - (controlType.width + 20);
		controlType.alpha = 0;
		FlxTween.tween(controlType, {alpha: 1, y: controlType.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.9});
		#end

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: levelInfo.y}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.ID=i;
			songText.isMenuItem = true;
			songText.targetY = (i-(menuItems.length/2)+0.5)*DIST_BEETWEN_ITEMS;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		#if mobile
		if(FlxG.touches.justReleased().length>0){
		for (touch in FlxG.touches.list) {
				for (item in grpMenuShit.members) {
					if(item.overlapsPoint(touch.getWorldPosition(camera))){
						curSelected=item.ID;
						changeSelection();
						accepted=true;
					}
				}
			}
		}
		#end

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					close();
				case "Restart Song":
					PlayState.firstTry=false;
					FlxG.resetState();
				case "Exit to menu":
					FlxG.switchState(new MainMenuState());
				case "Change difficulty":

#if debug
				case "Charting editor":
					FlxG.switchState(new ChartingState());
#end
			}
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;


		for (item in grpMenuShit.members)
		{
			#if !mobile
			item.targetY = (bullShit - curSelected)*DIST_BEETWEN_ITEMS;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
			#else
			item.alpha = 1;
			#end
		}
	}
	override function onBack() {
		close();
	}
}
