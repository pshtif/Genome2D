package com.genome2d.components.particles.fields
{
	import com.genome2d.components.particles.GParticle;
	import com.genome2d.components.particles.GSimpleParticle;
	import com.genome2d.core.GNode;
	import com.genome2d.g2d;
	
	use namespace g2d;
	
	public class GGravityField extends GField
	{
		public var radius:Number = -1;
		
		public var gravity:Number = 0;
		public var gravityVariance:Number = 0;
		public var inverseGravity:Boolean = false;
		
		public function GGravityField(p_node:GNode)
		{
			super(p_node);
		}
		
		override public function updateParticle(p_particle:GParticle, p_deltaTime:Number):void {		
			if (!_bActive) return;
			
			var distanceX:Number = cNode.cTransform.nWorldX - p_particle.cNode.cTransform.nWorldX;
			var distanceY:Number = cNode.cTransform.nWorldY - p_particle.cNode.cTransform.nWorldY;
			var distanceSq:Number = distanceX*distanceX+distanceY*distanceY; 
			//var gravityLength:Number = Math.sqrt(gravityVectorX*gravityVectorX+gravityVectorY*gravityVectorY);
			if (distanceSq>radius*radius && radius>0) return;
			if (distanceSq!=0) {
				var distance:Number = Math.sqrt(distanceSq);
				distanceX /= (inverseGravity) ? -distance : distance;
				distanceY /= (inverseGravity) ? -distance : distance;
			}
			
			var g:Number = gravity;
			if (gravityVariance>0) g += gravityVariance * Math.random();
			
			p_particle.nVelocityX += g * distanceX *.001 * p_deltaTime;
			p_particle.nVelocityY += g * distanceY *.001 * p_deltaTime;
		}
		
		override public function updateSimpleParticle(p_particle:GSimpleParticle, p_deltaTime:Number):void {
			if (!_bActive) return;
			
			var distanceX:Number = cNode.cTransform.nWorldX - p_particle.nX;
			var distanceY:Number = cNode.cTransform.nWorldY - p_particle.nY;
			var distanceSq:Number = distanceX*distanceX+distanceY*distanceY; 
			//var gravityLength:Number = Math.sqrt(gravityVectorX*gravityVectorX+gravityVectorY*gravityVectorY);
			if (distanceSq>radius*radius && radius>0) return;
			if (distanceSq!=0) {
				var distance:Number = Math.sqrt(distanceSq);
				distanceX /= (inverseGravity) ? -distance : distance;
				distanceY /= (inverseGravity) ? -distance : distance;
			}
			
			var g:Number = gravity;
			if (gravityVariance>0) g += gravityVariance * Math.random();
			
			p_particle.nVelocityX += g * distanceX *.001 * p_deltaTime;
			p_particle.nVelocityY += g * distanceY *.001 * p_deltaTime;
		}
	}
}