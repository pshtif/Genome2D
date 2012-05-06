package examples
{
	import assets.Assets;
	
	import com.genome2d.components.renderables.GColorQuad;
	import com.genome2d.components.renderables.GMovieClip;
	import com.genome2d.components.renderables.GSprite;
	import com.genome2d.context.GBlendMode;
	import com.genome2d.core.GNode;
	
	import examples.components.Moving;
	
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	
	public class DepthSortExample extends Example
	{		
		private const COUNT:int = 500;
		
		private var __iNodeCount:int;
		private var __bMove:Boolean = true;
		
		private var __bAscending:Boolean = false;
		
		public function DepthSortExample(p_wrapper:Genome2DExamples):void {
			super(p_wrapper);
		}
		
		private function updateInfo():void {
			_cWrapper.info = "<font color='#00FFFF'><b>DepthSortExample</b> [ "+__iNodeCount+" GSprites ]\n"+
			"<font color='#FFFFFF'>This is a simple stress test for depth sorting inside Genome2D.\n"+
			"<font color='#FFFF00'>Press ARROW UP to increase the number of sprites and ARROW DOWN to decrease them, Press A to pause movement.";
		}
		
		override public function init():void {
			super.init();
			
			_cGenome.context.antiAliasing = 0;
			
			__iNodeCount = 0;
			addNodes(COUNT);
			
			_cGenome.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_cGenome.onPreUpdate.add(onUpdate);
			updateInfo();
		}
		
		override public function dispose():void {
			super.dispose();
			
			_cGenome.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_cGenome.onPreUpdate.removeAll();
		}
		
		private function createNode(p_x:Number, p_y:Number):GNode {
			var node:GNode = new GNode();
			node.transform.x = p_x;
			node.transform.y = p_y;
			//if (__bMove) node.transform.rotation = Math.random()*Math.PI;
			
			addSprite(node);
			
			return node;
		}
		
		private function addSprite(p_node:GNode):void	{
			var sprite:GSprite = p_node.addComponent(GSprite) as GSprite;
			sprite.setTexture(Assets.crateTexture);
			sprite.blendMode = GBlendMode.NONE;
			sprite.node.addComponent(Moving);
		}
		
		private function addColor(p_node:GNode):void {
			var color:GColorQuad = p_node.addComponent(GColorQuad) as GColorQuad;
			p_node.transform.scaleX = p_node.transform.scaleY = 32;
			var gray:Number = Math.random();
			p_node.transform.setColor(gray, gray, gray);
		}
		
		private function addClip(p_node:GNode):void {
			var clip:GMovieClip = p_node.addComponent(GMovieClip) as GMovieClip;
			clip.setTextureAtlas(Assets.mineTextureAtlas);
			clip.frameRate = Math.random()*10+3;
			clip.frames = ["mine2", "mine3", "mine4", "mine5", "mine6", "mine7", "mine8", "mine9"];
			clip.gotoFrame(Math.random()*8);
		}

		
		private function addNodes(p_count:int):void {
			__iNodeCount += p_count;
			for (var i:int = 0; i<p_count; ++i) {
				var clip:GNode;
				
				clip = createNode(Math.random()*_iWidth, Math.random()*_iHeight);
				
				_cContainer.addChild(clip);
			}
			
			updateInfo();
		}
		
		private function removeNodes(p_count:int):void {
			__iNodeCount -= p_count;
			if (__iNodeCount<0) __iNodeCount = 0;
			while (_cContainer.firstChild) {
				p_count--;
				_cContainer.removeChild(_cContainer.firstChild);
				if (p_count == 0) break;
			}
			
			updateInfo();
		}
		
		private function onUpdate(p_deltaTime:Number):void {
			_cContainer.sortChildrenOnY(__bAscending);
		
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
					__bAscending = !__bAscending;
					break;
			}
		}
	}
}