/*
 * 	Genome2D - GPU 2D framework utilizing Molehill API
 *
 *	Copyright 2012 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.context.postprocesses
{
	public class GDropShadowPP extends GGlowPP
	{
		public function get offsetX():int {
			return _iOffsetX;
		}
		public function set offsetX(p_value:int):void {
			_iOffsetX = p_value;
		}
		
		public function get offsetY():int {
			return _iOffsetY;
		}
		public function set offsetY(p_value:int):void {
			_iOffsetY = p_value;
		}
		
		public function GDropShadowPP(p_blurX:int=2, p_blurY:int=2, p_offsetX:int=0, p_offsetY:Number=0, p_blurPasses:int=1) {
			_iOffsetX = p_offsetX;
			_iOffsetY = p_offsetY;
			
			super(p_blurX, p_blurY, p_blurPasses);
		}
	}
}