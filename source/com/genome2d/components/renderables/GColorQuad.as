/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.components.renderables
{
	import com.genome2d.components.GCamera;
	import com.genome2d.components.GTransform;
	import com.genome2d.context.GContext;
	import com.genome2d.context.materials.GCameraColorQuadVertexShaderBatchMaterial;
	import com.genome2d.core.GNode;
	import com.genome2d.g2d;
	
	import flash.geom.Rectangle;
	
	use namespace g2d;
	
	public class GColorQuad extends GRenderable
	{		
		/**
		 * 	@private
		 */
		public function GColorQuad(p_node:GNode) {
			super(p_node);
			
			if (cMaterial == null) cMaterial = new GCameraColorQuadVertexShaderBatchMaterial();
		}
		
		static private var cMaterial:GCameraColorQuadVertexShaderBatchMaterial;
		static private var cTransformVector:Vector.<Number> = new <Number>[0,0,0,0, 0,1,1,1, 1,1,1,1];
		
		/**
		 * 	@private
		 */
		override public function render(p_context:GContext, p_camera:GCamera, p_maskRect:Rectangle):void {
			if (p_context.checkAndSetupRender(cMaterial, iBlendMode, true, p_maskRect)) cMaterial.bind(p_context.cContext, p_context.bReinitialize, p_camera);
			
			var transform:GTransform = cNode.cTransform;
			
			cTransformVector[0] = transform.nWorldX;
			cTransformVector[1] = transform.nWorldY;
			cTransformVector[2] = transform.nWorldScaleX;
			cTransformVector[3] = transform.nWorldScaleY;
			
			cTransformVector[4] = transform.nWorldRotation;
			
			cTransformVector[8] = transform.nWorldRed;
			cTransformVector[9] = transform.nWorldGreen;
			cTransformVector[10] = transform.nWorldBlue;
			cTransformVector[11] = transform.nWorldAlpha;
			
			/**/
			cMaterial.draw(cTransformVector);
		}
	}
}