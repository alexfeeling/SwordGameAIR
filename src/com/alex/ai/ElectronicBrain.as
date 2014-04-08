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
			_memory["phase"] = "thinking";
			_memory["purpose"] = PurposeType.CLEAR;
			_memory["behaviour"] = BehaviourType.CLOSE_TO;
			Commander.registerExecutor(this);
		}
		
		private var _body:IWorldUnit;
		
		///智力等级
		private var _levelOfIntelligence:int = 0;
		///人生目的
		private var _purpose:int = 0;
		///当前行为
		private var _behaviour:int = 0;
		///当前针对目标单位
		private var _target:IWorldUnit;
		
		public function run(passedTime:Number):void
		{
			if (_memory["phase"] == "nothing" || _memory["phase"] == "doing") return;
			switch (_memory["purpose"])
			{
				case PurposeType.CLEAR: //get target->close to target->(attack target || defense target attack)
					//清除敌人
					//switch (_behaviour)
					switch (_memory["behaviour"])
					{
						case BehaviourType.CLOSE_TO:
							if (!_body.physicsComponent.isStandOnSomething()) break;
							targetStatus = analyseTarget();
							if (targetStatus == null) break;
							//先判断X轴位置有没相交，有相交就先X轴反方向跑开
							//X轴位置不相交后，判断Y轴距离是否够近，不够近就Y轴接近
							//X轴位置不相交，Y轴够接近后判断X轴方向是否够近，不够则X轴接近
							//X轴位置够接近，Y轴位置够接近后靠近完成，准备下一步操作
							if (targetStatus.distanceFromMe < 0) {//X轴位置相交
								_body.physicsComponent.stopMove(MoveDirection.Y_DOWN);
								_body.physicsComponent.stopMove(MoveDirection.Y_UP);
								//要反方向移动
								if (targetStatus.dirFromMeX == "left" && targetStatus.moveDirX != "right") {
									_body.physicsComponent.startPlanMove(MoveDirection.X_RIGHT , targetStatus.distanceFromMe);
								} else if (targetStatus.moveDirX != "left") {
									_body.physicsComponent.startPlanMove(MoveDirection.X_LEFT, targetStatus.distanceFromMe);
								}
							} else {
								if (targetStatus.distanceY > 20) {//Y轴接近
									if (targetStatus.dirFromMeY == "up" && targetStatus.moveDirY != "up") {
										_body.physicsComponent.startPlanMove(MoveDirection.Y_UP, targetStatus.distanceY);
									} else if (targetStatus.moveDirX != "down") {
										_body.physicsComponent.startPlanMove(MoveDirection.Y_DOWN, targetStatus.distanceY);
									}
								} else if (targetStatus.distanceFromMe > targetStatus.miniAttackDistance) {
									//X轴接近
									if (targetStatus.dirFromMeX == "left" && targetStatus.moveDirX != "left") {
										_body.physicsComponent.startPlanMove(MoveDirection.X_LEFT , targetStatus.distanceFromMe);
									} else if (targetStatus.moveDirX != "right") {
										_body.physicsComponent.startPlanMove(MoveDirection.X_RIGHT, targetStatus.distanceFromMe);
									}
								} else {//靠近完成，可以揍他了
									_memory["behaviour"] = BehaviourType.ATTACK;
									_memory["phase"] = "thinking";
									//run(passedTime);
									break;
								}
							}
							_memory["phase"] = "doing";
							break;
						case BehaviourType.ATTACK: 
							trace("ready attack");
							var targetStatus:Object = analyseTarget();
							if (targetStatus.fightStatus == 0)
							{ //stand
								attackStandTarget(targetStatus);
							}
							else if (targetStatus.fightStatus == 1)
							{ //defence
								attackDefenceTarget(targetStatus);
							}
							else if (targetStatus.fightStatus == 2)
							{ //attack
								defence(targetStatus);
							}
							break;
						case BehaviourType.STAND:
							
							break;
					}
					break;
				case PurposeType.FREE:
					
					break;
			}
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
		 * moveDirX
		 * moveDirY
		 * dirFromMeX
		 * dirFromMeY
		 * xClosingMe
		 * yClosingMe
		 * closeingMe
		 * distanceFromMe
		 * distanceY
		 * miniAttackDistance
		 */
		private function analyseTarget():Object
		{
			if (_target == null)
				return null;
			var targetStatus:Object = { closingMe: false, moveDirX: "none", moveDirY: "none", xClosingMe: false, yClosingMe: false, closeingMe: false };
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
			
			targetStatus.distanceFromMe = Math.abs(_target.position.globalX - _body.position.globalX) - ((_target.physicsComponent.width + _body.physicsComponent.width) >> 1);
			targetStatus.distanceY = Math.abs(_target.position.globalY - _body.position.globalY);
			//最大攻击距离
			targetStatus.miniAttackDistance = 50;
			
			return targetStatus;
		}
		
		/* INTERFACE com.alex.core.commander.IOrderExecutor */
		
		public function getExecuteOrderList():Array
		{
			return [
				];
		}
		
		private var _phase:int = 0; //0:nothing, 1:thinking, 2:doing
		
		public function executeOrder(orderName:String, orderParam:Object = null):void
		{
			switch (orderName)
			{
				case BrainOrder.START:
					_memory["phase"] = "thinking";
					break;
				case BrainOrder.STOP:
					_memory["phase"] = "nothing";
					break;
				case BrainOrder.GOT_TARGET: 
					gotTarget(IWorldUnit(orderParam));
					break;
				case BrainOrder.BE_ATTACKED:
					_memory["phase"] = "nothing";
					break;
				case "brain_order_life_update": //气血更新
					
					break;
				case "brain_order_energy_update": //内力更新
					
					break;
				case BrainOrder.PLAN_MOVE_X_FINISH:
					_memory["phase"] = "thinking"
					break;
				case BrainOrder.PLAN_MOVE_Y_FINISH:
					_memory["phase"] = "thinking"
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
			_behaviour = 0;
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
			
			if (canUseSkill == null) return;
			
			var bestSuitSkill:SkillData;
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

/**
 * 行为
 */
class Behaviour
{
	public var purpose:int = 0;
	///类型 
	public var type:int = 0;
	//public var target:IWorldUnit;
	///进度 //1.get target->2.close to target->(3.attack target <-> 4.defense target attack)
	public var progress:int;
	
	public var targetStatus:Object;

}

/**
 * 性格
 */
class DispositionType
{
	
	///勇敢
	public static const BRAVE:int = 0;
	
	///怯弱
	public static const TIMID:int = 1;

}

