package examples
{
	import com.flashcore.g2d.core.Genome2D;
	import com.flashcore.g2d.g2d;
	import com.flashcore.g2d.materials.G2DMaterialLibrary;
	import com.flashcore.g2d.sprites.G2DMovieClip;
	import com.flashcore.g2d.sprites.G2DSprite;
	import com.flashcore.g2d.sprites.G2DTransform;
	import com.flashcore.g2d.textures.G2DTexture;
	
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	
	public class BasicExample extends Example
	{
		[Embed(source = "./assets/mines.xml", mimeType = "application/octet-stream")]
		private static const MinesXML:Class;
		[Embed(source = "./assets/mines.png")]
		private static const MinesGFX:Class;
		
		private var __cTexture:G2DTexture;
		
		private const COUNT:int = 500;
		
		private var __iClipCount:int;
		
		public function BasicExample(p_wrapper:Genome2DExamples):void {
			super(p_wrapper);
		}
		
		private function updateInfo():void {
			_cWrapper.info = "<font color='#00FFFF'>BasicExample [ "+__iClipCount+" G2DMovieClips ]\n"+
			"<font color='#FFFFFF'>This is a simple stress test example rendering movieclips, each moveclip plays at its own custom framerate.\n"+
			"<font color='#FFFF00'>Press ARROW UP to increase the number of movieclips and ARROW DOWN to decrease them.";
		}
		
		override public function init():void {
			__cTexture = G2DTexture.createFromBitmapAtlas((new MinesGFX()).bitmapData, XML(new MinesXML()));
			
			G2DMaterialLibrary.createMaterial("mines", __cTexture);
			G2DMaterialLibrary.createMaterial("mine", __cTexture.getSubTextureById("mine2"));
			
			__iClipCount = 0;
			addClips(COUNT);
			
			_cGenome.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			updateInfo();
		}
		
		override public function dispose():void {
			super.dispose();
			
			__cTexture.dispose();
		}
		
		private function createSprite(p_x:Number, p_y:Number):G2DSprite {
			var clip:G2DSprite = new G2DSprite();
			clip.setMaterialById("mine");
			clip.x = p_x;
			clip.y = p_y;
			return clip;
		}
		
		private function createClip(p_x:Number, p_y:Number):G2DMovieClip {
			var clip:G2DMovieClip = new G2DMovieClip();
			clip.setFrameRate(Math.random()*10+3);
			clip.setMaterialById("mines");
			//clip.stop();
			clip.setFrames(new <String>["mine2", "mine3", "mine4", "mine5", "mine6", "mine7", "mine8", "mine9"]);
			clip.gotoFrame(Math.random()*8);
			clip.x = p_x;
			clip.y = p_y;
			return clip;
		}
		
		private function addClips(p_count:int):void {
			__iClipCount += p_count;
			for (var i:int = 0; i<p_count; ++i) {
				var clip:G2DMovieClip = createClip(Math.random()*800, Math.random()*600);
				//var clip:G2DSprite = createSprite(Math.random()*800, Math.random()*600);
				_cGenome.root.addChild(clip);
			}
			
			updateInfo();
		}
		
		private function removeClips(p_count:int):void {
			__iClipCount -= p_count;
			for (var i:int = 0; i < p_count; ++i) {
				if (_cGenome.root.numChildren == 0) break;
				_cGenome.root.removeChildAt(0);
			}
			
			updateInfo();
		}
		
		private function onKeyDown(event:KeyboardEvent):void {
			trace(event.keyCode);
			switch (event.keyCode) {
				case 38:
					addClips(500);
					break;
				case 40:
					removeClips(500);
					break;
			}
		}
	}
}