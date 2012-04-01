package examples
{
	import com.genome2d.components.renderables.flash.GFlashVideo;
	import com.genome2d.core.GNode;
	import com.genome2d.textures.GTextureResampleType;
	
	import flash.events.KeyboardEvent;
	import flash.media.SoundTransform;
	
	public class VideoExample extends Example
	{
		private var __cVideo:GFlashVideo;
		
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
			
			var node:GNode = new GNode("video");
			node.transform.x = _iWidth/2;
			node.transform.y = _iHeight/2;
			node.mouseEnabled = true;
			
			__cVideo = node.addComponent(GFlashVideo) as GFlashVideo;
			__cVideo.resampleType = GTextureResampleType.NEAREST_DOWN_RESAMPLE_UP_CROP;
			__cVideo.resampleScale = 2;
			__cVideo.updateFrameRate = 20;
			__cVideo.netStream.soundTransform = new SoundTransform(.1);
			
			__cVideo.playVideo(_cWrapper.getFilePath("/external/clip.mp4"));
			
			_cContainer.addChild(node);
			
			_cGenome.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_cGenome.onPreUpdate.add(onUpdated);
			
			updateInfo();
		}
		
		override public function dispose():void {
			super.dispose();
			
			__cVideo = null;
			
			_cGenome.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_cGenome.onPreUpdate.removeAll();
		}
		

		private function onUpdated(p_deltaTime:Number):void {
			__cVideo.node.transform.rotation+=.02;
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