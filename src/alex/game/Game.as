package alex.game
{
	import alex.ai.ElectronicBrain;
	import alex.controll.KeyboardController;
	import alex.core.animation.AnimationManager;
	import alex.core.component.PhysicsComponent;
	import alex.core.pool.InstancePool;
	import alex.core.component.Position;
	import alex.core.world.World;
	import alex.loader.LoaderManager;
	import alex.skill.SkillManager;
	import alex.socket.GameSocket;
	import alex.unit.Tree;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import starling.core.Starling;
	
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
			InstancePool.preset(ElectronicBrain, 20);
			
			//启动动画管理器
			AnimationManager.startUp(60);
			new SkillManager();
			
			//添加动画
			new KeyboardController(stage);
			
			var worldMap:World = new World();
			this.addChild(worldMap);
			
			//var starling:Starling = new Starling(World, stage);
			//starling.showStatsAt("center");
			//starling.start();
			//ApplicationDomain.currentDomain.getQualifiedDefinitionNames();
			loadAsset();
		}
		
		private function loadAsset():void {
			LoaderManager.getInstance().addLoader("role", "asset/role/role.swf");
			LoaderManager.getInstance().startLoad();
		}
		
	}

}