package com.alex.ai 
{
	import com.alex.core.commander.Commander;
	import com.alex.core.commander.IOrderExecutor;
	import com.alex.core.component.MoveDirection;
	import com.alex.core.pool.InstancePool;
	import com.alex.core.pool.IRecycle;
	import com.alex.core.unit.IWorldUnit;
	import com.alex.core.util.IdMachine;
	/**
	 * 电子大脑，用以思考，指挥操作
	 * @author alex
	 */
	public class ElectronicBrain implements IOrderExecutor, IRecycle
	{
		
		private var _id:String;
		
		public function ElectronicBrain() 
		{
			
		}
		
		public static function make():ElectronicBrain {
			return InstancePool.getInstance(ElectronicBrain) as ElectronicBrain;
		}
		
		public function init(body:IWorldUnit, type:int):void {
			_id = IdMachine.getId(ElectronicBrain);
			_body = body;
			Commander.registerExecutor(this);
		}
		
		private var _body:IWorldUnit;
		
		private var _purpose:int = 0;
		private var _currentBehaviour:int = 0;
		private var _target:IWorldUnit;
		
		public function run(passedTime:Number):void {
			//switch(_currentBehaviour) {
				//case BehaviourType.STAND:
					//
					//break;
				//case BehaviourType.CLOSE_TO:
					//if (_target) {
						//closeToTarget();
					//} else {
						//_body.executeOrder("brain_order_search_target");
						//_currentBehaviour = BehaviourType.STAND;
					//}
					//break;
			//}
			switch(_purpose) {
				case PurposeType.CLEAR:
					switch(_currentBehaviour) {
						case BehaviourType.ATTACK:
							
							break;
						case BehaviourType.STAND:
							
							break;
					}
					break;
				case PurposeType.SAUNTER:
					
					break;
			}
		}
		
		/**
		 * 设定目标单位
		 * @param	target
		 */
		public function gotTarget(target:IWorldUnit):void {
			_target = target;
		}
		
		/**
		 * 靠近目标
		 */
		private function closeToTarget():void {
			_body.executeOrder(BrainOrder.START_MOVE, MoveDirection.X_RIGHT);
		}
		
		/**
		 * 分析目标状态
		 */
		private function analyseTarget():void {
			if (_target == null) return;
			var status:Object = { };
			if (_target.physicsComponent.velocityX == 0) {
				status.moveX = false;
			} else {
				status.moveX = true;
				if (_body.position.globalX > _target.position.globalX && _target.physicsComponent.velocityX > 0)
				{
					status.closeMe = true;
					status.xDir = "right";
				} else if (_body.position.globalX < _target.position.globalX && _target.physicsComponent.velocityX < 0) 
				{
					status.closeMe = true;
					status.xDir = "left";
				} else status.closeMe = false;
			}
			if (_target.physicsComponent.velocityY == 0) {
				status.moveY = false;
				if (status.moveX == false) {
					status.closeMe = false;
				}
			} else {
				status.moveY = true;
				if (_body.position.globalX > _target.position.globalX && _target.physicsComponent.velocityX > 0)					{
					status.closeMe = true;
				} else if (_body.position.globalX < _target.position.globalX && _target.physicsComponent.velocityX < 0) {
					status.closeMe = true;
				} else status.closeMe = false;
				//if (status.closeMe) {
					//
				//}
				
			}
		}
		
		/* INTERFACE com.alex.core.commander.IOrderExecutor */
		
		public function getExecuteOrderList():Array 
		{
			return [
					//BrainOrder.GOT_TARGET,
					//BrainOrder.BE_ATTACKED
				];
		}
		
		
		public function executeOrder(orderName:String, orderParam:Object = null):void 
		{
			switch(orderName) {
				case BrainOrder.GOT_TARGET:
					gotTarget(IWorldUnit(orderParam));
					break;
				case BrainOrder.BE_ATTACKED:
					
					break;
			}
		}
		
		public function getExecutorId():String 
		{
			return _id;
		}
		
		/* INTERFACE com.alex.core.pool.IRecycle */
		
		public function release():void 
		{
			_id = null;
			_body = null;
			_purpose = 0;
			_currentBehaviour = 0;
			Commander.cancelExecutor(this);
			_isRelease = true;
		}
		
		private var _isRelease:Boolean = false;
		public function isRelease():Boolean 
		{
			return _isRelease;
		}
		
		/**
		 * 攻击目标，分析目标当前各种状态，根据相应的反应做出相应的动作。
		 * 主动状态：无，行走，攻击，防守
		 * 身体状态：正常，僵直，倒地
		 * 位置状态：地面，空中，站立其它单位之上
		 */
		private function attackTarget():void {
			
		}
		
	}
	
	/**
	 * 行为
	 */
	class Behaviour {
		public var type:int = 0;
		public var target:IWorldUnit;
		
		
	}
	
	class BehaviourType {
		public static const STAND:int = 0;
		public static const CLOSE_TO:int = 1;
		public static const DEFENCE:int = 2;
		public static const ATTACK:int = 3;
	}
	
	class PurposeType {
		
		///等待命令
		public static const WAIT:int = 0;
		///闲逛
		public static const SAUNTER:int = 1;
		///保护，守卫
		public static const PROTECT:int = 2;
		///清除敌人
		public static const CLEAR:int = 3;
		///逃跑
		public static const ESCAPE:int = 4;
		
	}
	
	/**
	 * 大脑命令常量
	 */
	class BrainOrder {
		
		public static const START_MOVE:String = "brain_order_start_move";
		public static const STOP_MOVE:String = "brain_order_stop_move";
		public static const FORCE_STOP_MOVE:String = "brain_order_force_stop_move";
		public static const SEARCH_TARGET:String = "brain_order_search_target";
		public static const GOT_TARGET:String = "brain_order_got_target";
		public static const USE_SKILL:String = "brain_order_use_skill";
		public static const BE_ATTACKED:String = "brain_order_be_attacked";
	}
}

