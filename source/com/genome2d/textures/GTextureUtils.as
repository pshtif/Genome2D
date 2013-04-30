/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.textures
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;

	public class GTextureUtils
	{
		static private const ZERO_POINT:Point = new Point;
		
		static public function isBitmapDataTransparent(p_bitmapData:BitmapData):Boolean {
			return p_bitmapData.getColorBoundsRect(0xFF000000, 0xFF000000, false).width != 0;
		}
		
		static public function isValidTextureSize(p_size:int):Boolean {
			var size:int = 1;
			while (size < p_size) size*=2;

			return (size == p_size);			
		}
		
		static public function getNextValidTextureSize(p_size:int):int {
			var size:int = 1;
			while (p_size > size) size*=2;
			return size;
		}
		
		static public function getPreviousValidTextureSize(p_size:int):int {
			var size:int = 1;
			while (p_size > size) size*=2;
			size/=2;			
			return size;
		}
		
		static public function getNearestValidTextureSize(p_size:int):int {
			var previous:int = getPreviousValidTextureSize(p_size);
			var next:int = getNextValidTextureSize(p_size);
			
			return (p_size-previous < next-p_size) ? previous : next; 
		}
		
		static public function resampleBitmapData(p_bitmapData:BitmapData, p_resampleType:int, p_resampleScale:int):BitmapData {
			var bitmapWidth:int = p_bitmapData.width;
			var bitmapHeight:int = p_bitmapData.height;

			var validWidth:int;
			var validHeight:int;
			
			switch (p_resampleType) {
				case GTextureResampleType.UP_CROP:
				case GTextureResampleType.UP_RESAMPLE:
					validWidth = getNextValidTextureSize(bitmapWidth);
					validHeight = getNextValidTextureSize(bitmapHeight);
					break;
				case GTextureResampleType.DOWN_RESAMPLE:
					validWidth = getPreviousValidTextureSize(bitmapWidth);
					validHeight = getPreviousValidTextureSize(bitmapHeight);
					break;
				case GTextureResampleType.NEAREST_RESAMPLE:
				case GTextureResampleType.NEAREST_DOWN_RESAMPLE_UP_CROP:
					validWidth = getNearestValidTextureSize(bitmapWidth);
					validHeight = getNearestValidTextureSize(bitmapHeight);
					break;
			}

			if (validWidth == bitmapWidth && validHeight == bitmapHeight && p_resampleScale == 1) return p_bitmapData;
			
			var resampled:BitmapData;
			var resampleMatrix:Matrix;
			
			switch (p_resampleType) {
				case GTextureResampleType.UP_CROP:
					resampleMatrix = new Matrix();
					resampleMatrix.scale(1/p_resampleScale, 1/p_resampleScale);
					resampled = new BitmapData(validWidth/p_resampleScale, validHeight/p_resampleScale, true, 0x0);
					
					if (p_resampleScale == 1) resampled.copyPixels(p_bitmapData, p_bitmapData.rect, ZERO_POINT);
						else resampled.draw(p_bitmapData, resampleMatrix);
					break;
				case GTextureResampleType.UP_RESAMPLE:
				case GTextureResampleType.DOWN_RESAMPLE:
				case GTextureResampleType.NEAREST_RESAMPLE:
					resampleMatrix = new Matrix();
					resampleMatrix.scale(validWidth/(bitmapWidth * p_resampleScale), validHeight/(bitmapHeight * p_resampleScale));
					
					resampled = new BitmapData(validWidth/p_resampleScale, validHeight/p_resampleScale, true, 0x0);
					resampled.draw(p_bitmapData, resampleMatrix);
					break;
				case GTextureResampleType.NEAREST_DOWN_RESAMPLE_UP_CROP:
					resampleMatrix = new Matrix();

					var scaleX:Number = validWidth/bitmapWidth;
					var scaleY:Number = validHeight/bitmapHeight;
					var scale:Number = (scaleX>scaleY) ? scaleY : scaleX;
					resampleMatrix.scale(scale/p_resampleScale, scale/p_resampleScale);

					resampled = new BitmapData(validWidth/p_resampleScale, validHeight/p_resampleScale, true, 0x0);
					resampled.draw(p_bitmapData, resampleMatrix);
					break;
			}
			
			return resampled;			
		}
	}
}