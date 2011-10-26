package examples
{
	import com.flashcore.g2d.core.Genome2D;
	import com.flashcore.g2d.g2d;
	import com.flashcore.g2d.display.G2DMovieClip;
	import com.flashcore.g2d.display.G2DSprite;
	import com.flashcore.g2d.display.G2DTransform;
	import com.flashcore.g2d.textures.G2DTexture;
	
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	
	public class BasicExample extends Example
	{
		[Embed(source = "./assets/mines.xml", mimeType = "application/octet-stream")]
		private static const MinesXML:Class;
		[Embed(source = "./assets/mines.png")]
		private static const MinesGFX:Class;
		[Embed(source = "./assets/ninja.xml", mimeType = "application/octet-stream")]
		private static const NinjaXML:Class;
		[Embed(source = "./assets/ninja.png")]
		private static const NinjaGFX:Class;
		
		private var __cMineTexture:G2DTexture;
		private var __cNinjaTexture:G2DTexture;
		
		private const COUNT:int = 500;
		
		private var __iClipCount:int;
		private var __bMove:Boolean = true;
		
		public function BasicExample(p_wrapper:Genome2DExamples):void {
			super(p_wrapper);
		}
		
		private function updateInfo():void {
			_cWrapper.info = "<font color='#00FFFF'><b>BasicExample</b> [ "+__iClipCount+" G2DMovieClips ]\n"+
			"<font color='#FFFFFF'>This is a simple stress test example rendering movieclips, each moveclip plays at its own custom framerate.\n"+
			"<font color='#FFFF00'>Press ARROW UP to increase the number of movieclips and ARROW DOWN to decrease them, Press P to pause movement.";
		}
		
		override public function init():void {
			super.init();
			__cMineTexture = G2DTexture.createFromBitmapAtlas((new MinesGFX()).bitmapData, XML(new MinesXML()));
			__cNinjaTexture = G2DTexture.createFromBitmapAtlas((new NinjaGFX()).bitmapData, XML(new NinjaXML()));
			//__cTexture = G2DTexture.createFromBitmapData((new CrateGFX()).bitmapData);
			
			__iClipCount = 0;
			addClips(COUNT);
			
			_cGenome.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_cGenome.onRender.add(onRender);
			
			updateInfo();
		}
		
		override public function dispose():void {
			super.dispose();
			
			__cMineTexture.dispose();
			__cNinjaTexture.dispose();
			
			_cGenome.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_cGenome.onRender.removeAll();
		}
		
		private function createSprite(p_x:Number, p_y:Number):G2DSprite {
			var clip:G2DSprite = new G2DSprite(__cMineTexture.getSubTextureById("mine2"));
			clip.x = p_x;
			clip.y = p_y;
			return clip;
		}
		
		private function createMine(p_x:Number, p_y:Number):G2DMovieClip {
			var clip:G2DMovieClip = new G2DMovieClip(__cMineTexture);
			clip.setFrameRate(Math.random()*10+3);
			clip.setFrames(new <String>["mine2", "mine3", "mine4", "mine5", "mine6", "mine7", "mine8", "mine9"]);
			clip.gotoFrame(Math.random()*8);
			clip.x = p_x;
			clip.y = p_y;
			clip.rotation = Math.random()*Math.PI;
			return clip;
		}
		
		private function createNinja(p_x:Number, p_y:Number):G2DMovieClip {
			var clip:G2DMovieClip = new G2DMovieClip(__cNinjaTexture);
			clip.setFrameRate(Math.random()*10+3);
			clip.setFrames(new <String>["nw1", "nw2", "nw3", "nw2", "nw1", "stood", "nw4", "nw5", "nw6", "nw5", "nw4"]);
			clip.gotoFrame(Math.random()*8);
			clip.x = p_x;
			clip.y = p_y;
			return clip;
		}
		
		private function addClips(p_count:int):void {
			__iClipCount += p_count;
			for (var i:int = 0; i<p_count; ++i) {
				var clip:G2DMovieClip;
				//if (i%2 == 0)
				clip = createMine(Math.random()*800, Math.random()*600);
				//else clip = createNinja(Math.random()*800, Math.random()*600);
				//var clip:G2DSprite = createSprite(Math.random()*800, Math.random()*600);
				_cGenome.root.addChild(clip);
			}
			
			updateInfo();
		}
		
		private function removeClips(p_count:int):void {
			__iClipCount -= p_count;
			if (__iClipCount<0) __iClipCount = 0;
			for (var i:int = 0; i < p_count; ++i) {
				if (_cGenome.root.numChildren == 0) break;
				_cGenome.root.removeChildAt(0);
			}
			
			updateInfo();
		}
		
		private function onRender():void {
			if (!__bMove) return;
			
			for (var i:int = 0; i<_cGenome.root.numChildren; ++i) {
				_cGenome.root.getChildAt(i).rotation+=.1;
			}
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
				case 80:
					__bMove = !__bMove;
					break;
			}
		}
	}
}