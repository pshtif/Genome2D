/*
 * 	Genome2D - GPU 2D framework utilizing Molehill API
 *
 *	Copyright 2012 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.context.postprocesses
{
	import com.genome2d.context.filters.GFilter;
	
	public class GFilterPP extends GPostProcess
	{
		public function GFilterPP(p_filters:Vector.<GFilter>) {
			super(p_filters.length);
			
			_aPassFilters = p_filters;
		}
	}
}