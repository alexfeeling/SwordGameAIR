package alex.core.animation
{
	import alex.core.commander.Commander;
	import alex.core.commander.IOrderExecutor;
	import alex.core.unit.IWorldUnit;
	import alex.core.util.IdMachine;
	import flash.display.DisplayObject;
	
	/**
	 * 通过定义属性变化的缓动动画
	 * @author alexfeeling
	 */
	public class AttributeAnimation implements IAnimation
	{
		
		private var _target:IWorldUnit;
		private var _targetDisplay:DisplayObject;
		private var _beforeAttrobj:Object;
		private var _attrObj:Object;
		private var _holeTime:Number;
		private var _currentTime:Number;
		private var _id:String;
		
		private var _endOrder:String;
		private var _endOrderParam:Object;
		private var _endOrderExecutor:IOrderExecutor;
		
		public function AttributeAnimation(target:IWorldUnit, attrObj:Object, time:Number, 
			endOrder:String = null, endOrderParam:Object = null, endOrderExecutor:IOrderExecutor = null)
		{
			this._id = IdMachine.getId(AttributeAnimation);
			this._target = target;
			this._targetDisplay = target.toDisplayObject();
			this._attrObj = attrObj;
			this._holeTime = time;
			this._currentTime = 0;
			_beforeAttrobj = {};
			for (var attrName:String in attrObj)
			{
				if (_targetDisplay[attrName] != null)
				{
					_beforeAttrobj[attrName] = _targetDisplay[attrName];
				}
				else
				{
					throw "no such attribute";
				}
			}
			_endOrder = endOrder;
			_endOrderParam = endOrderParam;
			_endOrderExecutor = endOrderExecutor;
		}
		
		/* INTERFACE alex.animation.IAnimation */
		
		public function get id():String
		{
			return _id;
		}
		
		public function isPause():Boolean
		{
			return false;
		}
		
		public function isPlayEnd():Boolean
		{
			return _currentTime >= _holeTime || this._target.isRelease();
		}
		
		public function gotoNextFrame(passedTime:Number):void
		{
			_currentTime += passedTime;
			if (_currentTime >= this._holeTime)
			{
				for (var attrName:String in _attrObj)
				{
					_targetDisplay[attrName] = _attrObj[attrName];
				}
				if (this._endOrder)
				{
					Commander.sendOrder(_endOrder, _endOrderParam, _endOrderExecutor);
				}
			}
			else
			{
				for (attrName in _attrObj)
				{
					_targetDisplay[attrName] = _beforeAttrobj[attrName] + (_attrObj[attrName] - _beforeAttrobj[attrName]) * (_currentTime / _holeTime);
				}
			}
		}
	
	}

}