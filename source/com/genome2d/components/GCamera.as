/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.components
{
	import com.genome2d.g2d;
	import com.genome2d.context.GContext;
	import com.genome2d.core.GNode;
	
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	import avmplus.getQualifiedClassName;
	
	use namespace g2d;
	
	public class GCamera extends GComponent
	{		
		override public function getPrototype():XML {
			_xPrototype = super.getPrototype();

			return _xPrototype;
		}
		
		/**
		 * 	Camera mask used against node camera group a node is rendered through this camera if camera.mask and nodecameraGroup != 0
		 */
		public var mask:int = 0xFFFFFF;
		/**
		 * 	Viewport x offset, this value should be always within 0 and 1 its based on context main viewport
		 */
		public var normalizedViewX:Number = 0;
		/**
		 * 	Viewport y offset, this value should be always within 0 and 1 it based on context main viewport
		 */
		public var normalizedViewY:Number = 0;
		/**
		 * 	Viewport width, this value should be always within 0 and 1 its based on context main viewport
		 */
		public var normalizedViewWidth:Number = 1;
		/**
		 * 	Viewport height, this value should be always within 0 and 1 its  based on context main viewport
		 */
		public var normalizedViewHeight:Number = 1;
		
		/**
		 * 	Red component of viewport background color
		 */
		public var backgroundRed:Number = 0;
		/**
		 * 	Green component of viewport background color
		 */
		public var backgroundGreen:Number = 0;
		/**
		 * 	Blue component of viewport background color
		 */
		public var backgroundBlue:Number = 0;
		/**
		 * 	@private
		 */
		public var backgroundAlpha:Number = 0;
		
		/**
		 * 	Get a viewport color
		 */
		public function get backgroundColor():uint {
			var alpha:uint = uint(backgroundAlpha*255)<<24;
			var red:uint = uint(backgroundRed*255)<<16;
			var green:uint = uint(backgroundGreen*255)<<8;
			var blue:uint = uint(backgroundBlue*255);

			return alpha+red+green+blue;
		}
		/**
		 * 	@private
		 */
		g2d var rViewRectangle:Rectangle;
		/**
		 * 	@private
		 */
		g2d var rendererData:Object;
		
		g2d var bCapturedThisFrame:Boolean = false;
		
		/**
		 * 	@private
		 */
		//g2d var nX:Number = 0;
		/**
		 * 	@private
		 */
		//g2d var nY:Number = 0;
		/**
		 * 	@private
		 */
		g2d var nViewX:Number = 0;
		/**
		 * 	@private
		 */
		g2d var nViewY:Number = 0;
		/**
		 * 	@private
		 */
		g2d var nScaleX:Number = 1;
		/**
		 * 	@private
		 */
		g2d var nScaleY:Number = 1;
		
		g2d var aCameraVector:Vector.<Number> = new <Number>[0,0,0,0, 0,0,0,0];
		
		g2d var iRenderedNodesCount:int;
		
		public function get zoom():Number {
			return nScaleX;
		}
		public function set zoom(p_value:Number):void {
			nScaleX = nScaleY = p_value;
		}
		
		/**
		 * 	@private
		 */
		//g2d var nRotation:Number = 0;
		
		/**
		 * 	@private
		 */
		public function GCamera(p_node:GNode) {
			super(p_node);
			
			rViewRectangle = new Rectangle();
			
			if (cNode != cNode.cCore.root && cNode.isOnStage()) cNode.cCore.addCamera(this);
			
			cNode.onAddedToStage.add(onAddedToStage);
			cNode.onRemovedFromStage.add(onRemovedFromStage);
		}

		/**
		 * 	@private
		 */
		override public function update(p_deltaTime:Number, p_parentTransformUpdate:Boolean, p_parentColorUpdate:Boolean):void {
		}
		
		g2d function invalidate():void {
			rViewRectangle.x = normalizedViewX*cNode.cCore.cConfig.viewRect.width;
			rViewRectangle.y = normalizedViewY*cNode.cCore.cConfig.viewRect.height;
			var nw:Number = (normalizedViewWidth+normalizedViewX > 1) ? 1-normalizedViewX : normalizedViewWidth;
			var nh:Number = (normalizedViewHeight+normalizedViewY > 1) ? 1-normalizedViewY : normalizedViewHeight;
			rViewRectangle.width = nw*cNode.cCore.cConfig.viewRect.width;
			rViewRectangle.height = nh*cNode.cCore.cConfig.viewRect.height;
			
			aCameraVector[0] = cNode.cTransform.nWorldRotation;
			aCameraVector[1] = rViewRectangle.x + rViewRectangle.width/2;
			aCameraVector[2] = rViewRectangle.y + rViewRectangle.height/2;
			
			aCameraVector[4] = cNode.cTransform.nWorldX;
			aCameraVector[5] = cNode.cTransform.nWorldY;
			
			aCameraVector[6] = nScaleX;
			aCameraVector[7] = nScaleY;
		}
		
		/**
		 * 	@private
		 */
		override public function render(p_context:GContext, p_camera:GCamera, p_maskRect:Rectangle):void {			
			if (p_camera != null || !cNode.active) return;
			iRenderedNodesCount = 0;

			if (backgroundAlpha != 0) p_context.blitColor(rViewRectangle.x + rViewRectangle.width/2, rViewRectangle.y + rViewRectangle.height/2, rViewRectangle.width, rViewRectangle.height, backgroundRed, backgroundGreen, backgroundBlue, backgroundAlpha, 1, rViewRectangle);
			
			p_context.setCamera(this);
			cNode.cCore.root.render(p_context, this, rViewRectangle, false);
		}
		
		/**
		 * 	@private
		 */
		g2d function captureMouseEvent(p_captured:Boolean, p_event:MouseEvent, p_position:Vector3D):Boolean {
			if (bCapturedThisFrame || !cNode.active) return false;
			bCapturedThisFrame = true;

			if (!rViewRectangle.contains(p_position.x, p_position.y)) return false;

			p_position.x -= rViewRectangle.x + rViewRectangle.width/2;
			p_position.y -= rViewRectangle.y + rViewRectangle.height/2;
			
			var cos:Number = Math.cos(-cNode.cTransform.nWorldRotation);
			var sin:Number = Math.sin(-cNode.cTransform.nWorldRotation);
			
			var tx:Number = (p_position.x*cos - p_position.y*sin);
			var ty:Number = (p_position.y*cos + p_position.x*sin);
			
			tx /= nScaleY;
			ty /= nScaleX;
			
			p_position.x = tx + cNode.cTransform.nWorldX;
			p_position.y = ty + cNode.cTransform.nWorldY;

			return cNode.cCore.root.processMouseEvent(p_captured, p_event, p_position, this);
		}
		
		/**
		 * 	@private
		 */
		override public function dispose():void {
			cNode.cCore.removeCamera(this);
			
			cNode.onAddedToStage.remove(onAddedToStage);
			cNode.onRemovedFromStage.remove(onRemovedFromStage);
			
			super.dispose();
		}
		
		private function onAddedToStage():void {
			cNode.cCore.addCamera(this);
		}
		
		private function onRemovedFromStage():void {
			cNode.cCore.removeCamera(this);
		}
	}
}