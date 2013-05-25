/*
 * 	Genome2D - GPU 2D framework utilizing Molehill API
 *
 *	Copyright 2011 Peter Stefcek. All rights reserved.
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
	
	public class GDistortFilter extends GFilter
	{	
		public var redOffset:Number = 8;
		public var greenOffset:Number = 16;
		public var blueOffset:Number = 12;
		
		public var frequency:int = 40;
		
		public function GDistortFilter() {
			super();
			
			bOverrideFragmentShader = true;
			
			fragmentCode = 	"mul ft3, v0, fc2.x							\n" +   // Multiply UV by frequency
							"sin ft3, ft3								\n" +
							"mul ft4, ft3.y, fc1						\n" +   // Multiply by offsets
							"add ft0, v0, ft4.xwww 						\n" +   // Offset u for red
							"tex ft1, ft0, fs0 <2d,linear,mipnone,clamp>\n" +
							
							"add ft0, v0, ft4.ywww						\n" +   // Offset u for green
							"tex ft2, ft0, fs0 <2d,linear,mipnone,clamp>\n" +
							"mov ft1.y, ft2.xy							\n" +
							
							"add ft0, v0, ft4.zwww						\n" +   // Offset u for blue
							"tex ft2, ft0, fs0 <2d,linear,mipnone,clamp>\n" +
							"mov ft1.z, ft2.xyz							\n" +

							"mov oc, ft1";
			
			_aFragmentConstants = new <Number>[0.1, .05, 0.2, 0, 4, 0, 0, 0];
		}
		
		override public function bind(p_context:Context3D, p_texture:GTexture):void {
			var pixelSize:Number = 1/p_texture.gpuWidth;
			_aFragmentConstants = new <Number>[redOffset*pixelSize, greenOffset*pixelSize, blueOffset*pixelSize, 0, frequency, 0, 0, 0];
			
			super.bind(p_context, p_texture);
		}
	}
}