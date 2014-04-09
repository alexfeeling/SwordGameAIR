package alex.loader 
{
	import alex.asset.AssetManager;
	import alex.core.commander.Commander;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author alex
	 */
	public class LoaderManager 
	{
		
		public static const ALL_LOAD_COMPLETE:String = "all_load_complete";
		
		private var _allLoader:Array;
		private var _loadCnt:int = 0;
		private var _nameDic:Dictionary;
		
		public function LoaderManager() 
		{
			if (_instance != null) throw "singleton error.";
			
			_allLoader = [];
			_nameDic = new Dictionary();
			_loadCnt = 0;
		}
		
		private static var _instance:LoaderManager;
		public static function getInstance():LoaderManager {
			if (_instance == null) {
				_instance = new LoaderManager();
			}
			return _instance;
		}
		
		/**
		 * 加载图片，swf等资源时用这个加载
		 * @param	name
		 * @param	url
		 */
		public function addLoader(name:String, url:String):void {
			var loader:Loader = new Loader();
			_allLoader.push(loader, url);
			_nameDic[loader] = name;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadSucc);
		}
		
		/**
		 * 加载数据资源时用这个加载
		 * @param	name
		 * @param	url
		 */
		public function addURLLoader(name:String, url:String):void {
			var urlLoader:URLLoader = new URLLoader();
			_allLoader.push(urlLoader, url);
			urlLoader.addEventListener(Event.COMPLETE, onLoadURLSucc);
		}
		
		private function onLoadSucc(evt:Event):void {
			var loader:Loader = (evt.target as LoaderInfo).loader;
			switch(loader.contentLoaderInfo.contentType) {
				case "image/jpeg":
				case "image/gif":
				case "image/png":
					AssetManager.getInstance().addBitmapData(String(_nameDic[loader]), (loader.content as Bitmap).bitmapData);
					break;
				case "application/x-shockwave-flash":
					var appDomain:ApplicationDomain = loader.contentLoaderInfo.applicationDomain;
					var assetNames:Vector.<String> = appDomain.getQualifiedDefinitionNames();
					for (var i:int = 0, len:int = assetNames.length; i < len; i++) {
						AssetManager.getInstance().addClass(assetNames[i], appDomain.getDefinition(assetNames[i]) as Class);
					}
					break;
			}
			
			_allLoader.splice(_allLoader.indexOf(loader), 1);
			delete _nameDic[loader];
			onOneSucc();
		}
		
		private function onLoadURLSucc(evt:Event):void {
			var urlLoader:URLLoader = evt.target as URLLoader;
			urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
			AssetManager.getInstance().addData(String(_nameDic[urlLoader]), urlLoader.data as String);
			_allLoader.splice(_allLoader.indexOf(urlLoader), 1);
			delete _nameDic[urlLoader];
			onOneSucc();
		}
		
		private function onOneSucc():void {
			_loadCnt--;
			if (_loadCnt > 0) return;
			Commander.sendOrder(ALL_LOAD_COMPLETE);
		}
		
		public function startLoad():void {
			_loadCnt = _allLoader.length >> 1;
			for (var i:int = 0, len:int = _allLoader.length; i < len; i += 2) {
				_allLoader[i].load(new URLRequest(_allLoader[i + 1]));
			}
		}
		
		public function clearLoad():void {
			_loadCnt = 0;
			var loader:Object = _allLoader.pop();
			while (loader != null) {
				delete _nameDic[loader];
				if (loader is Loader) {
					(loader as Loader).contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadSucc);
					(loader as Loader).close();
				} else if (loader is URLLoader) {
					(loader as URLLoader).removeEventListener(Event.COMPLETE, onLoadURLSucc);
					(loader as URLLoader).close();
				}
				
				loader = _allLoader.pop();
			}
		}
		
	}

}