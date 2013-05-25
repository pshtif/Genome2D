/*
 * 	Genome2D - GPU 2D framework utilizing Molehill API
 *
 *	Copyright 2012 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.context.filters
{
	import com.genome2d.textures.GTexture;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;

	public class GRetroFilter extends GFilter
	{
		public function GRetroFilter() {
			super();
			
			fragmentCode = 
				"dp3 ft2.x, ft0.xyz, fc1.xyz    \n" +
				// overlay grey
				"sub ft3.xyz, fc1.www, ft2.xxx  \n" +
				"sub ft4.xyz, fc1.www, ft0.xyz  \n" +
				"mul ft3.xyz, ft3.xyz, ft4.xyz  \n" +
				"add ft3.xyz, ft3.xyz, ft3.xyz  \n" +
				"sub ft3.xyz, fc1.www, ft3.xyz  \n" +
				"mul ft4.xyz, ft2.xxx, ft0.xyz  \n" +
				"add ft4.xyz, ft4.xyz, ft4.xyz  \n" +
				"sge ft1.xyz, ft0.xyz, fc2.www  \n" +
				"slt ft5.xyz, ft0.xyz, fc2.www  \n" +
				"mul ft1.xyz, ft1.xyz, ft3.xyz  \n" +
				"mul ft5.xyz, ft5.xyz, ft4.xyz  \n" +
				"add ft1.xyz, ft1.xyz, ft5.xyz  \n" +
				// multiply
				"mul ft1.xyz, ft1.xyz, fc2.xyz  \n" +
				// screen
				"sub ft1.xyz, fc1.www, ft1.xyz  \n" +
				"mul ft1.xyz, fc3.xyz, ft1.xyz  \n" +
				"sub ft1.xyz, fc1.www, ft1.xyz  \n" +
				// screen
				"sub ft1.xyz, fc1.www, ft1.xyz  \n" +
				"mul ft1.xyz, fc4.xyz, ft1.xyz  \n" +
				"sub ft1.xyz, fc1.www, ft1.xyz  \n" +
				//out
				"mov ft0.xyz, ft1.xyz           \n";
			
			_aFragmentConstants = new <Number>[
				0.3, 0.59, 0.11, 1.0,
				251/255*0.588235, 242/255*0.588235, 163/255*0.588235, 0.5,
				1.-(232/255*0.2), 1.-(101/255*0.2), 1.-(179/255*0.2), 0,
				1.-(9/255*0.168627), 1.-(73/255*0.168627), 1.-(233/255*0.168627), 0
			];
		}
	}
}