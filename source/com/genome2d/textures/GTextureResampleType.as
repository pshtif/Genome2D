/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.textures
{
	import com.genome2d.error.GError;
	import com.genome2d.g2d;

	use namespace g2d;
	
	public class GTextureResampleType
	{
		static public const NEAREST_RESAMPLE:int = 0;
		static public const NEAREST_DOWN_RESAMPLE_UP_CROP:int = 1;
		static public const UP_CROP:int = 2;
		static public const UP_RESAMPLE:int = 3;
		static public const DOWN_RESAMPLE:int = 4;
		static public const NEAREST_RESAMPLE_WIDTH:int = 5;
		static public const NEAREST_RESAMPLE_HEIGHT:int = 6;
		
		/**
		 * 	@private
		 */
		static g2d function isValid(p_type:int):Boolean {
			if (p_type == NEAREST_RESAMPLE || p_type == NEAREST_DOWN_RESAMPLE_UP_CROP || p_type == UP_CROP || p_type == UP_RESAMPLE || p_type == DOWN_RESAMPLE) return true;
			return false;
		}
		
		public function GTextureResampleType() {
			throw new GError(GError.CANNOT_INSTANTATE_ABSTRACT);
		}
	}
}