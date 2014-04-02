package com.alex.ai 
{
	import com.alex.core.commander.Commander;
	import com.alex.core.commander.IOrderExecutor;
	import com.alex.core.component.MoveDirection;
	import com.alex.core.pool.InstancePool;
	import com.alex.core.pool.IRecycle;
	import com.alex.core.unit.IWorldUnit;
	import com.alex.core.util.IdMachine;
	import flash.utils.Dictionary;
	/**
	 * 电子大脑，用以思考，指挥操作
	 * @author alex
	 */
	public class ElectronicBrain implements IOrderExecutor, IRecycle
	{
		
		private var _id:String;
		private var _memory:Dictionary;
		
		public function ElectronicBrain() 
		{
			
		}
		
		public static function make():ElectronicBrain {
			return InstancePool.getInstance(ElectronicBrain) as ElectronicBrain;
		}
		
		public function init(body:IWorldUnit, type:int):void {
			_id = IdMachine.getId(ElectronicBrain);
			_body = body;
			_memory = new Dictionary();
			Commander.registerExecutor(this);
		}
		
		private var _body:IWorldUnit;
		
		///智力等级
		private var _levelOfIntelligence:int = 0;
		///人生目的
		private var _purpose:int = 0;
		///当前行为
		private var _currentBehaviour:int = 0;
		///当前针对目标单位
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
				case PurposeType.CLEAR://get target->close to target->(attack target || defense target attack)
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
			var targetStatus:Object = { closingMe:false, moveDirX:"none", moveDirY:"none", 
										xClosingMe:false, yClosingMe:false, closeingMe:false };
			if (_target.physicsComponent.velocityX > 0) targetStatus.moveDirX = "left";
			else if (_target.physicsComponent.velocityX < 0) targetStatus.moveDirX = "right";
			
			if (_target.physicsComponent.velocityY > 0) targetStatus.moveDirY = "up";
			else if (_target.physicsComponent.velocityY < 0) targetStatus.moveDirY = "down";
			
			if (_target.position.globalX < _body.position.globalX) targetStatus.dirFromMeX = "left";
			else if (_target.position.globalX > _body.position.globalX) targetStatus.dirFromMeX = "right";
			
			if (_target.position.globalY < _body.position.globalY) targetStatus.dirFromMeY = "up";
			else if (_target.position.globalY > _body.position.globalY) targetStatus.dirFromMeY = "down";
			
			targetStatus.xClosingMe = (targetStatus.dirFromMeX == "left" && targetStatus.moveDirX == "right") ||
									(targetStatus.dirFromMeX == "right" && targetStatus.moveDirX == "left");
			targetStatus.yClosingMe = (targetStatus.dirFromMeY == "up" && targetStatus.moveDirY == "down") ||
									(targetStatus.dirFromMeY == "down" && targetStatus.moveDirY == "up");
			targetStatus.closeingMe = (targetStatus.xClosingMe && (targetStatus.yClosingMe || targetStatus.moveDirX == "none")) ||
									(targetStatus.yClosingMe && targetStatus.moveDirY == "none");
			
			//_target
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
			_memory = null;
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
		public var purpose:int = 0;
		///类型 
		public var type:int = 0;
		public var target:IWorldUnit;
		///进度 //1.get target->2.close to target->(3.attack target <-> 4.defense target attack)
		public var progress:int;
		
		public var targetStatus:Object;
		
	}
	
	class BehaviourType {
		public static const STAND:int = 0;
		public static const CLOSE_TO:int = 1;
		public static const DEFENCE:int = 2;
		public static const ATTACK:int = 3;
	}
	
	/**
	 * 人生的所有目的
	 */
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
	 * 性格
	 */
	class DispositionType {
		
		///勇敢
		public static const BRAVE:int = 0;
		
		///怯弱
		public static const TIMID:int = 1;
		
	}
	
}


