package com.indiestream.controls.videoplayer
{
	
	import com.indiestream.common.Constants;
	import com.indiestream.controls.dialogs.DialogsOverlay;
	import com.indiestream.events.ControlEvent;
	import com.indiestream.model.Model;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.utils.Timer;
	
	import mx.binding.utils.ChangeWatcher;
	
	import org.mangui.hls.HLS;
	import org.mangui.hls.constant.HLSPlayStates;
	import org.mangui.hls.constant.HLSTypes;
	import org.mangui.hls.event.HLSEvent;
	
	public class VideoPlayer extends Sprite
	{
		
		
		public static const DEFAULT_HEIGHT : uint = 420;
		
		public static const DEFAULT_WIDTH : uint = 640;
		
		public static const STATE_NULL : String = "";
		
		
		public function VideoPlayer()
		{
			
			super();
			
			this._model = Model.getInstance();
			
			this._createChildren();
			
		}
		
		private var _audioLevel : Number = 1;
		
		private var _btnBackgroundPlay : Sprite;
		
		private var _buffering : Boolean = false;
		
		private var _dialogOverlay : DialogsOverlay;
		
		private var _hls : HLS;
		
		private var _isFirst : Boolean = true;
		
		private var _model : Model;
		
		private var _seeking : Boolean = false;
		
		private var _sound : Sound; 
		
		private var _timerTimeout : Timer;
		
		private var _video : Video;
		
		private var _videoDimentions : Point = new Point(DEFAULT_WIDTH, DEFAULT_HEIGHT);
		
		private var _watcherAudioLevel : ChangeWatcher;
		
		
		private var _dimentions : Point = new Point(DEFAULT_WIDTH, DEFAULT_HEIGHT);
		
		public function set dimentions( dim : Point ) : void
		{
			
			if(this._dimentions !== dim)
			{
				
				this._dimentions = dim;
				this._updateDisplayList();
				
			}
			
		}
		
		public function get dimentions() : Point
		{
			return this._dimentions;
		}
		
		
		public function controlPlayer( event : ControlEvent ) : void
		{
			
			//trace("VideoPlayer::controlPlayer:" + event.type);
			
			event.stopImmediatePropagation();
			
			switch(event.type)
			{
				
				case ControlEvent.CONTROL_PAUSE:
					this._hls.stream.pause();
					break;
				
				case ControlEvent.CONTROL_PLAY:
					this._hls.stream.resume();
					break;
				
				case ControlEvent.CONTROL_STOP:
					this._hls.stream.pause();
					break;

				case ControlEvent.CONTROL_SEEK:
					//trace("VideoPlayer::controlPlayer::seek::" +this._model.video.timeDuration + " " + event.percent);
					var time : Number = Math.round(event.percent * this._model.video.timeDuration);
					this._seeking = true;
					this._hls.stream.seek(time);
					this._hls.stream.resume();
					break;
				
				default:
					throw new Error("VideoPlayer:controlPlayer:ERROR event type " + event.type + " not found.");
					break;
				
			}	
			
		}
		
		public function loadMedia() : void
		{
			
			//trace("VideoPlayer::loadMedia::" + this._model.video.urlMedia);
			
			this.reset();
			
			this._isFirst = true;
			
			this._hls.load(this._model.video.urlMedia);
			
			this._updateDisplayList();
			
		}
		
		public function reset() : void
		{
			
			//this.removeEventListener(Event.ENTER_FRAME, _onEnterFrame);
			
			if(this._hls != null)
			{
				
				if( this._hls.playbackState == HLSPlayStates.PLAYING || 
					this._hls.playbackState == HLSPlayStates.PAUSED_BUFFERING || 
					this._hls.playbackState == HLSPlayStates.PLAYING_BUFFERING ) 
				{
					this.stop();
				}
				
				this._listenersVideoPlayerRemove();
				
				this._hls = null;
				
			}
			
			this._hls = new HLS();
			
			if(this.stage)
				this._hls.stage = this.stage;
			
			//this._hls.stream.bufferTime = Constants.BUFFER_TIME_LOAD;
			this._hls.stream.inBufferSeek = true;
			this._updateAudio();
			
			if(this._video != null) {
				
				if(this.contains(this._video)) 
					this.removeChild(this._video);
				
				this._video = null;
				
			}
			
			this._video = new Video(this._dimentions.x, this._dimentions.y);
			this._video.smoothing = true;
			this._video.attachNetStream(this._hls.stream);
			
			this._listenersVideoPlayerAdd();
			
			this.addChildAt(this._video, 0);

		}
		
		public function stop() : void
		{
			//this._();
			this._hls.stream.pause();
			this._hls.stream.seek(0);
		}
		
		public function volume( volume : Number ) : void
		{
			this._audioLevel = volume;
			this._updateAudio();
		}
		
		private function _createChildren() : void
		{
			
			this._dialogOverlay = new DialogsOverlay(this._model.interfaceStage.stageDim.x, this._model.interfaceStage.stageDim.y);
			this.addChild(this._dialogOverlay);
			
			this._btnBackgroundPlay = new Sprite();
			with(this._btnBackgroundPlay)
			{
				graphics.beginFill(0,0);
				graphics.drawRect(0,0,10,10);
				graphics.endFill();
				buttonMode = true;
				useHandCursor = false;
			}
			this.addChild(this._btnBackgroundPlay);
			
			this._timerTimeout = new Timer(Constants.LOADING_TIMEOUT);
			this._timerTimeout.addEventListener(TimerEvent.TIMER, _onTimeout);
			
			ExternalInterface.addCallback("setTime", _externalSetTime);	
			
		}
		
		private function _externalSetTime( time : Number ) : Boolean
		{
		
			this._hls.stream.seek(time);
			
			return true;
			
		}
		
		private function _listenersVideoPlayerAdd() : void
		{
			
			//trace("VideoPlayer:_listenersVideoPlayerAdd");
			
			for each(var event : String in [
				
				HLSEvent.MANIFEST_LOADING,
				HLSEvent.MANIFEST_PARSED,
				HLSEvent.MANIFEST_LOADED,
				HLSEvent.LEVEL_LOADING,
				HLSEvent.LEVEL_LOADED,
				HLSEvent.LEVEL_SWITCH,
				HLSEvent.LEVEL_ENDLIST,
				HLSEvent.FRAGMENT_LOADING,
				HLSEvent.FRAGMENT_LOADED,
				HLSEvent.FRAGMENT_LOAD_EMERGENCY_ABORTED,
				HLSEvent.FRAGMENT_PLAYING,
				HLSEvent.FRAGMENT_SKIPPED,
				HLSEvent.AUDIO_TRACKS_LIST_CHANGE,
				HLSEvent.AUDIO_TRACK_SWITCH,
				HLSEvent.AUDIO_LEVEL_LOADING,
				HLSEvent.AUDIO_LEVEL_LOADED,
				HLSEvent.TAGS_LOADED,
				HLSEvent.LAST_VOD_FRAGMENT_LOADED,
				HLSEvent.WARNING,
				HLSEvent.ERROR,
				HLSEvent.MEDIA_TIME,
				HLSEvent.PLAYBACK_STATE,
				HLSEvent.SEEK_STATE,
				HLSEvent.PLAYBACK_COMPLETE,
				HLSEvent.PLAYLIST_DURATION_UPDATED,
				HLSEvent.ID3_UPDATED,
				HLSEvent.STAGE_SET,
				HLSEvent.FPS_DROP,
				HLSEvent.FPS_DROP_LEVEL_CAPPING,
				HLSEvent.FPS_DROP_SMOOTH_LEVEL_SWITCH,
				HLSEvent.LIVE_LOADING_STALLED
				
			])
			{
				if( this._hls.stream != null ){
					this._hls.addEventListener(event, _onVideoEvent);		
				}
					
			}
			
		}
		
		private function _listenersVideoPlayerRemove() : void
		{
			
			//trace("VideoPlayer:_listenersVideoPlayerRemove");
			
			for each(var event : String in [
				
				HLSEvent.MANIFEST_LOADING,
				HLSEvent.MANIFEST_PARSED,
				HLSEvent.MANIFEST_LOADED,
				HLSEvent.LEVEL_LOADING,
				HLSEvent.LEVEL_LOADED,
				HLSEvent.LEVEL_SWITCH,
				HLSEvent.LEVEL_ENDLIST,
				HLSEvent.FRAGMENT_LOADING,
				HLSEvent.FRAGMENT_LOADED,
				HLSEvent.FRAGMENT_LOAD_EMERGENCY_ABORTED,
				HLSEvent.FRAGMENT_PLAYING,
				HLSEvent.FRAGMENT_SKIPPED,
				HLSEvent.AUDIO_TRACKS_LIST_CHANGE,
				HLSEvent.AUDIO_TRACK_SWITCH,
				HLSEvent.AUDIO_LEVEL_LOADING,
				HLSEvent.AUDIO_LEVEL_LOADED,
				HLSEvent.TAGS_LOADED,
				HLSEvent.LAST_VOD_FRAGMENT_LOADED,
				HLSEvent.WARNING,
				HLSEvent.ERROR,
				HLSEvent.MEDIA_TIME,
				HLSEvent.PLAYBACK_STATE,
				HLSEvent.SEEK_STATE,
				HLSEvent.PLAYBACK_COMPLETE,
				HLSEvent.PLAYLIST_DURATION_UPDATED,
				HLSEvent.ID3_UPDATED,
				HLSEvent.STAGE_SET,
				HLSEvent.FPS_DROP,
				HLSEvent.FPS_DROP_LEVEL_CAPPING,
				HLSEvent.FPS_DROP_SMOOTH_LEVEL_SWITCH,
				HLSEvent.LIVE_LOADING_STALLED
				
			])
			{
				if( this._hls.stream != null )
					this._hls.removeEventListener(event, _onVideoEvent);		
			}
			
		}
		private function _updateDisplayList() : void
		{
			//trace("VideoPlayer::_updateDisplayList");
			
			if (this._video != null) {
				
				if((this._videoDimentions.x / this._videoDimentions.y) >
					(this._dimentions.x / this._dimentions.y)){
					
						this._video.width = this._dimentions.x;
						this._video.height = this._videoDimentions.y * ( this._dimentions.x / this._videoDimentions.x );
						this._video.x = 0;
						this._video.y = (this._dimentions.y - this._video.height) / 2;
						
					} else {
						
						this._video.height = this._dimentions.y;
						this._video.width = this._videoDimentions.x * ( this._dimentions.y / this._videoDimentions.y );
						this._video.y = 0;
						this._video.x = (this._dimentions.x - this._video.width) / 2;
						
					}
				
				
			}
			
			this._btnBackgroundPlay.width = this._dimentions.x;
			this._btnBackgroundPlay.height = this._dimentions.y;
			
			this._dialogOverlay.dimentions = new Point(this._dimentions.x, this._dimentions.y);
			this._dialogOverlay.updateDisplayList();
			
		}
		
		private function _updateAudio() : void
		{
			if(this._hls != null)
			{
				var st:SoundTransform = this._hls.stream.soundTransform;
				st.volume = this._audioLevel;
				this._hls.stream.soundTransform = st;
			}
			
		}
		
		private function _onEnterFrame( e : Event ) : void
		{
			
			var time : Number = (this._hls.stream.bufferLength / this._hls.stream.bufferTime);
			
			time = (time <= 1) ? Math.round(time * 100) : 100; 
			
			this._model.video.loadedAmount = time;
			
		}
		
		private function _onMouseUpPlay( e : MouseEvent ) : void
		{
			
			if(this._hls.playbackState == "playing" || this._hls.playbackState == "playing_buffering")
			{
				this._hls.stream.pause();
			} else {
				this._hls.stream.resume();
			}
			
		}
		
		private function _onStageAdd( e : Event ) : void
		{
			
			//trace("VideoPlayer:_onStageAdd");
			
			if(this._hls)
				this._hls.stage = this.stage;
			
			//this._watcherAudioLevel = BindingUtils.bindSetter(_onChangeVideo, this._model.video, "audioLevel");
			
			this.removeEventListener(Event.ADDED_TO_STAGE, _onStageAdd);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, _onStageRemove);
			
		}
		
		private function _onStageRemove( e : Event ) : void
		{
			
			this.addEventListener(Event.ADDED_TO_STAGE, _onStageAdd);
			
			this.removeEventListener(Event.REMOVED_FROM_STAGE, _onStageRemove);
			
		}
		
		private function _onTimeout( e : TimerEvent ) : void
		{
			
			// Insert Error Code Here
			this.reset();
			this._dialogOverlay.state = DialogsOverlay.STATE_ERROR;
		}
		
		private function _onVideoEvent( e : HLSEvent ) : void
		{
			
			
			trace("VideoPlayer:_onVideoEvent:" + e.type );
			
			switch(e.type)
			{
				
				case HLSEvent.ERROR:
					trace('VideoPlayer:_onVideoEvent:MediaError');
					//this.reset();
					this._dialogOverlay.state = DialogsOverlay.STATE_ERROR;
					break;
				
				case HLSEvent.LIVE_LOADING_STALLED:
					trace('VideoPlayer:_onVideoEvent:LIVE_LOADING_STALLED');
					break;
				
				case HLSEvent.MANIFEST_LOADED:
					
					ExternalInterface.call("playerEvent", "ready");
					
					this._model.video.mediaType = this._hls.type;
					
					this._videoDimentions = new Point(e.levels[this._hls.startLevel].width, e.levels[this._hls.startLevel].height);
					
					this._updateDisplayList();
					
					
					
					if(this._model.video.mediaType == HLSTypes.VOD)
					{
						this._model.video.timeDuration = e.levels[this._hls.startLevel].duration;
						this._hls.stream.play(null, 0);
					} else {
						this._hls.stream.play(null, -1);
					}
						
					
					break;
				
				
				case HLSEvent.MANIFEST_LOADING:
					ExternalInterface.call("playerEvent", "loading");
					//this._ctlDialogs.state = VideoDialogsOverlay.STATE_LOADING;
					this._timerTimeout.start();
					break;
				
				case HLSEvent.MEDIA_TIME:
					
					trace("VideoPlayer::_onVideoEvent:timeChange:" + e.mediatime.position + "::" + this._hls.playbackState);
					this._model.video.timeCurrent = e.mediatime.position;
//					if(this._model.video.mediaType == HLSTypes.VOD)
//					{
//						
//					}
					break;
				
				case HLSEvent.PLAYBACK_COMPLETE:
					ExternalInterface.call("playerEvent", "complete");
					break;
				
				case HLSEvent.PLAYBACK_STATE:
					
					trace("VideoPlayer::" + HLSEvent.PLAYBACK_STATE + "::" + this._hls.playbackState);
					
					if(this._model.video.playState != this._hls.playbackState)
					{
						
						switch(this._hls.playbackState)
						{
							
							case HLSPlayStates.PAUSED_BUFFERING:
							case HLSPlayStates.PLAYING_BUFFERING:
								
								if(!_buffering)
								{
									this._timerTimeout.stop();
									this._timerTimeout.reset();
									this._model.video.isBuffering = true;
									this._btnBackgroundPlay.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUpPlay);
									
									if(this._isFirst)// && this._model.videoType != VideoType.VIDEO_TYPE_LIVE)
									{
										this.addEventListener(Event.ENTER_FRAME, _onEnterFrame);
										this._dialogOverlay.state = DialogsOverlay.STATE_BUFFERING;
										//this._hls.stream.pause();
										//this._hls.stream.resume();
										this._isFirst = false;
									}
									
									//this._hls.stream.bufferTime = Constants.BUFFER_TIME_LOAD;
									
									
									_buffering = true;
									
									this._model.video.playState = this._hls.playbackState;
									
								}
								 
								break;
							
							case HLSPlayStates.PAUSED:
								
								if(this._seeking)
									this._seeking = false;
								
								this._model.video.playState = this._hls.playbackState;
								break;
							
							case HLSPlayStates.PLAYING:
								
								if(this._model.viewState == Constants.VIEW_LOADING)
								{
									this.removeEventListener(Event.ENTER_FRAME, _onEnterFrame);
									this._model.viewState = Constants.VIEW_PLAYER;
								}
								
								if(this._seeking)
								{
									this._seeking = false;
									//this._hls.stream.pause();
									//this._hls.stream.resume();
								}
								
								if(_buffering)
								{
									
									this._btnBackgroundPlay.addEventListener(MouseEvent.MOUSE_UP, _onMouseUpPlay);
									this._model.video.isBuffering = false;
									
									if(this._hls.stream.bufferTime != Constants.BUFFER_TIME_PLAY)
									{
										//this._hls.stream.bufferTime = Constants.BUFFER_TIME_PLAY;
										this._dialogOverlay.state = DialogsOverlay.STATE_OFF;
									}
									
									_buffering = false;
									
								}
								
								this._model.video.playState = this._hls.playbackState;
								
								break;
							
							default:
								//trace("VideoPlayer::_onEvent::" + e.type + "::" + (e as PlayEvent).playState);
								//throw new Error("VideoPlayer: ERROR Play State :" + (e as PlayEvent).playState + " not found.");
								break;
							
						}
						
					}
					
					break;
				
				default:
					//trace("VideoPlayer::_onEvent::" + e.type + "::" + getQualifiedClassName(e));
					break;
				
			}
			
		}
		
	}
	
}