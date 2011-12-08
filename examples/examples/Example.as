package examples
{
	import com.flashcore.g2d.components.G2DCamera;
	import com.flashcore.g2d.core.G2DNode;
	import com.flashcore.g2d.components.G2DTransform;
	import com.flashcore.g2d.core.Genome2D;

	public class Example
	{
		protected var _cGenome:Genome2D;
		protected var _cWrapper:Genome2DExamples;
		protected var _cContainer:G2DNode;
		protected var _cCamera:G2DNode;
		
		public function Example(p_wrapper:Genome2DExamples) {
			_cGenome = Genome2D.getInstance();
			_cWrapper = p_wrapper;
		}
		
		static private var index:int = 0;
		public function init():void {
			_cGenome.autoUpdate = true;
			index++;
			_cCamera = new G2DNode("example camera"+index);
			_cCamera.addComponent(G2DCamera);
			_cCamera.transform.x = 400;
			_cCamera.transform.y = 300;
			_cGenome.root.addChild(_cCamera);			
			
			_cContainer = new G2DNode("container"+index);
			_cGenome.root.addChild(_cContainer);
		}
		
		public function dispose():void {
			_cGenome.root.disposeChildren();
		}
	}
}