package examples
{
	import assets.Assets;
	
	import com.flashcore.g2d.components.renderables.G2DMovieClip;
	import com.flashcore.g2d.components.renderables.G2DSprite;
	import com.flashcore.g2d.core.G2DNode;
	
	import flash.events.KeyboardEvent;
	
	public class RenderExample extends Example
	{		
		private const COUNT:int = 500;
		
		private var __iNodeCount:int;
		private var __bMove:Boolean = true;
		
		private var __bSprite:Boolean = true
		
		public function RenderExample(p_wrapper:Genome2DExamples):void {
			super(p_wrapper);
		}
		
		private function updateInfo():void {
			_cWrapper.info = "<font color='#00FFFF'><b>BasicExample</b> [ "+__iNodeCount+" G2DSprites ]\n"+
			"<font color='#FFFFFF'>This is a simple stress test example rendering movieclips, each moveclip plays at its own custom framerate.\n"+
			"<font color='#FFFF00'>Press ARROW UP to increase the number of movieclips and ARROW DOWN to decrease them, Press P to pause animation and movement.";
		}
		
		override public function init():void {
			super.init();
			
			__iNodeCount = 0;
			addNodes(COUNT);
			
			_cGenome.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_cGenome.onUpdated.add(onUpdate);
			
			updateInfo();
		}
		
		override public function dispose():void {
			super.dispose();
			
			_cGenome.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_cGenome.onUpdated.removeAll();
		}
		
		private function createNode(p_x:Number, p_y:Number):G2DNode {
			var node:G2DNode = new G2DNode();
			node.transform.x = p_x;
			node.transform.y = p_y;
			if (__bMove) node.transform.rotation = Math.random()*Math.PI;
			
			if (__bSprite) addSprite(node);
			else addClip(node);
			
			return node;
		}
		
		private function addSprite(p_node:G2DNode):void	{
			var sprite:G2DSprite = p_node.addComponent(G2DSprite) as G2DSprite;
			sprite.setTexture(Assets.crateTexture);
		}
		
		private function addClip(p_node:G2DNode):void {
			var clip:G2DMovieClip = p_node.addComponent(G2DMovieClip) as G2DMovieClip;
			clip.setTextureAtlas(Assets.mineTextureAtlas);
			clip.setFrameRate(Math.random()*10+3);
			clip.setFrames(new <String>["mine2", "mine3", "mine4", "mine5", "mine6", "mine7", "mine8", "mine9"]);
			clip.gotoFrame(Math.random()*8);
		}

		
		private function addNodes(p_count:int):void {
			__iNodeCount += p_count;
			for (var i:int = 0; i<p_count; ++i) {
				var clip:G2DNode;
				
				clip = createNode(Math.random()*_iWidth, Math.random()*_iHeight);
				
				_cContainer.addChild(clip);
			}
			
			updateInfo();
		}
		
		private function removeNodes(p_count:int):void {
			__iNodeCount -= p_count;
			if (__iNodeCount<0) __iNodeCount = 0;
			for (var i:int = 0; i < p_count; ++i) {
				if (_cContainer.numChildren == 0) break;
				_cContainer.removeChildAt(0);
			}
			
			updateInfo();
		}
		
		private function onUpdate(p_deltaTime:Number):void {
			if (!__bMove) return;
			/**/
			var length:int = _cContainer.numChildren;
			for (var i:int = 0; i<length; ++i) {
				_cContainer.getChildAt(i).transform.rotation+=.1;
			}
			/**/
		}
		
		private function onKeyDown(event:KeyboardEvent):void {
			switch (event.keyCode) {
				case 38:
					addNodes(500);
					break;
				case 40:
					removeNodes(500);
					break;
				case 65:

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