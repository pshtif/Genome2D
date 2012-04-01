package examples.components
{
	import com.genome2d.components.GComponent;
	import com.genome2d.core.GNode;
	
	public class CustomParticle extends GComponent
	{
		public function CustomParticle(p_node:GNode) {
			super(p_node);
			
			node.transform.red = Math.random();
			node.transform.green = Math.random();
			node.transform.blue = Math.random();
		}
	}
}