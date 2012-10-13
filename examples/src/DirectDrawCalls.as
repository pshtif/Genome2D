/*
 * Simple standalone example containing just the Genome2D initialization
 * great as a starting point for any project.
 *
 * Create by: Peter "sHTiF" Stefcek / http://blog.flash-core.com
 */

package
{
	import com.genome2d.context.GContext;
	import com.genome2d.core.GConfig;
	import com.genome2d.core.Genome2D;
	import com.genome2d.textures.GTexture;
	import com.genome2d.textures.factories.GTextureFactory;
	
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	[SWF(width="800", height="600", backgroundColor="#000000", frameRate="60")]
	public class DirectDrawCalls extends Sprite
	{
		[Embed(source = "../assets/crate.jpg")]
		static private const CrateGFX:Class;
		
		private var __cTexture:GTexture;
		
		public function DirectDrawCalls() {
			// Hook up a callback once initialization is done
			Genome2D.getInstance().onInitialized.addOnce(onGenome2DInitialized);
			
			// Initialize Genome2D config, we need to specify area where Genome2D will be rendered
			// if we want the whole stage simply put the stage size there
			var config:GConfig = new GConfig(new Rectangle(0,0,stage.stageWidth, stage.stageHeight));
			config.enableStats = true;
			
			// Initiaiize Genome2D
			Genome2D.getInstance().init(stage, config);
		}
		
		// Initialization callback
		protected function onGenome2DInitialized():void {
			__cTexture = GTextureFactory.createFromAsset("crate", CrateGFX, false);
			
			// Hook up a callback at the end of rendering pipeline
			Genome2D.getInstance().onPostRender.add(onPostRender);
		}
		
		// Post render callback
		protected function onPostRender():void {
			// Just store reference to context so we don't need to access it through singleton each draw call, you can prestore this as well
			var context:GContext = Genome2D.getInstance().context;		
			var matrix:Matrix = new Matrix();
			
			for (var i:int=0; i<40000; ++i) {
				//matrix.identity();
				//matrix.translate(Math.random()*800,Math.random()*600);
				//context.draw2(__cTexture, matrix);
				//context.draw(__cTexture, Math.random()*800,Math.random()*600);
				context.blit(__cTexture, Math.random()*800,Math.random()*600);
			}
		}
	}
}