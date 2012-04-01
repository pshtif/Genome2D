package examples
{
	import assets.Assets;
	
	import com.genome2d.components.renderables.GMovieClip;
	import com.genome2d.core.GNode;

	public class CollisionExample extends Example
	{
		private var __cRotatingContainer:GNode;
		private var __cNinjaContainer:GNode;
		
		static private const NINJA_COUNT:int = 10;
		
		public function CollisionExample(p_wrapper:Genome2DExamples):void {
			super(p_wrapper);
		}
		
		override public function init():void {
			super.init();
			_cWrapper.info = "<font color='#00FFFF'><b>CollisionExample</b>\n"+
			"<font color='#FFFFFF'>Collision example where numbers collide with ninjas ;)\n"+
			"<font color='#FFFF00'>You can use mouse to DRAG ninjas around.";
			
			__cRotatingContainer = new GNode();
			__cRotatingContainer.transform.x = _iWidth/2;
			__cRotatingContainer.transform.y = _iHeight/2;
			for (var i:int = 0; i<23; ++i) {
				var mine:GNode = createMine(-264+24*i, 0);
				mine.userData = false;
				__cRotatingContainer.addChild(mine);
				var mine:GNode = createMine(0, -265+24*i);
				mine.userData = false;
				__cRotatingContainer.addChild(mine);
			}
			_cContainer.addChild(__cRotatingContainer);
			
			
			__cNinjaContainer = new GNode();
			for (var i:int = 0; i<NINJA_COUNT; ++i) {
				var clip:GNode = createNinja(Math.random()*(_iWidth-200)+100,Math.random()*(_iHeight-100)+50);
				__cNinjaContainer.addChild(clip);
			}
			_cContainer.addChild(__cNinjaContainer);
			/**/
			_cGenome.onPreUpdate.add(onUpdate);
		}
		
		override public function dispose():void {
			super.dispose();
			
			_cGenome.onPreUpdate.removeAll();
		}
		
		private function createMine(p_x:Number, p_y:Number):GNode {
			var node:GNode = new GNode();
			var clip:GMovieClip = node.addComponent(GMovieClip) as GMovieClip;
			clip.setTextureAtlas(Assets.mineTextureAtlas);
			clip.frameRate = Math.random()*10+3;
			clip.frames = ["mine2", "mine3", "mine4", "mine5", "mine6", "mine7", "mine8", "mine9"];
			clip.gotoFrame(Math.random()*8);
			node.transform.x = p_x;
			node.transform.y = p_y;
			return node;
		}
		
		private function createNinja(p_x:Number, p_y:Number):GNode {
			var node:GNode = new GNode();
			var clip:GMovieClip = node.addComponent(GMovieClip) as GMovieClip;
			clip.setTextureAtlas(Assets.ninjaTextureAtlas);
			clip.frameRate = Math.random()*10+3;
			clip.frames = ["nw1", "nw2", "nw3", "nw2", "nw1", "stood", "nw4", "nw5", "nw6", "nw5", "nw4"];
			clip.gotoFrame(Math.random()*8);
			node.transform.x = p_x;
			node.transform.y = p_y;
			return node;
		}
		
		private function onUpdate(p_deltaTime:Number):void {
			__cRotatingContainer.transform.rotation+=.01;
			
			var i:int;
			var j:int;
			var c:Boolean = false;
			
			for (var ninja:GNode = __cNinjaContainer.firstChild; ninja; ninja = ninja.next) {
				c = false;
				var ninjaClip:GMovieClip = ninja.getComponent(GMovieClip) as GMovieClip;
				for (var mine:GNode = __cRotatingContainer.firstChild; mine; mine = mine.next) {
					if (c && mine.userData) continue;
					var mineClip:GMovieClip = mine.getComponent(GMovieClip) as GMovieClip;
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
			
			for (var mine:GNode = __cRotatingContainer.firstChild; mine; mine = mine.next) {
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