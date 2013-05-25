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
	import com.genome2d.textures.GTexture;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;

	use namespace g2d;
	
	public class GPixelateFilter extends GFilter
	{	
		public var pixelSize:int = 1;
		
		public function GPixelateFilter(p_pixelSize:int) {
			super();
			
			bOverrideFragmentShader = true;
		
			fragmentCode = 	
				"div ft0, v0, fc1                       \n" +
				"frc ft1, ft0                           \n" +
				"sub ft0, ft0, ft1                      \n" +
				"mul ft1, ft0, fc1                      \n" +
				"add ft0.xy, ft1,xy, fc1.zw 			\n" +
				"tex oc, ft0, fs0<2d, clamp, nearest>"
				
			pixelSize = p_pixelSize;
		}
		
		override public function bind(p_context:Context3D, p_texture:GTexture):void {
			_aFragmentConstants = new <Number>[pixelSize/p_texture.gpuWidth, pixelSize/p_texture.gpuHeight, pixelSize/(p_texture.gpuWidth*2), pixelSize/(p_texture.gpuHeight*2)];
			
			super.bind(p_context, p_texture);
		}
	}
}