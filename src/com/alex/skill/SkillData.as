package com.alex.skill
{
	import com.alex.constant.OrderConst;
	import com.alex.core.commander.Commander;
	import com.alex.core.component.MoveDirection;
	import com.alex.core.component.PhysicsComponent;
	import com.alex.core.util.Cube;
	import com.alex.core.component.Position;
	import com.alex.core.world.World;
	import com.alex.unit.AttackableUnit;
	import flash.geom.Point;
	
	/**
	 * 技能运作类
	 * @author alex
	 */
	public class SkillData
	{
		
		public var name:String;
		///是否单人伤害
		public var isSingleHurt:Boolean = true;
		///伤害范围，以格子行列数表示
		public var rangeOfHurt:Point;
		
		///最大作用目标个数
		public var maxImpactNum:int = 1;
		public var descript:String;
		public var needLife:int = 0;
		public var needEnergy:int = 0;
		
		private var _currentFrame:int = 0;
		private var _maxFrame:int = 10;
		private var _frameDataList:Array;
		
		public function SkillData(skillData:Object, frameDataList:Array)
		{
			if (skillData) {
				if (skillData.name is String) name = skillData.name as String;
				if (skillData.descript is String) descript = skillData.descript as String;
				if (skillData.needLife is Number) needLife = int(skillData.needLife);
				if (skillData.needEnergy is Number) needEnergy = int(skillData.needEnergy);
				if (skillData.maxImpactNum is Number) maxImpactNum = int(skillData.maxImpactNum);
			}
			if (frameDataList) {
				_frameDataList = frameDataList;
			} else {
				_frameDataList = [ { type:"end" } ];
			}
			_currentFrame = 0;
			_maxFrame = _frameDataList.length;
		}
		
		public function refresh():void {
			this._currentFrame = 0;
		}
		
		public function readFrameData():Object {
			return _frameDataList[_currentFrame++];
		}
		
	}

}