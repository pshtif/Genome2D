package examples
{
	import assets.Assets;
	
	import com.flashcore.g2d.components.G2DCamera;
	import com.flashcore.g2d.components.renderables.G2DMovieClip;
	import com.flashcore.g2d.components.renderables.G2DTexturedQuad;
	import com.flashcore.g2d.core.G2DNode;
	import com.flashcore.g2d.signals.G2DMouseSignal;
	
	public class CameraMouseExample extends Example
	{
		private const COUNT:int = 50;
		
		private var __iClipCount:int;
		private var __nCameraMove:Number = 4;
		private var __nCameraRotation:Number = .02;
		private var __nCameraZoom:Number = .002;
		
		public function CameraMouseExample(p_wrapper:Genome2DExamples):void {
			super(p_wrapper);
		}
		
		private function updateInfo():void {
			_cWrapper.info = "<font color='#00FFFF'><b>CameraMultipleMouseExample</b>\n"+
			"<font color='#FFFFFF'>Showcase of working mouse interaction through multiple viewports into a scene with custom transforms.\n"+
			"<font color='#FFFF00'>CLICK a clip to switch between pixel precise [green] and geometry [red] mouse test.";
		}
		
		override public function init():void {
			super.init();
	
			for (var i:int = 0; i<COUNT; ++i) {
				var node:G2DNode = createClip(Math.random()*_iWidth, Math.random()*_iHeight);
				_cContainer.addChild(node);
			}
			
			_cGenome.onUpdated.add(onUpdate);
			
			var camera:G2DCamera;
			camera = _cCamera.getComponent(G2DCamera) as G2DCamera;
			camera.normalizedViewWidth = .5;
			camera.normalizedViewHeight = .5;
			camera.normalizedViewX = 0;
			camera.normalizedViewY = 0;
			
			var cameraNode:G2DNode = new G2DNode("camera1");
			camera = cameraNode.addComponent(G2DCamera) as G2DCamera;
			cameraNode.transform.x = _iWidth/2;
			cameraNode.transform.y = _iHeight/2;
			cameraNode.transform.rotation = Math.PI/4;
			camera.normalizedViewWidth = .5;
			camera.normalizedViewHeight = .5;
			camera.normalizedViewX = .5;
			camera.normalizedViewY = 0;
			camera.mask = 1;
			camera.index = 1;
			_cContainer.addChild(cameraNode);
			
			cameraNode = new G2DNode("camera2");
			camera = cameraNode.addComponent(G2DCamera) as G2DCamera;
			cameraNode.transform.x = _iWidth/2;
			cameraNode.transform.y = _iHeight/2;
			camera.normalizedViewWidth = .5;
			camera.normalizedViewHeight = .5;
			camera.normalizedViewX = 0;
			camera.normalizedViewY = .5;
			camera.zoom = .3;
			camera.mask = 1;
			camera.index = 2;
			_cContainer.addChild(cameraNode);
			
			cameraNode = new G2DNode("camera3");
			camera = cameraNode.addComponent(G2DCamera) as G2DCamera;
			cameraNode.transform.x = _iWidth/2;
			cameraNode.transform.y = _iHeight/2;
			camera.normalizedViewWidth = .5;
			camera.normalizedViewHeight = .5;
			camera.normalizedViewX = .5;
			camera.normalizedViewY = .5;
			camera.index = 3;
			camera.mask = 1;
			_cContainer.addChild(cameraNode);
			
			updateInfo();
		}
		
		override public function dispose():void {
			super.dispose();
				
			_cGenome.onUpdated.removeAll();
		}
		
		private function createClip(p_x:Number, p_y:Number):G2DNode {
			var node:G2DNode = new G2DNode();
			var clip:G2DMovieClip = node.addComponent(G2DMovieClip) as G2DMovieClip;
			clip.setTextureAtlas(Assets.ninjaTextureAtlas);
			clip.setFrameRate(15);
			clip.setFrames(new <String>["nw1", "nw2", "nw3", "nw2", "nw1", "stood", "nw4", "nw5", "nw6", "nw5", "nw4"]);
			clip.gotoFrame(Math.random()*8);
			//clip.stop();
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
		
		private function onUpdate(p_deltaTime:Number):void {
			var cameraNode:G2DNode;
			
			cameraNode = _cGenome.getCameraAt(3).node;
			if (cameraNode.transform.x < 200 || cameraNode.transform.x>600) {
				__nCameraMove = -__nCameraMove;
			}
			cameraNode.transform.rotation += __nCameraRotation;
			
			var camera:G2DCamera = cameraNode.getComponent(G2DCamera) as G2DCamera;
			if (camera.zoom < .2 || camera.zoom>2) {
				__nCameraZoom = -__nCameraZoom;
			}			
			camera.zoom += __nCameraZoom;
			camera.zoom += __nCameraZoom;
		}
	}
}