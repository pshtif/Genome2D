/*
 * 	Genome2D - GPU 2D framework utilizing Molehill API
 *
 *	Copyright 2012 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.context.postprocesses
{
	import com.genome2d.components.GCamera;
	import com.genome2d.context.GContext;
	import com.genome2d.context.filters.GFilter;
	import com.genome2d.core.GNode;
	import com.genome2d.textures.GTexture;
	
	import flash.geom.Rectangle;
	
	public class GComposedPP extends GPostProcess
	{
		protected var _cEmptyPass:GFilterPP;
		protected var _aPostProcesses:Vector.<GPostProcess>;
		
		public function GComposedPP(p_postProcesses:Vector.<GPostProcess>) {
			super(p_postProcesses.length+1);
			
			throw new Error("Not supported yet.");
			
			_cEmptyPass = new GFilterPP(new <GFilter>[null]);
			_aPostProcesses = p_postProcesses;
		}
		
		override public function render(p_context:GContext, p_camera:GCamera, p_maskRect:Rectangle, p_node:GNode, p_bounds:Rectangle = null, p_source:GTexture = null, p_target:GTexture = null):void {	
			var bounds:Rectangle = (_rDefinedBounds) ? _rDefinedBounds : p_node.getWorldBounds(_rActiveBounds);
			
			// Invalid bounds
			if (bounds.x == Number.MAX_VALUE) return;

			updatePassTextures(bounds);
			
			_cEmptyPass.render(p_context, p_camera, p_maskRect, p_node, bounds, null, _aPassTextures[0]);
			var count:int = _aPostProcesses.length;
			for (var i:int=0; i<count-1; ++i) {
				_aPostProcesses[i].render(p_context, p_camera, p_maskRect, p_node, bounds, _aPassTextures[i], _aPassTextures[i+1]);
			}
			
			_aPostProcesses[count-1].render(p_context, p_camera, p_maskRect, p_node, bounds, _aPassTextures[count-1], null);
		}
	}
}