package
{
	import com.genome2d.components.GComponent;
	import com.genome2d.core.GNode;
	
	/**
	 * 	Simple custom component of falling crate
	 */	
	public class FallingCrateComponent extends GComponent
	{
		public var speed:Number = 1;
		
		public function FallingCrateComponent(p_node:GNode) {
			super(p_node);
		}
		
		/**
		 * 	Lets override update method so we can move the crate
		 */
		override public function update(p_deltaTime:Number, p_parentTransformUpdate:Boolean, p_parentColorUpdate:Boolean):void {
			// Move the crate by its speed
			node.transform.y += speed;
			
			// Once the crate is at the bottom of the screen deactivate it
			if (node.transform.y>=616) {
				// This is crucial for pooling, instead of node.dispose() which would dispose the node and everything in it we simply call deactivate it,
				// what this does is deactivate which means such node will not be updated/rendered and it will automatically be pushed back to the pool of available instances
				node.active = false;
			}
		}
	}
}