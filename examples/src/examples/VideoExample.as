package examples
{
	import com.flashcore.g2d.components.renderables.G2DVideo;
	import com.flashcore.g2d.core.G2DNode;
	import com.flashcore.g2d.textures.G2DTextureResampleType;
	
	import flash.events.KeyboardEvent;
	import flash.media.SoundTransform;
	
	public class VideoExample extends Example
	{
		private var __cVideo:G2DVideo;
		
		public function VideoExample(p_wrapper:Genome2DExamples):void {
			super(p_wrapper);
		}
		
		private function updateInfo():void {
			_cWrapper.info = "<font color='#00FFFF'><b>VideoExample</b> [ Sampling scale "+__cVideo.resampleScale+" ]\n"+
			"<font color='#FFFFFF'>This is a demo of G2DVideo component.\n"+
			"<font color='#FFFF00'>Press UP/DOWN keys to scale the sampling ratio.";
		}
		
		override public function init():void {
			super.init();
			
			var node:G2DNode = new G2DNode("video");
			node.transform.x = _iWidth/2;
			node.transform.y = _iHeight/2;
			node.mouseEnabled = true;
			
			__cVideo = node.addComponent(G2DVideo) as G2DVideo;
			__cVideo.resampleType = G2DTextureResampleType.NEAREST_DOWN_RESAMPLE_UP_CROP;
			__cVideo.resampleScale = 2;
			__cVideo.updateFrameRate = 20;
			__cVideo.netStream.soundTransform = new SoundTransform(.1);
			
			__cVideo.playVideo(_cWrapper.getFilePath("/external/clip.flv"));
			
			_cContainer.addChild(node);
			
			_cGenome.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_cGenome.onUpdated.add(onUpdated);
			
			updateInfo();
		}
		
		override public function dispose():void {
			super.dispose();
			
			__cVideo = null;
			
			_cGenome.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_cGenome.onUpdated.removeAll();
		}
		

		private function onUpdated(p_deltaTime:Number):void {
			__cVideo.node.transform.rotation+=.05;
		}
		
		private function onKeyDown(event:KeyboardEvent):void {
			switch (event.keyCode) {
				case 38:
					__cVideo.resampleScale*=2;
					break;
				case 40:
					__cVideo.resampleScale/=2;
					break;
			}
			
			updateInfo();
		}
	}
}