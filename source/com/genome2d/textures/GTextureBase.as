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
	import com.genome2d.context.GContextTexture;
	import com.genome2d.core.Genome2D;
	import com.genome2d.error.GError;
	
	import flash.display.BitmapData;
	import flash.display3D.Context3DTextureFormat;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	use namespace g2d;
	
	public class GTextureBase
	{
		static public var alwaysUseCompressed:Boolean = false;
		
		static private var __iDefaultResampleType:int = GTextureResampleType.UP_CROP;
		static public function get defaultResampleType():int {
			return __iDefaultResampleType;
		}
		static public function set defaultResampleType(p_type:int):void {
			if (!GTextureResampleType.isValid(p_type)) throw new GError(GError.INVALID_RESAMPLE_TYPE);
			__iDefaultResampleType = p_type;
		}
		
		static public var defaultResampleScale:int = 1;
		
		static private var __iDefaultFilteringType:int = GTextureFilteringType.LINEAR;
		static public function get defaultFilteringType():int {
			return __iDefaultFilteringType;
		}
		static public function set defaultFilteringType(p_type:int):void {
			if (!GTextureFilteringType.isValid(p_type)) throw new GError(GError.INVALID_FILTERING_TYPE);
			__iDefaultFilteringType = p_type;
		}
		
		static private var __dReferences:Dictionary = new Dictionary();
		static public function getTextureBaseById(p_id:String):GTextureBase {
			return __dReferences[p_id];
		}
		
		static public function getGPUTextureCount():int {
			var count:int = 0;
			for each (var it:GTextureBase in __dReferences) {
				if (it.cContextTexture && !it.hasParent()) count++;
			}
			return count;
		}
		
		static public function getTextureCount():int {
			var count:int = 0;
			for each (var it:GTextureBase in __dReferences) {
				if (it is GTexture) count++;
			}
			return count;
		}
		
		static g2d function invalidate():void {
			for (var it:String in __dReferences) {
				(__dReferences[it] as GTextureBase).invalidateContextTexture(true);
			}
		}

		public function invalidate():void {
			invalidateContextTexture(false);
		}
		
		/**
		 * 	@private
		 */
		g2d var bdBitmapData:BitmapData;
		public function get bitmapData():BitmapData {
			return bdBitmapData;
		}
		
		/**
		 * 	@private
		 */
		g2d var baByteArray:ByteArray;
		
		protected var _iResampleType:int = defaultResampleType;
		public function get resampleType():int {
			return _iResampleType;
		}
		public function set resampleType(p_type:int):void {
			if (!GTextureResampleType.isValid(p_type)) throw new GError(GError.INVALID_RESAMPLE_TYPE);
			_iResampleType = p_type;
		}
		
		
		protected var _iResampleScale:int = defaultResampleScale;
		public function get resampleScale():int {
			return _iResampleScale;
		}
		public function set resampleScale(p_scale:int):void {
			_iResampleScale = (p_scale > 0) ? p_scale : 1;	
			invalidateContextTexture(false);
		}
		
		g2d var iFilteringType:int = __iDefaultFilteringType;
		public function get filteringType():int {
			return iFilteringType;
		}
		public function set filteringType(p_type:int):void {
			if (!GTextureFilteringType.isValid(p_type)) throw new GError(GError.INVALID_FILTERING_TYPE);
			iFilteringType = p_type;
		}		
		
		g2d var nSourceWidth:int;
		g2d var nSourceHeight:int;
		
		public var premultiplied:Boolean = true;
		/**
		 * 	@private
		 */
		g2d var iWidth:int;
		public function get width():int { return iWidth };
		public function get gpuWidth():int { return GTextureUtils.getNextValidTextureSize(iWidth) }
		/**
		 * 	@private
		 */
		g2d var iHeight:int;
		public function get height():int { return iHeight };
		public function get gpuHeight():int { return GTextureUtils.getNextValidTextureSize(iHeight) }
		
		public function hasParent():Boolean {
			return false;
		}
		
		protected var _sId:String;
		/**
		 * 	Id of this texture atlas
		 */
		public function get id():String {
			return _sId;
		}
		
		g2d var cContextTexture:GContextTexture;
		g2d var iSourceType:int;
		g2d var sAtfType:String = "";
		g2d var bTransparent:Boolean;
		protected var _fAsyncCallback:Function;
		
		g2d function getSource():* {
			switch (iSourceType) {
				case GTextureSourceType.BITMAPDATA:
					return bdBitmapData;
					break;
				case GTextureSourceType.ATF_COMPRESSED:
					return baByteArray;
					break;
				case GTextureSourceType.BYTEARRAY:
					return baByteArray;
					break;
			}
		}
	
		public function GTextureBase(p_id:String, p_sourceType:int, p_source:*, p_transparent:Boolean, p_asyncCallback:Function) {
			if (!Genome2D.getInstance().isInitialized()) throw new GError(GError.GENOME2D_NOT_INITIALIZED);
			if (p_id == null || p_id.length == 0) throw new GError(GError.INVALID_TEXTURE_ID);
			if (__dReferences[p_id] != null) throw new GError(GError.DUPLICATE_TEXTURE_ID, p_id);
			__dReferences[p_id] = this;
			
			_sId = p_id;
			iSourceType = p_sourceType;
			bTransparent = p_transparent;
			_fAsyncCallback = p_asyncCallback;
			
			switch (p_sourceType) {
				case GTextureSourceType.BITMAPDATA:
					bdBitmapData = p_source as BitmapData;
					premultiplied = true;
					break;
				case GTextureSourceType.ATF_BGRA:
					baByteArray = p_source as ByteArray;
					premultiplied = false;
					break;
				case GTextureSourceType.ATF_COMPRESSED:
					baByteArray = p_source as ByteArray;
					sAtfType = "dxt1";
					premultiplied = false;
					break;
				case GTextureSourceType.ATF_COMPRESSEDALPHA:
					baByteArray = p_source as ByteArray;
					sAtfType = "dxt5";
					premultiplied = false;
					break;
				case GTextureSourceType.BYTEARRAY:
					baByteArray = p_source as ByteArray;
					premultiplied = false;
					break;
			}
		}
		
		public var resampled:BitmapData;
		protected function invalidateContextTexture(p_reinitialize:Boolean):void {
            var format:String;
			switch (iSourceType) {
				case GTextureSourceType.BITMAPDATA:						
					//var resampled:BitmapData = GTextureUtils.resampleBitmapData(bdBitmapData, _iResampleType, resampleScale);
					resampled = GTextureUtils.resampleBitmapData(bdBitmapData, _iResampleType, resampleScale);
					
					if (cContextTexture == null || p_reinitialize || cContextTexture.iWidth != resampled.width || cContextTexture.iHeight != resampled.height) {
						if (cContextTexture) cContextTexture.dispose();
						format = Context3DTextureFormat.BGRA;
						if (alwaysUseCompressed) {
							format = (bTransparent) ? Context3DTextureFormat.COMPRESSED_ALPHA : Context3DTextureFormat.COMPRESSED;
							sAtfType = (bTransparent) ? "dxt5" : "dxt1";
						} else sAtfType = "";
						cContextTexture = Genome2D.getInstance().cContext.createTexture(resampled.width, resampled.height, format, false);
					}

					cContextTexture.uploadFromBitmapData(resampled);
					break;
				case GTextureSourceType.ATF_BGRA:
					if (cContextTexture == null || p_reinitialize || cContextTexture.iWidth != iWidth || cContextTexture.iHeight != iHeight) {
						if (cContextTexture) cContextTexture.dispose();
						cContextTexture = Genome2D.getInstance().cContext.createTexture(iWidth, iHeight, Context3DTextureFormat.BGRA, false);
						if (_fAsyncCallback != null) cContextTexture.tTexture.addEventListener("textureReady", onATFUploaded);
					}
					cContextTexture.uploadFromCompressedByteArray(baByteArray, 0, (_fAsyncCallback != null));
					break;
				case GTextureSourceType.ATF_COMPRESSED:
					if (cContextTexture == null || p_reinitialize || cContextTexture.iWidth != iWidth || cContextTexture.iHeight != iHeight) {
						if (cContextTexture) cContextTexture.dispose();
						cContextTexture = Genome2D.getInstance().cContext.createTexture(iWidth, iHeight, Context3DTextureFormat.COMPRESSED, false);
						if (_fAsyncCallback != null) cContextTexture.tTexture.addEventListener("textureReady", onATFUploaded);
						sAtfType = "dxt1";
					}
					cContextTexture.uploadFromCompressedByteArray(baByteArray, 0, (_fAsyncCallback != null));
					break;
				case GTextureSourceType.ATF_COMPRESSEDALPHA:
					if (cContextTexture == null || p_reinitialize || cContextTexture.iWidth != iWidth || cContextTexture.iHeight != iHeight) {
						if (cContextTexture) cContextTexture.dispose();
						cContextTexture = Genome2D.getInstance().cContext.createTexture(iWidth, iHeight, Context3DTextureFormat.COMPRESSED_ALPHA, false);
						if (_fAsyncCallback != null) cContextTexture.tTexture.addEventListener("textureReady", onATFUploaded);
						sAtfType = "dxt5";
					}
					cContextTexture.uploadFromCompressedByteArray(baByteArray, 0, (_fAsyncCallback != null));
					break;
				case GTextureSourceType.BYTEARRAY:
					if (cContextTexture == null || p_reinitialize || cContextTexture.iWidth != iWidth || cContextTexture.iHeight != iHeight) {
						if (cContextTexture) cContextTexture.dispose();
						format = Context3DTextureFormat.BGRA;
						if (alwaysUseCompressed) {
							format = (bTransparent) ? Context3DTextureFormat.COMPRESSED_ALPHA : Context3DTextureFormat.COMPRESSED;
							sAtfType = (bTransparent) ? "dxt5" : "dxt1";
						} else sAtfType = "";
						cContextTexture = Genome2D.getInstance().cContext.createTexture(iWidth, iHeight, format, false);
					}
					cContextTexture.uploadFromByteArray(baByteArray, 0);
					break;
				case GTextureSourceType.RENDER_TARGET:
					var validWidth:int = GTextureUtils.getNextValidTextureSize(iWidth);
					var validHeight:int = GTextureUtils.getNextValidTextureSize(iHeight);
					if (cContextTexture == null || p_reinitialize || cContextTexture.iWidth != validWidth || cContextTexture.iHeight != validHeight) {
						if (cContextTexture) cContextTexture.dispose();
						cContextTexture = Genome2D.getInstance().cContext.createTexture(validWidth, validHeight, Context3DTextureFormat.BGRA, true);
					}
					break;
			}
		}
		
		protected function onATFUploaded(event:Event):void {
			cContextTexture.tTexture.removeEventListener("textureReady", onATFUploaded);
			_fAsyncCallback(this);
			_fAsyncCallback = null;
		}
		
		public function dispose():void {			
			delete __dReferences[_sId];
		}
	}
}