package com.indiestream.sceens
{
	
	import com.confluence.core.managers.ManagerStage;
	import com.greensock.TweenMax;
	import com.indiestream.common.Constants;
	import com.indiestream.controls.playcontrols.ControlBar;
	import com.indiestream.controls.videoplayer.VideoPlayer;
	import com.indiestream.events.ControlEvent;
	import com.indiestream.model.Model;
	import com.indiestream.model.VOVideo;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	
	import org.mangui.hls.constant.HLSPlayStates;

	
	public class ScreenPlayer extends Sprite
	{
		
		
		public static const CONTROL_BAR_HIDE : String = "control_bar_hide";
		
		public static const CONTROL_BAR_SHOW : String = "control_bar_show";
		
		public static const DURATION : Number = 0.5;
		
		
		public function ScreenPlayer()
		{
			
			super();
			
			this._model = Model.getInstance();
			
			this._createChildren();
			
			this.addEventListener(Event.ADDED_TO_STAGE, _onStageAdd);
			
		}
		
		private var _controls : ControlBar;
		
		private var _grcBackground : Sprite;
		
		private var _mngStage : ManagerStage;
		
		private var _model : Model;
		
		private var _scrVideoPlayer: VideoPlayer;
		
		private var _controlBarTimeout : Timer;
		
		private var _watcherPlayState : ChangeWatcher;
		
		private var _watcherVideo : ChangeWatcher;
		
		private var _watcherVolume : ChangeWatcher;
		
		
		private var _stateControlBar : String = CONTROL_BAR_SHOW;
		
		public function get stateControlBar() : String
		{
			return this._stateControlBar;
		}
		
		public function set stateControlBar( state : String ) : void
		{
			
			if(this._stateControlBar != state)
			{
				
				switch(state)
				{
					
					case CONTROL_BAR_HIDE:
						Mouse.hide();
						TweenMax.killTweensOf(this._controls);
						TweenMax.to(this._controls, DURATION, { autoAlpha : 0 } );
						this._stateControlBar = state;
						break;
					
					case CONTROL_BAR_SHOW:
						Mouse.show();
						TweenMax.killTweensOf(this._controls);
						TweenMax.to(this._controls, DURATION, { autoAlpha : 1 } );
						this._stateControlBar = state;
						break;
					
					default:
						throw new Error("ScreenPlayer:stateControlBar:ERROR state " + state + " not found");
						break;
					
				}
				
			}
			
		}
		
		private var _stateTimer : Boolean = false;
		
		public function get stateTimer() : Boolean
		{
			return this._stateTimer;
		}
		
		public function set stateTimer( state : Boolean ) : void
		{
			
			//ExternalInterface.call("playerEvent", "stateTimer:" + state);
			
			if(this._controlBarTimeout.running)
			{
				//trace("ScreenPlayer:RESTART");
				this._controlBarTimeout.reset();
				this._controlBarTimeout.start();
			}
			
			if(state != this._stateTimer)
			{
				
				if(state)
				{
					//ExternalInterface.call("playerEvent", "stateTimer:STARTING");
					//trace("ScreenPlayer:START");
					this._controlBarTimeout.start();
					
				} else {
					
					//trace("ScreenPlayer:STOP");
					this._controlBarTimeout.stop();
					this.stateControlBar = CONTROL_BAR_SHOW;
					
				}
				
				this._stateTimer = state;
				
			}
			
		}
		
		
		public function resize() : void
		{
			this._updateDisplayList();
		}
		
		private function _createChildren() : void
		{
			
			this._mngStage = ManagerStage.getInstance();
			
			this._controlBarTimeout = new Timer(Constants.CONTROL_BAR_TIMEOUT);
			this._controlBarTimeout.addEventListener(TimerEvent.TIMER, _onControlBarTimeout);
			
			this._grcBackground = new Sprite();
			this._grcBackground.width = this._model.interfaceStage.stageDim.x;
			this._grcBackground.height = this._model.interfaceStage.stageDim.y;
			this.addChild(this._grcBackground);
			
			this._scrVideoPlayer = new VideoPlayer();
			this.addChild(this._scrVideoPlayer);
			
			this._controls = new ControlBar();
			this._controls.x = 0;
			this.addChild(this._controls);
			
			this._updateDisplayList();
			
		}
		
		private function _updateDisplayList() : void
		{
			
			//trace("ScreenPlayer:_updateDisplayList:" + this._model.interfaceStage.stageDim.y);
			
			this.x = 0;
			this.y = 0;
			
			this._scrVideoPlayer.dimentions = new Point(this._model.interfaceStage.stageDim.x, this._model.interfaceStage.stageDim.y);
			
			this._controls.resize(this._model.interfaceStage.stageDim.x);
			this._controls.x = 0;
			this._controls.y = this._model.interfaceStage.stageDim.y - this._controls.height;
			
		}
		
		private function _onChangePlayState( state : String ) : void
		{
			
			//ExternalInterface.call("playerEvent", "ScreenPlayer:_onChangePlayState:" + state);
			
			if( state == HLSPlayStates.PLAYING || state == HLSPlayStates.PLAYING_BUFFERING)
			{
				
				this.stateTimer = true;
				this._mngStage.addEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
				
			} else {
				
				this.stateTimer = false;
				this._mngStage.removeEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
				
			}
			
		}
		
		private function _onChangeVideo( video : VOVideo ) : void
		{
			
			//ExternalInterface.call("playerEvent", "ScreenPlayer:_onChangeVideo");
			
			if(this._watcherPlayState != null)
			{
				this._watcherPlayState.unwatch();
				this._watcherPlayState = null;
			}
			
			if(this._watcherVolume != null)
			{
				this._watcherVolume.unwatch();
				this._watcherVolume = null;
			}
			
			if(video != null)
			{
				
				this._controls.addEventListener(ControlEvent.CONTROL_NEXT, _onControlNext);
				
				this._controls.addEventListener(ControlEvent.CONTROL_PLAY, _onControlEvent);
				
				this._controls.addEventListener(ControlEvent.CONTROL_PAUSE, _onControlEvent);
				
				this._controls.addEventListener(ControlEvent.CONTROL_SEEK, _onControlEvent);
				
				this._controls.addEventListener(ControlEvent.CONTROL_STOP, _onControlEvent);
				
				this._watcherPlayState = BindingUtils.bindSetter(_onChangePlayState, this._model.video, "playState");
				
				this._watcherVolume = BindingUtils.bindSetter(_onChangeVolume, this._model.video, "audioLevel");
				
				this._scrVideoPlayer.loadMedia();
				
			} else {
				
				this._controls.removeEventListener(ControlEvent.CONTROL_NEXT, _onControlNext);
				
				this._controls.removeEventListener(ControlEvent.CONTROL_PLAY, _onControlEvent);
				
				this._controls.removeEventListener(ControlEvent.CONTROL_PAUSE, _onControlEvent);
				
				this._controls.removeEventListener(ControlEvent.CONTROL_SEEK, _onControlEvent);
				
				this._controls.removeEventListener(ControlEvent.CONTROL_STOP, _onControlEvent);
				
			}
				
		}
		
		private function _onChangeVolume( volume : Number ) : void
		{
			
			this._scrVideoPlayer.volume(volume);

		}
		
		private function _onControlBarTimeout( e : TimerEvent ) : void
		{
			
			//ExternalInterface.call("playerEvent", "_onControlBarTimeout");
			this.stateControlBar = CONTROL_BAR_HIDE;
			
		}
		
		private function _onControlEvent( e : ControlEvent ) : void
		{
		
			//trace("ScreenPlayer:_onControlEvent:" + e.type);
			
			this._scrVideoPlayer.controlPlayer(e);
		
		}
		
		private function _onControlNext( e: ControlEvent ) : void
		{
			
			//trace("ScreenPlayer:_onControlEvent:" + e.type);
			this._controls.reset();
			this._scrVideoPlayer.stop();
			
		}
		
		private function _onMouseMove( e : MouseEvent ) : void
		{
			
			//trace("ScreenPlayer:_onMouseMove");
			
			this.stateControlBar = CONTROL_BAR_SHOW;
			
			if(this._controls.hitTestPoint(this.mouseX, this.mouseY))
			{
				this.stateTimer = false;
			} else {
				this.stateTimer = true;
			}
			
		}
		
		private function _onStageAdd( e : Event ) : void
		{
			
			//trace("ScreenPlayer:_onStageAdd");
			
			this.removeEventListener(Event.ADDED_TO_STAGE, _onStageAdd);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, _onStageRemove);
			
			this._watcherVideo = BindingUtils.bindSetter(_onChangeVideo, this._model, "video");
			
		}
		
		private function _onStageRemove( e : Event ) : void
		{
			
			//trace("ScreenPlayer:_onStageRemove");
			
			this.stateTimer = false;
			
			this._controls.removeEventListener(ControlEvent.CONTROL_NEXT, _onControlNext);
			
			this._controls.removeEventListener(ControlEvent.CONTROL_PLAY, _onControlEvent);
			
			this._controls.removeEventListener(ControlEvent.CONTROL_PAUSE, _onControlEvent);
			
			this._controls.removeEventListener(ControlEvent.CONTROL_SEEK, _onControlEvent);
			
			this._controls.removeEventListener(ControlEvent.CONTROL_STOP, _onControlEvent);
			
			this.addEventListener(Event.ADDED_TO_STAGE, _onStageAdd);
			
			this.removeEventListener(Event.REMOVED_FROM_STAGE, _onStageRemove);
			
			if(this._watcherPlayState != null)
			{
				this._watcherPlayState.unwatch();
				this._watcherPlayState = null;
			}
			
			if(this._watcherVideo != null)
			{
				this._watcherVideo.unwatch();
				this._watcherVideo = null;
			}
			
			if(this._watcherVolume != null)
			{
				this._watcherVolume.unwatch();
				this._watcherVolume = null;
			}
			
		}
		
	}
	
}