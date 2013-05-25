/*
 * 	Genome2D - GPU 2D framework utilizing Molehill API
 *
 *	Copyright 2012 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.context.filters
{
	
	public class GColorMatrixFilter extends GFilter
	{		
		static private const IDENTITY_MATRIX:Vector.<Number> = new <Number>[1,0,0,0,0,
																	 	    0,1,0,0,0,
																			0,0,1,0,0,
																			0,0,0,1,0];
		
		public function setMatrix(p_matrix:Vector.<Number>):void {
			_aFragmentConstants.unshift(p_matrix[0], p_matrix[1], p_matrix[2], p_matrix[3],
										p_matrix[5], p_matrix[6], p_matrix[7], p_matrix[8],
										p_matrix[10], p_matrix[11], p_matrix[12], p_matrix[13], 
										p_matrix[15], p_matrix[16], p_matrix[17], p_matrix[18],
										p_matrix[4]/255, p_matrix[9]/255, p_matrix[14]/255, p_matrix[19]/255,
										0,0,0,0.0001); 
			_aFragmentConstants.length = 24;
		}
		
		public function GColorMatrixFilter(p_matrix:Vector.<Number> = null) {
			super();
			
			setMatrix(p_matrix == null ? IDENTITY_MATRIX : p_matrix);	

			fragmentCode =	"max ft0, ft0, fc6             \n" +
							"div ft0.xyz, ft0.xyz, ft0.www \n" +
							"m44 ft0, ft0, fc1             \n" + 
							"add ft0, ft0, fc5             \n" +
							"mul ft0.xyz, ft0.xyz, ft0.www \n";
		}
	}
}