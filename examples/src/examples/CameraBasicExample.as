package examples
{
	import assets.Assets;
	
	import com.genome2d.components.GCamera;
	import com.genome2d.components.renderables.GMovieClip;
	import com.genome2d.core.GNode;
	
	import flash.events.KeyboardEvent;
	
	public class CameraBasicExample extends Example
	{
		private const COUNT:int = 200;
		
		private var __iClipCount:int;
		private var __nCameraMove:Number = 4;
		private var __nCameraRotation:Number = .05;
		private var __nCameraZoom:Number = .02;
		
		public function CameraBasicExample(p_wrapper:Genome2DExamples):void {
			super(p_wrapper);
		}
		
		private function updateInfo():void {
			_cWrapper.info = "<font color='#00FFFF'><b>CameraViewPortsExample</b>\n"+
			"<font color='#FFFFFF'>Just to showcase 3 cameras each using a different viewport rectangle, its own transform and custom clear color background.\n"+
			"<font color='#FFFF00'>";
		}
		
		override public function init():void {
			super.init();
				
			__iClipCount = 0;
			addSprites(COUNT);
			
			_cGenome.onPreUpdate.add(onUpdate);
			
			var camera:GCamera;
			camera = _cCamera.getComponent(GCamera) as GCamera;
			camera.normalizedViewWidth = 1/3;
			camera.backgroundRed = .2;
			
			var cameraNode:GNode = new GNode("camera1");
			camera = cameraNode.addComponent(GCamera) as GCamera;
			cameraNode.transform.x = _iWidth/2;
			cameraNode.transform.y = _iHeight/2;
			camera.normalizedViewWidth = 1/3;
			camera.normalizedViewX = 1/3;
			camera.backgroundGreen = .2;
			camera.mask = 1;
			camera.index = 1;
			_cContainer.addChild(cameraNode);
			
			cameraNode = new GNode("camera2");
			camera = cameraNode.addComponent(GCamera) as GCamera;
			cameraNode.transform.x = _iWidth/2;
			cameraNode.transform.y = _iHeight/2;
			camera.normalizedViewWidth = 1/3;
			camera.normalizedViewX = 2/3;
			camera.backgroundBlue = .2;
			camera.mask = 1;
			camera.index = 2;
			_cContainer.addChild(cameraNode);
			
			updateInfo();
		}
		
		override public function dispose():void {
			super.dispose();

			_cGenome.onPreUpdate.removeAll();
		}
		
		private function createClip(p_x:Number, p_y:Number):GNode {
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

		
		private function addSprites(p_count:int):void {
			__iClipCount += p_count;
			for (var i:int = 0; i<p_count; ++i) {
				var clip:GNode;
				
				clip = createClip(Math.random()*_cGenome.stage.stageWidth, Math.random()*_cGenome.stage.stageHeight);
				
				_cContainer.addChild(clip);
			}
			
			updateInfo();
		}
		
		private function removeSprites(p_count:int):void {
			__iClipCount -= p_count;
			if (__iClipCount<0) __iClipCount = 0;
			while (_cContainer.firstChild) {
				_cContainer.removeChild(_cContainer.firstChild);
			}
			
			updateInfo();
		}
		
		private function onUpdate(p_deltaTime:Number):void {
			var cameraNode:GNode;
			
			cameraNode = _cGenome.getCameraAt(0).node;
			if (cameraNode.transform.x < 200 || cameraNode.transform.x>600) {
				__nCameraMove = -__nCameraMove;
			}
			cameraNode.transform.x += __nCameraMove;
			cameraNode.transform.y += __nCameraMove;
			
			cameraNode = _cGenome.getCameraAt(1).node;
			if (cameraNode.transform.rotation < -2*Math.PI || cameraNode.transform.rotation > 2*Math.PI) {
				__nCameraRotation = -__nCameraRotation;
			}
			cameraNode.transform.rotation += __nCameraRotation;
			
			cameraNode = _cGenome.getCameraAt(2).node;
			var camera:GCamera = cameraNode.getComponent(GCamera) as GCamera;
			if (camera.zoom < .2 || camera.zoom>2) {
				__nCameraZoom = -__nCameraZoom;
			}			
			camera.zoom += __nCameraZoom;
			camera.zoom += __nCameraZoom;
		}
	}
}