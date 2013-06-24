/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.components.particles.fields
{
	import com.genome2d.components.GComponent;
	import com.genome2d.components.particles.GParticle;
	import com.genome2d.components.particles.GSimpleParticle;
	import com.genome2d.core.GNode;
	import com.genome2d.g2d;
	
	use namespace g2d;
	
	/**
	 * 	A GField class is a super class for all particle system fields classes containing abstract methods
	 */
	public class GField extends GComponent
	{
		protected var _bUpdateParticles:Boolean = true;
		
		/**
		 * 	@private
		 */
		public function GField(p_node:GNode) {
			super(p_node);
		}

		/**
		 * 	Update a specific particle in time this method is called by the GEmitter and should be overriden for custom behavior
		 * 
		 *  @param p_particle a particle instance to be updated
		 *  @param p_deltaTime an amount of time in simulation step
		 */
		public function updateParticle(p_particle:GParticle, p_deltaTime:Number):void {
		}
		
		/**
		 * 	Update a specific simple particle in time this method is called by GSimpleEmitter and should be override for custom behavior
		 * 
		 *  @param p_particle a particle instance to be updated
		 *  @param p_deltaTime an amount of time in simulation step
		 */
		public function updateSimpleParticle(p_particle:GSimpleParticle, p_deltaTime:Number):void {
		}
	}
}