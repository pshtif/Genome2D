package examples.components
{
	import com.genome2d.components.GComponent;
	import com.genome2d.core.GNode;
	
	public class Moving extends GComponent
	{
		private const MAX_SPEED:int = 5;
		
		private var __iX:int;
		private var __iY:int;
		
		public function Moving(p_node:GNode) {
			super(p_node);
			__iX = (int(Math.random()*2)==1) ? -Math.random()*MAX_SPEED : Math.random()*MAX_SPEED;
			__iY = (int(Math.random()*2)==1) ? -Math.random()*MAX_SPEED : Math.random()*MAX_SPEED;
		}
		
		override public function update(p_deltaTime:Number, p_parentTransformUpdate:Boolean, p_parentColorUpdate:Boolean):void {
			if (node.transform.x >= node.core.stage.stageWidth || node.transform.x <= 0) __iX = -__iX;
			if (node.transform.y >= node.core.stage.stageWidth || node.transform.y <= 0) __iY = -__iY;

			node.transform.x += __iX;
			node.transform.y += __iY;
		}
	}
}