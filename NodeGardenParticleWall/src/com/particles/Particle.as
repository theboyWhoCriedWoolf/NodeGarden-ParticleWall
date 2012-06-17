package com.particles
{
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;

	/**
	 * @author Tal
	 */
	public class Particle extends Sprite
	{
		
		public static const MALE		: String = "male";
		public static const FEMALE		: String = "female";
		
		private var _sphere				: Shape;
		private var _resetDuration 		: Number = .8;
		private var _tintDuration 		: Number = .5;
		private var _speedCap 			: Number = 8;
		private var _startingXpos 		: int;
		private var _startingYpos 		: int;
		private var _startingPoint 		: Point;
		private var _withAlpha 			: Boolean;
		private var _startedTinting		: Boolean;
		
		/*
		 * Constructor
		 */
		public function Particle( radius : int, colour : int )
		{
			_radius = radius;
			_colour = colour;
			
			_sphere = new Shape();
			addChild( _sphere );
			
			_sphere.graphics.clear();
			_sphere.graphics.beginFill( _colour );
			_sphere.graphics.drawCircle( 0, 0, _radius );
			_sphere.graphics.endFill();
		}
		
		private function redraw() : void
		{
			_sphere.graphics.clear();
			_sphere.graphics.beginFill( _colour );
			_sphere.graphics.drawCircle( 0, 0, _radius );
			_sphere.graphics.endFill();
		}
		
	// [ GETTERS AND SETTERS
	
		/*
		 * set particle ID
		 */
		public function get id() : int { return _id; }
		public function set id( particleID : int ) : void
		{
			_id = particleID;
		}
		private var _id : int = 0;
	
		/*
		 * get and set the particle colour
		 */
		public function get colour() : int { return _colour; }
		public function set colour( col : int ) : void
		{
			_colour = col;
			redraw();
		}
		private var _colour : int;
		
		/*
		 * get and set the radius
		 */
		public function get radius() : int { return _radius; }
		public function set radius( rad : int ) : void
		{
			_radius = rad;
			redraw();
		}
		private var _radius : int;
		
		/*
		 * Velocity Y
		 */
		public function get vx() : Number { return _vx; }
		public function set vx( velX : Number ) : void
		{
			_vx =  Math.min( velX, _speedCap );
		}
		private var _vx : Number = 0;
		
		/*
		 * velocity X
		 */
		public function get vy() : Number { return _vy; }
		public function set vy( velY : Number ) : void
		{
			_vy = Math.min( velY, _speedCap );
		}
		private var _vy : Number = 0;
		
		/*
		 * set the mass
		 */
		public function get mass() : Number { return _mass; }
		public function set mass( partMass : Number ) : void
		{
			_mass = partMass;
		}
		private var _mass : Number = 1;
		
		
		/*
		 * angle
		 */
		public function get angle() : Number { return _angle; }
		public function set angle( value : Number ) : void
		{
			_angle = value;
		}
		private var _angle : Number = 0;
		
		
		/*
		 * starting position point
		 */
		public function get startingPosition() : Point { return  _startingPoint; }
		public function setStartingPosition( xPos : int, yPos : int ) : void 
		{
			_startingXpos = xPos;
			_startingYpos = yPos;
			_startingPoint = new Point( _startingXpos, _startingYpos );
		}
		
		/*
		 * set reset duration
		 */
		public function set resetDuration( value : Number ) : void { _resetDuration = value; }
		
		/*
		 * get started tinting information
		 */
		public function get startedTinting() : Boolean { return _startedTinting; }
		
	// ] 
	
		public function addRadius( amount : int ) : void 
		{
			var total : int = radius + amount;
			radius = total;
		}
	
	// [ RESET
		
		public function timelineTint( tintColour : int, tintStrength : Number ) : void 
		{
			_startedTinting = true;
			var timeline : TimelineLite = new TimelineLite( { onComplete : reset } );
			timeline.insert( new TweenLite( this, _tintDuration, {  alpha : 1, tint : tintColour, glowFilter:{ color:tintColour, alpha:1, blurX:30, blurY:30, strength: tintStrength } } ) );
			timeline.insert( new TweenLite( this, _resetDuration, {  delay : _resetDuration, alpha : 0, tint : tintColour, glowFilter:{ color:tintColour, alpha:0, blurX:30, blurY:30, strength: tintStrength }, removeTint:true } ) );
		}
		
	
		public function tint( tintColour : int, tintStrength : Number, withAlpha : Boolean = false ) : void 
		{
			_startedTinting = true;
			tintColour = ( tintColour == -1 ) ? this.colour : tintColour;
			_withAlpha = withAlpha;
			TweenLite.to( this, _tintDuration, { alpha : 1, tint : tintColour, glowFilter:{ color:tintColour, alpha:1, blurX:30, blurY:30, strength: tintStrength }, onComplete : tintCompleted } );
		}
		
		private function tintCompleted() : void 
		{
			var alphaAmount : Number = ( _withAlpha )? 0 : 1;
			TweenLite.to( this, _resetDuration, { alpha : alphaAmount, removeTint:true, glowFilter:{ color:this.colour, alpha:0, blurX:30, blurY:30, strength: 0, remove : true }, onComplete : reset } );
		}
		
		/*
		 * reset the tinting bool
		 */
		private function reset() : void { _startedTinting = false; } 
		
	// ]
		
	
	
	}
}
