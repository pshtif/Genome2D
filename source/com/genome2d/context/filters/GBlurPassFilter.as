/*
 * 	Genome2D - GPU 2D framework utilizing Molehill API
 *
 *	Copyright 2012 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.context.filters
{
	import com.genome2d.g2d;
	import com.genome2d.core.Genome2D;
	import com.genome2d.error.GError;
	import com.genome2d.textures.GTexture;
	
	import flash.display3D.Context3D;
	
	use namespace g2d;
	
	public class GBlurPassFilter extends GFilter
	{
		static public const VERTICAL:int = 0;
		static public const HORIZONTAL:int = 1;
		
		public var blur:Number = 0;
		public var direction:int = VERTICAL;
		
		public var colorize:Boolean = false;
		public var red:Number = 0;
		public var green:Number = 0;
		public var blue:Number = 0;
		public var alpha:Number = 1;
		
		public function GBlurPassFilter(p_blur:int, p_direction:int) {
			super();
			
			if (Genome2D.getInstance().cConfig.profile != "baseline") throw new GError(GError.CANNOT_RUN_IN_CONSTRAINED, GBlurPassFilter);
			
			bOverrideFragmentShader = true;
			
			fragmentCode =
				"tex ft0, v0, fs0 <2d,linear,mipnone,clamp>     \n" +
				"mul ft0.xyzw, ft0.xyzw, fc2.y                  \n" +
			
				"sub ft1.xy, v0.xy, fc1.xy                      \n" +
				"tex ft2, ft1.xy, fs0 <2d,linear,mipnone,clamp> \n" +
				"mul ft2.xyzw, ft2.xyzw, fc2.z                  \n" +
				"add ft0, ft0, ft2                              \n" +
				
				"add ft1.xy, v0.xy, fc1.xy                      \n" +
				"tex ft2, ft1.xy, fs0 <2d,linear,mipnone,clamp> \n" +
				"mul ft2.xyzw, ft2.xyzw, fc2.z                  \n" +
				"add ft0, ft0, ft2                              \n" +
				
				"sub ft1.xy, v0.xy, fc1.zw                      \n" +
				"tex ft2, ft1.xy, fs0 <2d,linear,mipnone,clamp> \n" +
				"mul ft2.xyzw, ft2.xyzw, fc2.w                  \n" +
				"add ft0, ft0, ft2                              \n" +
				
				"add ft1.xy, v0.xy, fc1.zw                      \n" +
				"tex ft2, ft1.xy, fs0 <2d,linear,mipnone,clamp> \n" +
				"mul ft2.xyzw, ft2.xyzw, fc2.w                  \n" +
				"add ft0, ft0, ft2                              \n" +
				
				"mul ft0.xyz, ft0.xyz, fc2.xxx					\n" +
				"mul ft1.xyz, ft0.www, fc3.xyz					\n" +
				"add ft0.xyz, ft0.xyz, ft1.xyz					\n" +
				"mul oc, ft0, fc3.wwww							\n";
			
			_aFragmentConstants = new <Number>[0, 0, 0, 0, 1, 0.2270270270, 0.3162162162, 0.0702702703, 0, 0, 0, 1];
			
			blur = p_blur;
			direction = p_direction;
		}
		
		override public function bind(p_context:Context3D, p_texture:GTexture):void {
			// We do invalidation each bind as the texture parameters are crucial for constants
			if (direction == HORIZONTAL) {
				_aFragmentConstants[0] = 1/p_texture.gpuWidth * 1.3846153846 * blur * .5;
				_aFragmentConstants[1] = 0;
				_aFragmentConstants[2] = 1/p_texture.gpuWidth * 3.2307692308 * blur * .5;
				_aFragmentConstants[3] = 0;
			} else {
				_aFragmentConstants[0] = 0;
				_aFragmentConstants[1] = 1/p_texture.gpuHeight * 1.3846153846 * blur * .5;
				_aFragmentConstants[2] = 0;
				_aFragmentConstants[3] = 1/p_texture.gpuHeight * 3.2307692308 * blur * .5;
			}
			
			_aFragmentConstants[4] = (colorize) ? 0 : 1;
			
			_aFragmentConstants[8] = red;
			_aFragmentConstants[9] = green;
			_aFragmentConstants[10] = blue;
			_aFragmentConstants[11] = alpha;
			
			super.bind(p_context, p_texture);
		}
	}
}