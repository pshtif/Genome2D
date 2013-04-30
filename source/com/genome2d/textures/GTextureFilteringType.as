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
	
	public class GTextureFilteringType
	{
		static public const NEAREST:int = 0;
		static public const LINEAR:int = 1;
		
		/**
		 * 	@private
		 */
		static g2d function isValid(p_type:int):Boolean {
			if (p_type == NEAREST || p_type == LINEAR) return true;
			return false;
		}
		
		public function GTextureFilteringType() {
			throw new GError(GError.CANNOT_INSTANTATE_ABSTRACT);
		}
	}
}