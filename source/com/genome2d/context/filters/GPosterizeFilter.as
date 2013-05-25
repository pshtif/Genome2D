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
	
	public class GPosterizeFilter extends GFilter
	{	
		public function GPosterizeFilter(p_red:int, p_green:int, p_blue:int) {
			super();
			
			fragmentCode = 	
				"mul ft0.xyz, ft0.xyz, fc1.xyz \n" +
				"frc ft1.xyz, ft0.xyz 		   \n" +
				"sub ft0.xyz, ft0.xyz, ft1.xyz \n" +
				"div ft0.xyz, ft0.xyz, fc1.xyz \n";
			
			_aFragmentConstants = new <Number>[0, 0, 0, 0];
			
			red = p_red;
			green = p_green;
			blue = p_blue;
		}
		
		protected var _iRed:int = 0;
		public function get red():int {
			return _iRed;
		}
		public function set red(p_value:int):void {
			_iRed = p_value;
			_aFragmentConstants[0] = _iRed;
		}
		
		protected var _iGreen:int = 0;
		public function get green():int {
			return _iGreen;
		}
		public function set green(p_value:int):void {
			_iGreen = p_value;
			_aFragmentConstants[1] = _iGreen;
		}
		
		protected var _iBlue:int = 0;
		public function get blue():int {
			return _iBlue;
		}
		public function set blue(p_value:int):void {
			_iBlue = p_value;
			_aFragmentConstants[2] = _iBlue;
		}
	}
}