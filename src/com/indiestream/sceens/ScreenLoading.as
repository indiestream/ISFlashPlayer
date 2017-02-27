package com.indiestream.sceens
{
	
	
	import com.indiestream.model.Model;
	import com.indiestream.model.VOVideo;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	
	import ui.ControlLoading;
	import ui.ControlMovieLabel;
	import ui.GraphicLoaderBackground;
	import ui.GraphicLoadingBackgroundImage;
	
	
	public class ScreenLoading extends Sprite
	{
		
		
		public static const BOTTOM_LABEL_OFFEST : Number = 35; 
		
		
		public function ScreenLoading()
		{
			
			super();
			
			this._model = Model.getInstance();
			
			this._createChildren();
			
			this.mouseChildren = false;
			
			this.addEventListener(Event.ADDED_TO_STAGE, _onStageAdd);
			
		}
		
		
		private var _background : GraphicLoaderBackground;
		
		private var _bottomLabel : ControlMovieLabel;
		
		private var _cntLoading : ControlLoading;
		
		private var _grcBackground : GraphicLoadingBackgroundImage;
		
		private var _mskBck : Sprite;
		
		private var _model : Model;
		
		private var _watcherPercent : ChangeWatcher;
		
		private var _watcherVideo : ChangeWatcher;
		
		
		public function resize() : void
		{
		
			//trace("ScreenLoading::resize");
			this._updateDisplayList();
		
		}
		
		private function _createChildren() : void
		{
			
			this._background = new GraphicLoaderBackground();
			this.addChild(this._background);
			
			this._grcBackground = new GraphicLoadingBackgroundImage();
			this.addChild(this._grcBackground);
			
			this._mskBck = new Sprite();
			with(this._mskBck)
			{
				graphics.beginFill(0);
				graphics.drawRect(0, 0, 10, 10);
				graphics.endFill();
			}
			this.addChild(this._mskBck);
			
			this._grcBackground.mask = this._mskBck;
			
			this._bottomLabel = new ControlMovieLabel();
			this.addChild(this._bottomLabel);
			
			this._cntLoading = new ControlLoading();
			this.addChild(this._cntLoading);
			
		}
		
		private function _releaseWatchers() : void
		{
			
			//trace("ControlBar:_releaseWatchers");
			
			if(this._watcherPercent != null)
			{
				this._watcherPercent.unwatch();
				this._watcherPercent = null;
			}
			
		}
		
		private function _updateDisplayList() : void
		{
			
			//trace("ScreenLoading::_updateDisplayList");
			
			with(this._background)
			{
				x = 0;
				y = 0;
				width = this._model.interfaceStage.stageDim.x;
				height = this._model.interfaceStage.stageDim.y;
			}
			
			with(this._mskBck)
			{
				width = this._model.interfaceStage.stageDim.x;
				height = this._model.interfaceStage.stageDim.y;
			}
			
			with(this._bottomLabel)
			{
				label.autoSize = TextFieldAutoSize.CENTER;
				x = this._model.interfaceStage.stageDim.x / 2;
				y = this._model.interfaceStage.stageDim.y - (this._bottomLabel.height + BOTTOM_LABEL_OFFEST);
			}
			
			with(this._grcBackground)
			{
				x = this._model.interfaceStage.stageDim.x / 2;
				y = this._model.interfaceStage.stageDim.y / 2;
			}
			
			with(this._cntLoading)
			{
				x = this._model.interfaceStage.stageDim.x / 2;
				y = this._model.interfaceStage.stageDim.y / 2;
			}
			
		}
		
		
		private function _onStageAdd( e : Event ) : void
		{
			
			//trace("ScreenLoading:_onstageAdd");
			
			this.removeEventListener(Event.ADDED_TO_STAGE, _onStageAdd);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, _onStageRemove);
			
			this._watcherVideo = BindingUtils.bindSetter(_onChangeVideo, this._model, "video");
			
		}
		
		private function _onStageRemove( e : Event ) : void
		{
			
			//trace("ScreenLoading:_onStageRemove");
			
			this._watcherVideo.unwatch();
			this._watcherVideo = null;
			
			this._releaseWatchers();
			
			this.addEventListener(Event.ADDED_TO_STAGE, _onStageAdd);
			
			this.removeEventListener(Event.REMOVED_FROM_STAGE, _onStageRemove);
			
		}
		
		
		private function _onChangePercentLoaded( amount : uint ) : void
		{
			
			this._cntLoading.percentLabel.text = amount.toString();
			
			this._updateDisplayList();
			
		}
		
		
		private function _onChangeVideo( video : VOVideo ) : void
		{
			
			if(video != null)
			{
				
				this._bottomLabel.label.htmlText = video.title;
				
				this._updateDisplayList();
				
				this._watcherPercent = BindingUtils.bindSetter(_onChangePercentLoaded, this._model.video, "loadedAmount");
				
			} else {
				
				this._bottomLabel.label.htmlText = '';
				this._releaseWatchers();
				
			}
			
			this._bottomLabel.label.autoSize = TextFieldAutoSize.CENTER;
			
		}
		
	}
	
}