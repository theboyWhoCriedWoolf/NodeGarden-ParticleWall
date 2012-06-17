package com
{
	import com.greensock.TweenLite;

	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;

	/**
	 * @author Tal
	 */
	public class Chevron extends Sprite
	{
		[Embed(source="../embeddedAssets/chevron.png")]
		private var ChevronArrow 	: Class;
		private var _overCol 		: int;
		private var _bgCol 			: int;
		private var _arrow 			: DisplayObject;
		private var _bg				: Shape;
		
		/*
		 * Constructor
		 */
		public function Chevron( w : int, h : int, bgCol : int, overCol : int  )
		{
			_bg = new Shape();
			_bg.graphics.beginFill( bgCol );
			_bg.graphics.drawRect( 0, 0, w, h );
			_bg.graphics.endFill();
			
			addChild( _bg );
			
			_bgCol 		= bgCol;
			_overCol	= overCol;
			
			_bg.alpha = .4;
			
			addArrow();
		}

		/*
		 * add arrow to display
		 */
		private function addArrow() : void
		{
			_arrow = new ChevronArrow();
			_arrow.x = ( this.width >> 1 ) - ( _arrow.width >> 1 );
			_arrow.y = ( this.height >> 1 ) - ( _arrow.height >> 1 );
			addChild( _arrow );
		}
		
		/*
		 * flip the chevron arrow
		 */		
		public function flipChevron( openState : Boolean ) : void 
		{
			this.scaleX = ( openState ) ? -1 : 1;
			this.x = ( openState ) ? ( this.x + this.width ) : ( this.x - this.width );
		}
		
		/*
		 * tween chevron
		 */
		public function tweenChevron( duration : Number = 1, over : Boolean = false ) : void 
		{
			TweenLite.to( _bg, duration, { tint : ( over ) ? _overCol : _bgCol } );
		}
	}
}
