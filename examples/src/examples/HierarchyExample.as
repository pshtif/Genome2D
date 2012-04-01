package examples
{
	import assets.Assets;
	
	import com.genome2d.components.renderables.GMovieClip;
	import com.genome2d.core.GNode;

	public class HierarchyExample extends Example
	{
		private var __aMills:Vector.<GNode>;
		
		static public const MAX_MILL_SPEED:Number = .005;
		
		public function HierarchyExample(p_wrapper:Genome2DExamples):void {
			super(p_wrapper);
		}
		
		override public function init():void {
			super.init();
			_cWrapper.info = "<font color='#00FFFF'><b>HierarchyExample</b>\n"+
			"<font color='#FFFFFF'>Simple hierarchy setup to showcase an example hierachical scene setup in G2D";
			
			__aMills = new Vector.<GNode>();
			
			var mill:GNode;
			mill= createMill(_iWidth/2-200, _iHeight/2, 10);
			_cContainer.addChild(mill);
			
			mill= createMill(_iWidth/2+200, _iHeight/2, 10);
			_cContainer.addChild(mill);
			/**/
			_cGenome.onPreUpdate.add(onUpdate);
		}
		
		override public function dispose():void {
			super.dispose();
			
			_cGenome.onPreUpdate.removeAll();
			__aMills = null;
		}
		
		private function createMill(p_x:Number, p_y:Number, p_size:int):GNode {
			var container:GNode = new GNode();
			
			container.userData = Math.random()*MAX_MILL_SPEED+.01;
			container.transform.x = p_x;
			container.transform.y = p_y;
			for (var i:int = 0; i < p_size; ++i) {
				var node:GNode = new GNode();
				var clip:GMovieClip = node.addComponent(GMovieClip) as GMovieClip; 
				clip.setTextureAtlas(Assets.mineTextureAtlas);
				clip.frameRate = Math.random()*10+3;
				clip.frames = ["mine2", "mine3", "mine4", "mine5", "mine6", "mine7", "mine8", "mine9"];
				clip.gotoFrame(Math.random()*8);
				node.transform.x = -(p_size-1)*24/2 + i*24;
				container.addChild(node);
			}
			
			if (p_size>3) {
				var sub:GNode;
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
				var mill:GNode = __aMills[i];
				mill.transform.rotation+=mill.userData;
			}
		}
	}
}