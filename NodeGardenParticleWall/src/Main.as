package 
{
	import com.ParticleWall;
	import com.ICurrentView;
	import com.NodeGarden;
	import com.SelectionPanel;
	import com.bit101.components.CheckBox;
	import com.greensock.plugins.GlowFilterPlugin;
	import com.greensock.plugins.RemoveTintPlugin;
	import com.greensock.plugins.TintPlugin;
	import com.greensock.plugins.TweenPlugin;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;

	[ SWF( backgroundColor="#000000" )]
	public class Main extends Sprite
	{
		private static const YMARGIN 				: Number = 16;
		private static const XMARGIN 				: Number = 18;
		private static const PARTICLE_WALL 			: String = "particle_wall";
		private static const NODE_GRADEN 			: String = "node_garden";
		
		
		private var _decisionPanel 					: SelectionPanel;
		private var _currentView 					: ICurrentView;
		private var _nodeGardenCheckbox 			: CheckBox;
		private var _particleWallCheckbox 			: CheckBox;
		
		public function Main()
		{
			stage.scaleMode 	= StageScaleMode.NO_SCALE;
			stage.align			= StageAlign.TOP_LEFT;
			
			TweenPlugin.activate([ GlowFilterPlugin, TintPlugin, RemoveTintPlugin ]);
			
			activateView();
			setUpChoicePanel();
		}
		
		/*
		 * create the display panel
		 */
		private function setUpChoicePanel() : void
		{
			
			_decisionPanel = new SelectionPanel( 0x1f1f1f );
			addChild( _decisionPanel );
			
			_nodeGardenCheckbox = new CheckBox( _decisionPanel, 10, 10, "Colour Node Garden", showNodeGarden_handler );
			_nodeGardenCheckbox.selected = true;
			_particleWallCheckbox = new CheckBox( _decisionPanel, 10, 25, "Particle Wall", showParticleWall_handler );
			
			_decisionPanel.draw( ( _decisionPanel.width + XMARGIN) , ( _decisionPanel.height + YMARGIN ) );
			_decisionPanel.activate();
			
		}

		/*
		 * show the particle wall - hide node garden
		 */
		private function showParticleWall_handler( event : Event ) : void 
		{ 
			( _particleWallCheckbox.selected )? activateView( PARTICLE_WALL ) : activateView( NODE_GRADEN ); 
		}
		
		/*
		 * shwo node garden - hide particle wall
		 */
		private function showNodeGarden_handler( event : Event ) : void 
		{ 
			( _nodeGardenCheckbox.selected )? activateView( NODE_GRADEN ) : activateView( PARTICLE_WALL ); 
		}
		
		/*
		 * swap views and activate current view
		 */
		public function activateView( viewName : String = "" ) : void
		{
			
			if( _currentView )
			{
				 _currentView.dispose();
				 this.removeChild( _currentView as DisplayObject );
				 _currentView = null;
			}
			
			switch( viewName )
			{
				case NODE_GRADEN :
					_currentView = new NodeGarden();
					_particleWallCheckbox.selected = false;
					break;
				
				case PARTICLE_WALL :
					_currentView = new ParticleWall();
					_nodeGardenCheckbox.selected = false;
					break;
					
				default :
					_currentView = new NodeGarden();
					break;
			}
			
			addChild( _currentView as DisplayObject );
			if( _decisionPanel ) setChildIndex( _decisionPanel, this.numChildren - 1 );
		}
			
	}
}
