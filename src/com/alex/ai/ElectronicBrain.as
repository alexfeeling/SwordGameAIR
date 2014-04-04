package com.alex.ai
{
	import com.alex.core.commander.Commander;
	import com.alex.core.commander.IOrderExecutor;
	import com.alex.core.component.MoveDirection;
	import com.alex.core.pool.InstancePool;
	import com.alex.core.pool.IRecycle;
	import com.alex.core.unit.IWorldUnit;
	import com.alex.core.util.IdMachine;
	import com.alex.skill.SkillData;
	import flash.utils.Dictionary;
	
	/**
	 * 电子大脑，用以思考，指挥操作
	 * @author alex
	 */
	public class ElectronicBrain implements IOrderExecutor, IRecycle
	{
		
		private var _id:String;
		
		///记忆数据
		private var _memory:Dictionary;
		
		public function ElectronicBrain()
		{
		
		}
		
		public static function make():ElectronicBrain
		{
			return InstancePool.getInstance(ElectronicBrain) as ElectronicBrain;
		}
		
		public function init(body:IWorldUnit, type:int):void
		{
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
		
		public function run(passedTime:Number):void
		{
			//if (_memory["phase"] == "nothing") return;
			//if (_memory["phase"] == "thinking")
			//switch (_memory["purpose"])
			//{
				//case PurposeType.CLEAR: //get target->close to target->(attack target || defense target attack)
					//清除敌人
					//switch (_currentBehaviour)
					//switch (_memory["currentBehaviour"])
					//{
						//case BehaviourType.ATTACK: 
							//var targetStatus:Object = analyseTarget();
							//if (targetStatus.fightStatus == 0)
							//{ //stand
								//attackStandTarget(targetStatus);
							//}
							//else if (targetStatus.fightStatus == 1)
							//{ //defence
								//attackDefenceTarget(targetStatus);
							//}
							//else if (targetStatus.fightStatus == 2)
							//{ //attack
								//defence(targetStatus);
							//}
							//break;
						//case BehaviourType.STAND:
							//
							//break;
					//}
					//break;
				//case PurposeType.FREE:
					//
					//break;
			//}
		}
		
		/**
		 * 设定目标单位
		 * @param	target
		 */
		public function gotTarget(target:IWorldUnit):void
		{
			_target = target;
		}
		
		/**
		 * 靠近目标
		 */
		private function closeToTarget():void
		{
			_body.executeOrder(BrainOrder.START_MOVE, MoveDirection.X_RIGHT);
		}
		
		/**
		 * 分析目标状态
		 */
		private function analyseTarget():Object
		{
			if (_target == null)
				return null;
			var targetStatus:Object = {closingMe: false, moveDirX: "none", moveDirY: "none", xClosingMe: false, yClosingMe: false, closeingMe: false};
			if (_target.physicsComponent.velocityX > 0)
				targetStatus.moveDirX = "left";
			else if (_target.physicsComponent.velocityX < 0)
				targetStatus.moveDirX = "right";
			
			if (_target.physicsComponent.velocityY > 0)
				targetStatus.moveDirY = "up";
			else if (_target.physicsComponent.velocityY < 0)
				targetStatus.moveDirY = "down";
			
			if (_target.position.globalX < _body.position.globalX)
				targetStatus.dirFromMeX = "left";
			else if (_target.position.globalX > _body.position.globalX)
				targetStatus.dirFromMeX = "right";
			
			if (_target.position.globalY < _body.position.globalY)
				targetStatus.dirFromMeY = "up";
			else if (_target.position.globalY > _body.position.globalY)
				targetStatus.dirFromMeY = "down";
			
			targetStatus.xClosingMe = (targetStatus.dirFromMeX == "left" && targetStatus.moveDirX == "right") || (targetStatus.dirFromMeX == "right" && targetStatus.moveDirX == "left");
			targetStatus.yClosingMe = (targetStatus.dirFromMeY == "up" && targetStatus.moveDirY == "down") || (targetStatus.dirFromMeY == "down" && targetStatus.moveDirY == "up");
			targetStatus.closeingMe = (targetStatus.xClosingMe && (targetStatus.yClosingMe || targetStatus.moveDirX == "none")) || (targetStatus.yClosingMe && targetStatus.moveDirY == "none");
			
			targetStatus.distanceFromMe = Math.abs(_target.position.globalX - _body.position.globalX);
			return targetStatus;
		}
		
		/* INTERFACE com.alex.core.commander.IOrderExecutor */
		
		public function getExecuteOrderList():Array
		{
			return [
				//BrainOrder.GOT_TARGET,
				//BrainOrder.BE_ATTACKED
				];
		}
		
		private var _phase:int = 0; //0:nothing, 1:thinking, 2:doing
		
		public function executeOrder(orderName:String, orderParam:Object = null):void
		{
			switch (orderName)
			{
				case BrainOrder.GOT_TARGET: 
					gotTarget(IWorldUnit(orderParam));
					break;
				case BrainOrder.BE_ATTACKED:
					
					break;
				case "brain_order_life_update": //气血更新
					
					break;
				case "brain_order_energy_update": //内力更新
					
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
		private function attackStandTarget(targetStatus:Object):void
		{
			var canUseSkill:Array = _memory["canUseSkill"] as Array;
			var bestSuitSkill:Object;
			for (var i:int = 0; i < canUseSkill.length; i++)
			{
				//找出当前最适合释放技能
			}
			if (bestSuitSkill) {
				_body.executeOrder("brain_order_use_skill", bestSuitSkill);
			}
		}
		
		private var _allSkillDic:Dictionary;
		
		/**
		 * 攻击正在防御的敌人，找出最适合的攻击招式，发送命令给body执行
		 * @param	targetStatus
		 */
		private function attackDefenceTarget(targetStatus:Object):void
		{
			var canUseSkill:Array = _memory["canUseSkill"] as Array;
			//for each(var skill:Object in _allSkillDic) {
			//if (skill.rangeOfHurt.x >= targetStatus.distanceFramMe) {
			//canUseSkill.push(skill);
			//}
			//}
			if (canUseSkill == null)
				return;
			var bestSuitSkill:Object;
			for (var i:int = 0; i < canUseSkill.length; i++)
			{
				
				//找出当前最适合释放技能
			}
			if (bestSuitSkill)
				_body.executeOrder("brain_order_use_skill", bestSuitSkill);
		}
		
		private function defence(targetStatus:Object):void
		{
		
		}
	
	}

}
//
///**
 //* 行为
 //*/
//class Behaviour
//{
	//public var purpose:int = 0;
	///类型 
	//public var type:int = 0;
	//public var target:IWorldUnit;
	///进度 //1.get target->2.close to target->(3.attack target <-> 4.defense target attack)
	//public var progress:int;
	//
	//public var targetStatus:Object;
//
//}
//
//class BehaviourType
//{
	//public static const STAND:int = 0;
	//public static const CLOSE_TO:int = 1;
	//public static const DEFENCE:int = 2;
	//public static const ATTACK:int = 3;
//}
//
///**
 //* 人生的所有目的
 //*/
//class PurposeType
//{
	//
	///我一直在等候着一个命令
	//public static const WAIT:int = 0;
	///我要自由自在的活在这个世界里
	//public static const FREE:int = 1;
	///保护某人某物，守卫某个地方
	//public static const PROTECT:int = 2;
	///我生来的目的就是为了清除敌人
	//public static const CLEAR:int = 3;
	///我只愿能苟活在这个尘世中
	//public static const SURVIVAL:int = 4;
//
//}
//
///**
 //* 性格
 //*/
//class DispositionType
//{
	//
	///勇敢
	//public static const BRAVE:int = 0;
	//
	///怯弱
	//public static const TIMID:int = 1;
//
//}

