package examples
{
	import com.flashcore.g2d.display.G2DContainer;
	import com.flashcore.g2d.display.G2DMovieClip;
	import com.flashcore.g2d.display.G2DSprite;
	import com.flashcore.g2d.display.G2DTransform;
	import com.flashcore.g2d.textures.G2DTexture;

	public class CollisionExample extends Example
	{
		[Embed(source = "./assets/mines.xml", mimeType = "application/octet-stream")]
		private static const MinesXML:Class;
		[Embed(source = "./assets/mines.png")]
		private static const MinesGFX:Class;
		[Embed(source = "./assets/ninja.xml", mimeType = "application/octet-stream")]
		private static const NinjaXML:Class;
		[Embed(source = "./assets/ninja.png")]
		private static const NinjaGFX:Class;

		
		private var __cRotatingContainer:G2DContainer;
		private var __cNinjaContainer:G2DContainer;
		
		private var __cMineTexture:G2DTexture;
		private var __cNinjaTexture:G2DTexture;
		
		static private const NINJA_COUNT:int = 100;
		
		public function CollisionExample(p_wrapper:Genome2DExamples):void {
			super(p_wrapper);
		}
		
		override public function init():void {
			super.init();
			_cWrapper.info = "<font color='#00FFFF'><b>CollisionExample</b>\n"+
			"<font color='#FFFFFF'>Collision example where numbers collide with ninjas ;)\n"+
			"<font color='#FFFF00'>You can use mouse to DRAG ninjas around.";
			
			__cMineTexture = G2DTexture.createFromBitmapAtlas((new MinesGFX()).bitmapData, XML(new MinesXML()));
			
			__cNinjaTexture = G2DTexture.createFromBitmapAtlas((new NinjaGFX()).bitmapData, XML(new NinjaXML()));
			
			__cRotatingContainer = new G2DContainer();
			__cRotatingContainer.x = 400;
			__cRotatingContainer.y = 300;
			for (var i:int = 0; i<23; ++i) {
				var mine:G2DMovieClip = createMine(-264+24*i, 0);
				mine.userData = false;
				__cRotatingContainer.addChild(mine);
				var mine:G2DMovieClip = createMine(0, -265+24*i);
				mine.userData = false;
				__cRotatingContainer.addChild(mine);
			}
			_cGenome.root.addChild(__cRotatingContainer);
			
			
			__cNinjaContainer = new G2DContainer();
			for (var i:int = 0; i<NINJA_COUNT; ++i) {
				var clip:G2DMovieClip = createNinja(Math.random()*(800-200)+100,Math.random()*(600-100)+50);
				clip.mouseEnabled = true;
				clip.onMouseDown.add(onClipMouseDown);
				clip.onMouseUp.add(onClipMouseUp);
				__cNinjaContainer.addChild(clip);
			}
			_cGenome.root.addChild(__cNinjaContainer);
			/**/
			_cGenome.onRender.add(onRender);
		}
		
		override public function dispose():void {
			super.dispose();
			
			_cGenome.onRender.removeAll();
			__cMineTexture.dispose();
			__cNinjaTexture.dispose();
		}
		
		private function createMine(p_x:Number, p_y:Number):G2DMovieClip {
			var clip:G2DMovieClip = new G2DMovieClip(__cMineTexture);
			clip.setFrameRate(Math.random()*10+3);
			clip.setFrames(new <String>["mine2", "mine3", "mine4", "mine5", "mine6", "mine7", "mine8", "mine9"]);
			clip.gotoFrame(Math.random()*8);
			clip.x = p_x;
			clip.y = p_y;
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
		
		private function onClipMouseDown(p_target:G2DTransform, p_dispatcher:G2DTransform, p_x:Number, p_y:Number):void {
			p_dispatcher.startDrag();
			p_dispatcher.setChildIndex(p_dispatcher.parent.numChildren-1);
		}
		
		private function onClipMouseUp(p_target:G2DTransform, p_dispatcher:G2DTransform, p_x:Number, p_y:Number):void {
			trace("onMouseUp");
			p_dispatcher.stopDrag();
		}
		
		private function onRender():void {
			__cRotatingContainer.rotation+=.01;
			
			var i:int;
			var j:int;
			var c:Boolean = false;
			
			for (i = 0; i<__cNinjaContainer.numChildren; ++i) {
				c = false;
				var ninja:G2DSprite = __cNinjaContainer.getChildAt(i) as G2DSprite;
				for (j = 0; j<__cRotatingContainer.numChildren; ++j) {
					var mine:G2DSprite = __cRotatingContainer.getChildAt(j) as G2DSprite;
					if (c && mine.userData) continue;
					var a:Boolean = ninja.hitTestObject(mine);
					mine.userData = a || mine.userData;
					c = a || c;
				}
				
				if (c) {
					ninja.green = ninja.blue = 0;
				} else {
					ninja.green = ninja.blue = 1;
				}
			}
			
			for (i = 0; i<__cRotatingContainer.numChildren; ++i) {
				var mine:G2DSprite = __cRotatingContainer.getChildAt(i) as G2DSprite; 
				if (mine.userData) {
					mine.green = mine.blue = 0;
					mine.userData = false;
				} else {
					mine.green = mine.blue = 1;
				}
			}
		}
	}
}