/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.components.renderables
{
	import com.genome2d.components.GComponent;
	import com.genome2d.context.GBlendMode;
	import com.genome2d.core.GNode;
	import com.genome2d.g2d;
	
	import flash.geom.Rectangle;

	use namespace g2d;
	
	public class GRenderable extends GComponent {
		
		g2d var iBlendMode:int = GBlendMode.NORMAL;
		public function set blendMode(p_blendMode:int):void {
			iBlendMode = p_blendMode;
		}
		public function get blendMode():int {
			return iBlendMode;
		}
		/**
		 * 	@private
		 */
		public function GRenderable(p_node:GNode) {
			super(p_node);
		}
		
		public function getWorldBounds(p_target:Rectangle = null):Rectangle {
			if (p_target) p_target.setTo(cNode.cTransform.nWorldX, cNode.cTransform.nWorldY, 0, 0);
			else p_target = new Rectangle(cNode.cTransform.nWorldX, cNode.cTransform.nWorldY, 0, 0);
			
			return p_target;
		}
	}
}