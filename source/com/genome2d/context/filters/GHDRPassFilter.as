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

	public class GHDRPassFilter extends GFilter
	{		
		public var texture:GTexture;
		
		private var _nSaturation:Number = 1.3;
		public function get saturation():Number {
			return _nSaturation;
		}
		public function set saturation(p_value:Number):void {
			_nSaturation = p_value;
			_aFragmentConstants[4] = _nSaturation;
		}
		
		public function GHDRPassFilter(p_saturation:Number = 1.3) {
			super();
			
			fragmentCode = 
				"tex ft1, v0, fs1 <2d,linear,mipnone,clamp>	\n" + // original
				
				"sub ft0.xyz, fc1.www, ft0.xyz               \n" +
				"add ft0.xyz, ft1.xyz, ft0.xyz               \n" +
				"sub ft0.xyz, ft0.xyz, fc2.yyy               \n" +
				"sat ft0.xyz, ft0.xyz                        \n" +
				// boost original saturation
				"dp3 ft2.x, ft1.xyz, fc1.xyz                \n" +
				"sub ft1.xyz, ft1.xyz, ft2.xxx                \n" +
				"mul ft1.xyz, ft1.xyz, fc2.xxx                \n" +
				"add ft1.xyz, ft1.xyz, ft2.xxx                \n" +
				// merge result

				"add ft0.xyz, ft0.xyz, ft1.xyz               \n" +
				"sub ft0.xyz, ft0.xyz, fc2.yyy               \n"
				
			_aFragmentConstants = new <Number>[0.2125, 0.7154, 0.0721, 1.0, p_saturation, 0.5, 0, 0];
			
			_nSaturation = p_saturation;
		}
		
		override public function bind(p_context:Context3D, p_texture:GTexture):void {
			super.bind(p_context, p_texture);
			if (texture == null) throw GError("There is no texture set for HDR pass.");
			p_context.setTextureAt(1, texture.cContextTexture.tTexture);
		}
		
		override public function clear(p_context:Context3D):void {
			p_context.setTextureAt(1, null);
		}
	}
}