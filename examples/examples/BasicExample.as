package examples
{
	import com.flashcore.g2d.components.G2DComponent;
	import com.flashcore.g2d.components.G2DMovieClip;
	import com.flashcore.g2d.components.G2DSprite;
	import com.flashcore.g2d.core.G2DNode;
	import com.flashcore.g2d.core.Genome2D;
	import com.flashcore.g2d.g2d;
	import com.flashcore.g2d.textures.G2DTextureAtlas;
	import com.flashcore.g2d.textures.G2DTextureLibrary;
	
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	
	public class BasicExample extends Example
	{		
		private var __cMineTexture:G2DTextureAtlas;
		private var __cNinjaTexture:G2DTextureAtlas;
		
		private const COUNT:int = 1000;
		
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
	
			__cMineTexture = G2DTextureAtlas.createFromBitmapDataAndXML("mineTexture", (new Assets.MinesGFX()).bitmapData, XML(new Assets.MinesXML()));
			//__cNinjaTexture = G2DTextureAtlas.createFromBitmapDataAndXML("ninja", (new NinjaGFX()).bitmapData, XML(new NinjaXML()));
			
			__iClipCount = 0;
			addSprites(COUNT);
			
			_cGenome.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_cGenome.onUpdated.add(onUpdate);
			
			updateInfo();
		}
		
		override public function dispose():void {
			super.dispose();
			
			__cMineTexture.dispose();
			__cMineTexture = null;
			//__cNinjaTexture.dispose();
			
			_cGenome.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_cGenome.onUpdated.removeAll();
		}
		
		private function createSprite(p_x:Number, p_y:Number):G2DNode {
			var node:G2DNode = new G2DNode();
			var sprite:G2DSprite = node.addComponent(G2DSprite) as G2DSprite;
			sprite.setTexture(__cMineTexture.getTexture("mine2"));
			node.transform.x = p_x;
			node.transform.y = p_y;
			return node;
		}
		
		private function createClip(p_x:Number, p_y:Number):G2DNode {
			var node:G2DNode = new G2DNode();
			var clip:G2DMovieClip = node.addComponent(G2DMovieClip) as G2DMovieClip;
			clip.setTextureAtlas(__cMineTexture);
			clip.setFrameRate(Math.random()*10+3);
			clip.setFrames(new <String>["mine2", "mine3", "mine4", "mine5", "mine6", "mine7", "mine8", "mine9"]);
			clip.gotoFrame(Math.random()*8);
			node.transform.x = p_x;
			node.transform.y = p_y;
			if (__bMove) node.transform.rotation = Math.random()*Math.PI;
			return node;
		}

		
		private function addSprites(p_count:int):void {
			__iClipCount += p_count;
			for (var i:int = 0; i<p_count; ++i) {
				var clip:G2DNode;
				
				//clip = createSprite(Math.random()*800, Math.random()*600);
				clip = createClip(Math.random()*800, Math.random()*600);
				
				_cContainer.addChild(clip);
			}
			
			updateInfo();
		}
		
		private function removeSprites(p_count:int):void {
			__iClipCount -= p_count;
			if (__iClipCount<0) __iClipCount = 0;
			for (var i:int = 0; i < p_count; ++i) {
				if (_cContainer.numChildren == 0) break;
				_cContainer.removeChildAt(0);
			}
			
			updateInfo();
		}
		
		private function onUpdate(p_deltaTime:Number):void {
			if (!__bMove) return;

			var length:int = _cContainer.numChildren;
			for (var i:int = 0; i<length; ++i) {
				_cContainer.getChildAt(i).transform.rotation+=.1;
			}
		}
		
		private function onKeyDown(event:KeyboardEvent):void {
			trace(event.keyCode);
			switch (event.keyCode) {
				case 38:
					addSprites(100);
					break;
				case 40:
					removeSprites(100);
					break;
				case 80:
					__bMove = !__bMove;
					var length:int = _cContainer.numChildren;
					var i:int;
					if (__bMove) { 
						for (i = 0; i<length; ++i) {
							_cContainer.getChildAt(i).transform.rotation=Math.random()*Math.PI;
						}
					} else {
						for (i = 0; i<length; ++i) {
							_cContainer.getChildAt(i).transform.rotation=0;
						}
					}
					break;
			}
		}
	}
}