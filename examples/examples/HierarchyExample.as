package examples
{
	import com.flashcore.g2d.components.G2DMovieClip;
	import com.flashcore.g2d.core.G2DNode;
	import com.flashcore.g2d.textures.G2DTextureAtlas;
	import com.flashcore.g2d.textures.G2DTextureLibrary;

	public class HierarchyExample extends Example
	{
		private var __aMills:Vector.<G2DNode>;
		
		private var __cTexture:G2DTextureAtlas;
		
		static public const MAX_MILL_SPEED:Number = .005;
		
		public function HierarchyExample(p_wrapper:Genome2DExamples):void {
			super(p_wrapper);
		}
		
		override public function init():void {
			super.init();
			_cWrapper.info = "<font color='#00FFFF'><b>HierarchyExample</b>\n"+
			"<font color='#FFFFFF'>Simple hierarchy setup to showcase an example hierachical scene setup in G2D";
			
			__cTexture = G2DTextureAtlas.createFromBitmapDataAndXML("mine", (new Assets.MinesGFX()).bitmapData, XML(new Assets.MinesXML()));
			
			__aMills = new Vector.<G2DNode>();
			
			var mill:G2DNode;
			mill= createMill(200, 300, 10);
			_cContainer.addChild(mill);
			
			mill= createMill(600, 300, 10);
			_cContainer.addChild(mill);
			/**/
			_cGenome.onUpdated.add(onUpdate);
		}
		
		override public function dispose():void {
			super.dispose();
			
			_cGenome.onUpdated.removeAll();
			__aMills = null;
			__cTexture.dispose();
		}
		
		private function createMill(p_x:Number, p_y:Number, p_size:int):G2DNode {
			var container:G2DNode = new G2DNode();
			
			container.userData = Math.random()*MAX_MILL_SPEED+.01;
			container.transform.x = p_x;
			container.transform.y = p_y;
			for (var i:int = 0; i < p_size; ++i) {
				var node:G2DNode = new G2DNode();
				var clip:G2DMovieClip = node.addComponent(G2DMovieClip) as G2DMovieClip; 
				clip.setTextureAtlas(__cTexture);
				clip.setFrameRate(Math.random()*10+3);
				clip.setFrames(new <String>["mine2", "mine3", "mine4", "mine5", "mine6", "mine7", "mine8", "mine9"]);
				clip.gotoFrame(Math.random()*8);
				node.transform.x = -(p_size-1)*24/2 + i*24;
				container.addChild(node);
			}
			
			if (p_size>3) {
				var sub:G2DNode;
				sub = createMill(-(p_size-1)/2*24, 0, Math.ceil(p_size/2));
				container.addChild(sub);
				sub = createMill((p_size-1)/2*24, 0, Math.ceil(p_size/2));
				container.addChild(sub);
			}
			
			__aMills.push(container);
			/**/
			return container;
		}
		
		private function onUpdate(p_deltaTime:Number):void {
			for (var i:int = 0; i < __aMills.length; ++i) {
				var mill:G2DNode = __aMills[i];
				mill.transform.rotation+=mill.userData;
			}
		}
	}
}