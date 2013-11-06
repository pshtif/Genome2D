/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.components.renderables.flash
{
	import com.genome2d.g2d;
	import com.genome2d.components.GCamera;
	import com.genome2d.components.renderables.GTexturedQuad;
	import com.genome2d.context.GBlendMode;
	import com.genome2d.context.GContext;
	import com.genome2d.core.GNode;
	import com.genome2d.error.GError;
	import com.genome2d.textures.GTextureAlignType;
	import com.genome2d.textures.GTextureFilteringType;
	import com.genome2d.textures.GTextureResampleType;
	import com.genome2d.textures.factories.GTextureFactory;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	use namespace g2d;
	
	public class GFlashObject extends GTexturedQuad
	{
		static public var defaultSampleScale:int = 1;
		static public var defaultUpdateFrameRate:int = 20;
		static private var __iDefaultResampleType:int = GTextureResampleType.UP_CROP;
		static public function get defaultResampleType():int {
			return __iDefaultResampleType;
		}
		static public function set defaultResampleType(p_type:int):void {
			if (!GTextureResampleType.isValid(p_type)) throw new GError(GError.INVALID_RESAMPLE_TYPE);
			__iDefaultResampleType = p_type;
		}
		
		protected var _iAlign:int = GTextureAlignType.CENTER;
		public function get align():int {
			return _iAlign;
		}
		public function set align(p_align:int):void {
			_iAlign = p_align;
			invalidateTexture(true);
		}
		
		protected var _doNative:DisplayObject;
		public function get native():DisplayObject {
			return _doNative;
		}
		public function set native(p_native:DisplayObject):void {
			_doNative = p_native;
		}
		
		private var __mNativeMatrix:Matrix;
		
		private var __sTextureId:String;
		
		protected var _bInvalidate:Boolean = false;
		public function invalidate(p_force:Boolean = false):void {
			if (p_force) invalidateTexture(true);
			else _bInvalidate = true;
		}
		
		protected var _iResampleScale:int = defaultSampleScale;
		public function get resampleScale():int {
			return _iResampleScale;
		}
		public function set resampleScale(p_scale:int):void {
			if (p_scale<=0) return;
			_iResampleScale = p_scale;
			if (_doNative != null) invalidateTexture(true);
		}
		
		protected var _iFilteringType:int = GTextureFilteringType.NEAREST;
		public function get filteringType():int {
			return _iFilteringType;
		}
		public function set filteringType(p_filteringType:int):void {
			_iFilteringType = p_filteringType;			
			if (cTexture) cTexture.filteringType = _iFilteringType;
		}
		
		protected var _iResampleType:int = __iDefaultResampleType;
		public function get resampleType():int {
			return _iResampleType;
		}
		public function set resampleType(p_type:int):void {
			if (!GTextureResampleType.isValid(p_type)) throw new GError(GError.INVALID_RESAMPLE_TYPE);
			_iResampleType = p_type;
			if (_doNative != null) invalidateTexture(true);
		}
		
		private var __nLastNativeWidth:Number = 0;
		private var __nLastNativeHeight:Number = 0;
		private var __nAccumulatedTime:Number = 0;
		
		public var updateFrameRate:int = defaultUpdateFrameRate;
		protected var _bTransparent:Boolean = false;
		public function set transparent(p_transparent:Boolean):void {
			_bTransparent = p_transparent;
			if (_doNative != null) invalidateTexture(true);
		}
		public function get transparent():Boolean {
			return _bTransparent;
		}
		
		static private var __iCount:int = 0;
		/**
		 * 	@private
		 */
		public function GFlashObject(p_node:GNode) {
			super(p_node);
			
			iBlendMode = GBlendMode.NONE;
			__sTextureId = "G2DFlashObject#"+__iCount++;
			__mNativeMatrix = new Matrix();
		}
		
		override public function update(p_deltaTime:Number):void {
			if (_doNative == null || updateFrameRate != 0) return;
			
			invalidateTexture(false);
			
			__nAccumulatedTime += p_deltaTime;
			var updateTime:Number = 1000/updateFrameRate;
			if (_bInvalidate || __nAccumulatedTime > updateTime) {
				cTexture.bitmapData.fillRect(cTexture.bitmapData.rect, 0x0);
				cTexture.bitmapData.draw(_doNative, __mNativeMatrix);
				cTexture.invalidate();
				
				__nAccumulatedTime %= updateTime;
			}
			
			_bInvalidate = false;
		}
		/**/
		override public function render(p_context:GContext, p_camera:GCamera, p_maskRect:Rectangle):void {
			cNode.cTransform.nWorldScaleX *= _iResampleScale;
			cNode.cTransform.nWorldScaleY *= _iResampleScale;
			
			super.render(p_context, p_camera, p_maskRect);
			
			cNode.cTransform.nWorldScaleX /= _iResampleScale;
			cNode.cTransform.nWorldScaleY /= _iResampleScale;
		}
		/**/
		protected function invalidateTexture(p_force:Boolean):void {
			if (_doNative == null) return;
			if (!p_force && __nLastNativeWidth == _doNative.width && __nLastNativeHeight == _doNative.height) return;
			
			__nLastNativeWidth = _doNative.width;
			__nLastNativeHeight = _doNative.height;

			__mNativeMatrix.identity();
			__mNativeMatrix.scale(_doNative.scaleX/_iResampleScale, _doNative.scaleY/_iResampleScale);
			var bitmapData:BitmapData = new BitmapData(__nLastNativeWidth/_iResampleScale, __nLastNativeHeight/_iResampleScale, _bTransparent, 0x0);

			//__mNativeMatrix.scale(_doNative.scaleX, _doNative.scaleY);
			//var bitmapData:BitmapData = new BitmapData(__nLastNativeWidth, __nLastNativeHeight, _bTransparent, 0x000000);

			if (cTexture == null) {
				cTexture = GTextureFactory.createFromBitmapData(__sTextureId, bitmapData);
				//cTexture.resampleScale = _iResampleScale;
				cTexture.resampleType = _iResampleType;
				cTexture.filteringType = _iFilteringType;
			} else {
				cTexture.bitmapData = bitmapData;
			}
			
			cTexture.alignTexture(_iAlign);
			
			_bInvalidate = true;
		}
		
		override public function dispose():void {
			cTexture.dispose();
			
			super.dispose();
		}
	}
}