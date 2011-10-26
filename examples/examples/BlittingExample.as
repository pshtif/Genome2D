package examples
{
	import com.flashcore.g2d.context.G2DContext;
	import com.flashcore.g2d.core.Genome2D;
	import com.flashcore.g2d.display.G2DMovieClip;
	import com.flashcore.g2d.display.G2DSprite;
	import com.flashcore.g2d.display.G2DTransform;
	import com.flashcore.g2d.g2d;
	import com.flashcore.g2d.textures.G2DTexture;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	public class BlittingExample extends Example
	{
		[Embed(source = "./assets/mines.xml", mimeType = "application/octet-stream")]
		private static const MinesXML:Class;
		[Embed(source = "./assets/crate.jpg")]
		private static const CrateGFX:Class;
		
		private var __cTexture:G2DTexture;
		
		private const COUNT:int = 500;
		
		private var __iClipCount:int;
		private var __bMove:Boolean = true;
		
		public function BlittingExample(p_wrapper:Genome2DExamples):void {
			super(p_wrapper);
		}
		
		private function updateInfo():void {
			_cWrapper.info = "<font color='#00FFFF'><b>BlittingExample</b> [ "+__iClipCount+" images ]\n"+
			"<font color='#FFFFFF'>This is a blitting example which uses blit() function instead of G2DSprites/G2DMovieClip instances, simply blits textures into random positions.\n"+
			"<font color='#FFFF00'>Press ARROW UP to increase the number of blitted images and ARROW DOWN to decrease them.";
		}
		
		override public function init():void {
			super.init();
			__cTexture = G2DTexture.createFromBitmapData((new CrateGFX()).bitmapData);
			
			__iClipCount = COUNT;
			
			_cGenome.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_cGenome.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			// We need to disable auto render of G2D content when using blitting
			_cGenome.autoRender = false;
			
			updateInfo();
		}
		
		override public function dispose():void {
			super.dispose();
			
			__cTexture.dispose();
			
			_cGenome.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_cGenome.stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function addClips(p_count:int):void {
			__iClipCount += p_count;

			updateInfo();
		}
		
		private function removeClips(p_count:int):void {
			__iClipCount -= p_count;
			if (__iClipCount<0) __iClipCount = 0;
			
			updateInfo();
		}
		
		private function onEnterFrame(event:Event):void {
			// Start genome rendering
			_cGenome.start();
			// Its faster to reference the genome context when blitting since this skips one function call
			var context:G2DContext = _cGenome.getContext();
			
			for (var i:int = 0; i<__iClipCount; ++i) {
				// Blit the textures to the screen, the funny thing is that if we removed the Math.random() calls it would be up to 2 times faster
				// yes random is that slow ;)
				context.blit(Math.random()*800, Math.random()*600, __cTexture);
				//context.blit(100, 100, __cTexture);
			}
			// End genome rendering
			_cGenome.end();
		}
		
		private function onKeyDown(event:KeyboardEvent):void {
			switch (event.keyCode) {
				case 38:
					addClips(500);
					break;
				case 40:
					removeClips(500);
					break;
				case 80:
					__bMove = !__bMove;
					break;
			}
		}
	}
}