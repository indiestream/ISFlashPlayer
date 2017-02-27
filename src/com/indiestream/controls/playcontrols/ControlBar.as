package com.indiestream.controls.playcontrols
{

	
	import com.confluence.core.utils.DateUtils;
	import com.indiestream.controls.playcontrols.buttons.ButtonAudio;
	import com.indiestream.controls.playcontrols.buttons.ButtonFullscreen;
	import com.indiestream.controls.playcontrols.buttons.ButtonNext;
	import com.indiestream.controls.playcontrols.buttons.ButtonPlayPause;
	import com.indiestream.events.ControlEvent;
	import com.indiestream.model.Model;
	import com.indiestream.model.VOVideo;
	
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextFieldAutoSize;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	
	import org.mangui.hls.HLS;
	import org.mangui.hls.constant.HLSPlayStates;
	import org.mangui.hls.constant.HLSTypes;
	
	import ui.ControlLiveLabel;
	import ui.ControlMovieLabel;
	import ui.ControlTimeLabel;
	import ui.GraphicBackgroundGradient;

	
	public class ControlBar extends Sprite
	{
		
		
		public static const BUTTON_PADDING : uint = 30;
		
		public static const EDGE_PADDING : uint = 15;
		
		public static const SECOND_OFFEST : uint = 5;
		
		
		public function ControlBar()
		{
			
			super();
			
			this._model = Model.getInstance();
			
			this._createChildren();
			
			this.addEventListener(Event.ADDED_TO_STAGE, _onStageAdd);
			
		}
		
		
		private var _backround : GraphicBackgroundGradient;
		
		private var _btnAudio : ButtonAudio;
		
		private var _btnFullscreen : ButtonFullscreen;
		
		private var _btnNext : ButtonNext;
		
		private var _btnPlayPause : ButtonPlayPause;
		
		//private var _height : Number = 1;
		
		private var _lblLive : ControlLiveLabel;
		
		private var _lblMovieTitle : ControlMovieLabel;
		
		private var _lblTimeCode : ControlTimeLabel;
		
		private var _model : Model;
		
		private var _scrubber : Scrubber;
		
		private var _width : Number = 500;
		
		private var _watcherMediaType : ChangeWatcher;
		
		private var _watcherPlayState : ChangeWatcher;
		
		private var _watcherTimeCurrent : ChangeWatcher;
		
		private var _watcherTimeDuration : ChangeWatcher;
		
		private var _watcherVideo : ChangeWatcher;
		
		
		private function _createChildren() : void
		{
			
			this._backround = new GraphicBackgroundGradient();
			this.addChild(this._backround);
			
			this._btnPlayPause = new ButtonPlayPause();
			this.addChild(this._btnPlayPause);
			
			this._btnAudio = new ButtonAudio();
			this.addChild(this._btnAudio);
			
			this._btnNext = new ButtonNext();
			//x this.addChild(this._btnNext);
			
			this._btnFullscreen = new ButtonFullscreen();
			this._btnFullscreen.buttonMode = true;
			this._btnFullscreen.mouseChildren = false;
			this.addChild(this._btnFullscreen);
			
			this._scrubber = new Scrubber();
			this.addChild(this._scrubber);
			
			this._lblTimeCode = new ControlTimeLabel();
			this.addChild(this._lblTimeCode);
			
			this._lblMovieTitle = new ControlMovieLabel();
			this._lblMovieTitle.mouseEnabled = false;
			this._lblMovieTitle.mouseChildren = false;
			this.addChild(this._lblMovieTitle);
			
			this._lblLive = new ControlLiveLabel();
			this.addChild(this._lblLive);
			
			this._updateDisplayList();
			
			//ExternalInterface.addCallback("", _externalLoadMedia);
			ExternalInterface.addCallback("getFullscreen", _externalGetFullscreen);
			//ExternalInterface.addCallback("setFullscreen", _externalSetFullscreen);
			ExternalInterface.addCallback("getPlayState", _externalGetPlayState);
			ExternalInterface.addCallback("setPlayState", _externalSetPlayState);
			ExternalInterface.addCallback("getTime", _externalGetTime);
			
		}
		
		private function _externalGetFullscreen() : String
		{
			
			return this._model.interfaceStage.stage.displayState;
//			
//			if(this._model.interfaceStage.stage.loaderInfo.parameters.cbFullscreen != undefined 
//				&& this._model.interfaceStage.stage.loaderInfo.parameters.cbFullscreen != null)
//			{
//				ExternalInterface.call(this._model.interfaceStage.stage.loaderInfo.parameters.cbFullscreen, 
//					this._model.interfaceStage.stage.displayState);
//			}
//			
		}
//		
//		private function _externalSetFullscreen(state : String) : Boolean
//		{
//			
//			if(state == StageDisplayState.FULL_SCREEN) 
//			{
//				
//				//ExternalInterface.call("playbackEvent", "fullscreenEnter");
//				this._model.interfaceStage.stage.displayState = StageDisplayState.FULL_SCREEN;
//				
//				return true;
//				
//			} else if(state == StageDisplayState.NORMAL) {
//				
//				//ExternalInterface.call("playbackEvent", "fullscreenLeave");
//				this._model.interfaceStage.stage.displayState = StageDisplayState.NORMAL;
//				
//				return true;
//				
//			} else {
//				
//				return false;
//				
//			}
//			
//		}
//		
		private function _externalGetPlayState() : String
		{
			
			return this._model.video.playState;
			//			
			//			if(this._model.interfaceStage.stage.loaderInfo.parameters.cbPlayState != undefined 
			//				&& this._model.interfaceStage.stage.loaderInfo.parameters.cbPlayState != null)
			//			{
			//				ExternalInterface.call(this._model.interfaceStage.stage.loaderInfo.parameters.cbPlayState, 
			//					(e as PlayEvent).playState);
			//			}
			//			
		}
		
		private function _externalSetPlayState(state : String) : Boolean
		{
						
			switch(state)
			{
				
				case ControlEvent.CONTROL_PLAY:
				case ControlEvent.CONTROL_PAUSE:
				case ControlEvent.CONTROL_STOP:
					this.dispatchEvent(new ControlEvent(state));
					return true;
					break;
				
				default:
					return false;
					break;
				
			}
			
		}
		 
		private function _externalGetTime() : Number
		{
			
			return this._model.video.timeCurrent;
		}
		
		private function _releaseWatchers() : void
		{

			//trace("ControlBar:_releaseWatchers");
			
			if(this._watcherTimeCurrent != null)
			{
				this._watcherTimeCurrent.unwatch();
				this._watcherTimeCurrent = null;
			}
			
			if(this._watcherTimeDuration != null)
			{
				this._watcherTimeDuration.unwatch();
				this._watcherTimeDuration = null;
			}
			
			if(this._watcherPlayState != null)
			{
				this._watcherPlayState.unwatch();
				this._watcherPlayState = null;
			}
			
			if(this._watcherMediaType != null)
			{
				this._watcherMediaType.unwatch();
				this._watcherMediaType = null;
			}
			
		}
		
		private function _updateDisplayList() : void
		{
			
			this._backround.width = this._width;
			
			this._btnPlayPause.x = EDGE_PADDING;
			this._btnPlayPause.y = this._backround.height - (this._btnPlayPause.height + EDGE_PADDING);
			
			this._btnNext.x = this._btnAudio.x + this._btnAudio.width + BUTTON_PADDING;
			this._btnNext.y = this._backround.height - (this._btnNext.height + EDGE_PADDING);
			
			this._btnFullscreen.x = this._width - (this._btnFullscreen.width + EDGE_PADDING);
			this._btnFullscreen.y = this._backround.height - (this._btnPlayPause.height + EDGE_PADDING);
			
			this._btnAudio.x = this._btnFullscreen.x - (this._btnAudio.width + (BUTTON_PADDING / 2));
			this._btnAudio.y = this._backround.height - (this._btnAudio.height + EDGE_PADDING);
			
			this._lblMovieTitle.x = this._width / 2;
			this._lblMovieTitle.y = this._btnPlayPause.y + (this._btnPlayPause.height / 2);
			
			this._lblTimeCode.x = this._width - EDGE_PADDING;
			this._lblTimeCode.y = this._btnFullscreen.y - (this._lblTimeCode.height + SECOND_OFFEST);
			
			this._lblLive.x = EDGE_PADDING;
			this._lblLive.y = this._backround.height - (this._lblLive.height + (EDGE_PADDING * 2/3));
			
			this._scrubber.x = EDGE_PADDING;
			this._scrubber.y = this._lblTimeCode.y + (this._lblTimeCode.height / 2);
			this._scrubber.resize(this._width - ((EDGE_PADDING * 2) + this._lblTimeCode.width ));
			this._updateScrubberPlayback();
			
		}
		
		public function reset() : void
		{
			
			this._scrubber.reset();
			this._btnPlayPause.buttonState = ButtonPlayPause.STATE_PLAY;
			
		}
		
		public function resize( width : Number ) : void
		{
			
			this._width = width;
			
			this._updateDisplayList();
			
		}
		
		public function _updateScrubberPlayback() : void
		{
			
			if(this._model.video != null)
				this._scrubber.updatePlayback(this._model.video.timeCurrent / this._model.video.timeDuration);

		}
		
		private function _onChangeMediaType( type : String ) : void
		{
			
			switch(type)
			{
				
				case HLSTypes.LIVE:
					this._lblTimeCode.visible = false;
					this._lblLive.visible = true;
					this._scrubber.visible = false;
					this._btnPlayPause.visible = false;
					break;
				
				case HLSTypes.VOD:
					this._lblTimeCode.visible = true;
					this._lblLive.visible = false;
					this._scrubber.visible = true;
					this._btnPlayPause.visible = true;
					break;
				
				default:
					break;
				
			}
			
		}
		
		private function _onChangePlayState( state : String ) : void
		{
			
			//trace("ControlBar:_onChangePlayState:" + state);
			
			switch(state)
			{
				
				
				case HLSPlayStates.PAUSED:
				case HLSPlayStates.IDLE:
				case HLSPlayStates.PAUSED_BUFFERING:
					this._btnPlayPause.buttonState = ButtonPlayPause.STATE_PAUSE;	
					break;
				
				case HLSPlayStates.PLAYING:
				case HLSPlayStates.PLAYING_BUFFERING:
					this._btnPlayPause.buttonState = ButtonPlayPause.STATE_PLAY;
					break;
				
				default:
					//trace("VideoPlayer::_onEvent::" + e.type + "::" + (e as PlayEvent).playState);
					throw new Error("GawkWebPlayer:ControlBar: ERROR Play State :" + state + " not found.");
					break;
				
			}
			
		}
		
		private function _onChangeTimeCurrent( time : Number ) : void
		{
			//trace("ControlBar:_onChangeTimeCurrent:" + this._timeFormatter.format(new Date(time * 1000)));

			this._lblTimeCode.label.text = DateUtils.convertSecondsToTime(time );//this._model.video.timeDuration -
			
			this._updateScrubberPlayback();
						
		}
		
		private function _onChangeTimeDuration( time : Number ) : void
		{
			
			//trace("ControlBar:_onChangeTimeDuration:" + this._timeFormatter.format(new Date(time * 1000)));
			this._lblTimeCode.label.text = DateUtils.convertSecondsToTime(time);
			
		}
		
		private function _onChangeVideo( video : VOVideo ) : void
		{
			
			this._releaseWatchers();
			
			if(video != null)
			{
				//trace("ControlBar:_onChangeVideo");
				
				this._lblMovieTitle.label.htmlText = this._model.video.title;
				
				this._lblMovieTitle.label.autoSize = TextFieldAutoSize.CENTER;
				
				this._watcherPlayState = BindingUtils.bindSetter(_onChangePlayState, this._model.video, "playState");
				
				this._watcherTimeDuration = BindingUtils.bindSetter(_onChangeTimeDuration, this._model.video, "timeDuration");
				
				this._watcherTimeCurrent = BindingUtils.bindSetter(_onChangeTimeCurrent, this._model.video, "timeCurrent");
				
				this._watcherMediaType = BindingUtils.bindSetter(_onChangeMediaType, this._model.video, "mediaType");
				
			}
			
			this.reset();
			
			this._updateDisplayList();
			
		}
		
		private function _onScrubDown( e : ControlEvent ) : void
		{
			
			//trace("ControlBar:_onScrubDown");
			
			this.dispatchEvent(new ControlEvent(ControlEvent.CONTROL_PAUSE, e.percent));
			
		}
		
		private function _onScrubUp( e : ControlEvent ) : void
		{
			
			//trace("ControlBar:_onScrubUp");
			
			this.dispatchEvent(new ControlEvent(ControlEvent.CONTROL_SEEK, e.percent));
		
		}
		
		private function _onMouseFullscreen( e : MouseEvent ) : void
		{
			
			//trace("Controlbar::_onMouseFullscreen");
			
			if(this._model.interfaceStage.stage.displayState == StageDisplayState.NORMAL) 
			{
				
				//ExternalInterface.call("playbackEvent", "fullscreenEnter");
				this._model.interfaceStage.stage.displayState = StageDisplayState.FULL_SCREEN;
			
			} else {
				
				//ExternalInterface.call("playbackEvent", "fullscreenLeave");
				this._model.interfaceStage.stage.displayState = StageDisplayState.NORMAL;
				
			}
		
		}
		
		private function _onMouseNext( e : MouseEvent ) : void
		{
			
			//trace("ControlBar:_onMouseNext");
			e.stopImmediatePropagation();
			
			this.dispatchEvent(new ControlEvent(ControlEvent.CONTROL_NEXT));
			
		}
		
		private function _onMousePlayPause( e : MouseEvent ) : void
		{
			
			trace("ControlBar:_onMousePlayPause::" + this._model.video.playState);
			e.stopImmediatePropagation();
			
			switch(this._model.video.playState)
			{
				
				case HLSPlayStates.PAUSED:
				case HLSPlayStates.IDLE:
				case HLSPlayStates.PAUSED_BUFFERING:
					this.dispatchEvent(new ControlEvent(ControlEvent.CONTROL_PLAY));
					break;
				
				case HLSPlayStates.PLAYING:
				case HLSPlayStates.PLAYING_BUFFERING:
					this.dispatchEvent(new ControlEvent(ControlEvent.CONTROL_PAUSE));
					break;
				
				default:
					//trace("VideoPlayer::_onEvent::" + e.type + "::" + (e as PlayEvent).playState);
					throw new Error("ControlBar:_onMousePlayPause:ERROR Play State :" + this._model.video.playState + " not found.");
					break;
				
			}
			
		}
		
		private function _onStageAdd( e : Event ) : void
		{
			
			//trace("ControlBar:_onstageAdd");
			
			this.removeEventListener(Event.ADDED_TO_STAGE, _onStageAdd);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, _onStageRemove);
			
			this._btnFullscreen.addEventListener(MouseEvent.MOUSE_UP, _onMouseFullscreen);
			
			this._btnNext.addEventListener(MouseEvent.MOUSE_UP, _onMouseNext);
			
			this._btnPlayPause.addEventListener(MouseEvent.MOUSE_UP, _onMousePlayPause);
			
			this._scrubber.addEventListener(ControlEvent.SCRUB_DOWN, _onScrubDown);
			
			this._scrubber.addEventListener(ControlEvent.SCRUB_UP, _onScrubUp);
			
			this._watcherVideo = BindingUtils.bindSetter(_onChangeVideo, this._model, "video");
			
		}
		
		private function _onStageRemove( e : Event ) : void
		{
			
			//trace("ControlBar:_onStageRemove");
			
			if(this._watcherVideo != null)
			{
				this._watcherVideo.unwatch();
				this._watcherVideo = null;
			}
			
			this._releaseWatchers();
			
			this.addEventListener(Event.ADDED_TO_STAGE, _onStageAdd);
			
			this._btnFullscreen.removeEventListener(MouseEvent.MOUSE_UP, _onMouseFullscreen);
			
			this._btnNext.removeEventListener(MouseEvent.MOUSE_UP, _onMouseNext);
			
			this._btnPlayPause.removeEventListener(MouseEvent.MOUSE_UP, _onMousePlayPause);
			
			this._scrubber.removeEventListener(ControlEvent.SCRUB_DOWN, _onScrubDown);
			
			this._scrubber.removeEventListener(ControlEvent.SCRUB_UP, _onScrubUp);
			
			this.removeEventListener(Event.REMOVED_FROM_STAGE, _onStageRemove);
			
		}
		
	}
	
}