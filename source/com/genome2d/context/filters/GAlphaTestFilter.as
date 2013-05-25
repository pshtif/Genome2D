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
	
	public class GAlphaTestFilter extends GFilter
	{	
		protected var _nTreshold:Number = .5;
		public function get treshold():Number {
			return _nTreshold;
		}
		public function set treshold(p_value:Number):void {
			_nTreshold = p_value;
			_aFragmentConstants[0] = _nTreshold;
		}
		
		public function GAlphaTestFilter(p_treshold:Number) {
			super();
	
			fragmentCode = "sub ft1.w, ft0.w, fc1.x   \n" +
				           "kil ft1.w                 \n";
						   //"mov ft0.xyzw, fc1.wwww    \n";
			
			_aFragmentConstants = new <Number>[.5, 0, 0, 1];
			
			treshold = p_treshold;
		}
	}
}