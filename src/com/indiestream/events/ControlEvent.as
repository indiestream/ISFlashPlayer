package com.indiestream.events
{

	import flash.events.Event;
	
	public class ControlEvent extends Event
	{
	
		
		public static const SCRUB_DOWN : String = "scrub_down";
		
		public static const SCRUB_MOVE : String = "scrub_move";
		
		public static const SCRUB_UP : String = "scrub_up";
		
		public static const CONTROL_NEXT : String = "control_next";
		
		public static const CONTROL_PLAY : String = "control_play";
		
		public static const CONTROL_PAUSE : String = "control_pause";
		
		public static const CONTROL_SEEK : String = "control_seek";
		
		public static const CONTROL_STOP : String = "control_stop";
		
		
		public function ControlEvent(type : String, percent : Number = 0)
		{
			
			super(type);
			
			this.percent = percent;
			
		}

	
		public var percent : Number;
	
	}
	
}