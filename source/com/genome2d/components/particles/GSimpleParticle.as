/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.components.particles
{
	import com.genome2d.g2d;

	use namespace g2d;
	
	public class GSimpleParticle
	{
		/**
		 * 	@private
		 */
		g2d var cNext:GSimpleParticle;
		/**
		 * 	@private
		 */
		g2d var cPrevious:GSimpleParticle;
		g2d var nX:Number;
		g2d var nY:Number;
		g2d var nRotation:Number;
		g2d var nScaleX:Number;
		g2d var nScaleY:Number;
		g2d var nRed:Number;
		g2d var nGreen:Number;
		g2d var nBlue:Number;
		g2d var nAlpha:Number;
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
		
		g2d var nEnergy:Number = 0;
		
		g2d var nInitialScale:Number = 1;
		g2d var nEndScale:Number = 1;
		
		g2d var nInitialVelocityX:Number;
		g2d var nInitialVelocityY:Number;
		g2d var nInitialVelocityAngular:Number;
		
		g2d var nInitialAccelerationX:Number;
		g2d var nInitialAccelerationY:Number;
		
		g2d var nInitialRed:Number;
		g2d var nInitialGreen:Number;
		g2d var nInitialBlue:Number;
		g2d var nInitialAlpha:Number;
		
		g2d var nEndRed:Number;
		g2d var nEndGreen:Number;
		g2d var nEndBlue:Number;
		g2d var nEndAlpha:Number;
		
		private var __nRedDif:Number;
		private var __nGreenDif:Number;
		private var __nBlueDif:Number;
		private var __nAlphaDif:Number;
		
		private var __nScaleDif:Number;
		
		g2d var nAccumulatedEnergy:Number = 0;
		
		private var __cNextInstance:GSimpleParticle;
		static private var availableInstance:GSimpleParticle;
		static private var count:int = 0;
		private var __iId:int = 0;
		public function GSimpleParticle():void {
			__iId = count++;
		}
		public function toString():String {
			return "["+__iId+"]";
		}
		
		static public function precache(p_precacheCount:int):void {
			if (p_precacheCount < count) return;
			
			var precached:GSimpleParticle = get();
			while (count<p_precacheCount) {
				var n:GSimpleParticle = get();
				n.cPrevious = precached;
				precached = n;
			}
			
			while (precached) {
				var d:GSimpleParticle = precached;
				precached = d.cPrevious;
				d.dispose();
			}
		}
		
		static g2d function get():GSimpleParticle {
			var instance:GSimpleParticle = availableInstance;
			if (instance) {
				availableInstance = instance.__cNextInstance;
				instance.__cNextInstance = null;
			} else {
				instance = new GSimpleParticle();
			}

			return instance;
		}
		
		g2d function init(p_emitter:GSimpleEmitter, p_invalidate:Boolean = true):void {
			nAccumulatedEnergy = 0;
			
			nEnergy = p_emitter.energy * 1000;
			if (p_emitter.energyVariance>0) nEnergy += (p_emitter.energyVariance * 1000) * Math.random();
			
			nInitialScale = p_emitter.initialScale;
			if (p_emitter.initialScaleVariance>0) nInitialScale += p_emitter.initialScaleVariance*Math.random();
			nEndScale = p_emitter.endScale;
			if (p_emitter.endScaleVariance>0) nEndScale += p_emitter.endScaleVariance*Math.random();
			
			var particleVelocityX:Number;
			var particleVelocityY:Number;
			var v:Number = p_emitter.initialVelocity;
			if (p_emitter.initialVelocityVariance>0) v += p_emitter.initialVelocityVariance * Math.random();
			
			var particleAccelerationX:Number;
			var particleAccelerationY:Number;
			var a:Number = p_emitter.initialAcceleration;
			if (p_emitter.initialAccelerationVariance>0) a += p_emitter.initialAccelerationVariance * Math.random();
			
			var vX:Number = particleVelocityX = v;
			var vY:Number = particleVelocityY = 0;
			var aX:Number = particleAccelerationX = a;
			var aY:Number = particleAccelerationY = 0;
			
			const rot:Number = p_emitter.cNode.transform.nWorldRotation;
			if (rot!=0) {
				var sin:Number = Math.sin(rot);
				var cos:Number = Math.cos(rot);
				
				vX = particleVelocityX = v*cos;
				vY = particleVelocityY = v*sin;
				aX = particleAccelerationX = a*cos;
				aY = particleAccelerationY = a*sin;
			}
			
			if (p_emitter.dispersionAngle!=0 || p_emitter.dispersionAngleVariance!=0) {
				var rangle:Number = p_emitter.dispersionAngle;
				if (p_emitter.dispersionAngleVariance>0) rangle += p_emitter.dispersionAngleVariance * Math.random();
				sin = Math.sin(rangle);
				cos = Math.cos(rangle);
				
				particleVelocityX = (vX*cos - vY*sin);
				particleVelocityY = (vY*cos + vX*sin);
				particleAccelerationX = (aX*cos - aY*sin);
				particleAccelerationY = (aY*cos + aX*sin);
			}
			
			nInitialVelocityX = nVelocityX = particleVelocityX * .001;
			nInitialVelocityY = nVelocityY = particleVelocityY * .001;
			nInitialAccelerationX = nAccelerationX = particleAccelerationX * .001;
			nInitialAccelerationY = nAccelerationY = particleAccelerationY * .001;
			
			nInitialVelocityAngular = p_emitter.initialAngularVelocity;
			if (p_emitter.initialAngularVelocityVariance>0) nInitialVelocityAngular += p_emitter.initialAngularVelocityVariance * Math.random();
			
			nInitialRed = p_emitter.initialRed;
			if (p_emitter.initialRedVariance>0) nInitialRed += p_emitter.initialRedVariance * Math.random(); 
			nInitialGreen = p_emitter.initialGreen;
			if (p_emitter.initialGreenVariance>0) nInitialGreen += p_emitter.initialGreenVariance * Math.random();
			nInitialBlue = p_emitter.initialBlue;
			if (p_emitter.initialBlueVariance>0) nInitialBlue += p_emitter.initialBlueVariance * Math.random();
			nInitialAlpha = p_emitter.initialAlpha;
			if (p_emitter.initialAlphaVariance>0) nInitialAlpha += p_emitter.initialAlphaVariance * Math.random();
			
			nEndRed = p_emitter.endRed;
			if (p_emitter.endRedVariance>0) nEndRed += p_emitter.endRedVariance * Math.random(); 
			nEndGreen = p_emitter.endGreen;
			if (p_emitter.endGreenVariance>0) nEndGreen += p_emitter.endGreenVariance * Math.random();
			nEndBlue = p_emitter.endBlue;
			if (p_emitter.endBlueVariance>0) nEndBlue += p_emitter.endBlueVariance * Math.random();
			nEndAlpha = p_emitter.endAlpha;
			if (p_emitter.endAlphaVariance>0) nEndAlpha += p_emitter.endAlphaVariance * Math.random();
			
			__nRedDif = nEndRed - nInitialRed;
			__nGreenDif = nEndGreen - nInitialGreen;
			__nBlueDif = nEndBlue - nInitialBlue;
			__nAlphaDif = nEndAlpha - nInitialAlpha;
			
			__nScaleDif = nEndScale - nInitialScale;
		}
		
		g2d function update(p_emitter:GSimpleEmitter, p_deltaTime:Number):void {
			nAccumulatedEnergy += p_deltaTime;
		
			if (nAccumulatedEnergy >= nEnergy) {
				p_emitter.deactivateParticle(this);
				return;
			}

			for (var i:int=0; i<p_emitter.iFieldsCount; ++i) {
				p_emitter.aFields[i].updateSimpleParticle(this, p_deltaTime);
			}
			
			const p:Number = nAccumulatedEnergy/nEnergy;
			nVelocityX += nAccelerationX*p_deltaTime;
			nVelocityY += nAccelerationY*p_deltaTime;
			
			nRed = __nRedDif*p + nInitialRed;
			nGreen = __nGreenDif*p + nInitialGreen;
			nBlue = __nBlueDif*p + nInitialBlue;
			nAlpha = __nAlphaDif*p + nInitialAlpha;			
			
			nX += nVelocityX * p_deltaTime;
			nY += nVelocityY * p_deltaTime;
			
			nRotation += nInitialVelocityAngular * p_deltaTime;
			nScaleX = nScaleY = __nScaleDif*p + nInitialScale;
			/*
			if (nX<=0 || nX>=800) nVelocityX = -nVelocityX;
			if (nY<=0 || nY>=600) nVelocityY = -nVelocityY;
			/**/
			
			if (p_emitter.special) {
				var n:Number = Math.sqrt(nVelocityX*nVelocityX+nVelocityY*nVelocityY);
				nScaleY = n*10;
				nRotation = -Math.atan2(nVelocityX, nVelocityY);
			}
			/**/
		}
		
		g2d function dispose():void {
			if (cNext) cNext.cPrevious = cPrevious;
			if (cPrevious) cPrevious.cNext = cNext;
			cNext = null;
			cPrevious = null;
			__cNextInstance = availableInstance;
			availableInstance = this;
		}
	}
}