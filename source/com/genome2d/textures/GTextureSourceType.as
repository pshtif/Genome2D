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
	
	public class GTextureSourceType
	{
		static public const ATF_BGRA:int = 0;
		static public const ATF_COMPRESSED:int = 1;
		static public const ATF_COMPRESSEDALPHA:int = 2;
		static public const BYTEARRAY:int = 2;
		static public const BITMAPDATA:int = 3;
		static public const RENDER_TARGET:int = 4;
		
		/**
		 * 	@private
		 */
		static g2d function isValid(p_type:int):Boolean {
			if (p_type == ATF_COMPRESSED || p_type == ATF_COMPRESSEDALPHA || p_type == BYTEARRAY || p_type == BITMAPDATA || p_type == RENDER_TARGET) return true;
			return false;
		}
		
		public function GTextureSourceType() {
			throw new GError(GError.CANNOT_INSTANTATE_ABSTRACT);
		}
	}
}