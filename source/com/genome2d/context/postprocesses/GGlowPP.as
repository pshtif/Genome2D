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
	import com.genome2d.context.filters.GColorMatrixFilter;
	import com.genome2d.context.filters.GFilter;
	import com.genome2d.core.GNode;
	import com.genome2d.g2d;
	import com.genome2d.textures.GTexture;
	
	import flash.geom.Rectangle;
	
	public class GGlowPP extends GPostProcess
	{
		protected var _cEmpty:GFilterPP;
		protected var _cBlur:GBlurPP;
		
		protected var _iOffsetX:int;
		protected var _iOffsetY:int;
		
		public function get color():int {
			var red:uint = (_cBlur.red*0xFF)<<16;
			var green:uint = (_cBlur.green*0xFF)<<8;
			var blue:uint = _cBlur.blue*0xFF;
			return red+green+blue;
		}
		public function set color(p_value:int):void {
			_cBlur.red = Number(p_value>>16&0xFF)/0xFF;
			_cBlur.green = Number(p_value>>8&0xFF)/0xFF;
			_cBlur.blue = Number(p_value&0xFF)/0xFF;
		}
		
		public function get alpha():Number {
			return _cBlur.alpha;
		}
		public function set alpha(p_value:Number):void {
			_cBlur.alpha = p_value;
		}
		
		public function get blurX():Number {
			return _cBlur.blurX;
		}
		public function set blurX(p_value:Number):void {
			_cBlur.blurX = p_value;
			_iLeftMargin = _iRightMargin = _cBlur.blurX * _cBlur.passes * .5;
			_cEmpty.setMargins(_iLeftMargin, _iRightMargin, _iTopMargin, _iBottomMargin);
		}
		
		public function get blurY():int {
			return _cBlur.blurY;
		}
		public function set blurY(p_value:int):void {
			_cBlur.blurY = p_value;
			_iTopMargin = _iBottomMargin = _cBlur.blurY * _cBlur.passes * .5;
			_cEmpty.setMargins(_iLeftMargin, _iRightMargin, _iTopMargin, _iBottomMargin);
		}
		
		public function GGlowPP(p_blurX:int = 2, p_blurY:int = 2, p_blurPasses:int = 1) {
			super(2);
			
			_cEmpty = new GFilterPP(new <GFilter>[null]);			
			_cBlur = new GBlurPP(p_blurX, p_blurY, p_blurPasses);
			_cBlur.colorize = true;

			_iLeftMargin = _iRightMargin = _cBlur.blurX * _cBlur.passes * .5;
			_iTopMargin = _iBottomMargin = _cBlur.blurY * _cBlur.passes * .5;
			_cEmpty.setMargins(_iLeftMargin, _iRightMargin, _iTopMargin, _iBottomMargin);
		}
		
		override public function render(p_context:GContext, p_camera:GCamera, p_maskRect:Rectangle, p_node:GNode, p_bounds:Rectangle = null, p_source:GTexture = null, p_target:GTexture = null):void {	
			var bounds:Rectangle = (_rDefinedBounds) ? _rDefinedBounds : p_node.getWorldBounds(_rActiveBounds);

			// Invalid bounds
			if (bounds.x == Number.MAX_VALUE) return;

			updatePassTextures(bounds);
			
			_cEmpty.render(p_context, p_camera, p_maskRect, p_node, bounds, null, _aPassTextures[0]);
			_cBlur.render(p_context, p_camera, p_maskRect, p_node, bounds, _aPassTextures[0], _aPassTextures[1]);
		
			p_context.setRenderTarget();
			p_context.setCamera(p_camera);
			p_context.draw(_aPassTextures[1], bounds.x-_iLeftMargin+_iOffsetX, bounds.y-_iTopMargin+_iOffsetY, 1, 1, 0, 1, 1, 1, 1, 1, p_maskRect);
			p_context.draw(_aPassTextures[0], bounds.x-_iLeftMargin, bounds.y-_iTopMargin, 1, 1, 0, 1, 1, 1, 1, 1, p_maskRect);
		}
		
		override public function dispose():void {
			_cEmpty.dispose();
			_cBlur.dispose();
			
			super.dispose();
		}
	}
}