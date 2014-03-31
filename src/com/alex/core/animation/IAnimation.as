package com.alex.core.animation 
{
	
	/**
	 * 动画对象接口
	 * @author alex
	 */
	public interface IAnimation 
	{

		function get id():String;
		
		function isPause():Boolean;
		
		function isPlayEnd():Boolean;
		
		function gotoNextFrame(passedTime:Number):void;
		
	}
	
}