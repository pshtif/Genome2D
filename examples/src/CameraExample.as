/*
 * Simple custom camera example example
 *
 * Create by: Peter "sHTiF" Stefcek / http://blog.flash-core.com
 */

package
{
	import com.genome2d.components.GCamera;
	import com.genome2d.components.renderables.GSprite;
	import com.genome2d.core.GConfig;
	import com.genome2d.core.GNode;
	import com.genome2d.core.GNodeFactory;
	import com.genome2d.core.Genome2D;
	import com.genome2d.textures.factories.GTextureFactory;
	
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	[SWF(width="800", height="600", backgroundColor="#000000", frameRate="60")]
	public class CameraExample extends Sprite
	{
		[Embed(source = "../assets/crate.jpg")]
		static private const CrateGFX:Class;
		
		protected var _cCamera:GCamera;
		
		public function CameraExample() {
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
			// Create a crate texture from embedded asset
			GTextureFactory.createFromAsset("crate", CrateGFX, false);
			
			// Create a custom camera
			_cCamera = GNodeFactory.createNodeWithComponent(GCamera) as GCamera;
			// Move the custom camera to the center of the screen
			_cCamera.node.transform.setPosition(400,300);
			// Add the camera node to the render graph otherwise it is inactive
			Genome2D.getInstance().root.addChild(_cCamera.node);
			
			// Create some sprites to have something on the screen
			for (var i:int = 0; i<100; ++i) {
				createSprite("crate", Math.random()*800, Math.random()*600, Genome2D.getInstance().root);
			}
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		protected function createSprite(p_textureId:String, p_x:int, p_y:int, p_parent:GNode = null):GSprite {
			var sprite:GSprite = GNodeFactory.createNodeWithComponent(GSprite) as GSprite;
			sprite.textureId = p_textureId;
			sprite.node.transform.setPosition(p_x, p_y);
			if (p_parent) p_parent.addChild(sprite.node);
			return sprite;
		}
		
		protected function onKeyDown(event:KeyboardEvent):void {
			// Move the camera around
			switch (event.keyCode) {
				case Keyboard.LEFT:
					_cCamera.node.transform.x -= 5;
					break;
				case Keyboard.RIGHT:
					_cCamera.node.transform.x += 5;
					break;
				case Keyboard.UP:
					_cCamera.node.transform.y -= 5;
					break;
				case Keyboard.DOWN:
					_cCamera.node.transform.y += 5;
					break;
			}
		}
	}
}