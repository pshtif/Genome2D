package examples
{
	import com.flashcore.g2d.core.Genome2D;

	public class Example
	{
		protected var _cGenome:Genome2D;
		protected var _cWrapper:Genome2DExamples;
		
		public function Example(p_wrapper:Genome2DExamples) {
			_cGenome = Genome2D.getInstance();
			_cWrapper = p_wrapper;
		}
		
		public function init():void {
			_cGenome.autoRender = true;
		}
		
		public function dispose():void {
			_cGenome.root.dispose();
		}
	}
}