package com.alex.unit 
{
	
	import com.alex.skill.SkillFrameData
	
	/**
	 * ...
	 * @author alex
	 */
	public interface IAttackable 
	{
		
		function receiveAttackNotice(vAttacker:AttackableUnit):void;
		
		/**
		 * 接收攻击
		 * @param	vAttacker 攻击者
		 * @param	vSkillData 技能数据
		 */
		function receiveAttackHurt(attacker:AttackableUnit, frameData:SkillFrameData):void;
		
	}
	
}