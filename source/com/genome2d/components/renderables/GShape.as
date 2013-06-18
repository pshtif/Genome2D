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
	import com.genome2d.context.materials.GCameraTexturedPolygonMaterial;
	import com.genome2d.core.GNode;
	import com.genome2d.textures.GTexture;
	
	import flash.geom.Rectangle;
	
	use namespace g2d;
	
	public class GShape extends GRenderable
	{
		static private var cTransformVector:Vector.<Number> = new <Number>[0,0,0,0, 0,0,0,0, 0,1,1,1, 1,1,1,1];
		
		protected var _cMaterial:GCameraTexturedPolygonMaterial;
		g2d var cTexture:GTexture;
		
		protected var _iMaxVertices:int = 0;
		protected var _iCurrentVertices:int = 0;
		protected var _aVertices:Vector.<Number>;
		protected var _aUVs:Vector.<Number>;
		
		protected var _bDirty:Boolean = false;
		
		public function setTexture(p_texture:GTexture):void {
			cTexture = p_texture;
		}
		
		public function GShape(p_node:GNode) {
			super(p_node);
			
			_cMaterial = new GCameraTexturedPolygonMaterial();
		}
		
		override public function render(p_context:GContext, p_camera:GCamera, p_maskRect:Rectangle):void {
			if (cTexture == null || _iMaxVertices == 0) return;
			
			p_context.checkAndSetupRender(_cMaterial, iBlendMode, cTexture.premultiplied, p_maskRect);
			_cMaterial.bind(p_context.cContext, p_context.bReinitialize, p_camera, _iMaxVertices);
			var transform:GTransform = cNode.cTransform;
			
			cTransformVector[0] = transform.nWorldX;
			cTransformVector[1] = transform.nWorldY;
			cTransformVector[2] = transform.nWorldScaleX;
			cTransformVector[3] = transform.nWorldScaleY;
			
			cTransformVector[4] = cTexture.nUvX;
			cTransformVector[5] = cTexture.nUvY;
			cTransformVector[6] = cTexture.nUvScaleX;
			cTransformVector[7] = cTexture.nUvScaleY;
			
			cTransformVector[8] = transform.nWorldRotation;
			cTransformVector[10] = cTexture.nPivotX * transform.nWorldScaleX;
			cTransformVector[11] = cTexture.nPivotY * transform.nWorldScaleY;
			
			cTransformVector[12] = transform.nWorldRed*transform.nWorldAlpha;
			cTransformVector[13] = transform.nWorldGreen*transform.nWorldAlpha;
			cTransformVector[14] = transform.nWorldBlue*transform.nWorldAlpha;
			cTransformVector[15] = transform.nWorldAlpha;
			//trace(cTransformVector);
			/**/
			_cMaterial.draw(cTransformVector, cTexture.cContextTexture.tTexture, cTexture.iFilteringType, _aVertices, _aUVs, _iCurrentVertices, _bDirty);
			
			_bDirty = false;
		}
		
		public function init(p_vertices:Vector.<Number>, p_uvs:Vector.<Number>):void {
			_bDirty = true;
			_iCurrentVertices = p_vertices.length/2;
			
			if (p_vertices.length/2 > _iMaxVertices) {
				_iMaxVertices = p_vertices.length/2;
				_aVertices = p_vertices;
				_aUVs = p_uvs;
			} else {
				for (var i:int = 0; i<_iCurrentVertices*2; ++i) {
					_aVertices[i] = p_vertices[i];
					_aUVs[i] = p_uvs[i];
				}
			}
		}
	}
}