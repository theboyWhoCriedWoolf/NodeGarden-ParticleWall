package com
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.Label;
	import com.bit101.components.Slider;
	import com.particles.Particle;

	import flash.events.Event;
	import flash.geom.Point;

	/**
	 * @author Tal
	 */
	public class ParticleWall extends ApplicationBase implements ICurrentView
	{
		private static const COMPS_MARGIN_Y 	: Number = 5;
		private static const COMPS_MARGIN_X 	: Number = 10;
		
		private var _springAmountLabel 			: Label;
		private var _frictionPercentLabel 		: Label;
		private var _speedUp 					: Boolean = false;
		private var _updateFunction 			: Function;
		private var _eyeCount 					: int = 0;
		private var _radiusSliderPercentLabel 	: Label;
		private var _mouseMassLabel 			: Label;
		private var _halfStage : Number;
		private var _particleRadiusLabel : Label;
		
		/*
		 * Constructor
		 */
		public function ParticleWall(){}
		
		override protected function init( event : Event = null ) : void 
		{
			super.init();
			
			_springAmount = .5;
			minDistance = 200;
			
			_colomns = _bounds.width / ( _particleRadius * 2 + _particleMargin );
			_rows = _bounds.height / ( _particleRadius * 2 + _particleMargin );
			
			_totalParticles = _colomns * _rows;
			_updateFunction = avoidPosition;
			
			createParticles();
			startEnterFrame();
			createComps();
			alignComponents();
			
			stageResize_handler( null );
		}

		
		/*
		 * redraw with every resize of the stage
		 */
		override protected function stageResize_handler( event : Event ) : void 
		{
			super.stageResize_handler( event );
			
			stopEnterFrame();
			
			_halfStage = stage.stageHeight >> 1;
			_colomns = _bounds.width / ( _particleRadius * 2 + _particleMargin );
			_rows = _bounds.height / ( _particleRadius * 2 + _particleMargin );
			
			while( _view.numChildren > 0 )
			{
				_view.removeChildAt( 0 );
			}
			
			var i : int = _particleVect.length -1;
			var particle : Particle;
			while( i > -1 )
			{
				particle = _particleVect[ i ];
				particle = null;
				--i;
			}
			_totalParticles = _colomns * _rows;
			
			createParticles();
			startEnterFrame();
			alignComponents();
		}
		
		/*
		 * align the components to the bottom left of the screen
		 */
		private function alignComponents() : void
		{
			_compsContainer.y = ( _bounds.height - _compsContainer.height );
		}

		/*
		 * create controls
		 */
		private function createComps() : void
		{
			_compsContainer = new SelectionPanel( 0x1f1f1f );
			addChild( _compsContainer );
			
			// easing
			var springAmountLabel : Label = new Label( _compsContainer, 5, COMPS_MARGIN_Y, "Spring" );
			var springSlider : Slider = new Slider( "horizontal", _compsContainer, 5, springAmountLabel.height + COMPS_MARGIN_Y, spring_handler );
			springSlider.maximum = 2;
			springSlider.minimum = .1;
			springSlider.value = _springAmount;
			springSlider.width = 50;
			_springAmountLabel = new Label( _compsContainer, springSlider.x , ( springSlider.y + springSlider.height ), String( springSlider.value ) );
			
			// friction
			var frictionLabel : Label = new Label( _compsContainer, ( springSlider.x + springSlider.width )  + COMPS_MARGIN_X, COMPS_MARGIN_Y, "friction" );
			var frictionSlider : Slider = new Slider( "horizontal", _compsContainer, ( springSlider.x + springSlider.width)  + COMPS_MARGIN_X, frictionLabel.height + COMPS_MARGIN_Y, friction_handler );
			frictionSlider.maximum = 1;
			frictionSlider.minimum = 0.01;
			frictionSlider.width = 50;
			frictionSlider.value = _friction;
			_frictionPercentLabel = new Label( _compsContainer, frictionSlider.x, ( frictionSlider.y + frictionSlider.height ), String( frictionSlider.value ) );
			
			// friction
			var radiusLabel : Label = new Label( _compsContainer, ( frictionSlider.x + frictionSlider.width )  + COMPS_MARGIN_X, COMPS_MARGIN_Y, "Min Distance" );
			var radiusSlider : Slider = new Slider( "horizontal", _compsContainer, ( frictionSlider.x + frictionSlider.width)  + COMPS_MARGIN_X, radiusLabel.height + COMPS_MARGIN_Y, radius_handler );
			radiusSlider.maximum = 1000;
			radiusSlider.minimum = 10;
			radiusSlider.width = 50;
			radiusSlider.value = minDistance;
			_radiusSliderPercentLabel = new Label( _compsContainer, radiusSlider.x, ( radiusSlider.y + radiusSlider.height ), String( radiusSlider.value ) );
			
			// friction
			var mouseMassLabel : Label = new Label( _compsContainer, ( radiusSlider.x + radiusSlider.width ) + COMPS_MARGIN_X, COMPS_MARGIN_Y, "Mouse Mass" );
			var mouseMassSlider : Slider = new Slider( "horizontal", _compsContainer, ( radiusSlider.x + radiusSlider.width)  + COMPS_MARGIN_X, mouseMassLabel.height + COMPS_MARGIN_Y, mouseMass_handler );
			mouseMassSlider.maximum = 1000;
			mouseMassSlider.minimum = 10;
			mouseMassSlider.width = 50;
			mouseMassSlider.value = mouseMass;
			_mouseMassLabel = new Label( _compsContainer, mouseMassSlider.x, ( mouseMassSlider.y + mouseMassSlider.height ), String( mouseMassSlider.value ) );
			
			// friction
			var particleRadiusLabel : Label = new Label( _compsContainer, ( mouseMassSlider.x + mouseMassSlider.width ) + COMPS_MARGIN_X, COMPS_MARGIN_Y, "Particle Radius" );
			var particleRadiusSlider : Slider = new Slider( "horizontal", _compsContainer, ( mouseMassSlider.x + mouseMassSlider.width)  + COMPS_MARGIN_X, particleRadiusLabel.height + COMPS_MARGIN_Y, particleRadius_handler );
			particleRadiusSlider.maximum = 50;
			particleRadiusSlider.minimum = 2;
			particleRadiusSlider.width = 50;
			particleRadiusSlider.value = _particleRadius;
			_particleRadiusLabel = new Label( _compsContainer, particleRadiusSlider.x, ( particleRadiusSlider.y + particleRadiusSlider.height ), String( particleRadiusSlider.value ) );
			
			// speed up
			var speedUp : CheckBox = new CheckBox( _compsContainer, ( particleRadiusSlider.x + particleRadiusSlider.width ) + COMPS_MARGIN_X , particleRadiusSlider.y, "SpeedUp", speedUp_handler );
			speedUp.selected = false;
			
			var addSmiles : CheckBox = new CheckBox( _compsContainer, ( speedUp.x + speedUp.width  ) + COMPS_MARGIN_X , frictionSlider.y, "Smile", showSmiles_handler );
			addSmiles.selected = false;
			
			// add remove stats
			var addStatsCheckBox : CheckBox = new CheckBox( _compsContainer, ( addSmiles.x + addSmiles.width ) + COMPS_MARGIN_X , speedUp.y , "Stats", showStats_handler );
			addStatsCheckBox.selected = false;
			
			_compsContainer.draw(  ( addStatsCheckBox.x + addStatsCheckBox.width ) + COMPS_MARGIN_X, ( addStatsCheckBox.y + addStatsCheckBox.height ) + ( COMPS_MARGIN_Y * 4 ) );
			_compsContainer.activate();
		}

		
	// [ EVENT HANDLERS
	
		// spring handler, change the spring amount
		private function spring_handler( event : Event ) : void
		{
			_springAmount = Slider( event.target ).rawValue;
			_springAmountLabel.text = String( int((_springAmount/7)*100)/100 ); // show two decimal places
		}
		
		
		// speed up particle movement
		private function speedUp_handler( event : Event ) : void
		{
			_speedUp = CheckBox( event.target ).selected;
		}
		// choose friction amount
		private function friction_handler( event : Event ) : void
		{
			_friction = Slider( event.target ).rawValue;
			_frictionPercentLabel.text = String( Math.abs( _friction ) );
		}
		
		// show smile function
		private function showSmiles_handler( event : Event ) : void
		{
			var value : Boolean = CheckBox( event.target ).selected;
			_updateFunction = ( value ) ? showSmile : avoidPosition;
		}
		// min Distance slider
		private function radius_handler( event : Event ) : void 
		{
			var value : Number = Slider( event.target ).rawValue;
			minDistance = value;
			_radiusSliderPercentLabel.text = String( Math.round( minDistance ) );
		}
		// mouse mass
		private function mouseMass_handler( event : Event ) : void 
		{
			var value : Number = Slider( event.target ).rawValue;
			mouseMass = value;
			_mouseMassLabel.text = String( Math.round( mouseMass ) );
		}
		// mouse mass
		private function particleRadius_handler( event : Event ) : void 
		{
			_particleRadius = Math.round( Slider( event.target ).rawValue );
			_particleRadiusLabel.text = String( _particleRadius );
			stageResize_handler( null );
		}
		
	// ]

		/*
		 * create particles and place in a grid
		 */
		private function createParticles() : void
		{
			_particleVect = new Vector.<Particle>();
			
			var xPos 		: int = _particleRadius + _particleMargin;
			var yPos 		: int = _particleRadius + _particleMargin;
			var particle   	: Particle;
			var size 		: int = _particleRadius;
			
			for( var c : uint = 0; c < _colomns; c++ )
			{
				for( var r : uint = 0; r < _rows; r++ )
				{
					particle = new Particle( size, Math.random() * 0xFFFFFF );
					particle.x = ( xPos + ( size * 2 + _particleMargin ) * c );
					particle.y = ( yPos + ( size * 2 + _particleMargin ) * r ) ;
					particle.setStartingPosition( particle.x, particle.y );
					particle.vx = Math.random() * 6 - 3;
					particle.vy = Math.random() * 6 - 3;
					particle.mass = size;
					_view.addChild( particle );
					_particleVect.push( particle );
				}
			}
			
		}
	
	
		/*
		 * update the view, move particles
		 */
		override protected function update_handler( event : Event = null ) : void 
		{
			var i 				: int 	= _totalParticles - 1;
			var particle		: Particle;
			
			while( i > -1 )
			{
				particle = _particleVect[ i ];
				if( _speedUp )
				{
					particle.x += particle.vx; 
					particle.y += particle.vy;
				}
				
				_updateFunction( particle );
				--i;
			}
		}
		
		
		/*
		 * displace particles and move away from the mouse 
		 * based on mass
		 */
		private function avoidPosition( particle : Particle ) : void 
		{
			
			var originalPos		: Point =  particle.startingPosition;
			var dx 				: Number = originalPos.x - mouseX; // distance from original position
			var dy 				: Number = originalPos.y - mouseY;
			var distance		: Number = Math.sqrt( dx * dx + dy * dy );
			var targetPos		: Point = new Point();
			
			var angle 			: Number = Math.atan2( dy, dx );
			
			if( distance < minDistance )
			{
				targetPos.x = originalPos.x + Math.cos( angle ) * mouseMass; // get cords based on angel * mass
				targetPos.y = originalPos.y + Math.sin( angle ) * mouseMass;
			}
			else
			{
				targetPos.x = originalPos.x; // if not near minimum position, move back to starting position
				targetPos.y = originalPos.y;
			}
			
			// stop movement if position is at resting point ( original position )
			if( particle.x === targetPos.x && particle.y === targetPos.y ) return;
			
			// move velocity to spring
			particle.vx = ( targetPos.x - particle.x ) * _springAmount;
			particle.vy = ( targetPos.y - particle.y ) * _springAmount;
			particle.vx *= _friction;
			particle.vy *= _friction;
			
			particle.x += particle.vx;
			particle.y += particle.vy;
		}
		
		/*
		 * show smile hadler
		 * just for fun and randomly found
		 */
		private function showSmile( particle : Particle ) : void 
		{
			var originalPos		: Point =  particle.startingPosition;
			var dx 				: Number = mouseX - originalPos.x; // distance from original position
			var dy 				: Number = mouseY - originalPos.y;
			var distance		: Number = Math.sqrt( dx * dx + dy * dy );
			var targetPos		: Point = new Point();
			var yMargin			: Number = 0;
			
			var smileDistance 	: Number = ( minDistance * .8 );
			
			if( distance < minDistance && distance > smileDistance )
			{
				var theta : Number = ( dy / distance );
				var angle : Number = Math.asin( theta ) * 180 / Math.PI;
				
				if( mouseX < originalPos.x ) angle = 180 - angle;
				angle = 270 - angle;
				
				var radian : Number = angle / 180 * Math.PI;
				
				targetPos.x = mouseX + Math.sin( radian ) * ( minDistance * .75 );
				targetPos.y = mouseY + Math.cos( radian ) * ( minDistance * .75 );
				
			}
			else if(  distance < smileDistance )
			{
				var smileTheta : Number = ( dx / smileDistance );
				var smileAngle : Number = Math.asin( smileTheta ) * 180 / Math.PI;
				
				if( mouseY < _halfStage )
				{
					smileAngle = 180 - smileAngle;
					yMargin = ( minDistance * .55 );
				}
				
				var smileRad : Number = smileAngle / 180 * Math.PI;
				
				targetPos.x = mouseX + Math.sin( smileRad ) * ( minDistance * .35 );
				targetPos.y = ( mouseY  + yMargin ) + Math.cos( smileRad ) * ( minDistance * .35 );
				
				if( _eyeCount == 0 )
				{
					targetPos.x = mouseX - 40;
					targetPos.y = mouseY - 30;
					
					_eyeCount++;
				}
				else if( _eyeCount == 1 )
				{
					targetPos.x = mouseX + 40;
					targetPos.y = mouseY - 30;
					
					_eyeCount++;
				}
			}
			else
			{
				if( _eyeCount > 0 ) _eyeCount--;
				targetPos.x = originalPos.x; // if not near minimum position, move back to starting position
				targetPos.y = originalPos.y;
			}
			
			// stop movement if position is at resting point ( original position )
			if( particle.x === targetPos.x && particle.y === targetPos.y ) return;
			
			// move velocity to spring
			particle.vx = ( targetPos.x - particle.x ) * _springAmount;
			particle.vy = ( targetPos.y - particle.y ) * _springAmount;
			particle.vx *= _friction;
			particle.vy *= _friction;
			
			particle.x += particle.vx;
			particle.y += particle.vy;
			
		}
	}
}
