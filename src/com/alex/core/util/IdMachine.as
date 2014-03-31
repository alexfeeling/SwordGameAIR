package com.alex.core.util 
{
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	/**
	 * ...
	 * @author alex
	 */
	public class IdMachine 
	{
		private static var _idDic:Dictionary = new Dictionary();
		
		public function IdMachine() 
		{
			throw "IdMacine不能被实例化::IdMacine can't be instantiate";
		}
		
		/**
		 * 返回一个根据类对象名增加的唯一ID
		 * @param	vClass
		 * @return
		 */
		public static function getId(vClass:Class):String {
			if (_idDic[vClass] == null) {
				_idDic[vClass] = 0;
			} else {
				_idDic[vClass]++;
			}
			return getQualifiedClassName(vClass) + "@" + _idDic[vClass];
		}
		
	}

}