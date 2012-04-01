package examples
{
	import assets.Assets;
	
	import com.genome2d.components.renderables.GMovieClip;
	import com.genome2d.components.renderables.GTexturedQuad;
	import com.genome2d.core.GNode;
	import com.genome2d.signals.GMouseSignal;
	import com.greensock.TweenLite;

	public class CameraInterpolateExample extends Example
	{
		private const COUNT:int = 20;
		
		private var __iClipCount:int;
		private var __nCameraMove:Number = 4;
		private var __nCameraRotation:Number = .02;
		private var __nCameraZoom:Number;
		private var __cSelected:GNode;
		
		public function CameraInterpolateExample(p_wrapper:Genome2DExamples):void {
			super(p_wrapper);
		}
		
		private function updateInfo():void {
			_cWrapper.info = "<font color='#00FFFF'><b>CameraExample</b>\n"+
			"<font color='#FFFFFF'>This is a simple camera example that shows camera interpolation and tweening.\n"+
			"<font color='#FFFF00'>CLICK a clip where camera should go.";
		}
		
		override public function init():void {
			super.init();
			
			for (var i:int = 0; i<COUNT; ++i) {
				var node:GNode = createMine(Math.random()*_iWidth, Math.random()*_iHeight);
				_cContainer.addChild(node);
			}
			
			updateInfo();
		}
		
		override public function dispose():void {
			super.dispose();
					
			__cSelected = null;
			
			_cGenome.onPreUpdate.removeAll();
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
			node.transform.scaleX = node.transform.scaleY = 2;
			node.transform.rotation = Math.random()*2*Math.PI;
			node.mouseEnabled = true;
			
			clip.mousePixelEnabled = true;
			node.transform.blue = node.transform.red = 0;
			
			node.onMouseOver.add(onClipMouseOver);
			node.onMouseOut.add(onClipMouseOut);
			node.onMouseClick.add(onClipMouseClick);
			return node;
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
			node.transform.scaleX = node.transform.scaleY = Math.random()*2+1;
			node.transform.rotation = Math.random()*2*Math.PI;
			node.mouseEnabled = true;
			
			node.transform.blue = node.transform.green = 0;
			
			node.onMouseOver.add(onClipMouseOver);
			node.onMouseOut.add(onClipMouseOut);
			node.onMouseClick.add(onClipMouseClick);
			return node;
		}
		
		private function onClipMouseClick(p_signal:GMouseSignal):void {
			var sprite:GTexturedQuad = p_signal.dispatcher.getComponent(GMovieClip) as GMovieClip;
			sprite.mousePixelEnabled = !sprite.mousePixelEnabled;
			if (__cSelected) {
				__cSelected.transform.red = 1;
				__cSelected.transform.green = 0;
				__cSelected.transform.blue = 0;
			}
			
			p_signal.dispatcher.transform.red = 1;
			p_signal.dispatcher.transform.green = 1;
			p_signal.dispatcher.transform.blue = 1;
			
			__cSelected = p_signal.dispatcher;
			
			TweenLite.to(_cCamera.transform, .5, {x:p_signal.dispatcher.transform.x, y:p_signal.dispatcher.transform.y, rotation:-p_signal.dispatcher.transform.rotation});
		}
		
		private function onClipMouseOver(p_signal:GMouseSignal):void {
			if (p_signal.dispatcher == __cSelected) return;
			p_signal.dispatcher.transform.red = 0;
			p_signal.dispatcher.transform.green = 1;
			p_signal.dispatcher.transform.blue = 0;
		}
		
		private function onClipMouseOut(p_signal:GMouseSignal):void {
			if (p_signal.dispatcher == __cSelected) return;

			p_signal.dispatcher.transform.red = 1;
			p_signal.dispatcher.transform.green = 0;
			p_signal.dispatcher.transform.blue = 0;
		}
	}
}