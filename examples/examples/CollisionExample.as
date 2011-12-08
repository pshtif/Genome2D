package examples
{
	import com.flashcore.g2d.components.G2DMovieClip;
	import com.flashcore.g2d.core.G2DNode;
	import com.flashcore.g2d.textures.G2DTextureAtlas;
	import com.flashcore.g2d.textures.G2DTextureLibrary;

	public class CollisionExample extends Example
	{
		private var __cRotatingContainer:G2DNode;
		private var __cNinjaContainer:G2DNode;
		
		private var __cMineTexture:G2DTextureAtlas;
		private var __cNinjaTexture:G2DTextureAtlas;
		
		static private const NINJA_COUNT:int = 100;
		
		public function CollisionExample(p_wrapper:Genome2DExamples):void {
			super(p_wrapper);
		}
		
		override public function init():void {
			super.init();
			_cWrapper.info = "<font color='#00FFFF'><b>CollisionExample</b>\n"+
			"<font color='#FFFFFF'>Collision example where numbers collide with ninjas ;)\n"+
			"<font color='#FFFF00'>You can use mouse to DRAG ninjas around.";
			
			__cMineTexture = G2DTextureAtlas.createFromBitmapDataAndXML("mine", (new Assets.MinesGFX()).bitmapData, XML(new Assets.MinesXML()));
			
			__cNinjaTexture = G2DTextureAtlas.createFromBitmapDataAndXML("ninja", (new Assets.NinjaGFX()).bitmapData, XML(new Assets.NinjaXML()));
			
			__cRotatingContainer = new G2DNode();
			__cRotatingContainer.transform.x = 400;
			__cRotatingContainer.transform.y = 300;
			for (var i:int = 0; i<23; ++i) {
				var mine:G2DNode = createMine(-264+24*i, 0);
				mine.userData = false;
				__cRotatingContainer.addChild(mine);
				var mine:G2DNode = createMine(0, -265+24*i);
				mine.userData = false;
				__cRotatingContainer.addChild(mine);
			}
			_cGenome.root.addChild(__cRotatingContainer);
			
			
			__cNinjaContainer = new G2DNode();
			for (var i:int = 0; i<NINJA_COUNT; ++i) {
				var clip:G2DNode = createNinja(Math.random()*(800-200)+100,Math.random()*(600-100)+50);
				clip.mouseEnabled = true;
				clip.onMouseDown.add(onClipMouseDown);
				clip.onMouseUp.add(onClipMouseUp);
				__cNinjaContainer.addChild(clip);
			}
			_cGenome.root.addChild(__cNinjaContainer);
			/**/
			_cGenome.onUpdated.add(onUpdate);
		}
		
		override public function dispose():void {
			super.dispose();
			
			_cGenome.onUpdated.removeAll();
			__cMineTexture.dispose();
			__cNinjaTexture.dispose();
		}
		
		private function createMine(p_x:Number, p_y:Number):G2DNode {
			var node:G2DNode = new G2DNode();
			var clip:G2DMovieClip = node.addComponent(G2DMovieClip) as G2DMovieClip;
			clip.setTextureAtlas(__cMineTexture);
			clip.setFrameRate(Math.random()*10+3);
			clip.setFrames(new <String>["mine2", "mine3", "mine4", "mine5", "mine6", "mine7", "mine8", "mine9"]);
			clip.gotoFrame(Math.random()*8);
			node.transform.x = p_x;
			node.transform.y = p_y;
			return node;
		}
		
		private function createNinja(p_x:Number, p_y:Number):G2DNode {
			var node:G2DNode = new G2DNode();
			var clip:G2DMovieClip = node.addComponent(G2DMovieClip) as G2DMovieClip;
			clip.setTextureAtlas(__cNinjaTexture);
			clip.setFrameRate(Math.random()*10+3);
			clip.setFrames(new <String>["nw1", "nw2", "nw3", "nw2", "nw1", "stood", "nw4", "nw5", "nw6", "nw5", "nw4"]);
			clip.gotoFrame(Math.random()*8);
			node.transform.x = p_x;
			node.transform.y = p_y;
			return node;
		}
		
		private function onClipMouseDown(p_target:G2DNode, p_dispatcher:G2DNode, p_x:Number, p_y:Number):void {
			//p_dispatcher.startDrag();
			//p_dispatcher.setChildIndex(p_dispatcher.parent.numChildren-1);
		}
		
		private function onClipMouseUp(p_target:G2DNode, p_dispatcher:G2DNode, p_x:Number, p_y:Number):void {
			trace("onMouseUp");
			//p_dispatcher.stopDrag();
		}
		
		private function onUpdate(p_deltaTime:Number):void {
			__cRotatingContainer.transform.rotation+=.01;
			
			var i:int;
			var j:int;
			var c:Boolean = false;
			
			for (i = 0; i<__cNinjaContainer.numChildren; ++i) {
				c = false;
				var ninja:G2DNode = __cNinjaContainer.getChildAt(i) as G2DNode;
				var ninjaClip:G2DMovieClip = ninja.getComponent(G2DMovieClip) as G2DMovieClip;
				for (j = 0; j<__cRotatingContainer.numChildren; ++j) {
					var mine:G2DNode = __cRotatingContainer.getChildAt(j) as G2DNode;
					if (c && mine.userData) continue;
					var mineClip:G2DMovieClip = mine.getComponent(G2DMovieClip) as G2DMovieClip;
					var a:Boolean = ninjaClip.hitTestObject(mineClip);
					mine.userData = a || mine.userData;
					c = a || c;
				}
				
				if (c) {
					ninja.transform.green = ninja.transform.blue = 0;
				} else {
					ninja.transform.green = ninja.transform.blue = 1;
				}
			}
			
			for (i = 0; i<__cRotatingContainer.numChildren; ++i) {
				var mine:G2DNode = __cRotatingContainer.getChildAt(i) as G2DNode; 
				if (mine.userData) {
					mine.transform.green = mine.transform.blue = 0;
					mine.userData = false;
				} else {
					mine.transform.green = mine.transform.blue = 1;
				}
			}
		}
	}
}