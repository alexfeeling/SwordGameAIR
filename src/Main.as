package 
{
	import com.alex.game.Game;
	import com.alex.util.Stats;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	/**
	 * ...
	 * @author alex
	 */
	public class Main extends Sprite 
	{
		
		public function Main():void 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			this.addChild(new Game());
			///显示fps工具类
			var stats:Stats = new Stats();
			this.addChild(stats);
		}
		
	}
	
}