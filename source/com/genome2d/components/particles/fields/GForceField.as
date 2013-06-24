package com.genome2d.components.particles.fields
{
	import com.genome2d.components.particles.GParticle;
	import com.genome2d.components.particles.GSimpleParticle;
	import com.genome2d.core.GNode;
	import com.genome2d.g2d;
	
	use namespace g2d;
	
	public class GForceField extends GField
	{
		public var radius:Number = 0;
		
		public var forceX:Number = 0;
		public var forceXVariance:Number = 0;
		public var forceY:Number = 0;
		public var forceYVariance:Number = 0;
		
		public function GForceField(p_node:GNode) {
			super(p_node);
		}
		
		override public function updateParticle(p_particle:GParticle, p_deltaTime:Number):void {
			if (!_bActive) return;

			var distanceX:Number = cNode.cTransform.nWorldX - p_particle.cNode.cTransform.nWorldX;
			var distanceY:Number = cNode.cTransform.nWorldY - p_particle.cNode.cTransform.nWorldY;
			var distanceSq:Number = distanceX*distanceX+distanceY*distanceY;
			if (distanceSq>radius*radius && radius>0) return;
			//var distance:Number = Math.sqrt(distanceSq);

			p_particle.nVelocityX += forceX * .001 * p_deltaTime;
			p_particle.nVelocityY += forceY * .001 * p_deltaTime;
		}
		
		override public function updateSimpleParticle(p_particle:GSimpleParticle, p_deltaTime:Number):void {
			if (!_bActive) return;

			var distanceX:Number = cNode.cTransform.nWorldX - p_particle.nX;
			var distanceY:Number = cNode.cTransform.nWorldY - p_particle.nY;
			var distanceSq:Number = distanceX*distanceX+distanceY*distanceY;
			if (distanceSq>radius*radius && radius>0) return;
			//var distance:Number = Math.sqrt(distanceSq);

			p_particle.nVelocityX += forceX * .001 * p_deltaTime;
			p_particle.nVelocityY += forceY * .001 * p_deltaTime;
		}
	}
}