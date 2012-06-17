package com
{
	import com.bit101.components.CheckBox;
	import com.mrdoob.src.net.hires.debug.Stats;
	import com.particles.Particle;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * @author Tal
	 */
	public class ApplicationBase extends Sprite
	{
		
		protected var _totalParticles 			: Number = 10;
		protected var _springAmount 			: Number = .0025;
		protected var _stats 					: Stats;
		protected var _view						: Sprite;
		protected var _bounds 					: Rectangle;
		protected var _particleVect 			: Vector.<Particle>;
		protected var _animateFunction 			: Function;
		protected var _particleRadius			: int = 10;
		protected var _colomns 					: int = 30;
		protected var _rows 					: int = 25;
		protected var _particleMargin			: int = 10;
		protected var _friction 				: Number = 1;
		protected var _compsContainer 			: SelectionPanel;
		
		/*
		 * Constructor
		 */
		public function ApplicationBase()
		{
			if( stage ) init();
			addEventListener( Event.ADDED_TO_STAGE, init, false, 0, true );
		}
		
		// init handler
		protected function init( event : Event = null ) : void 
		{
			// create main view
			_view = new Sprite();
			addChild( _view );
			
			// assign bounds to stage dimensions
			_bounds	= new Rectangle( 0, 0, stage.stageWidth, stage.stageHeight );
			
			 removeEventListener( Event.ADDED_TO_STAGE, init );
			 stage.addEventListener( Event.RESIZE, stageResize_handler ); 
		}
		//resize handler, change stage dimensions
		protected function stageResize_handler( event : Event ) : void 
		{ 
			if( !stage ) return;
			_bounds = new Rectangle( 0, 0, stage.stageWidth, stage.stageHeight );
			if( _compsContainer ) _compsContainer.y = _bounds.height - _compsContainer.height;
		}
		// start enter frame
		public function startEnterFrame() : void { stage.addEventListener( Event.ENTER_FRAME, update_handler );	}
		//stop enter frame
		public function stopEnterFrame() : void 
		{ 
			if( stage && stage.hasEventListener( Event.ENTER_FRAME ) )
				stage.removeEventListener( Event.ENTER_FRAME, update_handler );	
		}
		// show and hide stats
		protected function showStats_handler( event : Event ) : void 
		{
			if( CheckBox( event.target ).selected ) 
			{ 
				_stats = new Stats(); 
				addChild( _stats ); 
				_stats.x = stage.stageWidth - _stats.width; 
			}
			else if( _stats && this.contains(_stats ) ) this.removeChild( _stats );
		}
		
		// move particles, enterFrame update
		protected function update_handler(  event : Event = null  ) : void 
		{
			_view.graphics.clear();
			var particle	: Particle;
			for each( particle in _particleVect )
			{
				particle.x += particle.vx;
				particle.y += particle.vy;
				checkBounds( particle );
			}
			
			if( _particleVect.length < 2 ) return; // stop if less than two particles
			
			var j		: uint;
			var k		: uint;
			
			var particleA : Particle;
			var particleB : Particle;
			
			for( j = 0; j < ( _particleVect.length - 1 ); j++ )
			{
				particleA = _particleVect[ j ];
				for( k = j + 1; k < _particleVect.length; k++ )
				{
					particleB = _particleVect[ k ];
					_animateFunction( particleA, particleB );
				}
			}
		}
		
		/*
		 * check bounds and screenwrap 
		 */
		protected function checkBounds( particle : Particle ) : void 
		{
			var halfRadius : int = particle.radius / 2;
			
			if( particle.x < ( _bounds.x - halfRadius ) )
			{
				particle.x = ( _bounds.width + halfRadius );
			}
			else if( particle.x > ( _bounds.width + halfRadius ) )
			{
				particle.x = ( _bounds.x - halfRadius );
			}
			if( particle.y < ( _bounds.y - halfRadius ) )
			{
				particle.y = ( _bounds.height - halfRadius );
			}
			else if ( particle.y > ( _bounds.height + halfRadius ) )
			{
				particle.y = ( _bounds.y - halfRadius );
			}
		}
		
		/*
		 * dispose
		 */
		public function dispose() : void 
		{
			while( this.numChildren > 0 )
			{
				this.removeChildAt( 0 );
			}
			_particleVect = null;
			
			_compsContainer.dispose();
			stopEnterFrame();
			if( stage.hasEventListener( Event.RESIZE ))
			stage.addEventListener( Event.RESIZE, stageResize_handler ); 
		}
		
		
		/*
		 * check collision, use billiards collision detection
		 * from Foundation ActionScript Animation by Kieth Peters
		 */
		protected function checkCollision( particle1 : Particle, particle2 : Particle ) : void 
		{
			var dx:Number = particle2.x - particle1.x;
			var dy:Number = particle2.y - particle1.y;
			var dist:Number = Math.sqrt(dx*dx + dy*dy);
			if( dist < particle1.radius + particle2.radius) 
			{
				// calculate angle, sine and cosine
				var angle:Number = Math.atan2(dy, dx);
				var sin:Number = Math.sin(angle);
				var cos:Number = Math.cos(angle);
				
				// rotate particle1's position
				var pos0:Point = new Point(0, 0);
				
				// rotate particle2's position
				var pos1:Point = rotate(dx, dy, sin, cos, true);
				
				// rotate particle1's velocity
				var vel0:Point = rotate(particle1.vx,
										particle1.vy,
										sin,
										cos,
										true);
				
				// rotate particle2's velocity
				var vel1:Point = rotate(particle2.vx,
										particle2.vy,
										sin,
										cos,
										true);
				
				// collision reaction
				var vxTotal:Number = vel0.x - vel1.x;
				vel0.x = ((particle1.mass - particle2.mass) * vel0.x + 
				          2 * particle2.mass * vel1.x) / 
				          (particle1.mass + particle2.mass);
				vel1.x = vxTotal + vel0.x;

				// update position
				var absV:Number = Math.abs(vel0.x) + Math.abs(vel1.x);
				var overlap:Number = (particle1.radius + particle2.radius) 
				                      - Math.abs(pos0.x - pos1.x);
				pos0.x += vel0.x / absV * overlap;
				pos1.x += vel1.x / absV * overlap;
				
				// rotate positions back
				var pos0F:Object = rotate(pos0.x,
										  pos0.y,
										  sin,
										  cos,
										  false);
										  
				var pos1F:Object = rotate(pos1.x,
										  pos1.y,
										  sin,
										  cos,
										  false);

				// adjust positions to actual screen positions
				particle2.x = particle1.x + pos1F.x;
				particle2.y = particle1.y + pos1F.y;
				particle1.x = particle1.x + pos0F.x;
				particle1.y = particle1.y + pos0F.y;
				
				// rotate velocities back
				var vel0F:Object = rotate(vel0.x,
										  vel0.y,
										  sin,
										  cos,
										  false);
				var vel1F:Object = rotate(vel1.x,
										  vel1.y,
										  sin,
										  cos,
										  false);
				particle1.vx = vel0F.x;
				particle1.vy = vel0F.y;
				particle2.vx = vel1F.x;
			}
		}
		
		/*
		 * rotate 
		 */
		protected function rotate(x:Number,
								y:Number,
								sin:Number,
								cos:Number,
								reverse:Boolean):Point
		{
			var result:Point = new Point();
			if(reverse)
			{
				result.x = x * cos + y * sin;
				result.y = y * cos - x * sin;
			}
			else
			{
				result.x = x * cos - y * sin;
				result.y = y * cos + x * sin;
			}
			return result;
		}
		
		
// [ GETTERS AND SETTERS 
	
		// mouse mass
		public function get mouseMass() : Number { return _mouseMass; }
		public function set mouseMass( value : Number ) : void
		{
			_mouseMass = value;
		}
		private var _mouseMass : Number = 100;
		
		// minimum distance
		public function get minDistance() : Number { return _minDisntance; }
		public function set minDistance( value : Number ) : void
		{
			_minDisntance = value;
		}
		private var _minDisntance : Number = 200;

// ]
		
		
	}
	
}
