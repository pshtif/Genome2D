/*
 * 	Genome2D - GPU 2D framework utilizing Molehill API
 *
 *	Copyright 2012 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.context.postprocesses
{
	import com.genome2d.components.GCamera;
	import com.genome2d.context.GContext;
	import com.genome2d.context.filters.GBloomPassFilter;
	import com.genome2d.context.filters.GBrightPassFilter;
	import com.genome2d.context.filters.GFilter;
	import com.genome2d.context.filters.GHDRPassFilter;
	import com.genome2d.core.GNode;
	import com.genome2d.g2d;
	import com.genome2d.textures.GTexture;
	
	import flash.geom.Rectangle;
	
	public class GHDRPP extends GPostProcess
	{
		protected var _cEmpty:GFilterPP;
		protected var _cBlur:GBlurPP;
		protected var _cHDRPassFilter:GHDRPassFilter;
		
		public function get blurX():int {
			return _cBlur.blurX;
		}
		public function set blurX(p_value:int):void {
			_cBlur.blurX = p_value;
			_iLeftMargin = _iRightMargin = p_value*2*_cBlur.passes;
			_cEmpty.setMargins(_iLeftMargin, _iRightMargin, _iTopMargin, _iBottomMargin);
		}
		
		public function get blurY():int {
			return _cBlur.blurY;
		}
		public function set blurY(p_value:int):void {
			_cBlur.blurY = p_value;
			_iTopMargin = _iBottomMargin = p_value*2*_cBlur.passes;
			_cEmpty.setMargins(_iLeftMargin, _iRightMargin, _iTopMargin, _iBottomMargin);
		}
		
		public function get saturation():Number {
			return _cHDRPassFilter.saturation;
		}
		public function set saturation(p_value:Number):void {
			_cHDRPassFilter.saturation = p_value;
		}
		
		public function GHDRPP(p_blurX:int = 3, p_blurY:int = 3, p_blurPasses:int = 2, p_saturation:Number = 1.3) {
			super(2);
			
			_iLeftMargin = _iRightMargin = p_blurX*2*p_blurPasses;
			_iTopMargin = _iBottomMargin = p_blurY*2*p_blurPasses;
			
			_cEmpty = new GFilterPP(new <GFilter>[null]);
			_cEmpty.setMargins(_iLeftMargin, _iRightMargin, _iTopMargin, _iBottomMargin);
			
			_cBlur = new GBlurPP(p_blurX, p_blurY, p_blurPasses);
			
			_cHDRPassFilter = new GHDRPassFilter(p_saturation);
		}
		
		override public function render(p_context:GContext, p_camera:GCamera, p_maskRect:Rectangle, p_node:GNode, p_bounds:Rectangle = null, p_source:GTexture = null, p_target:GTexture = null):void {	
			var bounds:Rectangle = (_rDefinedBounds) ? _rDefinedBounds : p_node.getWorldBounds(_rActiveBounds);

			// Invalid bounds
			if (bounds.x == Number.MAX_VALUE) return;
			
			updatePassTextures(bounds);
			
			_cEmpty.render(p_context, p_camera, p_maskRect, p_node, bounds, null, _aPassTextures[0]);
			_cBlur.render(p_context, p_camera, p_maskRect, p_node, bounds, _aPassTextures[0], _aPassTextures[1]);
			
			_cHDRPassFilter.texture = _cEmpty.getPassTexture(0);
			
			p_context.setRenderTarget(null);
			p_context.setCamera(p_camera);
			p_context.draw(_aPassTextures[1], bounds.x-_iLeftMargin, bounds.y-_iTopMargin, 1, 1, 0, 1, 1, 1, 1, 1, p_maskRect, _cHDRPassFilter);
		}
		
		override public function dispose():void {
			_cBlur.dispose();
			
			super.dispose();
		}
	}
}