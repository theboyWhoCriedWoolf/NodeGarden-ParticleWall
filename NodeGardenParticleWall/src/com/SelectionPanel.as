package com
{
	import com.eventManagement.EventManager;
	import com.eventManagement.EventVO;
	import com.greensock.TweenLite;

	import flash.display.Sprite;

	/**
	 * @author Tal
	 */
	public class SelectionPanel extends Sprite
	{
		
		public static var OPEN					: String = "open";
		public static var CLOSED				: String = "closed";
		
		// chevron satic properties
		private static var CHEVRON_WIDTH 		: int = 15;
		
		// private properties
		private var _chevron 					: Chevron;
		private var _chevronOverCol 			: int;
		private var _chevronBGCol 				: int;
		private var _state 						: String;
		private var _bgCol 						: int;
		
		private var _eventManager				: EventManager;
		
		/*
		 * Constructor
		 */
		public function SelectionPanel( bgCol : int, chevBackgroundCol : int = 0x666666, chevOvercol : int = 0xffffff ) : void 
		{
			_eventManager 	= new EventManager();
			
			_bgCol			= bgCol;
			_chevronBGCol 	= chevBackgroundCol;
			_chevronOverCol	= chevOvercol;
			_state 			= OPEN;
			
		}
		
		/*
		 * redraw panel
		 */
		public function draw( w : int, h : int ) : void 
		{
			graphics.clear();
			graphics.beginFill( _bgCol );
			graphics.drawRect( 0, 0, w, h );
			graphics.endFill();
			
			createChevron();
		}
		
		
		/*
		 * create chevron button
		 */
		private function createChevron() : void
		{
			_chevron = new Chevron( CHEVRON_WIDTH, this.height, _chevronBGCol, _chevronOverCol );
			_chevron.x = this.width;
			_chevron.flipChevron( true );
			addChild( _chevron );
		}
		
		/*
		 * set the state of the panel
		 */
		public function setInitialState( state : String = "" ) : void
		{
			switch( state )
			{
				case OPEN :
					_chevron.flipChevron( true );
					break;
					
				case CLOSED :
					_chevron.flipChevron( false );
					this.x = -this.width;
					break;
				
				default :
					_chevron.flipChevron( true );
					break;
			}
			_state = state;
		}
		
		/*
		 * activate 
		 */
		 public function activate() : void 
		 {
			addListeners();
		}
		
		/*
		 * addEventListeners
		 */
		private function addListeners() : void
		{
			_eventManager.mouseClickSignal.add( mouseClick_handler );
			_eventManager.mouseOutSignal.add( mouseOut_handler );
			_eventManager.mouseOverSignal.add( mouseOver_handler );
			
			_eventManager.addListenerByType( _chevron, EventManager.CLICK );
			_eventManager.addListenerByType( _chevron, EventManager.MOUSE_OUT );
			_eventManager.addListenerByType( _chevron, EventManager.MOUSE_OVER );
		}

	
	// [ HANDLERS
	
		// mouse click handler
		private function mouseClick_handler( event : EventVO ) : void { tween(); }
		// mouse out handler
		private function mouseOut_handler( event : EventVO ) : void { _chevron.tweenChevron( 1 ); }
		// mouse over handler
		private function mouseOver_handler( event : EventVO ) : void { _chevron.tweenChevron( 1, true ); }
		
	// ] 
	
		/*
		 * dispose
		 */
		public function dispose() : void 
		{
			_eventManager.removeListeners( _chevron );
			_eventManager.removeSignalListener( mouseClick_handler );
			_eventManager.removeSignalListener( mouseOut_handler );
			_eventManager.removeSignalListener( mouseOver_handler );
		}
		
		/*
		 * tween control
		 */
		 private function tween() : void 
		 {
			var stateOpen : Boolean = ( _state == OPEN ); 
			var xPos : int = ( stateOpen ) ? -( this.width - _chevron.width ) : 0;
			_chevron.flipChevron( !stateOpen );
			_state = ( stateOpen ) ? CLOSED : OPEN;
			
			TweenLite.to( this, .5, { x : xPos } );
		 }
		 
	}
}
