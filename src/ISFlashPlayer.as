package
{
	
	import com.indiestream.common.Constants;
	import com.indiestream.model.Model;
	import com.indiestream.views.ViewMain;
	import com.confluence.core.managers.ManagerStage;
	
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	
	
	public class ISFlashPlayer extends MovieClip
	{
		
		
		public function ISFlashPlayer()
		{
			
			ExternalInterface.call("growhousePlaybackEvent", "start");
			
			super();			
			
			/*
			* TODO:
			* Centralize the external interface calls.
			*		VideoPlayer, ControlBar, Main
			*/
			
			this._model = Model.getInstance(stage);
			
			ManagerStage.getInstance(stage).activate();
			
			stage.frameRate = 31;
			stage.color = 0;
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			this.addEventListener(Event.ADDED_TO_STAGE, _onStageAdd);	
			
		}
		
		
		private var _model : Model;
		
		private var _viewMain : ViewMain;
		
		private var _watcherResize : ChangeWatcher;
		
		
		private function _onStageAdd( e : Event = null ) : void
		{
			
			ExternalInterface.call("playbackEvent", "Main:stageAdd");
			
			//trace("Main:_onStageAdd");
			
			this._viewMain = new ViewMain();
			this.addChild(this._viewMain);
			
			this._watcherResize = BindingUtils.bindSetter(_onChangeStageSize, this._model.interfaceStage, "stageDim");
			
		}
		
		private function _onChangeStageSize( size : Point ) : void
		{
			
			ExternalInterface.call("playbackEvent", "_onChangeStageSize");
			
			//trace('Main:_onChangeStageSize:' + size.x + ':' + size.y);
			this._viewMain.resize();
			
		}
		
	}
	
}