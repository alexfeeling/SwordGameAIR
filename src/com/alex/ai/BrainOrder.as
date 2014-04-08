package com.alex.ai 
{
	/**
	 * 大脑命令常量
	 * @author alex
	 */
	public class BrainOrder 
	{
		
		public function BrainOrder() 
		{
			throw "const error";
		}
		
		public static const START:String = "start";
		
		public static const STOP:String = "stop";
		
		public static const START_MOVE:String = "brain_order_start_move";
		public static const STOP_MOVE:String = "brain_order_stop_move";
		public static const FORCE_STOP_MOVE:String = "brain_order_force_stop_move";
		public static const SEARCH_TARGET:String = "brain_order_search_target";
		public static const GOT_TARGET:String = "brain_order_got_target";
		public static const USE_SKILL:String = "brain_order_use_skill";
		public static const BE_ATTACKED:String = "brain_order_be_attacked";
		
		public static const PLAN_MOVE_X_FINISH:String = "plan_move_x_finish";
		public static const PLAN_MOVE_Y_FINISH:String = "plan_move_y_finish";
		
	}

}