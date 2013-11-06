/*
 * 	Genome2D - GPU 2D framework utilizing Molehill API
 *
 *	Copyright 2012 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.context.postprocesses
{
	import com.genome2d.g2d;
	import com.genome2d.components.GCamera;
	import com.genome2d.context.GContext;
	import com.genome2d.context.filters.GFilter;
	import com.genome2d.core.GNode;
	import com.genome2d.core.Genome2D;
	import com.genome2d.error.GError;
	import com.genome2d.textures.GTexture;
	import com.genome2d.textures.GTextureFilteringType;
	import com.genome2d.textures.factories.GTextureFactory;
	
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	
	use namespace g2d;
	
	public class GPostProcess
	{	
		protected var _iPasses:int = 1;
		public function get passes():int {
			return _iPasses;
		}
		
		protected var _aPassFilters:Vector.<GFilter>;
		protected var _aPassTextures:Vector.<GTexture>;
		protected var _cMatrix:Matrix3D = new Matrix3D();
		protected var _rDefinedBounds:Rectangle;
		protected var _rActiveBounds:Rectangle;
		
		protected var _iLeftMargin:int = 0;
		protected var _iRightMargin:int = 0;
		protected var _iTopMargin:int = 0;
		protected var _iBottomMargin:int = 0;
		
		static private var __iCount:int = 0;
		protected var _sId:String;
		public function GPostProcess(p_passes:int = 1) {
			_sId = String(__iCount++);
			if (p_passes<1) throw new GError(GError.ATLEAST_ONE_PASS_REQUIRED);
			
			_iPasses = p_passes;
			
			_aPassFilters = new Vector.<GFilter>(_iPasses);
			_aPassTextures = new Vector.<GTexture>(_iPasses);
			createPassTextures();
		}
		
		public function setBounds(p_bounds:Rectangle):void {
			_rDefinedBounds = p_bounds;
		}

		public function setMargins(p_leftMargin:int = 0, p_rightMargin:int = 0, p_topMargin:int = 0, p_bottomMargin:int = 0):void {
			_iLeftMargin = p_leftMargin;
			_iRightMargin = p_rightMargin;
			_iTopMargin = p_topMargin;
			_iBottomMargin = p_bottomMargin;
		}
		
		public function render(p_context:GContext, p_camera:GCamera, p_maskRect:Rectangle, p_node:GNode, p_bounds:Rectangle = null, p_source:GTexture = null, p_target:GTexture = null):void {
			var bounds:Rectangle = p_bounds;
			if (bounds == null) bounds = (_rDefinedBounds) ? _rDefinedBounds : p_node.getWorldBounds(_rActiveBounds);

			// Invalid bounds
			if (bounds.x == Number.MAX_VALUE) return;
			
			updatePassTextures(bounds);
			
			if (p_source == null) {
				_cMatrix.identity();
				_cMatrix.prependTranslation(-bounds.x+_iLeftMargin, -bounds.y+_iTopMargin, 0);
				p_context.setRenderTarget(_aPassTextures[0], _cMatrix);
				
				p_context.setCamera(Genome2D.getInstance().defaultCamera);
				p_node.render(p_context, true, true, p_camera, _aPassTextures[0].region, false);
			}
			
			var zero:GTexture = _aPassTextures[0];
			if (p_source) _aPassTextures[0] = p_source;
			
			for (var i:int = 1; i<_iPasses; ++i) {
				p_context.setRenderTarget(_aPassTextures[i]);
				p_context.draw(_aPassTextures[i-1], 0, 0, 1, 1, 0, 1, 1, 1, 1, 1, _aPassTextures[i].region, _aPassFilters[i-1]);
			}

            p_context.setRenderTarget(p_target);
			if (p_target == null) {
				p_context.setCamera(p_camera);
				p_context.draw(_aPassTextures[_iPasses-1], bounds.x-_iLeftMargin, bounds.y-_iTopMargin, 1, 1, 0, 1, 1, 1, 1, 1, p_maskRect, _aPassFilters[_iPasses-1]);
			} else {
				p_context.draw(_aPassTextures[_iPasses-1], 0, 0, 1, 1, 0, 1, 1, 1, 1, 1, p_target.region, _aPassFilters[_iPasses-1]);
			}
			_aPassTextures[0] = zero;
		}
		
		public function getPassTexture(p_pass:int):GTexture {
			return _aPassTextures[p_pass];
		}
		
		public function getPassFilter(p_pass:int):GFilter {
			return _aPassFilters[p_pass];
		}
		
		protected function updatePassTextures(p_bounds:Rectangle):void {
			var w:Number = p_bounds.width + _iLeftMargin + _iRightMargin;
			var h:Number = p_bounds.height + _iTopMargin + _iBottomMargin;
			if (_aPassTextures[0].width != w || _aPassTextures[0].height != h) {
				for (var i:int = _aPassTextures.length-1; i>=0; --i) {
					var texture:GTexture = _aPassTextures[i];
					texture.region = new Rectangle(0, 0, w, h);
					texture.pivotX = -texture.iWidth/2;
					texture.pivotY = -texture.iHeight/2;
				}
			}
		}
		
		protected function createPassTextures():void {
			for (var i:int = 0; i<_iPasses; ++i) {
				var texture:GTexture = GTextureFactory.createRenderTexture("g2d_pp_"+_sId+"_"+i, 2, 2, true);
				texture.filteringType = GTextureFilteringType.NEAREST;
				texture.pivotX = -texture.iWidth/2;
				texture.pivotY = -texture.iHeight/2;
				_aPassTextures[i] = texture;
			}
		}
		
		public function dispose():void {
			for (var i:int = _aPassTextures.length-1; i>=0; --i) {
				_aPassTextures[i].dispose();
			}
		}
	}
}