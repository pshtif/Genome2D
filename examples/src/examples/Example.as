package examples
{
	import com.flashcore.g2d.components.G2DCamera;
	import com.flashcore.g2d.components.G2DTransform;
	import com.flashcore.g2d.core.G2DNode;
	import com.flashcore.g2d.core.Genome2D;

	public class Example
	{
		protected var _cGenome:Genome2D;
		protected var _cWrapper:Genome2DExamples;
		protected var _cContainer:G2DNode;
		protected var _cCamera:G2DNode;
		
		protected var _iWidth:int = 0;
		protected var _iHeight:int = 0;
		
		public function Example(p_wrapper:Genome2DExamples) {
			_cGenome = Genome2D.getInstance();
			_cWrapper = p_wrapper;
		}
		
		static private var index:int = 0;
		public function init():void {
			_cGenome.autoUpdate = true;
			index++;
			
			_iWidth = _cGenome.stage.stageWidth;
			_iHeight = _cGenome.stage.stageHeight;

			_cCamera = new G2DNode("example camera"+index);
			var camera:G2DCamera = _cCamera.addComponent(G2DCamera) as G2DCamera;
			camera.mask = 1;
			camera.index = 0;
			_cCamera.transform.x = _cGenome.stage.stageWidth/2;
			_cCamera.transform.y = _cGenome.stage.stageHeight/2;
			_cWrapper.content.addChild(_cCamera);			
			
			_cContainer = new G2DNode("container"+index);
			_cWrapper.content.addChild(_cContainer);
		}
		
		public function dispose():void {
			_cWrapper.content.disposeChildren();
		}
	}
}