/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.components.physics
{
	import com.genome2d.core.GNode;
	import com.genome2d.g2d;
	import com.genome2d.components.GComponent;
	import com.genome2d.components.GTransform;
	
	use namespace g2d;

	public class GBody extends GComponent
	{
		public function get x():Number {
			return 0;
		}
		public function set x(p_x:Number):void {
		}
		
		public function get y():Number {
			return 0;
		}
		public function set y(p_y:Number):void {
		}
		
		public function get scaleX():Number {
			return 1;
		}
		public function set scaleX(p_scaleX:Number):void {
		}
		
		public function get scaleY():Number {
			return 1;
		}
		public function set scaleY(p_scaleY:Number):void {
		}
		
		public function get rotation():Number {
			return 0;
		}
		public function set rotation(p_rotation:Number):void {
		}
		
		public function isDynamic():Boolean {
			return false;
		}
		
		public function isKinematic():Boolean {
			return false;
		}
		/**
		 * 	@private
		 */
		public function GBody(p_node:GNode):void {
			super(p_node);
		}
		
		/**
		 * 	@private
		 */
		g2d function addToSpace():void {
		}
		
		/**
		 * 	@private
		 */
		g2d function removeFromSpace():void {
		}
		
		/**
		 * 	@private
		 */
		g2d function invalidateKinematic(p_transform:GTransform):void {
		}
	}
}