package 
{
	import com.alex.game.Game;
	import com.alex.util.Stats;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author alex
	 */
	public class Main extends Sprite 
	{
		
		public function Main():void 
		{
			this.addChild(new Game());
			///显示fps工具类
			var stats:Stats = new Stats();
			this.addChild(stats);
		}
		
	}
	
}