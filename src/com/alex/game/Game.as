package com.alex.game
{
	import com.alex.controll.KeyboardController;
	import com.alex.core.animation.AnimationManager;
	import com.alex.core.component.PhysicsComponent;
	import com.alex.core.pool.InstancePool;
	import com.alex.core.component.Position;
	import com.alex.core.world.World;
	import com.alex.skill.SkillManager;
	import com.alex.socket.GameSocket;
	import com.alex.unit.Tree;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author alex
	 */
	public class Game extends Sprite 
	{
		
		public function Game() 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			//new GameSocket(stage);
			InstancePool.startUp();
			InstancePool.preset(Position, 20);
			InstancePool.preset(Tree, 20);
			InstancePool.preset(PhysicsComponent, 20);
			
			//启动动画管理器
			AnimationManager.startUp(60);
			new SkillManager();
			
			//添加动画
			new KeyboardController(stage);
			
			var worldMap:World = new World();
			this.addChild(worldMap);
			
		}
		
	}

}