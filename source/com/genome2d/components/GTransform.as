/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.components
{
import com.genome2d.components.particles.GSimpleEmitter;
import com.genome2d.core.GNode;
	import com.genome2d.g2d;

	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;

	use namespace g2d;
	
	public class GTransform extends GComponent
	{
		public var visible:Boolean = true;
		
		private var __bWorldTransformMatrixDirty:Boolean = true;
		private var __mWorldTransformMatrix:Matrix3D = new Matrix3D();
		public function get worldTransformMatrix():Matrix3D {
			if (__bWorldTransformMatrixDirty) {
                var sx:Number = (nWorldScaleX == 0) ? 0.000001 : nWorldScaleX;
                var sy:Number = (nWorldScaleY == 0) ? 0.000001 : nWorldScaleY;
				__mWorldTransformMatrix.identity();
				__mWorldTransformMatrix.prependScale(sx, sy, 1);
				__mWorldTransformMatrix.prependRotation(nWorldRotation*180/Math.PI, Vector3D.Z_AXIS);
				__mWorldTransformMatrix.appendTranslation(nWorldX, nWorldY, 0);
				__bWorldTransformMatrixDirty = false;
			}
			
			return __mWorldTransformMatrix;
		}
		
		private var __mLocalTransformMatrix:Matrix3D = new Matrix3D();
		public function get localTransformMatrix():Matrix3D {
			__mLocalTransformMatrix.identity();
			__mLocalTransformMatrix.prependScale(__nLocalScaleX, __nLocalScaleY, 1);
			__mLocalTransformMatrix.prependRotation(__nLocalRotation*180/Math.PI, Vector3D.Z_AXIS);
			__mLocalTransformMatrix.appendTranslation(nLocalX, nLocalY, 0);
			
			return __mLocalTransformMatrix;
		}
		
		override public function set active(p_active:Boolean):void {
			super.active = p_active;
			bTransformDirty = _bActive;
		}
		
		public function getTransformedWorldTransformMatrix(p_scaleX:Number, p_scaleY:Number, p_rotation:Number, p_invert:Boolean):Matrix3D {
			var matrix:Matrix3D = worldTransformMatrix.clone();

			if (p_scaleX != 1 && p_scaleY != 1) matrix.prependScale(p_scaleX, p_scaleY, 1);
			if (p_rotation != 0) matrix.prependRotation(p_rotation, Vector3D.Z_AXIS);
			if (p_invert) matrix.invert();
			
			return matrix;
		}
		
		/**
		 * 	@private
		 */
		g2d var bTransformDirty:Boolean = true;
		/**
		 * 	@private
		 */
		g2d var nWorldX:Number = 0;
		g2d var nLocalX:Number = 0;
		public function get x():Number { return nLocalX };
		public function set x(p_x:Number):void {
			nWorldX = nLocalX = p_x;
			bTransformDirty = true;
			if (cNode.cBody) cNode.cBody.x = p_x;
			if (rMaskRect) rAbsoluteMaskRect.x = rMaskRect.x + nWorldX;
		}
		
		/**
		 * 	@private
		 */
		g2d var nWorldY:Number = 0;
		g2d var nLocalY:Number = 0;
		public function get y():Number { return nLocalY };
		public function set y(p_y:Number):void {
			nWorldY = nLocalY = p_y;
			bTransformDirty = true;
			if (cNode.cBody) cNode.cBody.y = p_y;
			if (rMaskRect) rAbsoluteMaskRect.y = rMaskRect.y + nWorldY;
		}
		
		public function setPosition(p_x:Number, p_y:Number):void {
			nWorldX = nLocalX = p_x;
			nWorldY = nLocalY = p_y;
			bTransformDirty = true;
			if (cNode.cBody) {
				cNode.cBody.x = p_x;
				cNode.cBody.y = p_y;
			}
			if (rMaskRect) {
				rAbsoluteMaskRect.x = rMaskRect.x + nWorldX;
				rAbsoluteMaskRect.y = rMaskRect.y + nWorldY;
			}
		}
		
		public function setScale(p_scaleX:Number, p_scaleY:Number):void {
			nWorldScaleX = __nLocalScaleX = p_scaleX;
			nWorldScaleY = __nLocalScaleY = p_scaleY;
			bTransformDirty = true;
			if (cNode.cBody) {
				cNode.cBody.scaleX = p_scaleX;
				cNode.cBody.scaleY = p_scaleY;
			}
		}
		
		/**
		 * 	@private
		 */
		g2d var nWorldScaleX:Number = 1;
		private var __nLocalScaleX:Number = 1;
		public function get scaleX():Number { return __nLocalScaleX };
		public function set scaleX(p_scaleX:Number):void {
			nWorldScaleX = __nLocalScaleX = p_scaleX;
			bTransformDirty = true;
			if (cNode.cBody) cNode.cBody.scaleX = p_scaleX;
		}
		
		/**
		 * 	@private
		 */
		g2d var nWorldScaleY:Number = 1;
		private var __nLocalScaleY:Number = 1;
		public function get scaleY():Number { return __nLocalScaleY };
		public function set scaleY(p_scaleY:Number):void {
			nWorldScaleY = __nLocalScaleY = p_scaleY;
			bTransformDirty = true;
			if (cNode.cBody) cNode.cBody.scaleY = p_scaleY;
		}
		
		/**
		 * 	@private
		 */
		g2d var nWorldRotation:Number = 0;
		private var __nLocalRotation:Number = 0;
		public function get rotation():Number { return __nLocalRotation };
		public function set rotation(p_rotation:Number):void {
			nWorldRotation = __nLocalRotation = p_rotation;
			bTransformDirty = true;
			if (cNode.cBody) cNode.cBody.rotation = p_rotation;
		}
		
		/**
		 * 	@private
		 */
		g2d var bColorDirty:Boolean = true;		
		
		public function set color(p_value:int):void {
			red = Number(p_value>>16&0xFF)/0xFF;
			green = Number(p_value>>8&0xFF)/0xFF;
			blue = Number(p_value&0xFF)/0xFF;
		}
		
		/**
		 * 	@private
		 */
		g2d var nWorldRed:Number = 1;
		private var _red:Number = 1;
		public function get red():Number { return _red };
		public function set red(p_red:Number):void { 
			nWorldRed = _red = p_red;
			bColorDirty = true;
		}
		
		/**
		 * 	@private
		 */
		g2d var nWorldGreen:Number = 1;
		private var _green:Number = 1;
		public function get green():Number { return _green };
		public function set green(p_green:Number):void { 
			nWorldGreen = _green = p_green;
			bColorDirty = true;
		}
		
		/**
		 * 	@private
		 */
		g2d var nWorldBlue:Number = 1;
		private var _blue:Number = 1;
		public function get blue():Number { return _blue };
		public function set blue(p_blue:Number):void { 
			nWorldBlue = _blue = p_blue;
			bColorDirty = true;
		}
		
		/**
		 * 	@private
		 */
		g2d var nWorldAlpha:Number = 1;
		private var _alpha:Number = 1;
		public function get alpha():Number { return _alpha };
		public function set alpha(p_alpha:Number):void {
			nWorldAlpha = _alpha = p_alpha;
			bColorDirty = true;
		}
		
		public var useWorldSpace:Boolean = false;
		public var useWorldColor:Boolean = false;
		
		g2d var cMask:GNode;
		public function get mask():GNode {
			return cMask;
		}
		public function set mask(p_mask:GNode):void {
			if (cMask) cMask.iUsedAsMask--;
			cMask = p_mask;
			cMask.iUsedAsMask++;
		}
		
		g2d var rMaskRect:Rectangle;
		public function get maskRect():Rectangle {
			return rMaskRect;
		}
		public function set maskRect(p_rect:Rectangle):void {
			rMaskRect = p_rect;
			rAbsoluteMaskRect = p_rect.clone();
			rAbsoluteMaskRect.x += nWorldX;
			rAbsoluteMaskRect.y += nWorldY;
            bTransformDirty = true;
		}
		g2d var rAbsoluteMaskRect:Rectangle;
		
		/**
		 * 	@private
		 */
		public function GTransform(p_node:GNode) {
			super(p_node);
		}
		
		/**
		 * 	@private
		 */
		g2d function invalidate(p_invalidateTransform:Boolean, p_invalidateColor:Boolean, p_makeValid:Boolean = true):void {
			if (cNode.cParent == null) {
				bColorDirty = bTransformDirty = false;
				return;
			}

			var parentTransform:GTransform = cNode.cParent.cTransform;
			if (cNode.cBody != null && cNode.cBody.isDynamic()) {
				nLocalX = nWorldX = cNode.cBody.x;
				nLocalY = nWorldY = cNode.cBody.y;
				__nLocalRotation = nWorldRotation = cNode.cBody.rotation;
				
				__bWorldTransformMatrixDirty = true;
			} else {
				if (p_invalidateTransform) {
					if (!useWorldSpace) {
						if (parentTransform.nWorldRotation != 0) {
							var cos:Number = Math.cos(parentTransform.nWorldRotation);
							var sin:Number = Math.sin(parentTransform.nWorldRotation);
							//nWorldX = (nLocalX*cos - nLocalY*sin)*parentTransform.nWorldScaleX + parentTransform.nWorldX;
                            nWorldX = nLocalX*parentTransform.nWorldScaleX*cos - nLocalY*parentTransform.nWorldScaleY*sin + parentTransform.nWorldX;
							//nWorldY = (nLocalY*cos + nLocalX*sin)*parentTransform.nWorldScaleY + parentTransform.nWorldY;
                            nWorldY = nLocalY*parentTransform.nWorldScaleY*cos + nLocalX*parentTransform.nWorldScaleX*sin + parentTransform.nWorldY;
						} else {
							nWorldX = nLocalX*parentTransform.nWorldScaleX + parentTransform.nWorldX;
							nWorldY = nLocalY*parentTransform.nWorldScaleY + parentTransform.nWorldY;
						}
						nWorldScaleX = __nLocalScaleX * parentTransform.nWorldScaleX;
						nWorldScaleY = __nLocalScaleY * parentTransform.nWorldScaleY;
						nWorldRotation = __nLocalRotation + parentTransform.nWorldRotation;
						
						if (rMaskRect) {
							rAbsoluteMaskRect.x = rMaskRect.x + nWorldX;
							rAbsoluteMaskRect.y = rMaskRect.y + nWorldY;
						}
						
						if (cNode.cBody != null && cNode.cBody.isKinematic()) {
							cNode.cBody.x = nWorldX;
							cNode.cBody.y = nWorldY;
							cNode.cBody.rotation = nWorldRotation;
						}
						
						if (p_makeValid) bTransformDirty = false;
						__bWorldTransformMatrixDirty = true;
					}
				} 
			}

            if (p_invalidateColor && !useWorldColor) {
				nWorldRed = _red * parentTransform.nWorldRed;
				nWorldGreen = _green * parentTransform.nWorldGreen;
				nWorldBlue = _blue * parentTransform.nWorldBlue;
				nWorldAlpha = _alpha * parentTransform.nWorldAlpha;
				
				bColorDirty = false;
			}
		}

        public function forceInvalidate():Boolean {
            return recursiveInvalidate(this);
        }

        private function recursiveInvalidate(p_transform:GTransform):Boolean {
            var parentTransformUpdate:Boolean = false;
            if (p_transform.cNode.cParent != null) recursiveInvalidate(p_transform.cNode.cParent.cTransform);

            parentTransformUpdate = parentTransformUpdate || bTransformDirty;
            if (parentTransformUpdate) invalidate(true, false, false);
            return parentTransformUpdate;
        }
		
		public function setColor(p_red:Number=1, p_green:Number=1, p_blue:Number=1, p_alpha:Number=1):void {
			red = p_red;
			green = p_green;
			blue = p_blue;
			alpha = p_alpha;
		}
		
		public function worldToLocal(p_position:Vector3D):Vector3D {
			if (cNode.cParent == null) return p_position;

			var matrix:Matrix3D = getTransformedWorldTransformMatrix(1,1,0,true);
			
			return matrix.transformVector(p_position);
		}
		
		public function localToWorld(p_position:Vector3D):Vector3D {
			if (cNode.cParent == null) return p_position;
			
			p_position = localTransformMatrix.transformVector(p_position);
			
			return cNode.cParent.cTransform.localToWorld(p_position);
		}
		
		public function toString():String {
			return "["+x+","+y+","+scaleX+","+scaleY+"]\n["+nWorldX+","+nWorldY+"]";
		}
	}
}