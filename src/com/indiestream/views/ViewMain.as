package com.indiestream.views
{
	
	import com.indiestream.common.Constants;
	import com.indiestream.model.Model;
	import com.indiestream.model.VOVideo;
	import com.indiestream.sceens.ScreenLoading;
	import com.indiestream.sceens.ScreenPlayer;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	
	
	public class ViewMain extends Sprite
	{
		
		public function ViewMain()
		{
			
			ExternalInterface.call("playerEvent", "ViewMain:init");
			
			//trace("ViewMain:constructor");
			
			super();
		
			this._model = Model.getInstance();
			
			this.addEventListener(Event.ADDED_TO_STAGE, _onStageAdd);
			
		}
		
		
		private var _model : Model;
		
		private var _scnLoading : ScreenLoading;
		
		private var _scnPlayer : ScreenPlayer;
		
		private var _watcherState : ChangeWatcher;
		
		private var _watcherVideo : ChangeWatcher;
		
		
		public function resize() : void
		{
			this._updateDisplayList();
		}
		
		private function _externalLoadMedia( objVideo : String ) : void
		{
			
			trace("_externalLoadMedia");
			
			ExternalInterface.call("playerEvent", "ViewMain:_externalLoadMedia");
			
			var video : Object = JSON.parse(objVideo);

			//for (var item : String in video) {
			//	ExternalInterface.call("playerEvent", "--->" + item + "=>" + video[item]);
				//trace(item + " => " + video[item]);
			//}
			
			this._model.video = new VOVideo(video.url, video.title);
			
		}
		
		private function _updateDisplayList() : void
		{
			
			//trace("ViewMain::_updateDisplayList");
			if(this.contains(this._scnLoading))
			{
				this._scnLoading.resize();
			}
			
			if(this.contains(this._scnPlayer))
			{
				this._scnPlayer.resize();
			}
			
		}
		
		
		private function _onChangeState( state : uint ) : void
		{
			
			ExternalInterface.call("playerEvent", "ViewMain:_onChangeState");
			
			//trace("ViewMain:_onChangeState:" + state);
			
			//if(this.numChildren > 0)
			//{
				//trace("ViewMain:_onChangeState:REMOVE CHILDREN");
				//this.removeChildren();
			//}
			
			switch(state)
			{
				
				case Constants.VIEW_NULL:
					ExternalInterface.call("playerEvent", "ViewMain:state_null");
					this.removeChildren();
					break;
				
				case Constants.VIEW_LOADING:
					//trace("ViewMain:_onChangeState:LOADING");
					ExternalInterface.call("playerEvent", "ViewMain:state_loading");
					this.addChild(this._scnPlayer);
					this.addChild(this._scnLoading);
					
					break;
				
				case Constants.VIEW_PLAYER:
					//trace("ViewMain:_onChangeState:PLAYER");
					ExternalInterface.call("playerEvent", "ViewMain:state_player");
					this.removeChild(this._scnLoading);
					//this.addChild(this._scnPlayer);
					break;
				
				default:
					throw new Error("ViewMain:_onChangeState:state " + state + " not found.");
					break;
				
			}
			
			this._updateDisplayList();
			
		}
		
		private function _onChangeVideo( video : VOVideo ) : void
		{
			
			
			ExternalInterface.call("playerEvent", "ViewMain:_onChangeVideo");
			
			if(video == null )
			{
				
				ExternalInterface.call("playerEvent", "ViewMain:video_null");
				
				this._model.viewState = Constants.VIEW_NULL;
				
				//trace("ViewMain:_onChangeVideo:LOADING");
				//this._model.viewState = Constants.VIEW_LOADING;
			
			} else {
				
				ExternalInterface.call("playerEvent", "ViewMain:video_set");
				
				this._model.viewState = Constants.VIEW_LOADING;
				
				//trace("ViewMain:_onChangeVideo:PLAYING");
				//this._model.viewState = Constants.VIEW_PLAYER;
			
			}
			
			
		}
		
		private function _onStageAdd( e : Event ) : void
		{
			
			ExternalInterface.call("playerEvent", "ViewMain:_onStageAdd");
			
			//trace("ViewMain:_onStageAdd");
			
			this._scnLoading = new ScreenLoading();
			
			this._scnPlayer = new ScreenPlayer();
			
			this._watcherState = BindingUtils.bindSetter(_onChangeState, this._model, "viewState");
			
			this._watcherVideo = BindingUtils.bindSetter(_onChangeVideo, this._model, "video");
			
			ExternalInterface.addCallback("loadMedia", _externalLoadMedia);	
			
			
			
			if(this._model.interfaceStage.stage.loaderInfo.parameters.id != undefined && this._model.interfaceStage.stage.loaderInfo.parameters.id != null)
			{
				ExternalInterface.call("playerLoaded", this._model.interfaceStage.stage.loaderInfo.parameters.id);
			} else {
				
				ExternalInterface.call("playerLoaded", 'undefined');
				
			}
			
			
		}
		
	}
	
}