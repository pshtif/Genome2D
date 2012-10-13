/*
 * Simple standalone example containing just the Genome2D initialization
 * great as a starting point for any project.
 *
 * Create by: Peter "sHTiF" Stefcek / http://blog.flash-core.com
 */

package
{
	import com.genome2d.core.GConfig;
	import com.genome2d.core.Genome2D;
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	[SWF(width="800", height="600", backgroundColor="#000000", frameRate="60")]
	public class InitializeGenome2D extends Sprite
	{
		public function InitializeGenome2D() {
			// Hook up a callback once initialization is done
			Genome2D.getInstance().onInitialized.addOnce(onGenome2DInitialized);
			
			// Initialize Genome2D config, we need to specify area where Genome2D will be rendered
			// if we want the whole stage simply put the stage size there
			var config:GConfig = new GConfig(new Rectangle(0,0,stage.stageWidth, stage.stageHeight));
			
			// Initiaiize Genome2D
			Genome2D.getInstance().init(stage, config);
		}
		
		// Initialization callback
		protected function onGenome2DInitialized():void {
			// And we are done we can do our stuff here
		}
	}
}