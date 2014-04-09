package alex.skill 
{
	import alex.core.pool.InstancePool;
	import alex.core.pool.IRecycle;
	/**
	 * 技能帧数据
	 * @author alexfeeling
	 */
	public class SkillFrameData implements IRecycle
	{
	
		///类型
		public var type:String;
		
		/**
		 * 伤害类型：0锐器，1钝器，2拳脚，3内功
		 */
		public var hurtType:int = 0;
		
		public var distanceId:String;
		public var speed:int=0;
		public var weight:int=0;
		
		public var needLife:int = 0;
		public var needEnergy:int = 0;
		
		public var lifeHurt:int=0;
		public var xImpact:int=0;
		public var yImpact:int=0;
		public var zImpact:int=0;
		
		public var catchZ:int = 0;
		public var catchX:int = 0;
		public var catchY:int = 0;
		
		public var releaseCatch:Boolean = false;
		
		
		public function SkillFrameData() 
		{
			
		}
		
		public function init():SkillFrameData {
			this._isRelease = false;
			
			return this;
		}
		
		public function initByObj(dataObj:Object):SkillFrameData {
			if (dataObj.type is String) type = String(dataObj.type);
			if (dataObj.hurtType is int) hurtType = int(dataObj.hurtType);
			if (dataObj.distanceId is String) distanceId = String(dataObj.distanceId);
			if (dataObj.speed is int) speed = int(dataObj.speed);
			if (dataObj.weight is int) weight = int(dataObj.weight);
			if (dataObj.lifeHurt is int) lifeHurt = int(dataObj.lifeHurt);
			if (dataObj.xImpact is int) xImpact = int(dataObj.xImpact);
			if (dataObj.yImpact is int) yImpact = int(dataObj.yImpact);
			if (dataObj.zImpact is int) zImpact = int(dataObj.zImpact);
			if (dataObj.catchZ is int) catchZ = int(dataObj.catchZ);
			if (dataObj.catchX is int) catchX = int(dataObj.catchX);
			if (dataObj.catchY is int) catchY = int(dataObj.catchY);
			if (dataObj.releaseCatch) releaseCatch = true;
			_isRelease = false;
			return this;
		}
		
		/* INTERFACE alex.pool.IRecycle */
		
		public function release():void 
		{
			if (_isRelease) throw "already release.";
			type = null;
			hurtType = 0;
			distanceId = null;
			speed = 0;
			weight = 0;
			lifeHurt = 0;
			xImpact = 0;
			yImpact = 0;
			zImpact = 0;
			catchZ = 0;
			catchX = 0;
			catchY = 0;
			releaseCatch = false;
			_isRelease = true;
			InstancePool.recycle(this);
		}
		
		private var _isRelease:Boolean = true;
		public function isRelease():Boolean 
		{
			return _isRelease;
		}
		
		/**
		 * 从对象池获取一个SkillFrameData对象
		 * @return
		 */
		public static function make():SkillFrameData {
			return SkillFrameData(InstancePool.getInstance(SkillFrameData));
		}
		
	}

}