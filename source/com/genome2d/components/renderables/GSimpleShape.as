/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.components.renderables
{
	import com.genome2d.g2d;
	import com.genome2d.components.GCamera;
	import com.genome2d.components.GTransform;
	import com.genome2d.context.GContext;
	import com.genome2d.core.GNode;
	import com.genome2d.textures.GTexture;
	
	import flash.geom.Rectangle;
	
	use namespace g2d;
	
	public class GSimpleShape extends GRenderable
	{
		g2d var cTexture:GTexture;
		
		protected var _aVertices:Vector.<Number>;
		protected var _aUvs:Vector.<Number>;
		
		public function setTexture(p_texture:GTexture):void {
			cTexture = p_texture;
		}
		
		public function GSimpleShape(p_node:GNode) {
			super(p_node);
		}
		
		override public function render(p_context:GContext, p_camera:GCamera, p_maskRect:Rectangle):void {
			if (cTexture == null || _aVertices == null || _aUvs == null) return;
			var transform:GTransform = cNode.cTransform;
			p_context.drawPoly(cTexture, _aVertices, _aUvs, transform.nWorldX, transform.nWorldY, transform.nWorldScaleX, transform.nWorldScaleY, transform.nWorldRotation, transform.nWorldRed, transform.nWorldGreen, transform.nWorldBlue, transform.nWorldAlpha, iBlendMode, p_maskRect);
		}
		
		public function init(p_vertices:Vector.<Number>, p_uvs:Vector.<Number>):void {
			_aVertices = p_vertices;
			_aUvs = p_uvs;
		}
	}
}