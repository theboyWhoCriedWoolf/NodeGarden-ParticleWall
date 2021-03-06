package com.eventManagement
{
	import org.osflash.signals.Signal;

	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	
	/**
	 * Class to allow the use of events and automativclly switch between mouse and touch events based on availability
	 * Will speed up and prevent bubbling, uses signals instead to dispatch to registered handlers
	 * Automatically switches to MultitouchInputMode.TOUCH_POINT if available
	 * 
	 * @author Tal
	 */
	final public class EventManager
	{
		
		// public consts
		public static const MOUSE_DOWN 		: String = "mouse_down";
		public static const MOUSE_UP 		: String = "mouse_up";
		public static const MOUSE_MOVE		: String = "mouse_move";
		public static const CLICK			: String = "click";
		public static const MOUSE_OVER		: String = "mouse_over";
		public static const MOUSE_OUT		: String = "mouse_out";
		
		// signal holder
		private static var _signalCont		: Vector.<Signal> = new Vector.<Signal>();
		private static var _supportsTouch	: Boolean;
		
		/*
		 * Constructor, set the event moe otherwise events wont work
		 */
		public function EventManager( ) : void 
		{ 
			setMode(); 
			
			// append signals
			_signalCont.push( mouseDownSignal );
			_signalCont.push( mouseUpSignal );
			_signalCont.push( mouseClickSignal );
			_signalCont.push( mouseMoveSignal );
			_signalCont.push( mouseOverSignal );
			_signalCont.push( mouseOutSignal );
			
		}
		
		/**
		 * Add listeners based on interaction type
		 */
		public function addListeners( obj : InteractiveObject ) : void 
		{
			if( obj == null ) return;
			if( _supportsTouch )
			{
				obj.addEventListener( TouchEvent.TOUCH_BEGIN, mouseDown_handler, false, 0, true );
				obj.addEventListener( TouchEvent.TOUCH_END, mouseUp_handler, false, 0, true );
				obj.addEventListener( TouchEvent.TOUCH_TAP, click_handler, false, 0, true );
				obj.addEventListener( TouchEvent.TOUCH_MOVE, mouseMove_handler, false, 0, true );
				return;
			}
			// add normal mouse events
			obj.addEventListener( MouseEvent.MOUSE_DOWN, mouseDown_handler, false, 0, true );
			obj.addEventListener( MouseEvent.MOUSE_UP, mouseUp_handler, false, 0, true );
			obj.addEventListener( MouseEvent.CLICK, click_handler, false, 0, true );
			obj.addEventListener( MouseEvent.MOUSE_MOVE, mouseMove_handler, false, 0, true );
			obj.addEventListener( MouseEvent.MOUSE_OVER, mouseOver_handler, false, 0, true );
			obj.addEventListener( MouseEvent.MOUSE_OUT, mouseOut_handler, false, 0, true );
		}

		/**
		 * Remove listeners based on interaction type
		 */
		public function removeListeners( obj : InteractiveObject ) : void 
		{
			if( obj == null ) return;
			if( _supportsTouch )
			{
				if( obj.hasEventListener( TouchEvent.TOUCH_BEGIN ) ) 		obj.removeEventListener( TouchEvent.TOUCH_BEGIN, mouseDown_handler );
				if( obj.hasEventListener( TouchEvent.TOUCH_END ) ) 			obj.removeEventListener( TouchEvent.TOUCH_END, mouseUp_handler );
				if( obj.hasEventListener( TouchEvent.TOUCH_TAP ) ) 			obj.removeEventListener( TouchEvent.TOUCH_TAP, click_handler );
				if( obj.hasEventListener( TouchEvent.TOUCH_MOVE ) ) 		obj.removeEventListener( TouchEvent.TOUCH_MOVE, mouseUp_handler );
				return;
			}
			
			// add normal mouse events
			if( obj.hasEventListener( MouseEvent.MOUSE_DOWN ) )				obj.removeEventListener( MouseEvent.MOUSE_DOWN, mouseDown_handler );
			if( obj.hasEventListener( MouseEvent.MOUSE_UP ) )				obj.removeEventListener( MouseEvent.MOUSE_UP, mouseUp_handler );
			if( obj.hasEventListener( MouseEvent.CLICK ) )					obj.removeEventListener( MouseEvent.CLICK, click_handler );
			if( obj.hasEventListener( MouseEvent.MOUSE_MOVE ) )				obj.removeEventListener( MouseEvent.MOUSE_MOVE, mouseMove_handler );
			if( obj.hasEventListener( MouseEvent.MOUSE_OVER ) )				obj.removeEventListener( MouseEvent.MOUSE_OVER, mouseOver_handler );
			if( obj.hasEventListener( MouseEvent.MOUSE_OUT ) )				obj.removeEventListener( MouseEvent.MOUSE_OUT, mouseOut_handler );
		}
		
		/**
		 * Add listener to Interactive object by type
		 */
		public function addListenerByType( obj : InteractiveObject, type : String ) : void 
		{
			if( obj == null ) return;
			switch( type )
			{
				case MOUSE_DOWN :
					if( _supportsTouch ) obj.addEventListener( TouchEvent.TOUCH_BEGIN, mouseDown_handler, false, 0, true );
					else obj.addEventListener( MouseEvent.MOUSE_DOWN, mouseDown_handler, false, 0, true );
					break;
					
				case MOUSE_UP:
					if( _supportsTouch ) obj.addEventListener( TouchEvent.TOUCH_END, mouseUp_handler, false, 0, true );
					else obj.addEventListener( MouseEvent.MOUSE_UP, mouseUp_handler, false, 0, true );
					break;
					
				case MOUSE_MOVE:
					if( _supportsTouch ) obj.addEventListener( TouchEvent.TOUCH_MOVE, mouseMove_handler, false, 0, true );
					else obj.addEventListener( MouseEvent.MOUSE_MOVE, mouseMove_handler, false, 0, true );
					break;
					
				case CLICK:
					if( _supportsTouch ) obj.addEventListener( TouchEvent.TOUCH_TAP, click_handler, false, 0, true );
					else obj.addEventListener( MouseEvent.CLICK, click_handler, false, 0, true );
					break;
				
				case MOUSE_OVER:
					if( !_supportsTouch ) obj.addEventListener( MouseEvent.MOUSE_OVER, mouseOver_handler, false, 0, true );
					break;
				
				case MOUSE_OUT:
					if( !_supportsTouch ) obj.addEventListener( MouseEvent.MOUSE_OUT, mouseOut_handler, false, 0, true );
					break;
			}
		}
		
		/**
		 * Remove listener by type
		 */
		public function removeListenerByType( obj : InteractiveObject, type : String ) : void 
		{
			if( obj == null ) return;
			try
			{
				switch( type )
				{
					case MOUSE_DOWN :
						if( _supportsTouch ) obj.removeEventListener( TouchEvent.PROXIMITY_BEGIN, mouseDown_handler);
						else obj.removeEventListener( MouseEvent.MOUSE_DOWN, mouseDown_handler );
						break;
						
					case MOUSE_UP:
						if( _supportsTouch ) obj.removeEventListener( TouchEvent.TOUCH_END, mouseUp_handler );
						else obj.removeEventListener( MouseEvent.MOUSE_UP, mouseUp_handler );
						break;
					
					case MOUSE_MOVE:
						if( _supportsTouch ) obj.removeEventListener( TouchEvent.TOUCH_MOVE, mouseMove_handler );
						else obj.removeEventListener( MouseEvent.MOUSE_MOVE, mouseMove_handler );
						break;
						
					case CLICK:
						if( _supportsTouch ) obj.removeEventListener( TouchEvent.TOUCH_TAP, click_handler );
						else obj.removeEventListener( MouseEvent.CLICK, click_handler );
						break;
					
					case MOUSE_OVER:
						if( !_supportsTouch ) obj.removeEventListener( MouseEvent.MOUSE_OVER, mouseOver_handler );
						break;
				
					case MOUSE_OUT:
						if( !_supportsTouch ) obj.removeEventListener( MouseEvent.MOUSE_OVER, mouseOut_handler );
						break;
				}
			}
			catch( e : Error ) { throw new Error("ERROR removing event listener from obj :: " + e ); } // fail 
		}
		

	// [ HANDLERS
	
		private function click_handler( event : * ) : void
		{
			event.stopImmediatePropagation();
			var eventVo : EventVO = vo;
			eventVo.event = event;
			mouseClickSignal.dispatch( eventVo  );
		}

		private function mouseUp_handler( event : * ) : void
		{
			event.stopImmediatePropagation();
			var eventVo : EventVO = vo;
			eventVo.event = event;
			mouseUpSignal.dispatch( eventVo  );
		}

		private function mouseDown_handler( event : * ) : void
		{
			event.stopImmediatePropagation();
			var eventVo : EventVO = vo;
			eventVo.event = event;
			mouseDownSignal.dispatch( eventVo );
		}
		
		private function mouseMove_handler( event : * ) : void
		{
			event.stopImmediatePropagation();
			var eventVo : EventVO = vo;
			eventVo.event = event;
			mouseMoveSignal.dispatch( eventVo );
		}
		
		private function mouseOver_handler( event : * ) : void
		{
			event.stopImmediatePropagation();
			var eventVo : EventVO = vo;
			eventVo.event = event;
			mouseOverSignal.dispatch( eventVo );
		}
		
		private function mouseOut_handler( event : * ) : void
		{
			event.stopImmediatePropagation();
			var eventVo : EventVO = vo;
			eventVo.event = event;
			mouseOutSignal.dispatch( eventVo );
		}
		
	// ]
	
	// [ SIGNALS
	
		/**
		 * Mouse Down signal
		 */
		public function get mouseDownSignal() : Signal { return _mouseDownSignal; }
		public function set mouseDownSignal( signal : Signal ) : void
		{
			_mouseDownSignal = signal;
		}
		private  var _mouseDownSignal : Signal = new Signal( EventVO );
		
		/**
		 * Mouse up signal
		 */
		public function get mouseUpSignal() : Signal { return _mouseUpSignal; }
		public function set mouseUpSignal( signal : Signal ) : void
		{
			_mouseUpSignal = signal;
		}
		private var _mouseUpSignal : Signal = new Signal( EventVO );
		
		/**
		 * Click signal
		 */
		public function get mouseClickSignal() : Signal { return _mouseClickSignal; }
		public function set mouseClickSignal( signal : Signal ) : void
		{
			_mouseClickSignal = signal;
		}
		private var _mouseClickSignal : Signal = new Signal( EventVO );
		
		/**
		 * Mouse move signal
		 */
		public function get mouseMoveSignal() : Signal { return _mouseMoveSignal; }
		public function set mouseMoveSignal( signal : Signal ) : void
		{
			_mouseMoveSignal = signal;
		}
		private var _mouseMoveSignal : Signal = new Signal( EventVO );
		
		/**
		 * Mouse over signal
		 */
		public function get mouseOverSignal() : Signal { return _mouseOverSignal; }
		public function set mouseOverSignal( signal : Signal ) : void
		{
			_mouseOverSignal = signal;
		}
		private var _mouseOverSignal : Signal = new Signal( EventVO );
		
		/**
		 * Mouse out signal
		 */
		public function get mouseOutSignal() : Signal { return _mouseOutSignal; }
		public function set mouseOutSignal( signal : Signal ) : void
		{
			_mouseOutSignal = signal;
		}
		private var _mouseOutSignal : Signal = new Signal( EventVO );
	
	// ] 
	
		/**
		 * Remove signal handler function
		 */
		public function removeSignalListener( handler : Function ) : void 
		{
			var i : uint = _signalCont.length;
			var s : Signal;
			while( --i )
			{
				s = _signalCont[ i ];
				s.remove( handler );
			}
		}
		
		/*
		 * automatically check for the mode
		 */
		private function setMode() : void 
		{
			_supportsTouch = Multitouch.supportsTouchEvents;
			if( _supportsTouch ) Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
		}
	
		/*
		 * return new vo
		 */
		private function get vo() : EventVO { return new EventVO(); }
	
		/**
		 * dispose of signals
		 */
		public function dispose() : void 
		{
			mouseDownSignal.removeAll();
			mouseUpSignal.removeAll();
			mouseClickSignal.removeAll();
			mouseMoveSignal.removeAll();
			mouseOverSignal.removeAll();
			mouseOverSignal.removeAll();
			
			mouseDownSignal 	= null;
			mouseUpSignal		= null;
			mouseClickSignal 	= null;
			mouseOverSignal 	= null;
			mouseOverSignal 	= null;
			_signalCont			= null;
		}
	
	}
}

internal class SingletonLock{} // lock
