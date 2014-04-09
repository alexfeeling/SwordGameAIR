package alex.asset 
{
	import flash.display.BitmapData;
	/**
	 * ...
	 * @author alex
	 */
	public class AssetManager 
	{
		
		public function AssetManager() 
		{
			if (_instance != null) throw "singleton error.";
		}
		
		private static var _instance:AssetManager;
		public static function getInstance():AssetManager {
			if (_instance == null) {
				_instance = new AssetManager();
			}
			return _instance;
		}
		
		public function addBitmapData(name:String, bitmapData:BitmapData):void {
			
		}
		
		public function addData(name:String, data:String):void {
			
		}
		
		public function addClass(name:String, vClass:Class):void {
			
		}
		
	}

}