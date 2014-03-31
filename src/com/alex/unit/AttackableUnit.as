package com.alex.unit
{
	import com.alex.constant.OrderConst;
	import com.alex.core.animation.AnimationManager;
	import com.alex.core.animation.AttributeAnimation;
	import com.alex.core.component.AttributeComponent;
	import com.alex.core.component.MoveDirection;
	import com.alex.core.component.PhysicsType;
	import com.alex.core.unit.IAttributeUnit;
	import com.alex.core.unit.IWorldUnit;
	import com.alex.core.util.Cube;
	import com.alex.core.world.World;
	import com.alex.skill.SkillFrameData;
	import com.alex.skill.SkillOperator;
	import com.alex.unit.BaseUnit;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author alex
	 */
	public class AttackableUnit extends BaseUnit implements IAttackable, IAttributeUnit
	{
		/**
		 * 攻击目标
		 */
		//private var _attackTarget:AttackableUnit;
		private var _enemyTarget:AttackableUnit;
		/**
		 * 攻击区块
		 */
		private var _attackCube:Cube;
		
		///视线范围
		private var _rangeOfVision:Rectangle;
		
		///当前技能运作对象
		private var _currentSkillOperator:SkillOperator;
		
		///本单位掌握的技能
		private var _allSkillDic:Dictionary;
		
		private var _attributeComponent:AttributeComponent;
		
		///被抓举的单位
		private var _catchingUnit:AttackableUnit;
		
		private var _lockingTarget:AttackableUnit;
		
		///是否正在死亡
		protected var _isDying:Boolean = false;
		
		public function AttackableUnit()
		{
			
		}
		
		protected function refreshAttribute(attributeComponent:AttributeComponent):void
		{
			this._attributeComponent = attributeComponent;
			_allSkillDic = new Dictionary();
			_allSkillDic["刺"] = new <SkillFrameData>[null, null, null, 
				SkillFrameData.make().initByObj({ type:"hurt", lifeHurt:50, xImpact: -30, zImpact:40 }), null, null, 
				SkillFrameData.make().initByObj({ type:"hurt", lifeHurt:50, xImpact:100, yImpact:50, zImpact: -40 }), null, null, 
				SkillFrameData.make().initByObj( { type:"end" } ) ];

			_allSkillDic["南剑诀"] = new <SkillFrameData>[null, null, null, 
				SkillFrameData.make().initByObj({ type:"distance", distanceId:"d1", speed:40, weight:10, lifeHurt:30, xImpact: 50, zImpact:20 }), null, null, 
				SkillFrameData.make().initByObj({ type:"distance", distanceId:"d1", speed:30, weight:10, lifeHurt:30, xImpact: -100, zImpact: -40 }), null, null, 
				SkillFrameData.make().initByObj( { type:"end" } ) ];
			
			_allSkillDic["升"] = new <SkillFrameData>[null, null, 
				//{type:"catch", elevation:20}, null,null,
				SkillFrameData.make().initByObj( { type:"catch", catchZ:50, catchX:50 } ), null,
				//{type:"catch", elevation:60, x:40 }, //null,null,
				//{type:"catch", elevation:70, x:30 }, //null,null,
				SkillFrameData.make().initByObj( { type:"catch", catchZ:80, catchX:0 } ), null,
				//{type:"catch", elevation:70, x:-40 }, //null,null,
				SkillFrameData.make().initByObj( { type:"catch", catchZ:50, catchX: -50 } ), null,
				//{type:"catch", elevation:30, x:-80 },  //null,null,
				SkillFrameData.make().initByObj( { type:"catch", catchZ:0, catchX: -100 } ), null,
				//{type:"catch", elevation:30, x: -80 },  //null,null,
				SkillFrameData.make().initByObj( { type:"catch", catchZ:50, catchX: -50 } ), null,
				//{type:"catch", elevation:70, x: -40 }, //null,null,
				SkillFrameData.make().initByObj( { type:"catch", catchZ:80, catchX:0 } ), null,
				SkillFrameData.make().initByObj( { type:"hurt_catch", lifeHurt:50, xImpact:100, zImpact: -40, releaseCatch:true } ), null, 
				SkillFrameData.make().initByObj( { type:"end" } ) ];
				
			_allSkillDic["穿心"] = new <SkillFrameData>[
				SkillFrameData.make().initByObj( { type:"lockTarget" } ), null, null, null, 
				SkillFrameData.make().initByObj( { type:"hurt_target" } ), null,
				SkillFrameData.make().initByObj( { type:"end" } )];
		}
		
		/**
		 * 开始攻击
		 * @param	vSkillName
		 */
		public function startAttack(vSkillName:String):void
		{
			//trace(vSkillName);
			if (this._isDying || _currentSkillOperator) return;
			
			_currentSkillOperator = new SkillOperator(this, _allSkillDic[vSkillName]);
			//无此技能
			if (!_currentSkillOperator) return;
				
			_attackCube = _currentSkillOperator.getAttackCube();
			for each (var target:AttackableUnit in searchTarget(_currentSkillOperator.maxImpactNum))
			{
				target.receiveAttackNotice(this);
			}
		}
		
		/* INTERFACE com.alex.display.IAttackable */
		
		public function receiveAttackNotice(vAttacker:AttackableUnit):void
		{
			if (this._isDying)
			{
				return;
			}
			if (this._physicsComponent.faceDirection == this._position.compareX(vAttacker.position))
			{
				//攻击者在我面对的方向
				
			}
		
		}
		
		/**
		 * 接收攻击伤害
		 * @param	attacker 攻击者
		 * @param	hurtObj 技能数据
		 */
		public function receiveAttackHurt(attacker:AttackableUnit, frameData:SkillFrameData):void
		{
			if (!this._isDying && frameData.lifeHurt)
			{
				this._attributeComponent.life -= frameData.lifeHurt;
			}
			if (frameData.xImpact)
			{
				this._physicsComponent.forceImpact(attacker.physicsComponent.faceDirection == 1?MoveDirection.X_RIGHT:MoveDirection.X_LEFT, 
					frameData.xImpact, true);
			}
			if (frameData.yImpact)
			{
				if (frameData.yImpact > 0)
					this._physicsComponent.forceImpact(MoveDirection.Y_DOWN, frameData.yImpact, true);
				else
					this._physicsComponent.forceImpact(MoveDirection.Y_UP, frameData.yImpact, true);
			}
			if (frameData.zImpact)
				this._physicsComponent.forceImpact(MoveDirection.Z_TOP, frameData.zImpact, true);
			//this.toDisplayObject().alpha = 0.5;
		}
		
		/**
		 * 查找攻击目标
		 * @param	maxTargetNum
		 * @return
		 */
		private function searchTarget(maxTargetNum:int = 1):Vector.<AttackableUnit>
		{
			var detectList:Array;
			if (this.physicsComponent.faceDirection == -1) {
				detectList = [World.getInstance().getGridItemDic(position.gridX, position.gridY), 
							World.getInstance().getGridItemDic(position.gridX, position.gridY - 1), 
							World.getInstance().getGridItemDic(position.gridX, position.gridY + 1), 
							World.getInstance().getGridItemDic(position.gridX - 1, position.gridY), 
							World.getInstance().getGridItemDic(position.gridX - 1, position.gridY - 1), 
							World.getInstance().getGridItemDic(position.gridX - 1, position.gridY + 1), 
							World.getInstance().getGridItemDic(position.gridX - 2, position.gridY), 
							World.getInstance().getGridItemDic(position.gridX - 2, position.gridY - 1), 
							World.getInstance().getGridItemDic(position.gridX - 2, position.gridY + 1)];
			} else if (this.physicsComponent.faceDirection == 1) {
				detectList = [World.getInstance().getGridItemDic(position.gridX, position.gridY), 
							World.getInstance().getGridItemDic(position.gridX, position.gridY - 1), 
							World.getInstance().getGridItemDic(position.gridX, position.gridY + 1), 
							World.getInstance().getGridItemDic(position.gridX + 1, position.gridY), 
							World.getInstance().getGridItemDic(position.gridX + 1, position.gridY - 1), 
							World.getInstance().getGridItemDic(position.gridX + 1, position.gridY + 1), 
							World.getInstance().getGridItemDic(position.gridX + 2, position.gridY), 
							World.getInstance().getGridItemDic(position.gridX + 2, position.gridY - 1), 
							World.getInstance().getGridItemDic(position.gridX + 2, position.gridY + 1)];
			} else throw "faceDirection error";
			
			var targetList:Vector.<AttackableUnit> = new Vector.<AttackableUnit>();
			for (var i:int = 0; i < detectList.length; i++)
			{
				var gridItemDic:Dictionary = detectList[i] as Dictionary;
				if (!gridItemDic)
				{
					continue;
				}
				for each (var detectTarget:IWorldUnit in gridItemDic)
				{
					if (!detectTarget || detectTarget==this || detectTarget.physicsComponent.physicsType != PhysicsType.SOLID)
						continue;
					
					if (_attackCube.intersects(detectTarget.physicsComponent.toCube()))
					{
						targetList.push(detectTarget);
						if (--maxTargetNum <= 0)
							return targetList;
					}
				}
			}
			return targetList;
		}
		
		/**
		 * 攻击伤害
		 * @param	hurtObj
		 * @param	attackCube
		 */
		public function attackHurt(frameData:SkillFrameData, attackCube:Cube = null):void
		{
			if (_catchingUnit) {
				_catchingUnit.physicsComponent.isBeingCatched = false;
				_catchingUnit = null;
			}
			if (attackCube)
				this._attackCube = attackCube;
			for each (var target:AttackableUnit in searchTarget(_currentSkillOperator.maxImpactNum))
			{
				target.receiveAttackHurt(this, frameData);
			}
		}
		
		/**
		 * 锁定一个目标单位
		 * @param	attackCube
		 */
		public function lockTarget(attackCube:Cube):void {
			if (attackCube) this._attackCube = attackCube;
			_lockingTarget = searchTarget(1)[0];
		}
		
		public function hurtLockingTarget(frameData:SkillFrameData):void {
			if (_lockingTarget) {
				_lockingTarget.receiveAttackHurt(this, frameData);
			}
		}
		
		/**
		 * 作用伤害到正抓举的单位
		 * @param	hurtObj
		 */
		public function attackHurtCatch(frameData:SkillFrameData):void {
			if (_catchingUnit) {
				_catchingUnit.receiveAttackHurt(this, frameData);
				if (frameData.releaseCatch) {
					_catchingUnit.physicsComponent.isBeingCatched = false;
					_catchingUnit = null;
				}
			}
		}
		
		/**
		 * 攻击结束
		 */
		public function attackEnd():void
		{
			this._attackCube = null;
			this._currentSkillOperator = null;
			if (this._catchingUnit) {
				this.releaseCatch();
			}
		}
		
		/**
		 * 抓举单位
		 * @param	frameObj
		 * @param	attackCube
		 * @return
		 */
		public function catchAndFollow(frameData:SkillFrameData, attackCube:Cube):Boolean {
			if (attackCube)
				this._attackCube = attackCube;
			
			if (_catchingUnit == null) {
				_catchingUnit = searchTarget(1).pop();
				if (_catchingUnit) _catchingUnit.physicsComponent.isBeingCatched = true;
			}
			
			if (_catchingUnit) {
				if (frameData.catchZ != 0) 
					_catchingUnit.position.z = _position.z + frameData.catchZ;
				
				if (frameData.catchX != 0)
					_catchingUnit.position.globalX = _position.globalX + frameData.catchX * _physicsComponent.faceDirection;
				
				if (frameData.catchY != 0)
					_catchingUnit.position.globalY = _position.globalY + frameData.catchY; 
					
				this.hurtLockingTarget(frameData);
				return true;
			} 
			return false;
		}
		
		/**
		 * 释放正抓举的单位
		 */
		public function releaseCatch():void {
			if (_catchingUnit) _catchingUnit.physicsComponent.isBeingCatched = false;
			_catchingUnit = null;
		}
		
		override public function release():void
		{
			super.release();
			this._attackCube = null;
			this._currentSkillOperator = null;
			this._rangeOfVision = null;
			this._isDying = false;
			this._allSkillDic = null;
		}
		
		/* INTERFACE com.alex.display.IAttribute */
		
		public function get attributeComponent():AttributeComponent
		{
			return _attributeComponent;
		}
		
		override public function getExecuteOrderList():Array
		{
			return super.getExecuteOrderList().concat(OrderConst.DIED_COMPLETE);
		}
		
		override public function executeOrder(orderName:String, orderParam:Object = null):void
		{
			switch (orderName)
			{
				case OrderConst.LIFE_EMPTY: 
					this._isDying = true;
					AnimationManager.add(new AttributeAnimation(this, {alpha: 0}, 5000, OrderConst.DIED_COMPLETE, null, this));
					break;
				case OrderConst.DIED_COMPLETE: 
					this.release();
					break;
				default: 
					super.executeOrder(orderName, orderParam);
			}
		}
		
		override public function gotoNextFrame(passedTime:Number):void 
		{
			super.gotoNextFrame(passedTime);
			if (this._currentSkillOperator) 
			{
				this._currentSkillOperator.run(passedTime);
			}
		}
	
	}

}