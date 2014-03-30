package com.alex.skill
{
	import com.alex.constant.OrderConst;
	import com.alex.core.commander.Commander;
	import com.alex.core.component.MoveDirection;
	import com.alex.core.component.PhysicsComponent;
	import com.alex.core.util.Cube;
	import com.alex.core.component.Position;
	import com.alex.unit.AttackableUnit;
	import flash.geom.Point;
	
	/**
	 * 技能运作类
	 * @author alex
	 */
	public class SkillOperator
	{
		
		public var name:String;
		///是否单人伤害
		public var isSingleHurt:Boolean = true;
		///伤害范围，以格子行列数表示
		public var rangeOfHurt:Point;
		
		///最大作用目标个数
		public var maxImpactNum:int = 1;
		
		private var _currentFrame:int = 0;
		private var _maxFrame:int = 10;
		private var _frameDataList:Vector.<SkillFrameData>;
		private var _attackableUnit:AttackableUnit;
		
		
		private var _fps:int = 60;
		private var _fTime:Number = 0;
		private var _tempTime:Number = 0;
		
		public function SkillOperator(attackableUnit:AttackableUnit, frameData:Vector.<SkillFrameData> = null)
		{
			_fps = 16;
			_fTime = 1000 / _fps;
			_attackableUnit = attackableUnit;
			if (frameData)
				_frameDataList = frameData;
			else
				_frameDataList = new <SkillFrameData>[SkillFrameData.make().initByObj({type:"end"})];
		}
		
		public function run(passedTime:Number):void {
			_tempTime += passedTime;
			if (_tempTime >= _fTime)
			{
				_tempTime -= _fTime;
				var frameData:SkillFrameData = _frameDataList[_currentFrame];
				if (frameData)
				{
					switch(frameData.type)
					{
						case "hurt"://普通伤害
							_attackableUnit.attackHurt(frameData, getAttackCube());
							break;
						case "distance"://释放远程招式
							if (frameData.distanceId == null) break;
							var sPosition:Position = _attackableUnit.position.copy();
							var skill:SkillShow = SkillShow.make(frameData.distanceId, _attackableUnit, sPosition, 
								_attackableUnit.physicsComponent.faceDirection == 1 ? MoveDirection.X_RIGHT : MoveDirection.X_LEFT, frameData);
							Commander.sendOrder(OrderConst.ADD_ITEM_TO_WORLD_MAP, skill);
							break;
						case "lockTarget"://锁定目标
							_attackableUnit.lockTarget(getAttackCube());
							break;
						case "hurt_target"://攻击锁定目标
							_attackableUnit.hurtLockingTarget(frameData);
							break;
						case "catch"://抓举单位
							var catched:Boolean = _attackableUnit.catchAndFollow(frameData, getAttackCube());
							if (!catched) _attackableUnit.attackEnd();
							break;
						case "hurt_catch"://伤害作用抓举单位
							_attackableUnit.attackHurtCatch(frameData);
							break;
						case "release_catch"://释放抓举单位
							_attackableUnit.releaseCatch();
							break;
						case "end"://攻击结束
							_attackableUnit.attackEnd();
							return;
					}
					if (frameData.releaseCatch) {
						_attackableUnit.releaseCatch();
					}
				}
				_currentFrame++;
				//if (_currentFrame >= _maxFrame)
					//_attackableUnit.attackEnd();
			}
		}
		
		private var _attackCube:Cube;
		public function getAttackCube():Cube
		{
			if (!_attackCube) _attackCube = new Cube();
			var ackPos:Position = _attackableUnit.position;
			var phyc:PhysicsComponent = _attackableUnit.physicsComponent;
			if (phyc.faceDirection == 1) {
				_attackCube.refresh(ackPos.globalX + 40, ackPos.globalY - 30, 
				ackPos.z, 80, 60, 80);
			} else {
				_attackCube.refresh(ackPos.globalX -80- 40, ackPos.globalY - 30, 
				ackPos.z, 80, 60, 80);
			}
			return _attackCube;
		}
	
	}

}