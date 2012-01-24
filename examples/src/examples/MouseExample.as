package examples
{
	import assets.Assets;
	
	import com.flashcore.g2d.components.renderables.G2DMovieClip;
	import com.flashcore.g2d.components.renderables.G2DTexturedQuad;
	import com.flashcore.g2d.core.G2DNode;
	import com.flashcore.g2d.signals.G2DMouseSignal;

	public class MouseExample extends Example
	{
		private var COUNT:int = 30;
		
		public function MouseExample(p_wrapper:Genome2DExamples):void {
			super(p_wrapper);
		}
		
		override public function init():void {
			super.init();
			_cWrapper.info = "<font color='#00FFFF'><b>MouseExample</b>\n"+
			"<font color='#FFFFFF'>In this example it showcases the mouse interactivity and its modes, green ninjas have pixel perfect mouse precision enabled where red ninjas don't and capture mouse events only using their geometry.\n"+
			"<font color='#FFFF00'>You can switch mouse mode of a particular ninja by CLICKing on him.";
			

			for (var i:int = 0; i<COUNT; ++i) {
				var node:G2DNode = createClip(Math.random()*_iWidth, Math.random()*_iHeight);
				_cContainer.addChild(node);
			}
		}
		
		private function createClip(p_x:Number, p_y:Number):G2DNode {
			var node:G2DNode = new G2DNode();
			var clip:G2DMovieClip = node.addComponent(G2DMovieClip) as G2DMovieClip;
			clip.setTextureAtlas(Assets.ninjaTextureAtlas);
			clip.setFrameRate(15);
			clip.setFrames(new <String>["nw1", "nw2", "nw3", "nw2", "nw1", "stood", "nw4", "nw5", "nw6", "nw5", "nw4"]);
			clip.gotoFrame(Math.random()*8);

			node.transform.x = p_x;
			node.transform.y = p_y;
			node.transform.scaleX = node.transform.scaleY = Math.random()*2+1;
			node.mouseEnabled = true;
			if (Math.random()*2<1) {
				clip.mousePixelEnabled = true;
				node.transform.blue = node.transform.red = 0;
			} else {
				node.transform.blue = node.transform.green = 0;
			}

			node.onMouseOver.add(onClipMouseOver);
			node.onMouseOut.add(onClipMouseOut);
			node.onMouseClick.add(onClipMouseClick);
			return node;
		}
		
		private function onClipMouseClick(p_signal:G2DMouseSignal):void {
			var sprite:G2DTexturedQuad = p_signal.dispatcher.getComponent(G2DMovieClip) as G2DMovieClip;
			var val:Boolean = sprite.mousePixelEnabled;
			sprite.mousePixelEnabled = !val; 
		}
		
		private function onClipMouseOver(p_signal:G2DMouseSignal):void {
			p_signal.dispatcher.transform.red = p_signal.dispatcher.transform.green = p_signal.dispatcher.transform.blue = 1;
		}
		
		private function onClipMouseOut(p_signal:G2DMouseSignal):void {
			var sprite:G2DTexturedQuad = p_signal.dispatcher.getComponent(G2DMovieClip) as G2DMovieClip;
			if (sprite.mousePixelEnabled) {
				p_signal.dispatcher.transform.red = 0;
				p_signal.dispatcher.transform.green = 1;
				p_signal.dispatcher.transform.blue = 0;
			} else {
				p_signal.dispatcher.transform.red = 1;
				p_signal.dispatcher.transform.green = 0;
				p_signal.dispatcher.transform.blue = 0;
			}
		}
	}
}