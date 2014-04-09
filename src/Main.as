package 
{
	import alex.game.Game;
	import alex.util.Stats;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.system.fscommand;
	
	/**
	 * ...
	 * @author alex
	 */
	public class Main extends Sprite 
	{
		
		public function Main():void 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			//trace(stage.scaleMode);
			stage.align = StageAlign.TOP_LEFT;
			//stage.displayState = StageDisplayState.FULL_SCREEN;
			//fscommand("trapallkeys","true");
			
			
			this.addChild(new Game());
			///显示fps工具类
			var stats:Stats = new Stats();
			this.addChild(stats);
		}
		
	}
	
}