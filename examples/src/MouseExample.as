/*
 *
 * Create by: Peter "sHTiF" Stefcek / http://blog.flash-core.com
 */

package
{
	import com.genome2d.components.renderables.GSprite;
	import com.genome2d.core.GConfig;
	import com.genome2d.core.GNodeFactory;
	import com.genome2d.core.Genome2D;
	import com.genome2d.signals.GMouseSignal;
	import com.genome2d.textures.factories.GTextureFactory;
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	[SWF(width="800", height="600", backgroundColor="#000000", frameRate="60")]
	public class MouseExample extends Sprite
	{
		[Embed(source = "../assets/crate.jpg")]
		static private const CrateGFX:Class;
		
		protected var _cGenome2D:Genome2D;
		
		public function MouseExample() {
			_cGenome2D = Genome2D.getInstance();
			// Hook up a callback once initialization is done
			_cGenome2D.onInitialized.addOnce(onGenome2DInitialized);
			
			// Initialize Genome2D config, we need to specify area where Genome2D will be rendered
			// if we want the whole stage simply put the stage size there
			var config:GConfig = new GConfig(new Rectangle(0,0,stage.stageWidth, stage.stageHeight));
			
			// Initiaiize Genome2D
			_cGenome2D.init(stage, config);
		}
		
		// Initialization callback
		protected function onGenome2DInitialized():void {
			GTextureFactory.createFromAsset("crate", CrateGFX);
			
			// Lets add bunch of crates to the screen so we have something to click on
			for (var i:int = 0; i<100; ++i) {
				var sprite:GSprite = GNodeFactory.createNodeWithComponent(GSprite) as GSprite;
				sprite.textureId = "crate";
				sprite.node.transform.setPosition(50+Math.random()*(stage.stageWidth-100), 50+Math.random()*(stage.stageHeight-100));
				// By default all nodes have mouse enabled false so we need to set it to true
				sprite.node.mouseEnabled = true;
				// Lets hook up our mouse click signal
				sprite.node.onMouseClick.add(onClick);
				_cGenome2D.root.addChild(sprite.node);
			}
		}
		
		// Mouse click signal callback
		protected function onClick(signal:GMouseSignal):void {
			trace("click");
		}
	}
}