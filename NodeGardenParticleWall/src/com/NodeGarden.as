package com
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.Label;
	import com.bit101.components.Slider;
	import com.particles.Particle;

	import flash.events.Event;


	/**
	 * @author Tal
	 */
	public class NodeGarden extends ApplicationBase implements ICurrentView
	{
		// static positioning margins
		private static var COMPS_MARGIN_X 		: Number = 5;
		private static var COMPS_MARGIN_Y 		: Number = 15;
		
		private var _tintAmount 				: Number = 2;
		private var _getStrongest 				: Boolean;
		private var _dontMixColours 			: Boolean;
		
		// labels
		private var _minDistPercentLabel 		: Label;
		private var _numParticlesPercentLabel 	: Label;
		private var _glowPercentLabel 			: Label;
		
		
		public function NodeGarden() {}
		
		/*
		 * init node garden
		 */
		override protected function init( event : Event = null ) : void 
		{
			super.init();
			
			_getStrongest 			= true;
			_dontMixColours 		= false;
			_animateFunction 		= springParticles;
			
			createParticles(); // create particles
			buildComponents(); // build components
			alignComponents(); // align components
			startEnterFrame(); // start enter frame
		}
		
		
		/*
		 * align the components to the bottom left of the screen
		 */
		private function alignComponents() : void
		{
			_compsContainer.y = ( _bounds.height - _compsContainer.height );
		}

		
		/*
		 * build components to add particle control
		 * built using minimal comps
		 */
		private function buildComponents() : void
		{
			_compsContainer = new SelectionPanel( 0x1f1f1f );
			addChild( _compsContainer );
			
			// minimum distance control
			var minDistanceLabel : Label = new Label( _compsContainer, 5, COMPS_MARGIN_Y, "Minimum Distance" );
			var minDistanceSlider : Slider = new Slider( "horizontal", _compsContainer, 5, minDistanceLabel.height + COMPS_MARGIN_Y, minDistance_handler );
			minDistanceSlider.maximum = 400;
			minDistanceSlider.value = minDistance;
			_minDistPercentLabel = new Label( _compsContainer, minDistanceSlider.x , ( minDistanceSlider.y + minDistanceSlider.height ), String( minDistanceSlider.value ) );
			
			// amount of particles in view
			var numParticlesLabel : Label = new Label( _compsContainer, ( minDistanceLabel.x + minDistanceSlider.width ) + COMPS_MARGIN_X, minDistanceLabel.y, "Number of particles" );
			var numParticlesSlider : Slider = new Slider( "horizontal", _compsContainer, ( minDistanceSlider.x + minDistanceSlider.width ) +  COMPS_MARGIN_X, numParticlesLabel.height + COMPS_MARGIN_Y, numParticles_handler );
			numParticlesSlider.maximum = 100;
			numParticlesSlider.width = 60;
			numParticlesSlider.value = _totalParticles;
			_numParticlesPercentLabel = new Label( _compsContainer, numParticlesSlider.x , ( numParticlesSlider.y + numParticlesSlider.height ), String( numParticlesSlider.value ) );
			
			// amount of glow 
			var glowLabel : Label = new Label( _compsContainer, ( numParticlesLabel.x + numParticlesLabel.width ) + COMPS_MARGIN_X, numParticlesLabel.y, "Glow" );
			var glowSlider : Slider = new Slider( "horizontal", _compsContainer, glowLabel.x, glowLabel.height + COMPS_MARGIN_Y, particleGlow_handler );
			glowSlider.maximum = 5;
			glowSlider.width = 30;
			glowSlider.value = _tintAmount;
			_glowPercentLabel = new Label( _compsContainer, glowSlider.x , ( glowSlider.y + glowSlider.height ), String( glowSlider.value ) );
			
			// compare colours or use the strongest colour between particles - default use strongest colour
			var useCompareCheckbox : CheckBox = new CheckBox( _compsContainer, ( glowSlider.x + glowSlider.width ) + COMPS_MARGIN_X + 2, COMPS_MARGIN_Y, "Stongest/Combine", mixColour_handler );
			useCompareCheckbox.selected = true;
			// remove all colour manipulation and leave particles with original colouring
			var removeColourMixCheckbox : CheckBox = new CheckBox( _compsContainer, useCompareCheckbox.x , useCompareCheckbox.y + COMPS_MARGIN_Y, "Dont Mix", dontMix_handler );
			removeColourMixCheckbox.selected = false;
			// gravitate instead of using the springing function
			var gravitateCheckBox : CheckBox = new CheckBox( _compsContainer, useCompareCheckbox.x , removeColourMixCheckbox.y + COMPS_MARGIN_Y, "Gravitate", gravitate_handler );
			gravitateCheckBox.selected = false;
			// add remove stats
			var addStatsCheckBox : CheckBox = new CheckBox( _compsContainer, gravitateCheckBox.x , gravitateCheckBox.y + COMPS_MARGIN_Y, "Stats", showStats_handler );
			addStatsCheckBox.selected = false;
			
			
			_compsContainer.draw( ( useCompareCheckbox.x + useCompareCheckbox.width ) + COMPS_MARGIN_X, ( gravitateCheckBox.y + gravitateCheckBox.height ) + ( COMPS_MARGIN_Y * 2 ) );
			_compsContainer.activate();
		}
		
		
	// [ HANDLERS
		
		/*
		 * mix colour / strongest handler
		 */
		private function dontMix_handler( event : Event ) : void
		{
			_dontMixColours = CheckBox( event.target ).selected;
		}
		/*
		 * use gravitate function handler
		 */
		private function gravitate_handler( event : Event ) : void
		{
			var value : Boolean = CheckBox( event.target ).selected;
			_animateFunction = ( value )? gravitateParticles : springParticles;
		}
		/*
		 * mix colours handler
		 */
		private function mixColour_handler( event : Event ) : void
		{
			_getStrongest = CheckBox( event.target ).selected;
		}
		/*
		 * glow percentage handler
		 */
		private function particleGlow_handler( event : Event ) : void
		{
			_tintAmount =  Slider( event.target ).value;
			_glowPercentLabel.text 	= String( _tintAmount );
		}
		/*
		 * number of particles in view handler
		 */
		private function numParticles_handler( event : Event ) : void
		{
			var value : int =  Slider( event.target ).value;
			
			if( _totalParticles < value )
			{
				var particle : Particle;
				var size : int;
				
				for( var i : uint = _totalParticles -1; i < value; i++ )
				{
					size = Math.random() * 20 + 2;
					particle = new Particle( size, Math.random() * 0xFFFFFF );
					particle.x = Math.random() * stage.stageWidth;
					particle.y = Math.random() * stage.stageHeight;
					particle.vx = Math.random() * 6 - 3;
					particle.vy = Math.random() * 6 - 3;
					particle.mass = size;
					_view.addChild( particle );
					_particleVect.push( particle );
				}
				_totalParticles = value;
			}
			else
			{
				var j 		: int = _particleVect.length;;
				var total 	: int = value;
				
				_view.graphics.clear();
				while( j > total )
				{
					particle = _particleVect[ value ]; 				// comps not that sensitive and can often skip values
					if( particle && _view.contains( particle ) )	// loops through all values above current value if any and removes
					{												// particles, makes sure all are removed
						_view.removeChild( particle );
						_particleVect.splice( value, 1 );
						particle = null;
						_totalParticles = _particleVect.length;
					}
					j--;
				}
			}
			_numParticlesPercentLabel.text 	= String( _totalParticles );
		}
		
		/*
		 * change the minimum distance handler
		 */
		private function minDistance_handler( event : Event ) : void
		{
			minDistance 				= Slider( event.target ).value;
			_minDistPercentLabel.text 	= String( Math.round( minDistance ) );
		}
		
	// ]
		
	// [ APPLICATION METHODS
	
		/*
		 * create particles
		 */
		protected function createParticles() : void
		{
			_particleVect = new Vector.<Particle>();
			
			var particle : Particle;
			var size : int;
			
			for( var i : uint = 0; i < _totalParticles; i++ )
			{
				size = Math.random() * 20 + 2;
				particle = new Particle( size, Math.random() * 0xFFFFFF );
				particle.x = Math.random() * stage.stageWidth;
				particle.y = Math.random() * stage.stageHeight;
				particle.vx = Math.random() * 6 - 3;
				particle.vy = Math.random() * 6 - 3;
				particle.mass = size;
				_view.addChild( particle );
				_particleVect.push( particle );
			}
		}
		
		
		/*
		 * spring gravitation,
		 * spring to particle and increase strength using mass
		 */
		private function springParticles( particleA : Particle, particleB : Particle ) : void 
		{
			var dx				: Number = particleB.x - particleA.x;
			var dy				: Number = particleB.y - particleA.y;
			var distance 		: Number = Math.sqrt( dx * dx + dy * dy );
			
			if( distance < minDistance )
			{
				var distAmount		: Number = ( distance / minDistance );
				// calculate amount being taken off
				
				var colour : int = getColour( particleA.colour, particleB.colour );
				particleA.tint( colour, _tintAmount - ( distAmount * _tintAmount ) );
				particleB.tint( colour, _tintAmount - ( distAmount * _tintAmount ) );
				
				_view.graphics.lineStyle( 2 - distAmount, colour, 1 - distAmount );
				_view.graphics.moveTo(particleA.x, particleA.y);
				_view.graphics.lineTo( particleB.x, particleB.y );
				// apply forces
				var ax : Number = dx * _springAmount;
				var ay : Number = dx * _springAmount;
				particleA.vx += ax / particleA.mass;
				particleA.vy += ay / particleA.mass;
				particleB.vx -= ax / particleB.mass;
				particleB.vy -= ay / particleB.mass;
			}
		}
		
		/*
		 * chose a colour function to use
		 * either get colour by combining both particles colours
		 * or use the dominant colour
		 */
		private function getColour( colour1 : int, colour2 : int ) : int 
		{
			if( _dontMixColours ) return -1;
			return ( _getStrongest ) ? ColourUtils.strongestColour( colour1, colour2 ) : ColourUtils.combineColours( colour1, colour2 );
		}
		
		/*
		 * gravitate function
		 * instead of springing and compare mass to add to force 
		 */
		private function gravitateParticles( particleA : Particle, particleB : Particle ) : void 
		{
			
			var dx:Number = particleB.x - particleA.x;
			var dy:Number = particleB.y - particleA.y;
			var distSQ:Number = dx*dx + dy*dy;
			var distance:Number = Math.sqrt(distSQ);
			
			if( distance < minDistance )
			{
				var distAmount		: Number = ( distance / minDistance );
				
				var colour : int = getColour( particleA.colour, particleB.colour );
				particleA.tint( colour, _tintAmount - ( distAmount * _tintAmount ) );
				particleB.tint( colour, _tintAmount - ( distAmount * _tintAmount ) );
				
				_view.graphics.lineStyle( 1 - distAmount, colour, 1 - distAmount );
				_view.graphics.moveTo( particleA.x, particleA.y );
				_view.graphics.lineTo( particleB.x, particleB.y );
				var force:Number = particleA.mass * particleB.mass / distSQ;
				var ax:Number = force * dx / distance;
				var ay:Number = force * dy / distance;
				particleA.vx += ax / particleA.mass;
				particleA.vy += ay / particleA.mass;
				particleB.vx -= ax / particleB.mass;
				particleB.vy -= ay / particleB.mass;
			}
			checkCollision( particleA, particleB );
		}
		
	// ]
	
	
	}
}
