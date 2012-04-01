package examples
{
	import assets.Assets;
	
	import com.genome2d.components.renderables.GMovieClip;
	import com.genome2d.components.renderables.GTexturedQuad;
	import com.genome2d.core.GNode;
	import com.genome2d.signals.GMouseSignal;

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
				var node:GNode = createClip(Math.random()*_iWidth, Math.random()*_iHeight);
				_cContainer.addChild(node);
			}
		}
		
		private function createClip(p_x:Number, p_y:Number):GNode {
			var node:GNode = new GNode();
			var clip:GMovieClip = node.addComponent(GMovieClip) as GMovieClip;
			clip.setTextureAtlas(Assets.ninjaTextureAtlas);
			clip.frameRate = 15;
			clip.frames = ["nw1", "nw2", "nw3", "nw2", "nw1", "stood", "nw4", "nw5", "nw6", "nw5", "nw4"];
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
		
		private function onClipMouseClick(p_signal:GMouseSignal):void {
			var sprite:GTexturedQuad = p_signal.dispatcher.getComponent(GMovieClip) as GMovieClip;
			var val:Boolean = sprite.mousePixelEnabled;
			sprite.mousePixelEnabled = !val; 
		}
		
		private function onClipMouseOver(p_signal:GMouseSignal):void {
			p_signal.dispatcher.transform.red = p_signal.dispatcher.transform.green = p_signal.dispatcher.transform.blue = 1;
		}
		
		private function onClipMouseOut(p_signal:GMouseSignal):void {
			var sprite:GTexturedQuad = p_signal.dispatcher.getComponent(GMovieClip) as GMovieClip;
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