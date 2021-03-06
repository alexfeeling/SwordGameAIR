package alex.unit
{
	import alex.constant.OrderConst;
	import alex.core.animation.IAnimation;
	import alex.core.commander.Commander;
	import alex.core.component.MoveDirection;
	import alex.core.component.PhysicsComponent;
	import alex.core.component.PhysicsType;
	import alex.core.unit.IWorldUnit;
	import alex.core.pool.InstancePool;
	import alex.core.component.Position;
	import alex.core.world.World;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	/**
	 * 基本单位
	 * @author alexfeeling
	 */
	public class BaseUnit implements IWorldUnit
	{
		protected var _isRelease:Boolean;
		
		protected var _displayObject:Sprite;
		protected var _body:Sprite;
		protected var _shadow:Sprite;
		
		protected var _physicsComponent:PhysicsComponent;
		protected var _position:Position;
		protected var _id:String;
		
		public function BaseUnit()
		{
		
		}
		
		protected function refresh(vId:String, vPosition:Position, vPhysicsComponent:PhysicsComponent):BaseUnit
		{
			this._isRelease = false;
			this._id = vId;
			this._position = vPosition;
			vPosition.phycItem = this;
			this._physicsComponent = vPhysicsComponent;
			this.createUI();
			Commander.registerExecutor(this);
			this.refreshXY();
			return this;
		}
		
		protected function createUI():void
		{
			this._displayObject = new Sprite();
			this._body = new Sprite();
			this._shadow = new Sprite();
			this._displayObject.addChild(_shadow);
			this._displayObject.addChild(_body);
		}
		
		/* INTERFACE alex.pattern.IOrderExecutor */
		
		public function getExecuteOrderList():Array
		{
			return [OrderConst.CHANGE_FACE_DIRECTION];
		}
		
		public function executeOrder(orderName:String, orderParam:Object = null):void
		{
			switch (orderName)
			{
				case OrderConst.CHANGE_FACE_DIRECTION: 
					if (orderParam == 1 || orderParam == -1)
						this._body.scaleX = orderParam as int;
					break;
				case OrderConst.MAP_ITEM_MOVE: 
					this.move(orderParam[0], orderParam[1]);
					break;
			}
		}
		
		public function getExecutorId():String
		{
			return this._id;
		}
		
		/* INTERFACE alex.display.IDisplay */
		
		public function toDisplayObject():DisplayObject
		{
			return this._displayObject;
		}
		
		public function refreshZ():void
		{
			;
		}
		
		/**
		 * 碰撞到刚体的处理
		 * @param	targetUnit 目标单位
		 * @param	moveDir 本次移动的方向
		 */
		public function collide(targetUnit:IWorldUnit, moveDir:int):void
		{
			switch(_physicsComponent.physicsType) {
				case PhysicsType.SOLID:
					//刚体碰撞到刚体，停止移动，贴合
					position.nestleUpTo(moveDir, targetUnit);
					break;
				case PhysicsType.BUBBLE:
					
					break;
				case PhysicsType.VIRTUAL:
					
					break;
			}
		}
		
		public function get position():Position
		{
			return _position;
		}
		
		public function get id():String
		{
			return _id;
		}
		
		public function get physicsComponent():PhysicsComponent
		{
			return _physicsComponent;
		}
		
		public function refreshXY():void
		{
			if (this._isRelease || this.position == null) return;
			
			_displayObject.x = position.gridX * World.GRID_WIDTH + position.insideX;
			_displayObject.y = position.gridY * World.GRID_HEIGHT + position.insideY;
		}
		
		public function release():void
		{
			if (this._isRelease) throw "release error";
			
			Commander.sendOrder(World.REMOVE_ITEM_FROM_WORLD, this);
			Commander.cancelExecutor(this);
			if (this._physicsComponent)
			{
				this._physicsComponent.release();
				this._physicsComponent = null;
			}
			if (this._position)
			{
				this._position.release();
				this._position = null;
			}
			this._body.removeChildren();
			this._shadow.removeChildren();
			this._displayObject.removeChildren();
			this._body = null;
			this._shadow = null;
			if (this._displayObject.parent)
				this._displayObject.parent.removeChild(this._displayObject);
			this._displayObject = null;
			this._id = null;
			this._isRelease = true;
			InstancePool.recycle(this);
		}
		
		public function isRelease():Boolean
		{
			return this._isRelease;
		}
		
		/* INTERFACE alex.animation.IAnimation */
		
		public function isPause():Boolean
		{
			return false;
		}
		
		public function isPlayEnd():Boolean
		{
			return false;
		}
		
		public function gotoNextFrame(passedTime:Number):void
		{
			this._physicsComponent.run(passedTime);
		}
		
		private static var STEP:int = 20;
		
		///direction:0左，1右，2上，3下
		public function move(vDirection:int, vDistance:int):void
		{
			var tDistance:int = vDistance;
			var collidedUnit:IWorldUnit = null;
			var tempCollidedUnit:IWorldUnit = null;
			while (tDistance > 0)
			{
				tempCollidedUnit = f_itemMove(vDirection, Math.min(tDistance, STEP));
				if (this.isRelease()) return;
				tDistance -= STEP;
				if (tempCollidedUnit)
				{
					collidedUnit = tempCollidedUnit;
					break;
				}
			}
			refreshXY();
			if (vDirection == MoveDirection.Z_BOTTOM && collidedUnit)
				_physicsComponent.executeOrder(OrderConst.STAND_ON_UNIT, collidedUnit);
		}
		
		///单位移动,direction:0左，1右，2上，3下
		//0无碰撞 1碰撞 2释放 XXXX
		private function f_itemMove(direction:int, distance:int):IWorldUnit
		{
			//先移动相应距离
			_position.move(direction, distance);
			if (_physicsComponent.physicsType == PhysicsType.SOLID)
				var unitList:Array = World.getInstance().getAroudItemsByMove(direction, _position);
			else
				unitList = World.getInstance().getAroudItems(_position);
			
			var isHitUnit:Boolean = false;
			var collidedUnit:IWorldUnit = null;
			for (var i:int = 0; i < unitList.length; i++)
			{
				var unitDic:Dictionary = unitList[i] as Dictionary;
				if (unitDic == null) continue;
				for each (var targetUnit:IWorldUnit in unitDic)
				{
					if (this.canCollide(targetUnit) && 
						this.physicsComponent.toCube().intersects(targetUnit.physicsComponent.toCube()))
					{
						collidedUnit = targetUnit;
						this.collide(targetUnit, direction);
						if (this.isRelease()) return null;
					}
				}
			}
			return collidedUnit;
		}
		
		/**
		 * 是否可碰撞该对象，目标是固体才可碰撞
		 * @param	target
		 * @return
		 */
		public function canCollide(target:IWorldUnit):Boolean
		{
			return this != target && target.physicsComponent.physicsType == PhysicsType.SOLID;
		}
	
	}

}