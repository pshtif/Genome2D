/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.textures.factories
{
	import com.genome2d.error.GError;
	import com.genome2d.textures.GTexture;
	import com.genome2d.textures.GTextureSourceType;
	import com.genome2d.textures.GTextureUtils;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	public class GTextureFactory
	{
		/**
		 * 	Factory method that will create a G2DTexture instance from embedded bitmap asset
		 * 
		 * 	@param p_id id of a texture
		 * 	@param p_asset class of the embedded asset
		 */
		static public function createFromAsset(p_id:String, p_asset:Class):GTexture {
			var bitmap:Bitmap = new p_asset();
			
			return new GTexture(p_id, GTextureSourceType.BITMAPDATA, bitmap.bitmapData, bitmap.bitmapData.rect, GTextureUtils.isBitmapDataTransparent(bitmap.bitmapData));
		}
		
		/**
		 * 	Factory method that will create a G2DTexture instance from color and size
		 * 
		 * 	@param p_id id of a texture
		 * 	@param p_color color
		 *  @param p_width
		 *  @param p_height
		 */
		static public function createFromColor(p_id:String, p_color:uint, p_width:int, p_height:int):GTexture {
			var bitmapData:BitmapData = new BitmapData(p_width, p_height, false, p_color);
			
			return new GTexture(p_id, GTextureSourceType.BITMAPDATA, bitmapData, bitmapData.rect, false);
		}
		
		/**
		 * 	Helper function that will create a G2DTexture instance from bitmap data
		 * 
		 * 	@param p_id id of a texture
		 * 	@param p_bitmapData bitmap data
		 */
		static public function createFromBitmapData(p_id:String, p_bitmapData:BitmapData):GTexture {
			if (p_bitmapData == null) throw new GError(GError.NULL_BITMAPDATA);
			
			return new GTexture(p_id, GTextureSourceType.BITMAPDATA, p_bitmapData, p_bitmapData.rect, GTextureUtils.isBitmapDataTransparent(p_bitmapData));
		}
		
		/**
		 * 	Factory method that will create a G2DTexture instance from compressed byte array, this method is used to create textures from ATF format.
		 * 	
		 * 	@param p_id id of a texture
		 * 	@param p_compressedByteArray byte array storing ATF compressed data
		 */
		static public function createFromATF(p_id:String, p_atfData:ByteArray, p_uploadCallback:Function = null):GTexture {
			var atf:String = String.fromCharCode(p_atfData[0], p_atfData[1], p_atfData[2]);
			if (atf != "ATF") throw new GError(GError.INVALID_ATF_DATA);
			var type:int;
			var transparent:Boolean = true;
			switch (p_atfData[6]) {
				case 1:
					type = GTextureSourceType.ATF_BGRA;
					break;
				case 3:
					type = GTextureSourceType.ATF_COMPRESSED;
					transparent = false;
					break;
				case 5:
					type = GTextureSourceType.ATF_COMPRESSEDALPHA;
					break;
			}
			var width:int = Math.pow(2, p_atfData[7]);
			var height:int = Math.pow(2, p_atfData[8]);
			
			return new GTexture(p_id, type, p_atfData, new Rectangle(0, 0, width, height), transparent, 0, 0, p_uploadCallback);
		}
		
		static public function createFromByteArray(p_id:String, p_byteArray:ByteArray, p_width:int, p_height:int, p_transparent:Boolean):GTexture {
			return new GTexture(p_id, GTextureSourceType.BYTEARRAY, p_byteArray, new Rectangle(0,0,p_width, p_height), p_transparent);
		}
		
		static public function createRenderTexture(p_id:String, p_width:int, p_height:int, p_transparent:Boolean):GTexture {
			return new GTexture(p_id, GTextureSourceType.RENDER_TARGET, null, new Rectangle(0,0,p_width, p_height), p_transparent);
		}
	}
}