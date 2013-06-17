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
	import com.genome2d.context.filters.GBlurPassFilter;
	import com.genome2d.context.postprocesses.GPostProcess;
	import com.genome2d.core.GNode;
	import com.genome2d.core.Genome2D;
	import com.genome2d.g2d;
	import com.genome2d.textures.GTexture;
	import com.genome2d.textures.factories.GTextureFactory;
	
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	
	use namespace g2d;
	
	public class GBlurPP extends GPostProcess
	{		
		protected var _bInvalidate:Boolean = false;
		
		protected var _bColorize:Boolean = false;
		public function get colorize():Boolean {
			return _bColorize;
		}
		public function set colorize(p_value:Boolean):void {
			_bColorize = p_value;
			_bInvalidate = true;
		}
		protected var _nRed:Number = 0;
		public function get red():Number {
			return _nRed;
		}
		public function set red(p_value:Number):void {
			_nRed = p_value;
			_bInvalidate = true;
		}
		protected var _nGreen:Number = 0;
		public function get green():Number {
			return _nGreen;
		}
		public function set green(p_value:Number):void {
			_nGreen = p_value;
			_bInvalidate = true;
		}
		protected var _nBlue:Number = 0;
		public function get blue():Number {
			return _nBlue;
		}
		public function set blue(p_value:Number):void {
			_nBlue = p_value;
			_bInvalidate = true;
		}
		protected var _nAlpha:Number = 1;
		public function get alpha():Number {
			return _nAlpha;
		}
		public function set alpha(p_value:Number):void {
			_nAlpha = p_value;
			_bInvalidate = true;
		}
		
		override public function get passes():int {
			return _iPasses/2;
		}
		
		protected var _nBlurX:Number = 0;
		public function get blurX():int {
			return _iPasses*_nBlurX/2;
		}
		public function set blurX(p_value:int):void {
			_nBlurX = 2*p_value/_iPasses;
			_bInvalidate = true;
		}
		protected var _nBlurY:Number = 0;
		public function get blurY():int {
			return _iPasses*_nBlurY/2;
		}
		public function set blurY(p_value:int):void {
			_nBlurY = 2*p_value/_iPasses;
			_bInvalidate = true;
		}
		
		public function GBlurPP(p_blurX:int, p_blurY:int, p_passes:int = 1) {
            // Double the passes since we need them for vertical and horizontal blur as well
			super(p_passes*2);

            // Multiply by 2 for both ends and divide by number of passes since its incremental blur per pass
			_nBlurX = 2*p_blurX/_iPasses;
			_nBlurY = 2*p_blurY/_iPasses;

            // Calculate margins for containment area since blur goes reaches out
			_iLeftMargin = _iRightMargin = _nBlurX * _iPasses * .5;
			_iTopMargin = _iBottomMargin = _nBlurY * _iPasses * .5;

            // Generate blur pass filters
			for (var i:int = 0; i<_iPasses; ++i) {
				var blurPass:GBlurPassFilter = new GBlurPassFilter((i<_iPasses/2) ? _nBlurY : _nBlurX, (i<_iPasses/2) ? GBlurPassFilter.VERTICAL : GBlurPassFilter.HORIZONTAL);
				_aPassFilters[i] = blurPass;
			}
		}
		
		override public function render(p_context:GContext, p_camera:GCamera, p_maskRect:Rectangle, p_node:GNode, p_bounds:Rectangle=null, p_source:GTexture=null, p_target:GTexture=null):void {
			if (_bInvalidate) invalidateBlurFilters();
			
			super.render(p_context, p_camera, p_maskRect, p_node, p_bounds, p_source, p_target);
		}
		
		private function invalidateBlurFilters():void {
			for (var i:int = _aPassFilters.length-1; i>=0; --i) {
				var filter:GBlurPassFilter = _aPassFilters[i] as GBlurPassFilter; 
				filter.blur = (i<_iPasses/2) ? _nBlurY : _nBlurX;
				filter.colorize = _bColorize;
				filter.red = _nRed;
				filter.green = _nGreen;
				filter.blue = _nBlue;
				filter.alpha = _nAlpha;
			}
			_iLeftMargin = _iRightMargin = _nBlurX * _iPasses * .5;
			_iTopMargin = _iBottomMargin = _nBlurY * _iPasses * .5;
			
			_bInvalidate = false;
		}
	}
}