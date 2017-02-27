package com.indiestream.controls.playcontrols
{
	import com.indiestream.events.ControlEvent;
	import com.indiestream.model.Model;
	import com.greensock.TweenMax;
	import com.confluence.core.managers.ManagerStage;
	import com.confluence.core.utils.DateUtils;
	import com.confluence.core.utils.MathUtils;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import ui.ControlTooltip;
	
	public class Scrubber extends Sprite
	{
	
		
		public static const DURATION : Number = 0.3;
		
		public static const STATE_CLOSED : String = "state_close";
		
		public static const STATE_OPEN : String = "state_open";
		
		
		// Scrubber Vars
		
		public static const COLOR_PLAYBACK : uint = 0xb5340b; 
		
		public static const COLOR_BUFFERED : uint = 0xffffff; 
		
		public static const COLOR_TRACK : uint = 0xb0b6c9; 
		
		public static const HEIGHT_CLOSED : uint = 2;
		
		public static const HEIGHT_OPEN : uint = 6;
		
		public static const HIT_HEIGHT : uint = 10;
		
		
		public function Scrubber()
		{
			
			super();
			
			this._model = Model.getInstance();
			
			this._createChildren();
			
			this.addEventListener(Event.ADDED_TO_STAGE, _onStageAdd);
			
		}
		
		
		private var _buffered : Sprite;
		
		private var _hit : Sprite;
		
		private var _mngStage : ManagerStage;
		
		private var _model : Model;
		
		private var _playback : Sprite;
		
		private var _tooltip : ControlTooltip;
		
		private var _track : Sprite;
		
		private var _width : Number = 1;
		
		
		private var _state_bar : String = STATE_CLOSED;
		
		public function get state_bar() : String
		{
			return this._state_bar;
		}
		
		public function set state_bar( state : String ) : void
		{
			
			if(state != this._state_bar)
			{
				
				switch(state)
				{
					
					case STATE_CLOSED:
						TweenMax.killTweensOf(this._track);
						TweenMax.killTweensOf(this._buffered);
						TweenMax.killTweensOf(this._playback);
						TweenMax.killTweensOf(this._tooltip);
						TweenMax.to(this._track, DURATION, { height : HEIGHT_CLOSED });
						TweenMax.to(this._buffered, DURATION, { height : HEIGHT_CLOSED });
						TweenMax.to(this._playback, DURATION, { height : HEIGHT_CLOSED });
						TweenMax.to(this._tooltip, DURATION, { alpha : 0 });
						this._mngStage.removeEventListener(MouseEvent.MOUSE_MOVE, _onMouseMoveToolTip);
						this._state_bar = state;
						break;
					
					case STATE_OPEN:
						TweenMax.killTweensOf(this._track);
						TweenMax.killTweensOf(this._buffered);
						TweenMax.killTweensOf(this._playback);
						TweenMax.killTweensOf(this._tooltip);
						TweenMax.to(this._track, DURATION, { height : HEIGHT_OPEN });
						TweenMax.to(this._buffered, DURATION, { height : HEIGHT_OPEN });
						TweenMax.to(this._playback, DURATION, { height : HEIGHT_OPEN });
						TweenMax.to(this._tooltip, DURATION, { alpha : 1 });
						this._mngStage.addEventListener(MouseEvent.MOUSE_MOVE, _onMouseMoveToolTip);
						this._state_bar = state;
						break;
					
					default: 
						throw new Error("Scrubber:state_bar:Error state " + state + " not found.");
						break;
					
				}
				
			}
			
		}
		
		public function reset() : void
		{
			
			this._playback.width = 0;
			
			this._buffered.width = 0;
			
		}
		
		public function resize( width : Number ) : void
		{
			
			this._width = width;
			
			this._updateDisplayList();
			
		}
		
		public function updatePlayback( percentage : Number ) : void
		{
			
			this._playback.width = this._width * percentage;
			
		}
		
		
		private function _createChildren() : void
		{
			
			this._mngStage = ManagerStage.getInstance();
			
			this._track = new Sprite();
			with(this._track as Sprite)
			{
				mouseEnabled = false;
				graphics.beginFill(COLOR_TRACK);
				graphics.drawRect(0, -HEIGHT_CLOSED / 2, 1, HEIGHT_CLOSED);
				graphics.endFill();
			}
			this.addChild(this._track);
			
			this._buffered = new Sprite();
			with(this._buffered as Sprite)
			{
				mouseEnabled = false;
				graphics.beginFill(COLOR_BUFFERED);
				graphics.drawRect(0, -HEIGHT_CLOSED / 2, 1, HEIGHT_CLOSED);
				graphics.endFill();
			}
			this.addChild(this._buffered);
			
			this._playback = new Sprite();
			with(this._playback as Sprite)
			{
				mouseEnabled = false;
				graphics.beginFill(COLOR_PLAYBACK);
				graphics.drawRect(0, -HEIGHT_CLOSED / 2, 1, HEIGHT_CLOSED);
				graphics.endFill();
			}
			this.addChild(this._playback);
			
			this._tooltip = new ControlTooltip();
			with(this._tooltip)
			{
				mouseEnabled = false;
				mouseChildren = false;
				alpha = 0;
				y = -(HIT_HEIGHT / 2);
			}
			this.addChild(this._tooltip);
			
			this._hit = new Sprite();
			with(this._hit as Sprite)
			{
				mouseEnabled = true;
				buttonMode = true;
				useHandCursor = true;
				alpha = 0;
				graphics.beginFill(0);
				graphics.drawRect(0, -HIT_HEIGHT / 2, 1, HIT_HEIGHT);
				graphics.endFill();
			}
			this.addChild(this._hit);
			
		}
		
		private function _hitCheck() : void
		{
			
			if(!this._hit.hitTestPoint(this.mouseX, this.mouseY))
			{
				
				this.state_bar = STATE_CLOSED;	
			}
			
		}
		
		private function _hitPercent() : Number
		{
		
			//trace("Scrubber:_hitPercent:" + MathUtils.round(this.mouseX / this._width, 2));
		
			var percent : Number = MathUtils.round(this.mouseX / this._width, 2);
			
			if(percent > 1) 
			{
				percent = 1;	
			} else if(percent < 0) {
				percent = 0;
			}
			
			return percent;
			
		}
		
		private function _updateDisplayList() : void
		{
			
			this._track.width = this._hit.width = this._width;
			
			this._buffered.width = 1;
			
			this._playback.width = 1;
			
		}
		
		private function _updateTooltip() : void
		{
			
			if(this.mouseX >= this._hit.x && this.mouseX < this._hit.x + this._hit.width)
			{
				this._tooltip.x = this.mouseX;
			} else if(this.mouseX < this._hit.x) {
				this._tooltip.x = this._hit.x;
			} else if(this.mouseX > this._hit.x) {
				this._tooltip.x = this._hit.x + this._hit.width;
			}
			
			this._tooltip.label.text = DateUtils.convertSecondsToTime(
				Math.round(this._model.video.timeDuration * ((this._tooltip.x - this._hit.x) / this._hit.width))
			);
			
		}
		
		private function _onMouseDown( e : MouseEvent ) : void
		{
		
			//e.stopImmediatePropagation();
			
			this._hit.removeEventListener(MouseEvent.MOUSE_OUT, _onMouseOut);
			this._mngStage.addEventListener(MouseEvent.MOUSE_MOVE, _onMouseMoveStage);
			this._mngStage.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
			
			this.dispatchEvent(new ControlEvent(ControlEvent.SCRUB_DOWN, this._hitPercent()));
		}
		
		private function _onMouseMoveStage( e : MouseEvent ) : void
		{
			
			//trace("Scrubber:_onMouseMoveStage:" + this._hitPercent() + "::" + this._width);
			
			this._playback.width = this._hitPercent() * this._width;
			
			this.dispatchEvent(new ControlEvent(ControlEvent.SCRUB_MOVE, this._hitPercent()));
			
		}
		
		private function _onMouseMoveToolTip( e : MouseEvent ) : void
		{
//			
//			if(this.mouseX >= this._hit.x && this.mouseX < this._hit.x + this._hit.width)
//				this._tooltip.x = this.mouseX;
			
			this._updateTooltip();
			
		}
		
		private function _onMouseOut( e : MouseEvent ) : void
		{
			this.state_bar = STATE_CLOSED;	
		}
		
		private function _onMouseOver( e : MouseEvent ) : void
		{
			this.state_bar = STATE_OPEN;
		}
		
		private function _onMouseUp( e : MouseEvent ) : void
		{
			
			e.stopImmediatePropagation();
			
			this._hitCheck();
			
			this._hit.addEventListener(MouseEvent.MOUSE_OUT, _onMouseOut);
			this._mngStage.removeEventListener(MouseEvent.MOUSE_MOVE, _onMouseMoveStage);
			this._mngStage.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
			
			this.dispatchEvent(new ControlEvent(ControlEvent.SCRUB_UP, this._hitPercent()));		
			
		}
		
		private function _onStageAdd( e : Event ) : void
		{
			
			this._hit.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
			this._hit.addEventListener(MouseEvent.MOUSE_OUT, _onMouseOut);
			this._hit.addEventListener(MouseEvent.MOUSE_OVER, _onMouseOver);
			
			this.removeEventListener(Event.ADDED_TO_STAGE, _onStageAdd);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, _onStageRemove);
			
		}
		
		private function _onStageRemove( e : Event ) : void
		{
			
			this._mngStage.removeEventListener(MouseEvent.MOUSE_MOVE, _onMouseMoveStage);
			this._mngStage.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
			this._hit.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
			this._hit.removeEventListener(MouseEvent.MOUSE_OUT, _onMouseOut);
			this._hit.removeEventListener(MouseEvent.MOUSE_OVER, _onMouseOver);
			//this._hit.removeEventListener(MouseEvent.MOUSE_MOVE);
			
			this.removeEventListener(Event.REMOVED_FROM_STAGE, _onStageRemove);
			
			this.addEventListener(Event.ADDED_TO_STAGE, _onStageAdd);
			
			
		}
		
	}
	
}