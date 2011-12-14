package examples.components
{
	import com.flashcore.g2d.components.G2DComponent;
	import com.flashcore.g2d.core.G2DNode;
	
	public class CustomParticle extends G2DComponent
	{
		public function CustomParticle(p_node:G2DNode) {
			super(p_node);
			
			node.transform.red = Math.random();
			node.transform.green = Math.random();
			node.transform.blue = Math.random();
		}
	}
}