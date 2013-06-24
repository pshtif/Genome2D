/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.components.particles
{
	import com.genome2d.components.GComponent;
	import com.genome2d.core.GNode;
	import com.genome2d.g2d;

	use namespace g2d;
	
	public class GParticle extends GComponent
	{
		/**
		 * 	@private
		 */
		g2d var nVelocityX:Number = 0;
		/**
		 * 	@private
		 */
		g2d var nVelocityY:Number = 0;
		
		g2d var nAccelerationX:Number;
		g2d var nAccelerationY:Number;
		
		protected var _nEnergy:Number = 0;
		
		protected var _nInitialScale:Number = 1;
		protected var _nEndScale:Number = 1;
		
		protected var _nInitialVelocityX:Number;
		protected var _nInitialVelocityY:Number;
		protected var _nInitialVelocityAngular:Number;
		
		protected var _nInitialAccelerationX:Number;
		protected var _nInitialAccelerationY:Number;
		
		protected var _nInitialRed:Number;
		protected var _nInitialGreen:Number;
		protected var _nInitialBlue:Number;
		protected var _nInitialAlpha:Number;
		
		protected var _nEndRed:Number;
		protected var _nEndGreen:Number;
		protected var _nEndBlue:Number;
		protected var _nEndAlpha:Number;
		/**
		 * 	@private
		 */
		g2d var cEmitter:GEmitter;
		protected var _nAccumulatedEnergy:Number = 0;
		
		override public function set active(p_value:Boolean):void {
			_bActive = p_value;
			_nAccumulatedEnergy = 0;
		}
		
		/**
		 * 	@private
		 */
		public function GParticle(p_node:GNode) {
			super(p_node);
		}
		
		g2d function init(p_invalidate:Boolean = true):void {
			_nEnergy = (cEmitter.energy + cEmitter.energyVariance * Math.random()) * 1000;
			if (cEmitter.energyVariance>0) _nEnergy += cEmitter.energyVariance * Math.random();
			
			_nInitialScale = cEmitter.initialScale;
			if (cEmitter.initialScaleVariance>0) _nInitialScale += cEmitter.initialScaleVariance*Math.random();
			_nEndScale = cEmitter.endScale;
			if (cEmitter.endScaleVariance>0) _nEndScale += cEmitter.endScaleVariance*Math.random();
			
			var sin:Number = Math.sin(cEmitter.cNode.transform.nWorldRotation);
			var cos:Number = Math.cos(cEmitter.cNode.transform.nWorldRotation);
			
			var particleVelocityX:Number;
			var particleVelocityY:Number;
			var v:Number = cEmitter.initialVelocity;
			if (cEmitter.initialVelocityVariance>0) v += cEmitter.initialVelocityVariance * Math.random();
			
			var particleAccelerationX:Number;
			var particleAccelerationY:Number;
			var a:Number = cEmitter.initialAcceleration;
			if (cEmitter.initialAccelerationVariance>0) a += cEmitter.initialAccelerationVariance * Math.random();
			
			var vX:Number = particleVelocityX = v*cos;
			var vY:Number = particleVelocityY = v*sin;
			var aX:Number = particleAccelerationX = a*cos;
			var aY:Number = particleAccelerationY = a*sin;
			
			if (cEmitter.dispersionAngle!=0 || cEmitter.dispersionAngleVariance!=0) {
				var rangle:Number = cEmitter.dispersionAngle;
				if (cEmitter.dispersionAngleVariance>0) rangle += cEmitter.dispersionAngleVariance * Math.random();
				
				sin = Math.sin(rangle);
				cos = Math.cos(rangle);
				
				particleVelocityX = (vX*cos - vY*sin);
				particleVelocityY = (vY*cos + vX*sin);
				particleAccelerationX = (aX*cos - aY*sin);
				particleAccelerationY = (aY*cos + aX*sin);
			}
			
			_nInitialVelocityX = nVelocityX = particleVelocityX * .001;
			_nInitialVelocityY = nVelocityY = particleVelocityY * .001;
			_nInitialAccelerationX = nAccelerationX = particleAccelerationX * .001;
			_nInitialAccelerationY = nAccelerationY = particleAccelerationY * .001;
			 
			_nInitialVelocityAngular = cEmitter.angularVelocity;
			if (cEmitter.angularVelocityVariance>0) _nInitialVelocityAngular += cEmitter.angularVelocityVariance * Math.random();
			
			_nInitialRed = cEmitter.initialRed;
			if (cEmitter.initialRedVariance>0) _nInitialRed += cEmitter.initialRedVariance * Math.random(); 
			_nInitialGreen = cEmitter.initialGreen;
			if (cEmitter.initialGreenVariance>0) _nInitialGreen += cEmitter.initialGreenVariance * Math.random();
			_nInitialBlue = cEmitter.initialBlue;
			if (cEmitter.initialBlueVariance>0) _nInitialBlue += cEmitter.initialBlueVariance * Math.random();
			_nInitialAlpha = cEmitter.initialAlpha;
			if (cEmitter.initialAlphaVariance>0) _nInitialAlpha += cEmitter.initialAlphaVariance * Math.random();
			
			_nEndRed = cEmitter.endRed;
			if (cEmitter.endRedVariance>0) _nEndRed += cEmitter.endRedVariance * Math.random(); 
			_nEndGreen = cEmitter.endGreen;
			if (cEmitter.endGreenVariance>0) _nEndGreen += cEmitter.endGreenVariance * Math.random();
			_nEndBlue = cEmitter.endBlue;
			if (cEmitter.endBlueVariance>0) _nEndBlue += cEmitter.endBlueVariance * Math.random();
			_nEndAlpha = cEmitter.endAlpha;
			if (cEmitter.endAlphaVariance>0) _nEndAlpha += cEmitter.endAlphaVariance * Math.random();
		}
		
		/**
		 * 	@private
		 *
		g2d function init2(p_energy:Number, p_velX:Number, p_velY:Number, p_velAngular:Number, p_initialScale:Number, p_endScale:Number, p_initialRed:Number, p_initialGreen:Number, p_initialBlue:Number, p_initialAlpha:Number, p_endRed:Number, p_endGreen:Number, p_endBlue:Number, p_endAlpha:Number):void {
			_nEnergy = p_energy;
			_nInitialVelX = nVelocityX = p_velX;
			_nInitialVelY = nVelocityY = p_velY;
			_nInitialVelAngular = p_velAngular;
			
			_nInitialScale = p_initialScale;
			_nEndScale = p_endScale;
			
			_nInitialRed = p_initialRed;
			_nInitialGreen = p_initialGreen;
			_nInitialBlue = p_initialBlue;
			_nInitialAlpha = p_initialAlpha;
			
			_nEndRed = p_endRed;
			_nEndGreen = p_endGreen;
			_nEndBlue = p_endBlue;
			_nEndAlpha = p_endAlpha;
		}
		/**/
		override public function update(p_deltaTime:Number, p_parentTransformUpdate:Boolean, p_parentColorUpdate:Boolean):void {
			_nAccumulatedEnergy += p_deltaTime;
			
			if (_nAccumulatedEnergy >= _nEnergy) {
				cNode.active = false;
				return;
			}

			for (var i:int=0; i<cEmitter.iFieldsCount; ++i) {
				cEmitter.aFields[i].updateParticle(this, p_deltaTime);
			}
			
			var p:Number = _nAccumulatedEnergy/_nEnergy;
			nVelocityX += nAccelerationX*p_deltaTime;
			nVelocityY += nAccelerationY*p_deltaTime;
			
			// Maybe precalculate differences? That however would be memory overhead as its 4 numbers in each particle instance which can go to tens of thousands.
			cNode.cTransform.red = (_nEndRed - _nInitialRed)*p + _nInitialRed;
			cNode.cTransform.green = (_nEndGreen - _nInitialGreen)*p + _nInitialGreen;
			cNode.cTransform.blue = (_nEndBlue - _nInitialBlue)*p + _nInitialBlue;
			cNode.cTransform.alpha = (_nEndAlpha - _nInitialAlpha)*p + _nInitialAlpha;			
			
			cNode.cTransform.x += nVelocityX * p_deltaTime;
			cNode.cTransform.y += nVelocityY * p_deltaTime;
			
			cNode.cTransform.rotation += _nInitialVelocityAngular * p_deltaTime;
			cNode.cTransform.scaleX = cNode.cTransform.scaleY = (_nEndScale - _nInitialScale)*p + _nInitialScale;
			/**/
		}
	}
}