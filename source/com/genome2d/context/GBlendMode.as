/*
 * 	Genome2D - GPU 2D framework utilizing Molehill API
 *
 *	Copyright 2012 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.context
{
	import com.genome2d.g2d;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	
	use namespace g2d;

	public class GBlendMode
	{
        // Available blend factor combinations alpha/nonalpha
		private static var blendFactors:Array = [
			[
				[Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO],
				[Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA],
				[Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.DESTINATION_ALPHA],
				[Context3DBlendFactor.DESTINATION_COLOR, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA],
				[Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE],
				[Context3DBlendFactor.ZERO, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA],
			],
			[ 
				[Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO],
				[Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA],
				[Context3DBlendFactor.ONE, Context3DBlendFactor.ONE],
				[Context3DBlendFactor.DESTINATION_COLOR, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA],
				[Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR],
				[Context3DBlendFactor.ZERO, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA],
			]
		];
		
		static public const NONE:int = 0;
		static public const NORMAL:int = 1;
		static public const ADD:int = 2;
		static public const MULTIPLY:int = 3;
		static public const SCREEN:int = 4;
		static public const ERASE:int = 5;

        // Add custom blend factor combinations
		static public function addBlendMode(p_normalFactors:Array, p_premultipliedFactors:Array):int { 
			blendFactors[0].push(p_normalFactors);
			blendFactors[1].push(p_premultipliedFactors);
			
			return blendFactors[0].length;
		}

        /**
         * 	@private
         */
		static g2d function setBlendMode(p_context:Context3D, p_mode:int, p_premultiplied:Boolean):void {
			p_context.setBlendFactors(blendFactors[int(p_premultiplied)][p_mode][0], blendFactors[int(p_premultiplied)][p_mode][1]);
		}
	}
}