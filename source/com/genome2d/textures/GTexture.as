/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.textures
{
	import com.genome2d.g2d;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;

	use namespace g2d;
	
	public class GTexture extends GTextureBase
	{		
		static public function getTextureById(p_id:String):GTexture {
			return GTextureBase.getTextureBaseById(p_id) as GTexture;
		}
		
		g2d var doNativeObject:DisplayObject;
		public function get nativeObject():DisplayObject {
			return doNativeObject;
		}
		
		public function set bitmapData(p_bitmapData:BitmapData):void {
			if (cParent) return;
			bdBitmapData = p_bitmapData;
			rRegion = bdBitmapData.rect;
			iWidth = rRegion.width;
			iHeight = rRegion.height;
			invalidateContextTexture(false);
		}
		
		/**
		 * 	@private
		 */
		g2d var nUvX:Number = 0;
		public function get uvX():Number { return nUvX };
		/**
		 * 	@private
		 */
		g2d var nUvY:Number = 0;
		public function get uvY():Number { return nUvY };
		public function set uvY(p_value:Number):void {
			nUvY = p_value;
		}
		/**
		 * 	@private
		 */
		g2d var nUvScaleX:Number = 1;
		public function get uvScaleX():Number { return nUvScaleX };
		/**
		 * 	@private
		 */
		g2d var nUvScaleY:Number = 1;
		public function get uvScaleY():Number { return nUvScaleY };
		
		g2d var nPivotX:Number = 0;
		public function get pivotX():Number {
			return nPivotX;
		}
		public function set pivotX(p_value:Number):void {
			nPivotX = p_value;
		}
		
		g2d var nPivotY:Number = 0;
		public function get pivotY():Number {
			return nPivotY;
		}
		public function set pivotY(p_value:Number):void {
			nPivotY = p_value;
		}
		
		override public function get gpuWidth():int {
			if (cParent) return cParent.gpuWidth;
			return GTextureUtils.getNextValidTextureSize(iWidth)
		}
		
		override public function get gpuHeight():int {
			if (cParent) return cParent.gpuHeight;
			return GTextureUtils.getNextValidTextureSize(iHeight)
		}
		
		override public function hasParent():Boolean {
			return (cParent != null);
		}
		
		public function alignTexture(p_align:int):void {
			switch (p_align) {
				case GTextureAlignType.CENTER:
					nPivotX = 0;
					nPivotY = 0;
					break;
				case GTextureAlignType.TOP_LEFT:
					nPivotX = -iWidth/2;
					nPivotY = -iHeight/2;
					break;
			}
		}
		
		override public function get resampleType():int {
			if (cParent != null) return cParent.resampleType;
			return _iResampleType;
		}
		override public function set resampleType(p_type:int):void {
			if (cParent != null) return;
			super.resampleType = p_type;
		}
		
		override public function get resampleScale():int {
			if (cParent != null) return cParent.resampleScale;
			return _iResampleScale;
		}
		override public function set resampleScale(p_scale:int):void {
			if (cParent != null) return;
			super.resampleScale = p_scale;
		}
		
		override public function set filteringType(p_type:int):void {
			if (cParent != null) return;
			super.filteringType = p_type;
		}		
		
		/**
		 * 	@private
		 */
		g2d var cParent:GTextureAtlas;
		public function get parent():GTextureAtlas {
			return cParent;
		}
		
		/**
		 * 	@private
		 */
		g2d var sSubId:String = "";
		
		/**
		 * 	@private
		 */
		g2d var rRegion:Rectangle;
		/**
		 * 	Get region of this texture
		 */
		public function get region():Rectangle {
			return rRegion;
		}
		/**
		 * 	Set region of this texture, only applicable if this is a subtexture
		 */
		public function set region(p_region:Rectangle):void {
			rRegion = p_region;
			
			iWidth = rRegion.width;
			iHeight = rRegion.height;

			if (cParent) {
				nUvX = rRegion.x/cParent.iWidth;
				nUvY = rRegion.y/cParent.iHeight;
				
				nUvScaleX = iWidth/cParent.iWidth;
				nUvScaleY = iHeight/cParent.iHeight;	
			} else {
				invalidateContextTexture(false);
			}
		}
		
		public function set width(p_value:int):void {
			rRegion.width = iWidth = p_value;
			
			nUvScaleX = iWidth/cParent.iWidth;
		}
		
		/**
		 * 	Get an alpha value at specified uv coordinates, its used internally for pixel precise mouse checking but you can also leverage this functionality as you want.
		 * 	Uv coordinates should be always values from 0 to 1, this method doesn't clamp them to avoid performance loss and will throw an error.
		 * 
		 * 	@param p_u
		 * 	@param p_v
		 */
		public function getAlphaAtUV(p_u:Number, p_v:Number):uint {
			if (bdBitmapData == null) return 255;
			return bdBitmapData.getPixel32(rRegion.x + p_u*rRegion.width, rRegion.y + p_v*rRegion.height)>>24&0xFF;
		}
		
		protected function updateUVScale():void {
			switch (_iResampleType) {
				case GTextureResampleType.UP_CROP:
					nUvScaleX = (rRegion.width)/GTextureUtils.getNextValidTextureSize(iWidth);
					nUvScaleY = (rRegion.height)/GTextureUtils.getNextValidTextureSize(iHeight)
					break;
				case GTextureResampleType.NEAREST_DOWN_RESAMPLE_UP_CROP:
					var validWidth:int = GTextureUtils.getNearestValidTextureSize(iWidth);
					var validHeight:int = GTextureUtils.getNearestValidTextureSize(iHeight);
					var scaleX:Number = validWidth/rRegion.width;
					var scaleY:Number = validHeight/rRegion.height;

					nUvScaleX = (scaleX > scaleY) ? scaleY/scaleX : 1;
					nUvScaleY = (scaleY > scaleX) ? scaleX/scaleY : 1;
					break;
				/**/
			}
		}
		
		override protected function invalidateContextTexture(p_reinitialize:Boolean):void {
			if (cParent != null) return;
			
			updateUVScale();
			
			super.invalidateContextTexture(p_reinitialize);
		}
		
		/**
		 * 	Constructor
		 *  @private
		 * 
		 * 	@param p_id id of the texture
		 * 	@param p_sourceType type of source this texture will be created from, thould be a constant in G2DTextureSourceType
		 * 	@param p_source source that this texture will be created from, at the moment types supported are BITMAPDATA, BYTEARRAY and COMPRESSEDBYTEARRAY.
		 * 	@param p_region region this texture is representing from the source, this should always be specified even if it will be using the whole source due to inability to extract this information from source in case of compressed byte array
		 *  @param p_parent you should avoid this argument its used internally when G2DTextureAtlas is creating its sub textures
		 */
		public function GTexture(p_id:String, p_sourceType:int, p_source:*, p_region:Rectangle, p_transparent:Boolean, p_pivotX:Number = 0, p_pivotY:Number = 0, p_asyncCallback:Function = null, p_parent:GTextureAtlas = null) {			
			super(p_id, p_sourceType, p_source, p_transparent, p_asyncCallback);
			
			rRegion = p_region;
			iWidth = rRegion.width;
			iHeight = rRegion.height;
		
			nPivotX = p_pivotX;
			nPivotY = p_pivotY;
			
			cParent = p_parent;			
			if (cParent != null) {
				nUvX = p_region.x/cParent.iWidth;
				nUvY = p_region.y/cParent.iHeight;
				nUvScaleX = (p_region.width)/cParent.iWidth;
				nUvScaleY = (p_region.height)/cParent.iHeight;
			} else {
				invalidate();
			}
		}
		
		g2d function setParent(p_parent:GTextureAtlas, p_region:Rectangle):void {
			cParent = p_parent;
			
			region = p_region;
		}
		
		/**
		 * 	Dispose this texture
		 */
		override public function dispose():void {
			if (cParent == null) {
				if (doNativeObject) doNativeObject = null;
				if (baByteArray) baByteArray = null;
				if (bdBitmapData) bdBitmapData = null;
				if (cContextTexture) cContextTexture.dispose();
			}	
			cParent = null;
			
			super.dispose();
		}
		
		public function toString():String {
			return "[GTexture id:"+_sId+", width:"+width+", height:"+height+"]";
		}
	}
}