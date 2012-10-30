/*
 * Simple standalone example containing just the Genome2D initialization
 * great as a starting point for any project.
 *
 * Create by: Peter "sHTiF" Stefcek / http://blog.flash-core.com
 */

package
{
	import com.genome2d.components.renderables.GSprite;
	import com.genome2d.core.GConfig;
	import com.genome2d.core.GNodeFactory;
	import com.genome2d.core.GNodePool;
	import com.genome2d.core.Genome2D;
	import com.genome2d.textures.factories.GTextureFactory;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	[SWF(width="800", height="600", backgroundColor="#000000", frameRate="60")]
	public class PoolExample extends Sprite
	{
		[Embed(source = "../assets/crate.jpg")]
		static private const CrateGFX:Class;
		
		protected var _cGenome2D:Genome2D;
		protected var _cPool:GNodePool;
		
		public function PoolExample() {
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
			
			// Create a node with sprite component and custom FallingCrateComponent
			var sprite:GSprite = GNodeFactory.createNodeWithComponent(GSprite) as GSprite;
			sprite.textureId = "crate";
			sprite.node.addComponent(FallingCrateComponent);
			
			// Now once we have this node created we can access its prototype which is basically and XML export of its state, this prototype can be used for various things like import/export
			// but in this case we will use it to create a pool of our objects
			
			// Its simple initialize a GNodePool with a specific prototype, don't forget that it always takes NODE PROTOTYPE as a parameter not a component prototype
			// Second and third parameter are also useful, second parameter sets the maximum amount of instances you want to pool at any case, which means that if there is this maximum instances 
			// and you call getNext on the pool you will get null
			// Third parameter is amount of precached instances that should be initialized, what this does is precache these instances right away, so if we specified 100 all of those 100 instances
			// would be instantiated at this moment instead of later by calling getNext when there are no cached instances available
			_cPool = new GNodePool(sprite.node.getPrototype(), 0, 0);
			
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		protected function onEnterFrame(event:Event):void {
			// Simple way to skip some frames as we don't want to add crate each frame
			if (Math.random()*100>20) return;
			
			// Get ourselves a free node instance from our pool, getNext method will automatically returns us an available pool instance and activate it if there is no available instance it 
			// will automatically create one for us (unless we specified max instances and there is already max reached)
			// As pool always work on nodes I need to access the FallingCrateComponent on it through getComponent
			var crate:FallingCrateComponent = _cPool.getNext().getComponent(FallingCrateComponent) as FallingCrateComponent;
			// Change the speed of the falling crate, if we didn't set this the speed would be reused from the dead instance
			crate.speed = 1+Math.random()*9;
			// Add the node instance to the root	
			_cGenome2D.root.addChild(crate.node);
			// Set a random position for our crate
			crate.node.transform.setPosition(Math.random()*800, -16);
			
			// If we wanted to check how many cached instances are there in the pool we can easily trace
			// _cPool.cachedCount this will return the number of instances inside the pool, both active and inactive
		}
	}
}