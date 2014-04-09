package alex.core.pool 
{
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	/**
	 * 对象池
	 * @author alex
	 */
	public class InstancePool 
	{
		
		private var _m_poolDic:Dictionary;
		private static var _instance:InstancePool;
		
		public function InstancePool() 
		{
			if (_instance != null) {//只能实例化一次
				throw "InstancePool已经有单例对象，不可再实例化";
			}
		}
		
		///对象池初始化
		public static function startUp():void {
			_instance = new InstancePool();
			_instance._m_poolDic = new Dictionary();
		}
		
		/**
		 * 预先装置对应对象池
		 * @param	vClass
		 * @param	num 初始化对象数量
		 */
		public static function preset(vClass:Class, num:int = 10):void {
			if (_instance == null || _instance._m_poolDic == null) {
				return;
			}
			var pool:Array = _instance._m_poolDic[vClass] as Array;
			if (pool == null) {
				pool = [];
				_instance._m_poolDic[vClass] = pool;
			}
			for (var i:int = 0; i < num; i++) {
				pool.push(new vClass() as IRecycle);
			}
		}
		
		/**
		 * 在对象池捞一个对象，对象池里如果没有这种对象，就new一个
		 * @param	vClass
		 * @return
		 */
		public static function getInstance(vClass:Class):IRecycle {
			var pool:Array = _instance._m_poolDic[vClass] as Array;
			if (pool == null) {
				pool = [];
				_instance._m_poolDic[vClass] = pool;
			}
			if (pool.length <= 0) {
				for (var i:int = 0; i < 10; i++) {
					pool.push(new vClass());
				}
			}
			return pool.pop() as IRecycle;
		}
		
		/**
		 * 回收对象
		 * @param	vInstance
		 */
		public static function recycle(vInstance:IRecycle):void {
			var vClass:Class = getDefinitionByName(getQualifiedClassName(vInstance)) as Class;
			var pool:Array = _instance._m_poolDic[vClass] as Array;
			if (pool == null) {
				pool = [];
				_instance._m_poolDic[vClass] = pool;
			}
			pool.push(vInstance);
		}
		
	}

}