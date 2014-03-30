package com.alex.unit
{
	import adobe.utils.CustomActions;
	import com.alex.constant.OrderConst;
	import com.alex.core.component.AttributeComponent;
	import com.alex.core.component.PhysicsComponent;
	import com.alex.core.component.PhysicsType;
	import com.alex.core.pool.InstancePool;
	import com.alex.core.util.IdMachine;
	import com.alex.core.component.Position;
	import com.alex.core.world.World;
	import com.alex.unit.AttackableUnit;
	import com.alex.unit.BaseUnit;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author alex
	 */
	public class Tree extends AttackableUnit
	{
		
		[Embed(source="/../bin/asset/role/head.jpg")]
		public var RUN_CLASS:Class;
		
		public function Tree()
		{
		
		}
		
		protected function init(vPostion:Position):Tree
		{
			this.refresh(IdMachine.getId(Tree), vPostion, PhysicsComponent.make(this, vPostion, 10, 40 * 2, 30 * 2, 100, 100, PhysicsType.SOLID));
			refreshAttribute(AttributeComponent.make(this, 100, 100));
			this.position.z = 200;
			return this;
		}
		
		public static function make(vPosition:Position):Tree
		{
			return Tree(InstancePool.getInstance(Tree)).init(vPosition);
		}
		
		override protected function createUI():void
		{
			super.createUI();
			_shadow.graphics.beginFill(0x0, 0.3);
			_shadow.graphics.drawEllipse(-World.GRID_WIDTH / 2, -World.GRID_HEIGHT / 2, World.GRID_WIDTH, World.GRID_HEIGHT);
			_shadow.graphics.endFill();
			
			_body.graphics.clear();
			_body.graphics.beginFill(0xff00ff, 0.5);
			_body.graphics.drawRect(-20, -100, 40, 100);
			_body.graphics.beginFill(0x0, 0.5);
			_body.graphics.drawRect(-20, -100, 40, 10);
			_body.graphics.endFill();
			
			var run:Bitmap = new RUN_CLASS();
			run.scaleX = 0.5;
			run.scaleY = 0.5;
			run.x = -run.width >> 1;
			run.y = -run.height;
			_body.addChild(run);
		}
		
		override public function refreshZ():void
		{
			this._body.y = -this._position.z;
		}
	
	}

}