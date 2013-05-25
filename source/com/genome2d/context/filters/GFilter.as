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
	
	public class GFilter
	{
		public var fragmentCode:String;
		protected var _aFragmentConstants:Vector.<Number>;
		
		g2d var sId:String;
		g2d var bOverrideFragmentShader:Boolean = false;
		
		public function GFilter() {
			sId = String(this["constructor"]);
			_aFragmentConstants = new Vector.<Number>();
		}
		
		public function bind(p_context:Context3D, p_texture:GTexture):void {
			p_context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, _aFragmentConstants, _aFragmentConstants.length/4);
		}
		
		public function clear(p_context:Context3D):void {}
	}
}