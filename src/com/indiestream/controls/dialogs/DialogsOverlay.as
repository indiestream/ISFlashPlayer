package com.indiestream.controls.dialogs
{
	
	
	import flash.display.Sprite;
	import flash.geom.Point;
	
	import ui.ControlSpinner;
	
	import ui.ControlLoading;

	
	public class DialogsOverlay extends Sprite
	{
		
		
		public static const STATE_NULL : String = "";
		
		public static const STATE_BUFFERING : String = "state_buffering";
		
		public static const STATE_ERROR : String = "state_error";
		
		public static const STATE_OFF : String = "state_off";
		
		
		public function DialogsOverlay( width : Number, height : Number )
		{
			
			this._dimentions = new Point(width, height);
			
			this._createChildren();
			
		}
		
		
		private var _aniLoading : ControlSpinner;
		
		private var _overlay : Sprite;
		
		
		private var _dimentions : Point;
		
		public function set dimentions( dim : Point ) : void
		{
			
			if(this._dimentions !== dim)
			{
				
				this._dimentions = dim;
				this.updateDisplayList();
				
			}
			
		}
		
		public function get dimentions() : Point
		{
			return this._dimentions;
		}
		
		
		private var _state : String = STATE_NULL;
		
		public function set state( state : String ) : void
		{
			
			if(this._state != state)
			{
				
				switch(state)
				{
					
					case STATE_BUFFERING:
						this._aniLoading.visible = true;
						this.visible = true;
						this._state = state;
						break;
					
					case STATE_ERROR:
						trace("DialogError");
						this._aniLoading.visible = false;
						this.visible = true;
						this._state = state;
						break;
					
					case STATE_OFF:
						this.visible = false;
						this._state = state;
						break;
					
					default:
						throw new Error("[ERROR]PlayerDialogsOverlay::State " + state + " not found.");
						break;
					
				}
				
			}
			
		}
		
		public function get state() : String
		{
			return this._state;
		}
		
		
		public function updateDisplayList() : void
		{
		
			with(this._overlay)
			{
				x = 0;
				y = 0;
				width = this._dimentions.x;
				height = this._dimentions.y;
			}
			
			with(this._aniLoading)
			{
				x = this._dimentions.x / 2;
				y = this._dimentions.y / 2;
			}
			
		}
		
		private function _createChildren() : void
		{
		
			this._overlay = new Sprite();
			with(this._overlay)
			{
				buttonMode = true;
				mouseChildren = false;
			}
			with(this._overlay.graphics)
			{
				clear();
				beginFill(0, 0.4);
				drawRect(0, 0, this._dimentions.x, this._dimentions.y);
				endFill();
			}
			this.addChild(this._overlay);
			
			this._aniLoading = new ControlSpinner();
			with(this._aniLoading)
			{
				buttonMode = false;
				mouseChildren = false;
			}
			this.addChild(this._aniLoading);
			
			this.state = STATE_OFF;
			
			this.updateDisplayList();
			
		}
		
	}
	
}