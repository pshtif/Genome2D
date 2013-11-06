/*
 * 	Genome2D - GPU 2D framework utilizing Molehill API
 *
 *	Copyright 2012 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.context.filters
{
	import com.genome2d.error.GError;
	import com.genome2d.g2d;
	import com.genome2d.textures.GTexture;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	
	use namespace g2d;

	public class GBloomPassFilter extends GFilter
	{
		public var texture:GTexture;
		
		public function GBloomPassFilter() {
			super();
			
			fragmentCode = 
				"tex ft1, v0, fs1 <2d,linear,mipnone,clamp>	\n" +
				"dp3 ft2.x, ft0.xyz, fc1.xyz                \n" +
				"sub ft3.xyz, ft0.xyz, ft2.xxx              \n" +
				"mul ft3.xyz, ft3.xyz, fc2.zzz              \n" +
				"add ft3.xyz, ft3.xyz, ft2.xxx              \n" +
				"mul ft0.xyz, ft3.xytz, fc2.xxx             \n" +
				"dp3 ft2.x, ft1.xyz, fc1.xyz                \n" +
				"sub ft3.xyz, ft1.xyz, ft2.xxx              \n" +
				"mul ft3.xyz, ft3.xyz, fc2.www              \n" +
				"add ft3.xyz, ft3.xyz, ft2.xxx              \n" +
				"mul ft1.xyz, ft3.xyz, fc2.yyy              \n" +
				"sat ft2.xyz, ft0.xyz                       \n" +
				"sub ft2.xyz, fc0.yyy, ft2.xyz              \n" +
				"mul ft1.xyz, ft1.xyz, ft2.xyz              \n" +
				"add ft0, ft0, ft1              			\n";
			
			_aFragmentConstants = new <Number>[0.3, 0.59, 0.11, 1, 1.25, 1, 1, 1];
		}
		
		override public function bind(p_context:Context3D, p_texture:GTexture):void {
			super.bind(p_context, p_texture);
			if (texture == null) throw GError("There is no texture set for bloom pass.");
			p_context.setTextureAt(1, texture.cContextTexture.tTexture);
		}
		
		override public function clear(p_context:Context3D):void {
			p_context.setTextureAt(1, null);
		}
	}
}