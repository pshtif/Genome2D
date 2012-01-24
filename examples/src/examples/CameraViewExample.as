package examples
{
	import assets.Assets;
	
	import com.flashcore.g2d.components.G2DCamera;
	import com.flashcore.g2d.components.renderables.G2DMovieClip;
	import com.flashcore.g2d.core.G2DNode;
	
	import flash.events.KeyboardEvent;
	
	public class CameraViewExample extends Example
	{
		private const COUNT:int = 10;
		static public const MAX_MILL_SPEED:Number = .005;
		
		private var __cRotatingContainer:G2DNode;
		private var __cNinjaContainer:G2DNode;
		
		private var __iClipCount:int;
		private var __nCameraMove:Number = 2;
		private var __nCameraRotation:Number = .05;
		private var __nCameraZoom:Number = .02;
		
		public function CameraViewExample(p_wrapper:Genome2DExamples):void {
			super(p_wrapper);
		}
		
		private function updateInfo():void {
			_cWrapper.info = "<font color='#00FFFF'><b>CameraDynamicViewportExample</b>\n"+
			"<font color='#FFFFFF'>First camera takes whole screen at default transform, second camera moves through scene at zoom 2 and uses dynamic viewport.\n"+
			"<font color='#FFFF00'>";
		}
		
		override public function init():void {
			super.init();
	
			__cRotatingContainer = new G2DNode();
			__cRotatingContainer.mouseChildren = false;
			__cRotatingContainer.transform.x = _iWidth/2;
			__cRotatingContainer.transform.y = _iHeight/2;
			for (var i:int = 0; i<23; ++i) {
				var mine:G2DNode = createMine(-264+24*i, 0);
				mine.userData = false;
				__cRotatingContainer.addChild(mine);
				var mine:G2DNode = createMine(0, -265+24*i);
				mine.userData = false;
				__cRotatingContainer.addChild(mine);
			}
			_cContainer.addChild(__cRotatingContainer);
			
			
			__cNinjaContainer = new G2DNode();
			__cNinjaContainer.mouseChildren = false;
			for (var i:int = 0; i<COUNT; ++i) {
				var clip:G2DNode = createNinja(Math.random()*(_iWidth-200)+100,Math.random()*(_iHeight-100)+50);
				__cNinjaContainer.addChild(clip);
			}
			_cContainer.addChild(__cNinjaContainer);
			
			_cGenome.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_cGenome.onUpdated.add(onUpdate);
			
			var camera:G2DCamera;
			camera = _cCamera.getComponent(G2DCamera) as G2DCamera;
			
			var cameraNode:G2DNode = new G2DNode("camera1");
			camera = cameraNode.addComponent(G2DCamera) as G2DCamera;
			cameraNode.transform.x = _iWidth/2;
			cameraNode.transform.y = _iHeight/2;
			camera.normalizedViewWidth = 1/3;
			camera.normalizedViewX = 1/3;
			camera.zoom = 2;
			camera.mask = 1;
			camera.index = 1;
			_cContainer.addChild(cameraNode);
			
			updateInfo();
		}
		
		override public function dispose():void {			
			_cGenome.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_cGenome.onUpdated.removeAll();
			
			super.dispose();
		}
		
		private function createMine(p_x:Number, p_y:Number):G2DNode {
			var node:G2DNode = new G2DNode();
			var clip:G2DMovieClip = node.addComponent(G2DMovieClip) as G2DMovieClip;
			clip.setTextureAtlas(Assets.mineTextureAtlas);
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
			clip.setTextureAtlas(Assets.ninjaTextureAtlas);
			clip.setFrameRate(Math.random()*10+3);
			clip.setFrames(new <String>["nw1", "nw2", "nw3", "nw2", "nw1", "stood", "nw4", "nw5", "nw6", "nw5", "nw4"]);
			clip.gotoFrame(Math.random()*8);
			node.transform.x = p_x;
			node.transform.y = p_y;
			return node;
		}
		
		private function onUpdate(p_deltaTime:Number):void {
			var cameraNode:G2DNode;
			
			cameraNode = _cGenome.getCameraAt(1).node;
			var camera:G2DCamera = cameraNode.getComponent(G2DCamera) as G2DCamera;
			if (camera.normalizedViewX <= 0 || camera.normalizedViewX >= 2/3) {
				__nCameraMove = -__nCameraMove;
			}
			camera.normalizedViewX += __nCameraMove/800;
			cameraNode.transform.x += __nCameraMove;
			
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
		
		private function onKeyDown(event:KeyboardEvent):void {
			trace(event.keyCode);
		}
	}
}