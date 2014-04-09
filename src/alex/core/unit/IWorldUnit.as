package alex.core.unit
{
	import alex.core.commander.IOrderExecutor;
	import alex.core.pool.IRecycle;
	import alex.core.component.PhysicsComponent;
	import alex.core.component.Position;
	import alex.core.animation.IAnimation;
	import flash.display.DisplayObject;
	
	/**
	 * 世界单位接口
	 * @author alex
	 */
	public interface IWorldUnit extends IOrderExecutor, IAnimation, IRecycle
	{
		
		///位置
		function get position():Position;
		
		///物理组件
		function get physicsComponent():PhysicsComponent;
		
		///能否碰撞此单位
		function canCollide(unit:IWorldUnit):Boolean;
		
		///获得显示对象
		function toDisplayObject():DisplayObject;
		
		///刷新海拔高度
		function refreshZ():void;
		
		///刷新显示位置
		function refreshXY():void;
	
	}

}