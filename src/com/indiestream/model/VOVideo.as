package com.indiestream.model
{
	import flash.events.EventDispatcher;
	
	import mx.events.PropertyChangeEvent;
	
	import org.mangui.hls.constant.HLSPlayStates;

	public class VOVideo extends EventDispatcher
	{
	
		public function VOVideo( urlMedia : String = '', title : String = '', type : String = '', description : String = '', urlImage : String = '' )
		{
			
			this._audioLevel = 1;
			
			this.title = title;
			
			this.description = description;
			
			this.isBuffering = false;
			
			this.loadedAmount = 0;
			
			this._mediaType = type;
			
			this._playState = HLSPlayStates.IDLE;
			
			this.timeCurrent = 0;
			
			this.timeDuration = 0;
			
			this.urlImage = urlImage;
			
			this.urlMedia = urlMedia;
			 
		}
		 
		public var description : String;
		
		public var id : String;
		
		public var isBuffering : Boolean;
		
		public var loadedAmount : uint;
		
		public var title : String;
		
		public var urlImage : String;
		
		public var urlMedia : String;
		
		
		private var _audioLevel : Number;
		
		[Bindable(event="propertyChange")]
		public function get audioLevel():Number
		{
			return this._audioLevel;
		}
		
		public function set audioLevel(value:Number):void
		{
			
			var oldValue:Object = this._audioLevel;
			
			if (oldValue !== value)
			{
				this._audioLevel = value;
				if (this.hasEventListener("propertyChange")) 
					this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "audioLevel", oldValue, value));	
			}
			
		}
		
		
		private var _mediaType : String;
		
		[Bindable(event="propertyChange")]
		public function get mediaType():String
		{
			return this._mediaType;
		}
		
		public function set mediaType(value:String):void
		{
			
			var oldValue:Object = this._mediaType;
			
			if (oldValue !== value)
			{
				this._mediaType = value;
				if (this.hasEventListener("propertyChange")) 
					this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "mediaType", oldValue, value));	
			}
			
		}
		
		
		private var _playState : String;
		
		[Bindable(event="propertyChange")]
		public function get playState():String
		{
			return this._playState;
		}
		
		public function set playState(value:String):void
		{
			
			var oldValue:Object = this._playState;
			
			if (oldValue !== value)
			{
				this._playState = value;
				if (this.hasEventListener("propertyChange")) 
					this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "playState", oldValue, value));	
			}
			
		}
		
		
		private var _timeCurrent : Number;
		
		[Bindable(event="propertyChange")]
		public function get timeCurrent():Number
		{
			return this._timeCurrent;
		}
		
		public function set timeCurrent( value : Number ) : void
		{
			
			var oldValue:Object = this._timeCurrent;
			
			if (oldValue !== value)
			{
				this._timeCurrent = value;
				if (this.hasEventListener("propertyChange")) 
					this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "timeCurrent", oldValue, value));	
			}
			
		}
		
		
		private var _timeDuration : Number;
		
		[Bindable(event="propertyChange")]
		public function get timeDuration():Number
		{
			return this._timeDuration;
		}
		
		public function set timeDuration( value : Number ) : void
		{
			
			var oldValue:Object = this._timeDuration;
			
			if (oldValue !== value)
			{
				this._timeDuration = value;
				if (this.hasEventListener("propertyChange")) 
					this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "timeDuration", oldValue, value));	
			}
			
		}
		
		
	}
	
}