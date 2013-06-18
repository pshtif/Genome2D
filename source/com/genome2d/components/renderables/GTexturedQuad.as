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
	import com.genome2d.context.filters.GFilter;
	import com.genome2d.core.GNode;
	import com.genome2d.textures.GTexture;
	
	import flash.events.MouseEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	use namespace g2d;

	public class GTexturedQuad extends GRenderable
	{	
		static private const NORMALIZED_VERTICES_3D:Vector.<Number> = Vector.<Number>([
			-.5,  .5, 0,
			-.5, -.5, 0,
			.5, -.5, 0,
			.5,  .5, 0
		]);
		
		public var filter:GFilter;
		
		/**
		 * 	@private
		 */
		g2d var cTexture:GTexture;
		public function getTexture():GTexture {
			return cTexture;
		}
		
		protected var _aTransformedVertices:Vector.<Number> = new Vector.<Number>();
		
		/**
		 * 	If this flag is true any node using this component will use pixel perfect mouse detection based on a data from this texture
		 */
		public var mousePixelEnabled:Boolean = false;
		
		/**
		 * 	@private
		 */
		public function GTexturedQuad(p_node:GNode) {
			super(p_node);
		}

		/**
		 * 	@private
		 */
		override public function render(p_context:GContext, p_camera:GCamera, p_maskRect:Rectangle):void {
			if (cTexture == null) return;
		
			var transform:GTransform = cNode.cTransform;
            //trace(node, "tx:", transform.nWorldX, "ty:", transform.nWorldY, "tsx:", transform.nWorldScaleX, "tsy:", transform.nWorldScaleY, "tr:", transform.nWorldRotation);
			p_context.draw(cTexture, transform.nWorldX, transform.nWorldY, transform.nWorldScaleX, transform.nWorldScaleY, transform.nWorldRotation, transform.nWorldRed, transform.nWorldGreen, transform.nWorldBlue, transform.nWorldAlpha, iBlendMode, p_maskRect, filter);
		}
		
		override public function getWorldBounds(p_target:Rectangle = null):Rectangle {
			var vertices:Vector.<Number> = getTransformedVertices3D();
			if (vertices == null) return p_target;
			if (p_target) p_target.setTo(vertices[0], vertices[1],0,0);
			else p_target = new Rectangle(vertices[0], vertices[1],0,0);
			var length:int = vertices.length;
			for (var i:int=3; i<length; i+=3) {
				if (p_target.left>vertices[i]) p_target.left = vertices[i];
				if (p_target.right<vertices[i]) p_target.right = vertices[i];
				if (p_target.top>vertices[i+1]) p_target.top = vertices[i+1];
				if (p_target.bottom<vertices[i+1]) p_target.bottom = vertices[i+1];
			}

			return p_target;
		}
		
		/**
		 * 	@private
		 */
		g2d function getTransformedVertices3D():Vector.<Number> {
			if (cTexture == null) return null;
			var region:Rectangle = cTexture.region;

			var transformMatrix:Matrix3D = cNode.cTransform.worldTransformMatrix;
			transformMatrix.prependTranslation(-cTexture.nPivotX, -cTexture.nPivotY, 0);
			transformMatrix.prependScale(region.width, region.height, 1);

			transformMatrix.transformVectors(NORMALIZED_VERTICES_3D, _aTransformedVertices);
			
			transformMatrix.prependScale(1/region.width, 1/region.height, 1);
			transformMatrix.prependTranslation(cTexture.nPivotX, cTexture.nPivotY, 0);
			return _aTransformedVertices;
		}
		
		/**
		 * 	Hit test detection of this and remote G2DSprite component
		 */
		public function hitTestObject(p_sprite:GTexturedQuad):Boolean {
			var tvs1:Vector.<Number> = p_sprite.getTransformedVertices3D();
			var tvs2:Vector.<Number> = getTransformedVertices3D();
			
			var cx:Number = (tvs1[0]+tvs1[3]+tvs1[6]+tvs1[9])/4;
			var cy:Number = (tvs1[1]+tvs1[4]+tvs1[7]+tvs1[10])/4;

			if (isSeparating(tvs1[3], tvs1[4], tvs1[0]-tvs1[3], tvs1[1]-tvs1[4], cx, cy, tvs2)) return false;
			
			if (isSeparating(tvs1[6], tvs1[7], tvs1[3]-tvs1[6], tvs1[4]-tvs1[7], cx, cy, tvs2)) return false;
			
			if (isSeparating(tvs1[9], tvs1[10], tvs1[6]-tvs1[9], tvs1[7]-tvs1[10], cx, cy, tvs2)) return false;
			
			if (isSeparating(tvs1[0], tvs1[1], tvs1[9]-tvs1[0], tvs1[10]-tvs1[1], cx, cy, tvs2)) return false;
			
			cx = (tvs2[0]+tvs2[3]+tvs2[6]+tvs2[9])/4;
			cy = (tvs2[1]+tvs2[4]+tvs2[7]+tvs2[10])/4;

			if (isSeparating(tvs2[3], tvs2[4], tvs2[0]-tvs2[3], tvs2[1]-tvs2[4], cx, cy, tvs1)) return false;

			if (isSeparating(tvs2[6], tvs2[7], tvs2[3]-tvs2[6], tvs2[4]-tvs2[7], cx, cy, tvs1)) return false;

			if (isSeparating(tvs2[9], tvs2[10], tvs2[6]-tvs2[9], tvs2[7]-tvs2[10], cx, cy, tvs1)) return false;

			if (isSeparating(tvs2[0], tvs2[1], tvs2[9]-tvs2[0], tvs2[10]-tvs2[1], cx, cy, tvs1)) return false;
			
			return true;
		}
		
		private function isSeparating(p_sx:Number, p_sy:Number, p_ex:Number, p_ey:Number, p_cx:Number, p_cy:Number, p_vertices:Vector.<Number>):Boolean {
			var rx:Number = -p_ey;
			var ry:Number = p_ex;
			
			var sideCenter:Number = rx * (p_cx - p_sx) + ry * (p_cy - p_sy);
			
			var sideV1:Number = rx * (p_vertices[0] - p_sx) + ry * (p_vertices[1] - p_sy);
			var sideV2:Number = rx * (p_vertices[3] - p_sx) + ry * (p_vertices[4] - p_sy);
			var sideV3:Number = rx * (p_vertices[6] - p_sx) + ry * (p_vertices[7] - p_sy);
			var sideV4:Number = rx * (p_vertices[9] - p_sx) + ry * (p_vertices[10] - p_sy);

			if (sideCenter < 0 && sideV1 >= 0 && sideV2 >= 0 && sideV3 >= 0 && sideV4 >= 0) return true;
			if (sideCenter > 0 && sideV1 <= 0 && sideV2 <= 0 && sideV3 <= 0 && sideV4 <= 0) return true;
			
			return false;
		}
		
		/**
		 * 	Hit test point if its within this quad
		 */
		public function hitTestPoint(p_point:Vector3D, p_pixelEnabled:Boolean = false):Boolean {	
			var tWidth:Number = cTexture.width;// * cTexture.resampleScale;
			var tHeight:Number = cTexture.height;// * cTexture.resampleScale;
		
			var transformMatrix:Matrix3D = cNode.cTransform.getTransformedWorldTransformMatrix(tWidth, tHeight, 0, true);
			
			var localPoint:Vector3D = transformMatrix.transformVector(p_point);
			localPoint.x = (localPoint.x+.5);
			localPoint.y = (localPoint.y+.5);

			if (localPoint.x >= -cTexture.nPivotX/tWidth && localPoint.x <= 1-cTexture.nPivotX/tWidth && localPoint.y >= -cTexture.nPivotY/tHeight && localPoint.y <= 1-cTexture.nPivotY/tHeight) {
				if (mousePixelEnabled && cTexture.getAlphaAtUV(localPoint.x+cTexture.pivotX/tWidth, localPoint.y+cTexture.nPivotY/tHeight) == 0) {
					return false;
				}
				return true;
			}
			
			return false;
		}
		
		/**
		 * 	@private
		 */
		override public function processMouseEvent(p_captured:Boolean, p_event:MouseEvent, p_position:Vector3D):Boolean {
			if (p_captured && p_event.type == MouseEvent.MOUSE_UP) cNode.cMouseDown = null;
			if (p_captured || cTexture == null) {
				if (cNode.cMouseOver == cNode) cNode.handleMouseEvent(cNode, MouseEvent.MOUSE_OUT, Number.NaN, Number.NaN, p_event.buttonDown, p_event.ctrlKey);
				return false;
			}
	
			var tWidth:Number = cTexture.width;// * cTexture.resampleScale;
			var tHeight:Number = cTexture.height;// * cTexture.resampleScale;

			var transformMatrix:Matrix3D = cNode.cTransform.getTransformedWorldTransformMatrix(tWidth, tHeight, 0, true);
		
			var localMousePosition:Vector3D = transformMatrix.transformVector(p_position);
			
			localMousePosition.x = (localMousePosition.x+.5);
			localMousePosition.y = (localMousePosition.y+.5);
			
			if (localMousePosition.x >= -cTexture.nPivotX/tWidth && localMousePosition.x <= 1-cTexture.nPivotX/tWidth && localMousePosition.y >= -cTexture.nPivotY/tHeight && localMousePosition.y <= 1-cTexture.nPivotY/tHeight) {
				if (mousePixelEnabled && cTexture.getAlphaAtUV(localMousePosition.x+cTexture.pivotX/tWidth, localMousePosition.y+cTexture.nPivotY/tHeight) == 0) {
					if (cNode.cMouseOver == cNode) {
						cNode.handleMouseEvent(cNode, MouseEvent.MOUSE_OUT, localMousePosition.x*tWidth+cTexture.nPivotX, localMousePosition.y*tHeight+cTexture.nPivotY, p_event.buttonDown, p_event.ctrlKey);
					}
					return false;
				}
				cNode.handleMouseEvent(cNode, p_event.type, localMousePosition.x*tWidth+cTexture.nPivotX, localMousePosition.y*tHeight+cTexture.nPivotY, p_event.buttonDown, p_event.ctrlKey);
				if (cNode.cMouseOver != cNode) {
					cNode.handleMouseEvent(cNode, MouseEvent.MOUSE_OVER, localMousePosition.x*tWidth+cTexture.nPivotX, localMousePosition.y*tHeight+cTexture.nPivotY, p_event.buttonDown, p_event.ctrlKey);
				}
				
				return true;
			} else {
				if (cNode.cMouseOver == cNode) {
					cNode.handleMouseEvent(cNode, MouseEvent.MOUSE_OUT, localMousePosition.x*tWidth+cTexture.nPivotX, localMousePosition.y*tHeight+cTexture.nPivotY, p_event.buttonDown, p_event.ctrlKey);
				}
			}
			
			return false;
		}
		
		/**
		 * 	@private
		 */
		override public function dispose():void {
			super.dispose();
			
			cTexture = null;
		}
	}
}