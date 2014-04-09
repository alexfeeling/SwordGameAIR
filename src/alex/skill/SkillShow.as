package alex.skill
{
	import alex.constant.OrderConst;
	import alex.core.component.PhysicsComponent;
	import alex.core.component.PhysicsType;
	import alex.core.unit.IWorldUnit;
	import alex.core.pool.InstancePool;
	import alex.core.util.IdMachine;
	import alex.core.component.Position;
	import alex.core.world.World;
	import alex.unit.AttackableUnit;
	import alex.unit.BaseUnit;
	import alex.unit.IAttackable;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	
	/**
	 * 显式技能招式
	 * @author alex
	 */
	public class SkillShow extends BaseUnit
	{
		
		private var _ownner:AttackableUnit;
		
		private var _lifeTime:Number = 0;
		
		private var _skillData:SkillData;
		
		private var _name:String;
		
		private var _frameData:Object;
		
		public function SkillShow()
		{
		
		}
		
		protected function init(vName:String, vOwnner:AttackableUnit, vPosition:Position, vDir:int, frameData:Object):SkillShow
		{
			refresh(IdMachine.getId(SkillShow), vPosition, PhysicsComponent.make(this, vPosition, frameData.speed, 50, 50, 50, 10, PhysicsType.BUBBLE));
			_name = vName;
			_ownner = vOwnner;
			_physicsComponent.startMove(vDir);
			_lifeTime = 5000;
			_frameData = frameData;
			return this;
		}
		
		public static function make(vName:String, vOwnner:AttackableUnit, vPosition:Position, vDir:int, frameData:Object):SkillShow
		{
			return SkillShow(InstancePool.getInstance(SkillShow)).init(vName, vOwnner, vPosition, vDir, frameData);
		}
		
		override protected function createUI():void
		{
			super.createUI();
			var body:Shape = new Shape();
			body.y = -this.position.z; // this._elevation; 
			body.graphics.beginFill(0xff00ff, 0.2);
			//body.graphics.drawRect( -25, - 50, 50, 50);
			body.graphics.drawRect(-World.GRID_WIDTH / 2, -World.GRID_HEIGHT, World.GRID_WIDTH, World.GRID_HEIGHT);
			body.graphics.endFill();
			this._body.addChild(body);
		}
		
		public function getHitEnergy():Number
		{
			return 50;
		}
		
		///碰撞
		override public function collide(unit:IWorldUnit, moveDir:int):void
		{
			if (unit == null) return;
			if (unit is IAttackable)
				(unit as IAttackable).receiveAttackHurt(this.ownner, _frameData);
			this.release();
		}
		
		override public function canCollide(unit:IWorldUnit):Boolean
		{
			return super.canCollide(unit) && unit != this.ownner;
		}
		
		/* INTERFACE alex.display.IDisplay */
		override public function refreshZ():void
		{
			
		}
		
		override public function release():void
		{
			super.release();
			this._ownner = null;
		}
		
		override public function gotoNextFrame(passedTime:Number):void
		{
			if (this._isRelease)
			{
				return;
			}
			super.gotoNextFrame(passedTime);
			if (this._isRelease)
			{
				return;
			}
			this._lifeTime -= passedTime;
			if (this._lifeTime <= 0)
			{
				this.release();
			}
		}
		
		public function get ownner():AttackableUnit
		{
			return _ownner;
		}
	
	}

}