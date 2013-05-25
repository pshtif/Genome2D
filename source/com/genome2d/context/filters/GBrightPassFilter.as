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

	public class GBrightPassFilter extends GFilter
	{
		protected var _nTreshold:Number = .5;
		public function get treshold():Number {
			return _nTreshold;
		}
		public function set treshold(p_value:Number):void {
			_nTreshold = p_value;
			_aFragmentConstants[0] = _nTreshold;
			_aFragmentConstants[1] = 1/(1-_nTreshold);
		}
		
		public function GBrightPassFilter(p_treshold:Number) {
			super();
			
			fragmentCode = "sub ft0.xyz, ft0.xyz, fc1.xxx    \n" +
						   "mul ft0.xyz, ft0.xyz, fc1.yyy    \n" +
						   "sat ft0, ft0           			 \n";
			
			_aFragmentConstants = new <Number>[.5, 2, 0, 0];
			
			treshold = p_treshold;
		}
	}
}