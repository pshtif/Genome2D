package examples
{
	import com.flashcore.g2d.core.Genome2D;
	import com.flashcore.g2d.materials.G2DMaterialLibrary;

	public class Example
	{
		protected var _cGenome:Genome2D;
		protected var _cWrapper:Genome2DExamples;
		
		public function Example(p_wrapper:Genome2DExamples) {
			_cGenome = Genome2D.getInstance();
			_cWrapper = p_wrapper;
		}
		
		public function init():void {
			
		}
		
		public function dispose():void {
			_cGenome.root.dispose();
			G2DMaterialLibrary.clear();
		}
	}
}