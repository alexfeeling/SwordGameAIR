package alex.core.component 
{
	import alex.core.component.MoveDirection;
	import alex.core.component.PhysicsComponent;
	import alex.core.unit.IWorldUnit;
	import alex.core.pool.InstancePool;
	import alex.core.pool.IRecycle;
	import alex.core.world.World;
	/**
	 * 单位位置类
	 * @author alex
	 */
	public class Position implements IRecycle
	{
		
		public var phycItem:IWorldUnit;
		
		private var _gridX:int;
		private var _gridY:int;
		
		///格子内坐标X
		private var _insideX:int;
		///格子内坐标Y
		private var _insideY:int;
		private var _isRelease:Boolean;
		
		///海拔高度
		public var z:int;
		
		///相对海拔高度
		public var relativeElevation:int;
		
		public function Position() 
		{
			
		}
		
		protected function init(vGridX:int = 0, vGridY:int = 0, 
								vInsideX:int = -1, vInsideY:int = -1,
								vElevation:int = 0):Position 
		{
			this._gridX = vGridX;
			this._gridY = vGridY;
			this._insideX = vInsideX == -1?World.GRID_WIDTH / 2:vInsideX;
			this._insideY = vInsideY == -1?World.GRID_HEIGHT / 2:vInsideY;
			this.z = vElevation;
			this._isRelease = false;
			return this;
		}
		
		/**
		 * 获取一个新的Position，从对象池里获取
		 * @param	gridX
		 * @param	gridY
		 * @param	insideX
		 * @param	insideY
		 * @param	elevation
		 * @return
		 */
		public static function make(gridX:int = 0, gridY:int = 0, insideX:int = -1, insideY:int = -1, elevation:int = 0):Position {
			return (InstancePool.getInstance(Position) as Position).init(gridX, gridY, insideX, insideY, elevation);
		}
		
		/**
		 * 与目标单位贴合
		 * @param	vDirection
		 * @param	vTarget
		 */
		public function nestleUpTo(vDirection:int, vTarget:IWorldUnit):void {
			var myPhysicsComponent:PhysicsComponent = this.phycItem.physicsComponent;
			var targetPhysicsComponent:PhysicsComponent = vTarget.physicsComponent;
			var targetPosition:Position = vTarget.position;
			switch(vDirection) {
				case MoveDirection.X_LEFT:
					this.gridX = targetPosition.gridX;
					this.insideX = targetPosition.insideX + 
						((myPhysicsComponent.length + targetPhysicsComponent.length) >> 1);
					break;
				case MoveDirection.X_RIGHT:
					this.gridX = targetPosition.gridX;
					this.insideX = targetPosition.insideX -
						((myPhysicsComponent.length + targetPhysicsComponent.length) >> 1);
					break;
				case MoveDirection.Y_UP:
					this.gridY = targetPosition.gridY;
					this.insideY = targetPosition.insideY + 
						((myPhysicsComponent.width + targetPhysicsComponent.width) >> 1);
					break;
				case MoveDirection.Y_DOWN:
					this.gridY = targetPosition.gridY;
					this.insideY = targetPosition.insideY - 
						((myPhysicsComponent.width + targetPhysicsComponent.width) >> 1);
					break;
				case MoveDirection.Z_BOTTOM:
					this.z = targetPosition.z + targetPhysicsComponent.height;
					myPhysicsComponent.forceStopZ();
					break;
				case MoveDirection.Z_TOP:
					this.z = targetPosition.z - targetPhysicsComponent.height;
					myPhysicsComponent.forceStopZ();
					break;
			}
		}
		
		/**
		 * 移动
		 * @param	vDirection
		 * @param	vDistance
		 */
		public function move(vDirection:int, vDistance:int):void {
			switch(vDirection) {
				case MoveDirection.X_LEFT://左
					this.insideX -= vDistance;
					break;
				case MoveDirection.X_RIGHT://右
					this.insideX += vDistance;
					break;
				case MoveDirection.Y_UP://上
					this.insideY -= vDistance;
					break;
				case MoveDirection.Y_DOWN://下
					this.insideY += vDistance;
					break;
				case MoveDirection.Z_BOTTOM://下落
					this.z -= vDistance;
					this.z = Math.max(this.z, 0);
					break;
				case MoveDirection.Z_TOP://上升
					this.z += vDistance;
					break;
			}
		}
		
		/**
		 * 比较X位置，目标在左边返回-1，在右边返回1，相等返回0
		 * @param	vPosition
		 * @return
		 */
		public function compareX(vPosition:Position):int {
			if (vPosition.gridX < _gridX) {
				return -1;
			} else if (vPosition.gridX > _gridX) {
				return 1;
			} else if (vPosition.insideX < _insideX) {
				return -1;
			} else if (vPosition.insideX > _insideX) {
				return 1;
			} else {
				return 0;
			}
		}
		
		/**
		 * 地图块内格子坐标X
		 */
		public function get gridX():int 
		{
			return _gridX;
		}
		
		public function set gridX(value:int):void 
		{
			if (_gridX == value) return;
			var orgin:int = _gridX;
			_gridX = value;
			World.getInstance().refreshGridItem(phycItem, orgin, gridY);
		}
		
		/**
		 * 地图块内格子坐标Y
		 */
		public function get gridY():int 
		{
			return _gridY;
		}
		
		public function set gridY(value:int):void 
		{
			if (_gridY == value) return;
			var orgin:int = _gridY;
			_gridY = value;
			World.getInstance().refreshGridItem(phycItem, gridX, orgin);
		}
		
		public function get globalX():int {
			return this.gridX * World.GRID_WIDTH + this.insideX;
		}
		
		public function get globalY():int {
			return this.gridY * World.GRID_HEIGHT + this.insideY;
		}
		
		public function set globalX(value:int):void {
			this.gridX = int(value / World.GRID_WIDTH);
			this._insideX = int(value % World.GRID_WIDTH);
		}
		
		public function set globalY(value:int):void {
			this.gridY = int(value / World.GRID_HEIGHT);
			this._insideY = int(value % World.GRID_HEIGHT);
		}
		
		public function get insideX():int 
		{
			return _insideX;
		}
		
		public function set insideX(value:int):void 
		{
			_insideX = int(value);
			if (_insideX < 0) {
				_insideX += World.GRID_WIDTH;
				this.gridX--;
			} else if (_insideX >= World.GRID_WIDTH) {
				_insideX -= World.GRID_WIDTH;
				this.gridX++;
			} 
		}
		
		public function get insideY():int 
		{
			return _insideY;
		}
		
		public function set insideY(value:int):void 
		{
			_insideY = int(value);
			if (_insideY < 0) {
				_insideY += World.GRID_HEIGHT;
				this.gridY--;
			} else if (_insideY >= World.GRID_HEIGHT) {
				_insideY -= World.GRID_HEIGHT;
				this.gridY++;
			}
		}
		
		/**
		 * 复制一个完全一样的Position
		 * @return
		 */
		public function copy():Position {
			return Position(InstancePool.getInstance(Position)).init(this._gridX, this._gridY, 
						this.insideX, this.insideY, this.z);
		}
		
		/* INTERFACE alex.pool.IRecycle */
		
		public function release():void 
		{
			if (this._isRelease) throw "already release.";
			
			this._isRelease = true;
			InstancePool.recycle(this);
			this.phycItem = null;
			this._gridX = 0;
			this._gridY = 0;
			this.insideX = 0;
			this.insideY = 0;
			this.z = 0;
		}
		
		/* INTERFACE alex.pool.IRecycle */
		
		public function isRelease():Boolean 
		{
			return this._isRelease;
		}
		
	}

}