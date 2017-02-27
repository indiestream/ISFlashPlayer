package com.indiestream.model
{
	
	/**
	 * @author Kiwi-Works, LLC
	 */
	
	import com.indiestream.common.Constants;
	import com.confluence.core.managers.interfaces.InterfaceStage;
	
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.events.PropertyChangeEvent;
	
	
	public class Model extends EventDispatcher implements IEventDispatcher
	{
		
		/**
		 * @param pvt 
		 */
		public function Model( pvt : PrivateClass, stage : Stage = null  )
		{
			_init(stage);
			pvt;	
		}
		
		public var interfaceStage : InterfaceStage;
		
		private var _video : VOVideo;
		
		[Bindable(event="propertyChange")]
		public function get video():VOVideo
		{
			return this._video;
		}
		
		
		public function set video(value:VOVideo):void
		{
			
			var oldValue:Object = this._video;
			
			if (oldValue !== value)
			{
				this._video = value;
				if (this.hasEventListener("propertyChange")) 
					this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "video", oldValue, value));	
			}
			
		}
		
		
		private var _viewState : uint;
		
		[Bindable(event="propertyChange")]
		public function get viewState():uint
		{
			return this._viewState;
		}
		
		public function set viewState(value:uint):void
		{
			
			var oldValue:Object = this._viewState;
			
			if (oldValue !== value)
			{
				this._viewState = value;
				if (this.hasEventListener("propertyChange")) 
					this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "viewState", oldValue, value));	
			}
			
		}
		
		/**
		 * This is internal to this singleton
		 * @private
		 */
		private static var _instance : Model;
		
		
		/**
		 * @param stage The instance to the stage object.
		 *
		 * @return The instance to this singleton object. 
		 */
		public static function getInstance( stage : Stage = null ) : Model
		{
			
			if ( Model._instance == null )
			{
				Model._instance = new Model( new PrivateClass(), stage );
			}
			
			return Model._instance;
			
		}
		
		
		private function _init( stage : Stage = null ) : void
		{
			
			this.interfaceStage = InterfaceStage.getInstance( stage );
			
			this.viewState = Constants.VIEW_NULL;
			
		}
		
//		
//		//	***************************************
//		//
//		//    IEventDispatcher implementation
//		//
//		//	***************************************
//		
//		private var _bindingEventDispatcher:flash.events.EventDispatcher =
//			new flash.events.EventDispatcher(flash.events.IEventDispatcher(this));
//		
//		/**
//		 * @inheritDoc
//		 */
//		public function addEventListener(type:String, listener:Function,
//										 useCapture:Boolean = false,
//										 priority:int = 0,
//										 weakRef:Boolean = false):void
//		{
//			_bindingEventDispatcher.addEventListener(type, listener, useCapture,
//				priority, weakRef);
//		}
//		
//		/**
//		 * @inheritDoc
//		 */
//		public function dispatchEvent(event:flash.events.Event):Boolean
//		{
//			return _bindingEventDispatcher.dispatchEvent(event);
//		}
//		
//		/**
//		 * @inheritDoc
//		 */
//		public function hasEventListener(type:String):Boolean
//		{
//			return _bindingEventDispatcher.hasEventListener(type);
//		}
//		
//		/**
//		 * @inheritDoc
//		 */
//		public function removeEventListener(type:String,
//											listener:Function,
//											useCapture:Boolean = false):void
//		{
//			_bindingEventDispatcher.removeEventListener(type, listener, useCapture);
//		}
//		
//		/**
//		 * @inheritDoc
//		 */
//		public function willTrigger(type:String):Boolean
//		{
//			return _bindingEventDispatcher.willTrigger(type);
//		}
		
	}
	
}


class PrivateClass
{
	
	public function PrivateClass()
	{
		//trace("PrivateClass called");
	}		

}