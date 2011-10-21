package examples
{
	import com.flashcore.g2d.materials.G2DMaterialLibrary;
	import com.flashcore.g2d.sprites.G2DMovieClip;
	import com.flashcore.g2d.sprites.G2DSprite;
	import com.flashcore.g2d.sprites.G2DTransform;
	import com.flashcore.g2d.textures.G2DTexture;
	
	import flash.display.Sprite;

	public class MouseExample extends Example
	{
		[Embed(source = "./assets/ninja.xml", mimeType = "application/octet-stream")]
		private static const NinjaXML:Class;
		[Embed(source = "./assets/ninja.png")]
		private static const NinjaGFX:Class;
		
		private var __cTexture:G2DTexture;
		
		private var COUNT:int = 100;
		
		public function MouseExample(p_wrapper:Genome2DExamples):void {
			super(p_wrapper);
		}
		
		override public function init():void {
			_cWrapper.info = "<font color='#00FFFF'>MouseExample\n"+
			"<font color='#FFFFFF'>In this example it showcases the mouse interactivity and its modes, green ninjas have pixel perfect mouse precision enabled where red ninjas don't and capture mouse events only using their geometry.\n"+
			"<font color='#FFFF00'>You can switch mouse mode of a particular ninja by CLICKing on him.";
			
			__cTexture = G2DTexture.createFromBitmapAtlas((new NinjaGFX()).bitmapData, XML(new NinjaXML()));
			
			G2DMaterialLibrary.createMaterial("ninja", __cTexture);
			
			for (var i:int = 0; i<COUNT; ++i) {
				var clip:G2DMovieClip = createClip(Math.random()*800, Math.random()*600);
				_cGenome.root.addChild(clip);
			}
		}
		
		override public function dispose():void {
			super.dispose();
			
			__cTexture.dispose();
		}
		
		private function createClip(p_x:Number, p_y:Number):G2DMovieClip {
			var clip:G2DMovieClip = new G2DMovieClip();
			clip.setFrameRate(15);
			clip.setMaterialById("ninja");
			clip.setFrames(new <String>["nw1", "nw2", "nw3", "nw2", "nw1", "stood", "nw4", "nw5", "nw6", "nw5", "nw4"]);
			clip.gotoFrame(Math.random()*8);
			//clip.stop();
			clip.x = p_x;
			clip.y = p_y;
			clip.scaleX = clip.scaleY = Math.random()*2+1;
			clip.mouseEnabled = true;
			if (Math.random()*2<1) {
				clip.mousePixelEnabled = true;
				clip.blue = clip.red = 0;
			} else {
				clip.blue = clip.green = 0;
			}

			clip.onMouseOver.add(onClipMouseOver);
			clip.onMouseOut.add(onClipMouseOut);
			clip.onMouseClick.add(onClipMouseClick);
			return clip;
		}
		
		private function onClipMouseClick(p_target:G2DTransform, p_dispatcher:G2DTransform, p_x:Number, p_y:Number):void {
			G2DSprite(p_dispatcher).mousePixelEnabled = !G2DSprite(p_dispatcher).mousePixelEnabled; 
		}
		
		private function onClipMouseOver(p_target:G2DTransform, p_dispatcher:G2DTransform, p_x:Number, p_y:Number):void {
			//trace("over: "+p_dispatcher);
			p_dispatcher.red = p_dispatcher.green = p_dispatcher.blue = 1;
		}
		
		private function onClipMouseOut(p_target:G2DTransform, p_dispatcher:G2DTransform, p_x:Number, p_y:Number):void {
			//trace("out: "+p_dispatcher);
			if (G2DSprite(p_dispatcher).mousePixelEnabled) {
				p_dispatcher.red = 0;
				p_dispatcher.green = 1;
				p_dispatcher.blue = 0;
			} else {
				p_dispatcher.red = 1;
				p_dispatcher.green = 0;
				p_dispatcher.blue = 0;
			}
		}
	}
}