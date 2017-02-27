package com.indiestream.controls.playcontrols.buttons
{
	import com.indiestream.common.Constants;
	import com.indiestream.model.Model;
	import com.greensock.TweenMax;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import ui.ControlFullscreen;
	import ui.ControlNext;
	import ui.ControlPlayback;
	
	public class ButtonNext extends Sprite
	{
		
		
		public function ButtonNext()
		{
			
			super();
			
			this._createChildren();
			
			this.addEventListener(Event.ADDED_TO_STAGE, _onStageAdd);
			
		}
		
		
		private var _icon : ControlNext;
		
		
		private function _createChildren() : void
		{
			
			this._icon = new ControlNext();
			this._icon.mouseChildren = false;
			this._icon.buttonMode = true;
			this.addChild(this._icon);
			
			this._updateDisplayList();
			
		}
		
		private function _updateDisplayList() : void
		{
			
		}
		
		
		private function _onMouseOut( e : MouseEvent ) : void
		{
			
			e.stopImmediatePropagation();
			
			TweenMax.killTweensOf(this._icon.over);
			TweenMax.to(this._icon.over, Constants.ICON_ANIMATION_DURATION, { autoAlpha : 0 });
			
			
		}
		
		private function _onMouseOver( e : MouseEvent ) : void
		{
			//trace("ButtonPlayPause:_onMouseOver");
			e.stopImmediatePropagation();
			
			TweenMax.killTweensOf(this._icon.over);
			TweenMax.to(this._icon.over, Constants.ICON_ANIMATION_DURATION, { autoAlpha : 1 });
			
		}
		
		private function _onMouseUp( e : MouseEvent ) : void
		{
			//trace("ButtonPlayPause:_onMouseUp");
			
			e.stopImmediatePropagation();
			
			this.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
			
		}
		
		private function _onStageAdd( e : Event ) : void
		{
			
			//trace("ButtonPlayPause:_onstageAdd");
			
			this._icon.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
			this._icon.addEventListener(MouseEvent.MOUSE_OVER, _onMouseOver);
			this._icon.addEventListener(MouseEvent.MOUSE_OUT, _onMouseOut);
			
			this.removeEventListener(Event.ADDED_TO_STAGE, _onStageAdd);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, _onStageRemove);
			
		}
		
		private function _onStageRemove( e : Event ) : void
		{
			
			//trace("ButtonPlayPause:_onStageRemove");
			
			this._icon.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
			this._icon.removeEventListener(MouseEvent.MOUSE_OVER, _onMouseOver);
			this._icon.removeEventListener(MouseEvent.MOUSE_OUT, _onMouseOut);
			
			this.addEventListener(Event.ADDED_TO_STAGE, _onStageAdd);
			
			this.removeEventListener(Event.REMOVED_FROM_STAGE, _onStageRemove);
			
		}
		
	}
	
}