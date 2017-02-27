package com.indiestream.controls.playcontrols.buttons
{
	import com.indiestream.common.Constants;
	import com.indiestream.model.Model;
	import com.greensock.TweenMax;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	import ui.ControlAudio;

	public class ButtonAudio extends Sprite
	{
		
		
		public static const STATE_FULL : uint = 4;
		
		public static const STATE_75 : uint = 3;
		
		public static const STATE_50 : uint = 2;
		
		public static const STATE_25 : uint = 1;
		
		public static const STATE_MUTE : uint = 0;
		
		
		public function ButtonAudio()
		{
	
			super();
			
			this._model = Model.getInstance();
			
			this._createChildren();
			
			this.addEventListener(Event.ADDED_TO_STAGE, _onStageAdd);
			
		}
	
		
		private var _icon : ControlAudio;
		
		private var _model : Model;
		
		
		private var _buttonState : uint;
		
		public function get buttonState() : uint
		{
			
			return this._buttonState;
			
		}
		
		public function set buttonState( state : uint ) : void
		{
			
			if(this._buttonState != state)
			{
				
				switch(state) 
				{
					
					case STATE_FULL:
						this._icon.over.bar1.visible = true;
						this._icon.over.bar2.visible = true;
						this._icon.over.bar3.visible = true;
						this._icon.out.bar1.visible = true;
						this._icon.out.bar2.visible = true;
						this._icon.out.bar3.visible = true;
						this._icon.over.visible = true;
						this._icon.out.visible = true;
						this._icon.back.visible = true;
						this._icon.mute.visible = false;
						if(this._model.video != null)
						{
							this._model.video.audioLevel = 1;
						}
						this._buttonState = state;
						break;
					
					case STATE_75:
						this._icon.over.bar1.visible = true;
						this._icon.over.bar2.visible = true;
						this._icon.over.bar3.visible = false;
						this._icon.out.bar1.visible = true;
						this._icon.out.bar2.visible = true;
						this._icon.out.bar3.visible = false;
						this._icon.mute.visible = false;
						if(this._model.video != null)
						{
							this._model.video.audioLevel = 0.75;
						}
						this._buttonState = state;
						break;
					
					case STATE_50:
						this._icon.over.bar1.visible = true;
						this._icon.over.bar2.visible = false;
						this._icon.over.bar3.visible = false;
						this._icon.out.bar1.visible = true;
						this._icon.out.bar2.visible = false;
						this._icon.out.bar3.visible = false;
						this._icon.mute.visible = false;
						if(this._model.video != null)
						{
							this._model.video.audioLevel = 0.5;
						}
						this._buttonState = state;
						break;
					
					case STATE_25:
						this._icon.over.bar1.visible = false;
						this._icon.over.bar2.visible = false;
						this._icon.over.bar3.visible = false;
						this._icon.out.bar1.visible = false;
						this._icon.out.bar2.visible = false;
						this._icon.out.bar3.visible = false;
						this._icon.mute.visible = false;
						if(this._model.video != null)
						{
							this._model.video.audioLevel = 0.25;
						}
						this._buttonState = state;
						break;
					
					case STATE_MUTE:
						this._icon.over.visible = false;
						this._icon.out.visible = false;
						this._icon.back.visible = false;
						this._icon.mute.visible = true;
						if(this._model.video != null)
						{
							this._model.video.audioLevel = 0;
						}
						this._buttonState = state;
						break;
					
					default:
						throw new Error("ButtonAudio::Error button state " + state + " not found.");
						break;
					
				}
			
				this._updateDisplayList();
				
			}
			
		}
		
		private function _createChildren() : void
		{
			
			this._icon = new ControlAudio();
			this._icon.mouseChildren = false;
			this._icon.buttonMode = true;
			this.addChild(this._icon);
			
			this.buttonState = STATE_FULL;
			
			ExternalInterface.addCallback("getAudio", _externalGetAudio);
			ExternalInterface.addCallback("setAudio", _externalSetAudio);
			
			this._updateDisplayList();
			
		}
		
		private function _externalGetAudio() : uint
		{
			return this._buttonState;		
		}
		
		private function _externalSetAudio(state : uint) : Boolean
		{
			
			switch(state)
			{
				
				case STATE_25:
				case STATE_50:
				case STATE_75:
				case STATE_FULL:
				case STATE_MUTE:
					this.buttonState = state;
					return true;
					break;
				
				default:
					return false;
					break;
				
			}
			
		}
		
		private function _updateDisplayList() : void
		{
			
		}
		
		
		private function _onMouseOut( e : MouseEvent ) : void
		{
			
			e.stopImmediatePropagation();
			
			if(this.buttonState != STATE_MUTE)
			{
				TweenMax.killTweensOf(this._icon.out);
				TweenMax.killTweensOf(this._icon.over);
				TweenMax.to(this._icon.out, Constants.ICON_ANIMATION_DURATION, { autoAlpha : 1 });
				TweenMax.to(this._icon.over, Constants.ICON_ANIMATION_DURATION, { autoAlpha : 0 });
			}
			
		}
		
		private function _onMouseOver( e : MouseEvent ) : void
		{
			//trace("ButtonAudio:_onMouseOver");
			e.stopImmediatePropagation();
			
			if(this.buttonState != STATE_MUTE)
			{
				TweenMax.killTweensOf(this._icon.out);
				TweenMax.killTweensOf(this._icon.over);
				TweenMax.to(this._icon.out, Constants.ICON_ANIMATION_DURATION, { autoAlpha : 0 });
				TweenMax.to(this._icon.over, Constants.ICON_ANIMATION_DURATION, { autoAlpha : 1 });
			}
			
		}
		
		private function _onMouseUp( e : MouseEvent ) : void
		{
			//trace("ButtonAudio:_onMouseUp");
			
			e.stopImmediatePropagation();
			
			if(this.buttonState == 0)
			{
				this.buttonState = STATE_FULL;
			} else {
				this.buttonState -= 1;
			}
			
			//this.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			
		}
		
		private function _onStageAdd( e : Event ) : void
		{
			
			//trace("ButtonAudio:_onstageAdd");
			
			this._icon.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
			this._icon.addEventListener(MouseEvent.MOUSE_OVER, _onMouseOver);
			this._icon.addEventListener(MouseEvent.MOUSE_OUT, _onMouseOut);
			
			this.removeEventListener(Event.ADDED_TO_STAGE, _onStageAdd);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, _onStageRemove);
			
		}
		
		private function _onStageRemove( e : Event ) : void
		{
			
			//trace("ButtonAudio:_onStageRemove");
			
			this._icon.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
			this._icon.removeEventListener(MouseEvent.MOUSE_OVER, _onMouseOver);
			this._icon.removeEventListener(MouseEvent.MOUSE_OUT, _onMouseOut);
			
			this.addEventListener(Event.ADDED_TO_STAGE, _onStageAdd);
			
			this.removeEventListener(Event.REMOVED_FROM_STAGE, _onStageRemove);
			
		}
		
	}
	
}