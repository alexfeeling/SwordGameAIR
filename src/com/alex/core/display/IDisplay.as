package com.alex.core.display
{
	import com.alex.core.commander.IOrderExecutor;
	import com.alex.core.pool.IRecycle;
	import com.alex.core.component.PhysicsComponent;
	import com.alex.core.component.Position;
	import flash.display.DisplayObject;
	
	/**
	 * ...
	 * @author alex
	 */
	public interface IDisplay extends IOrderExecutor, IRecycle
	{
		
		function get id():String;
		
		function get position():Position;
		
		///物理组件
		function get physicsComponent():PhysicsComponent;
		
		///能否碰撞此单位
		function canCollide(unit:IDisplay):Boolean;
		
		///获得显示对象
		function toDisplayObject():DisplayObject;
		
		///刷新海拔高度
		function refreshZ():void;
		
		function refreshDisplayXY():void;
	
	}

}