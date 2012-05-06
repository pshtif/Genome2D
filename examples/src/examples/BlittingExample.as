package examples
{
	import assets.Assets;
	
	import com.genome2d.components.GComponent;
	import com.genome2d.components.renderables.GMovieClip;
	import com.genome2d.components.renderables.GTexturedQuad;
	import com.genome2d.context.GBlendMode;
	import com.genome2d.core.GNode;
	import com.genome2d.core.Genome2D;
	import com.genome2d.g2d;
	import com.genome2d.textures.GTexture;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	public class BlittingExample extends Example
	{
		private const COUNT:int = 100;
		
		private var __iBlitCount:int;
		private var __bMove:Boolean = true;
		
		public function BlittingExample(p_wrapper:Genome2DExamples):void {
			super(p_wrapper);
		}
		
		private function updateInfo():void {
			_cWrapper.info = "<font color='#00FFFF'><b>BlittingExample</b> [ "+__iBlitCount+" blitted images ]\n"+
			"<font color='#FFFFFF'>This is a simple stress test example using blitting instead of render node list.\n"+
			"<font color='#FFFF00'>Press ARROW UP to increase the number of blitted images and ARROW DOWN to decrease them.";
		}
		
		/**
		 * 	Initialize example
		 */
		override public function init():void {
			super.init();
	
			_cCamera.dispose();
					
			// Set default number of blitted images
			__iBlitCount = COUNT;
			
			// Hook up a key event
			_cGenome.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			// Hook up an enter frame event
			_cGenome.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			// Turn off autoupdate/autorender of the scene, this is crucial for blitting composition
			_cGenome.autoUpdate = false;
			
			// Update the text of an example
			updateInfo();
		}
		
		/**
		 * 	Our enter frame callback for manual blitting
		 */
		private function onEnterFrame(event:Event):void {
			// This will update the node graph, we will call this so our UI is updated
			_cGenome.update();
			
			// Initialize Genome rendering
			_cGenome.beginRender();
			
			var texture:GTexture = Assets.crateTexture;
			// Blit all the images we want
			for (var i:int = 0; i<__iBlitCount; ++i) {
				_cGenome.blit(Math.random()*_iWidth, Math.random()*_iHeight, texture);
			}
			
			// This will render the node graph, we will call this so our UI is rendered
			_cGenome.render();
			
			// Finalize Genome rendering
			_cGenome.endRender();
		}
		
		/**
		 * 	Dispose this example resources
		 */
		override public function dispose():void {
			super.dispose();
			
			_cGenome.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_cGenome.stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		/**
		 * 	Keyboard event callback
		 */
		private function onKeyDown(event:KeyboardEvent):void {
			switch (event.keyCode) {
				case 38:
					__iBlitCount+=100;
					break;
				case 40:
					__iBlitCount-=100;
					if (__iBlitCount<0) __iBlitCount = 0;
					break;
			}
			
			updateInfo();
		}
	}
}