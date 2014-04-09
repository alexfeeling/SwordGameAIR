package alex.role
{
	import alex.constant.OrderConst;
	import alex.core.component.AttributeComponent;
	import alex.core.component.PhysicsComponent;
	import alex.core.component.PhysicsType;
	import alex.core.util.IdMachine;
	import alex.core.component.Position;
	import alex.core.world.World;
	import alex.skill.SkillShow;
	import alex.unit.AttackableUnit;
	import alex.unit.BaseUnit;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	
	/**
	 * ...
	 * @author alex
	 */
	public class MainRole extends AttackableUnit
	{
		
		[Embed(source="/../bin/asset/role/run.swf",symbol="RoleRun")]
		public var RUN_CLASS:Class;
		
		private var _speed:Number = 25;
		
		private static var _instance:MainRole;
		
		public function MainRole()
		{
			if (_instance)
			{
				throw "MainRole只能有一个对象";
			}
			_instance = this;
		}
		
		public static function getInstance():MainRole
		{
			return _instance;
		}
		
		protected function init(vPosition:Position):MainRole
		{
			refresh(IdMachine.getId(MainRole), vPosition, PhysicsComponent.make(this, vPosition, this._speed, 80, 60, 100, 50, PhysicsType.SOLID));
			refreshAttribute(AttributeComponent.make(this, 100, 100));
			return this;
		}
		
		public static function make(position:Position):MainRole
		{
			if (_instance)
			{
				return _instance;
			}
			_instance = new MainRole().init(position);
			return _instance;
		}
		
		private var run:MovieClip;
		
		override protected function createUI():void
		{
			super.createUI();
			_shadow.graphics.beginFill(0x0, 0.5);
			_shadow.graphics.drawRect(-World.GRID_WIDTH / 2, -World.GRID_HEIGHT / 2, World.GRID_WIDTH, World.GRID_HEIGHT);
			_shadow.graphics.endFill();
			run = new RUN_CLASS();
			run.stop();
			_body.addChild(run);
		}
		
		override public function getExecuteOrderList():Array
		{
			return super.getExecuteOrderList().concat([
				//OrderConst.CREATE_SKILL, 
				OrderConst.ROLE_START_MOVE, 
				OrderConst.ROLE_STOP_MOVE, 
				OrderConst.ROLE_START_JUMP,
				OrderConst.ROLE_END_JUMP,
				OrderConst.ATTACK]);
		}
		
		override public function executeOrder(orderName:String, orderParam:Object = null):void
		{
			switch (orderName)
			{
				//case OrderConst.CREATE_SKILL: 
					//var skillName:String = orderParam as String;
					//if (skillName != null)
					//{
						//var sPosition:Position = this.position.copy();
						//var skill:SkillShow = SkillShow.make(skillName, this, sPosition, this._physicsComponent.faceDirection == 1 ? MoveDirection.X_RIGHT : MoveDirection.X_LEFT);
						//Commander.sendOrder(OrderConst.ADD_ITEM_TO_WORLD_MAP, skill);
					//}
					//break;
				case OrderConst.ROLE_START_MOVE: 
					this._physicsComponent.startMove(int(orderParam));
					break;
				case OrderConst.ROLE_STOP_MOVE: 
					this._physicsComponent.stopMove(int(orderParam));
					break;
				case OrderConst.ROLE_START_JUMP: 
					this._physicsComponent.readyJump();
					break;
				case OrderConst.ROLE_END_JUMP:
					this._physicsComponent.endJump();
					break;
				case OrderConst.ATTACK:
					this.startAttack(orderParam as String);
					break;
				default: 
					super.executeOrder(orderName, orderParam);
			}
		
		}
		
		private var tempTime:Number = 0;
		private var fpsTime:Number = 1000 / 8;
		
		override public function gotoNextFrame(passedTime:Number):void
		{
			super.gotoNextFrame(passedTime);
			tempTime += passedTime;
			if (tempTime >= fpsTime)
			{
				tempTime -= fpsTime;
				if (run != null)
				{
					run.gotoAndStop((run.currentFrame + 1) % run.totalFrames);
				}
			}
		}
		
		override public function refreshZ():void
		{
			var elevation:Number = Math.max(this._position.z, 0);
			this._body.y = -elevation;
		}
		
		override public function release():void
		{
			super.release();
			this._speed = 0;
			this.run = null;
		}
	
	}

}