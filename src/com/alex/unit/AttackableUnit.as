package com.alex.unit
{
	import com.alex.ai.BrainOrder;
	import com.alex.ai.ElectronicBrain;
	import com.alex.constant.OrderConst;
	import com.alex.core.animation.AnimationManager;
	import com.alex.core.animation.AttributeAnimation;
	import com.alex.core.commander.Commander;
	import com.alex.core.component.AttributeComponent;
	import com.alex.core.component.MoveDirection;
	import com.alex.core.component.PhysicsType;
	import com.alex.core.component.Position;
	import com.alex.core.unit.IAttributeUnit;
	import com.alex.core.unit.IWorldUnit;
	import com.alex.core.util.Cube;
	import com.alex.core.world.World;
	import com.alex.skill.SkillData;
	import com.alex.skill.SkillShow;
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
		private var _currSkillData:SkillData;
		
		///本单位掌握的技能
		private var _allSkillDic:Dictionary;
		
		private var _attributeComponent:AttributeComponent;
		
		///被抓举的单位
		private var _catchingUnit:AttackableUnit;
		
		private var _lockingTarget:AttackableUnit;
		
		///是否正在死亡
		protected var _isDying:Boolean = false;
		
		///电子大脑
		protected var _brain:ElectronicBrain;
		
		public function AttackableUnit()
		{
			
		}
		
		protected function refreshAttribute(attributeComponent:AttributeComponent):void
		{
			this._attributeComponent = attributeComponent;
			_allSkillDic = new Dictionary();
			_allSkillDic["刺"] = new SkillData({name:"刺"}, [null, null, null, 
				{ type:"hurt", lifeHurt:50, xImpact: -30, zImpact:40 }, null, null, 
				{ type:"hurt", lifeHurt:50, xImpact:100, yImpact:50, zImpact: -40 }, null, null, 
				{ type:"end" } ]);

			_allSkillDic["南剑诀"] =new SkillData({name:"南剑诀"}, [null, null, null, 
				{ type:"distance", distanceId:"d1", speed:40, weight:10, lifeHurt:30, xImpact: 50, zImpact:20 }, null, null, 
				{ type:"distance", distanceId:"d1", speed:30, weight:10, lifeHurt:30, xImpact: -100, zImpact: -40 }, null, null, 
				{ type:"end" } ]);
			
			_allSkillDic["升"] = new SkillData({name:"升"}, [null, null, 
				//{type:"catch", elevation:20}, null,null,
				{ type:"catch", catchZ:50, catchX:50 }, null,
				//{type:"catch", elevation:60, x:40 }, //null,null,
				//{type:"catch", elevation:70, x:30 }, //null,null,
				{ type:"catch", catchZ:80, catchX:0 }, null,
				//{type:"catch", elevation:70, x:-40 }, //null,null,
				{ type:"catch", catchZ:50, catchX: -50 }, null,
				//{type:"catch", elevation:30, x:-80 },  //null,null,
				{ type:"catch", catchZ:0, catchX: -100 }, null,
				//{type:"catch", elevation:30, x: -80 },  //null,null,
				{ type:"catch", catchZ:50, catchX: -50 }, null,
				//{type:"catch", elevation:70, x: -40 }, //null,null,
				{ type:"catch", catchZ:80, catchX:0 }, null,
				{ type:"hurt_catch", lifeHurt:50, xImpact:100, zImpact: -40, releaseCatch:true }, null, 
				{ type:"end" } ]);
				
			_allSkillDic["穿心"] = new SkillData( { name:"穿心" }, [
				{ type:"lockTarget" }, null, null, null, 
				{ type:"hurt_target" }, null,
				{ type:"end" } ]);
			
			_brain = ElectronicBrain.make();
			_brain.init(this, 0);
			_physicsComponent.setBrain(_brain);
		}
		
		/**
		 * 开始攻击
		 * @param	vSkillName
		 */
		public function startAttack(vSkillName:String):void
		{
			//trace(vSkillName);
			if (this._isDying || _currSkillData) return;
			
			_currSkillData = _allSkillDic[vSkillName] as SkillData;
			
			//无此技能
			if (!_currSkillData) return;
			if (!_attributeComponent.satisfy(_currSkillData.needLife, _currSkillData.needEnergy)) {
				//需要消耗不足
				_currSkillData = null;
			}
			//释放失败
			if (!_currSkillData) return;
			
			_attackCube = getAttackCube();
			for each (var target:AttackableUnit in searchTarget(_currSkillData.maxImpactNum))
			{
				target.receiveAttackNotice(this);
			}
		}
		
		/* INTERFACE com.alex.display.IAttackable */
		
		public function receiveAttackNotice(vAttacker:AttackableUnit):void
		{
			if (this._isDying) return;
			if (this._physicsComponent.faceDirection == this._position.compareX(vAttacker.position))
			{
				//攻击者在我面对的方向
				
			}
			_brain.executeOrder(BrainOrder.BE_ATTACKED);
		}
		
		/**
		 * 接收攻击伤害
		 * @param	attacker 攻击者
		 * @param	hurtObj 技能数据
		 */
		public function receiveAttackHurt(attacker:AttackableUnit, frameData:Object):void
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
			
			//_brain.executeOrder(BrainOrder.STOP);
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
		public function attackHurt(frameData:Object, attackCube:Cube = null):void
		{
			if (_catchingUnit) {
				_catchingUnit.physicsComponent.isBeingCatched = false;
				_catchingUnit = null;
			}
			if (attackCube) this._attackCube = attackCube;
			
			for each (var target:AttackableUnit in searchTarget(_currSkillData.maxImpactNum))
			{
				_attributeComponent.consume(int(frameData.needLife), int(frameData.needEnergy));
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
		
		public function hurtLockingTarget(frameData:Object):void {
			if (_lockingTarget) {
				_lockingTarget.receiveAttackHurt(this, frameData);
			}
		}
		
		/**
		 * 作用伤害到正抓举的单位
		 * @param	hurtObj
		 */
		public function attackHurtCatch(frameData:Object):void {
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
			if (this._currSkillData) {
				this._currSkillData.refresh();
				this._currSkillData = null;
			}
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
		public function catchAndFollow(frameData:Object, attackCube:Cube):Boolean {
			if (attackCube)
				this._attackCube = attackCube;
			
			if (_catchingUnit == null) {
				_catchingUnit = searchTarget(1).pop();
				if (_catchingUnit) _catchingUnit.physicsComponent.isBeingCatched = true;
			}
			
			if (_catchingUnit) {
				if (frameData.catchZ is Number) 
					_catchingUnit.position.z = _position.z + frameData.catchZ;
				
				if (frameData.catchX is Number) 
					_catchingUnit.position.globalX = _position.globalX + frameData.catchX * _physicsComponent.faceDirection;
				
				if (frameData.catchY is Number) 
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
			this._currSkillData = null;
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
				case "brain_order_start_move":
					physicsComponent.startMove(int(orderParam));
					break;
				case "brain_order_stop_move":
					physicsComponent.stopMove(int(orderParam));
					break;
				case "brain_order_force_stop_move":
					physicsComponent.forceStopMove();
					break;
				case "brain_order_use_skill":
					startAttack(String(orderParam));
					break;
				case "brain_order_move_to_pointed_x":
					//physicsComponent.startPlanMove(
					break;
				default: 
					super.executeOrder(orderName, orderParam);
			}
		}
		
		override public function gotoNextFrame(passedTime:Number):void 
		{
			super.gotoNextFrame(passedTime);
			if (this._currSkillData) 
			{
				var frameData:Object = _currSkillData.readFrameData();
				if (frameData)
				{
					switch(frameData.type)
					{
						case "hurt"://普通伤害
							this.attackHurt(frameData, getAttackCube());
							break;
						case "distance"://释放远程招式
							if (frameData.distanceId == null) break;
							var sPosition:Position = this.position.copy();
							var skill:SkillShow = SkillShow.make(frameData.distanceId, this, sPosition, 
								this.physicsComponent.faceDirection == 1 ? MoveDirection.X_RIGHT : MoveDirection.X_LEFT, frameData);
							Commander.sendOrder(World.ADD_ITEM_TO_WORLD, skill);
							break;
						case "lockTarget"://锁定目标
							this.lockTarget(getAttackCube());
							break;
						case "hurt_target"://攻击锁定目标
							this.hurtLockingTarget(frameData);
							break;
						case "catch"://抓举单位
							var catched:Boolean = this.catchAndFollow(frameData, getAttackCube());
							if (!catched) this.attackEnd();
							break;
						case "hurt_catch"://伤害作用抓举单位
							this.attackHurtCatch(frameData);
							break;
						case "release_catch"://释放抓举单位
							this.releaseCatch();
							break;
						case "end"://攻击结束
							this.attackEnd();
							return;
					}
					if (frameData.releaseCatch) {
						this.releaseCatch();
					}
				}
			}
		}
		
		public function getAttackCube():Cube
		{
			if (!_attackCube) _attackCube = new Cube();
			if (physicsComponent.faceDirection == 1) {
				_attackCube.refresh(position.globalX + 40, position.globalY - 30, 
					position.z, 80, 60, 80);
			} else {
				_attackCube.refresh(position.globalX -80- 40, position.globalY - 30, 
					position.z, 80, 60, 80);
			}
			return _attackCube;
		}
		
		override public function collide(targetUnit:IWorldUnit, moveDir:int):void 
		{
			super.collide(targetUnit, moveDir);
			if (_brain) {
				_brain.executeOrder(BrainOrder.START);
			}
		}
	
	}

}