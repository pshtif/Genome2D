package examples
{
	import com.flashcore.g2d.display.G2DContainer;
	import com.flashcore.g2d.display.G2DMovieClip;
	import com.flashcore.g2d.textures.G2DTexture;

	public class HierarchyExample extends Example
	{
		[Embed(source = "./assets/mines.xml", mimeType = "application/octet-stream")]
		private static const MinesXML:Class;
		[Embed(source = "./assets/mines.png")]
		private static const MinesGFX:Class;
		
		private var __aMills:Vector.<G2DContainer>;
		
		private var __cTexture:G2DTexture;
		
		static public const MAX_MILL_SPEED:Number = .005;
		
		public function HierarchyExample(p_wrapper:Genome2DExamples):void {
			super(p_wrapper);
		}
		
		override public function init():void {
			super.init();
			_cWrapper.info = "<font color='#00FFFF'><b>HierarchyExample</b>\n"+
			"<font color='#FFFFFF'>Simple hierarchy setup to showcase an example hierachical scene setup in G2D";
			
			__cTexture = G2DTexture.createFromBitmapAtlas((new MinesGFX()).bitmapData, XML(new MinesXML()));
			
			__aMills = new Vector.<G2DContainer>();
			
			var mill:G2DContainer
			mill= createMill(200, 300, 10);
			_cGenome.root.addChild(mill);
			mill= createMill(600, 300, 10);
			_cGenome.root.addChild(mill);
			
			_cGenome.onRender.add(onRender);
		}
		
		override public function dispose():void {
			super.dispose();
			
			_cGenome.onRender.removeAll();
			__aMills = null;
			__cTexture.dispose();
		}
		
		private function createMill(p_x:Number, p_y:Number, p_size:int):G2DContainer {
			var container:G2DContainer = new G2DContainer();
			container.userData = Math.random()*MAX_MILL_SPEED+.01;
			container.x = p_x;
			container.y = p_y;
			for (var i:int = 0; i < p_size; ++i) {
				var clip:G2DMovieClip = new G2DMovieClip(__cTexture);
				clip.setFrameRate(Math.random()*10+3);
				clip.setFrames(new <String>["mine2", "mine3", "mine4", "mine5", "mine6", "mine7", "mine8", "mine9"]);
				clip.gotoFrame(Math.random()*8);
				clip.x = -(p_size-1)*24/2 + i*24;
				container.addChild(clip);
			}
			
			if (p_size>3) {
				var sub:G2DContainer
				sub = createMill(-(p_size-1)/2*24, 0, Math.ceil(p_size/2));
				container.addChild(sub);
				sub = createMill((p_size-1)/2*24, 0, Math.ceil(p_size/2));
				container.addChild(sub);
			}
			
			__aMills.push(container);
			return container;
		}
		
		private function onRender():void {
			for (var i:int = 0; i < __aMills.length; ++i) {
				var mill:G2DContainer = __aMills[i];
				mill.rotation+=mill.userData;
			}
		}
	}
}