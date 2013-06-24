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
	import com.genome2d.components.GCamera;
	import com.genome2d.components.particles.fields.GField;
	import com.genome2d.components.renderables.GRenderable;
	import com.genome2d.context.GContext;
	import com.genome2d.core.GNode;
	import com.genome2d.textures.GTexture;
	
	import flash.geom.Rectangle;
	
	use namespace g2d;
	
	public class GSimpleEmitter extends GRenderable
	{
		override public function bindFromPrototype(p_prototype:XML):void {
			super.bindFromPrototype(p_prototype);
		}
		
		/**
		 * 	Emitting particles
		 */
		public var emit:Boolean = false;
		/**
		 * 	Angle of emission
		 */
				
		public var initialScale:Number = 1;
		public var initialScaleVariance:Number = 0;
		public var endScale:Number = 1;
		public var endScaleVariance:Number = 0;
		
		public var energy:Number = 0;
		public var energyVariance:Number = 0;
		
		public var emission:int = 1;
		public var emissionVariance:int = 0;
		public var emissionTime:Number = 1;
		public var emissionDelay:Number = 0;
		
		public var initialVelocity:Number = 0;
		public var initialVelocityVariance:Number = 0;
		public var initialAcceleration:Number = 0;
		public var initialAccelerationVariance:Number = 0;
		
		public var initialAngularVelocity:Number = 0;
		public var initialAngularVelocityVariance:Number = 0;
		
		public var initialRed:Number = 1;
		public var initialRedVariance:Number = 0;
		public var initialGreen:Number = 1;
		public var initialGreenVariance:Number = 0;
		public var initialBlue:Number = 1;
		public var initialBlueVariance:Number = 0;
		public var initialAlpha:Number = 1;
		public var initialAlphaVariance:Number = 0;
		public function get initialColor():int {
			var red:uint = (initialRed*0xFF)<<16;
			var green:uint = (initialGreen*0xFF)<<8;
			var blue:uint = initialBlue*0xFF;
			return red+green+blue;
		}
		public function set initialColor(p_value:int):void {
			initialRed = Number(p_value>>16&0xFF)/0xFF;
			initialGreen = Number(p_value>>8&0xFF)/0xFF;
			initialBlue = Number(p_value&0xFF)/0xFF;
		}
		
		public var endRed:Number = 1;
		public var endRedVariance:Number = 0;
		public var endGreen:Number = 1;
		public var endGreenVariance:Number = 0;
		public var endBlue:Number = 1;
		public var endBlueVariance:Number = 0;
		public var endAlpha:Number = 1;
		public var endAlphaVariance:Number = 0;
		public function get endColor():int {
			var red:uint = (endRed*0xFF)<<16;
			var green:uint = (endGreen*0xFF)<<8;
			var blue:uint = endBlue*0xFF;
			return red+green+blue;
		}
		public function set endColor(p_value:int):void {
			endRed = Number(p_value>>16&0xFF)/0xFF;
			endGreen = Number(p_value>>8&0xFF)/0xFF;
			endBlue = Number(p_value&0xFF)/0xFF;
		}
		
		public var dispersionXVariance:Number = 0;
		public var dispersionYVariance:Number = 0;
		public var dispersionAngle:Number = 0;
		public var dispersionAngleVariance:Number = 0;
		
		public var initialAngle:Number = 0;
		public var initialAngleVariance:Number = 0;
		
		public var burst:Boolean = false;
		
		public var special:Boolean = false;
		
		//public var useWorldSpace:Boolean = false;
		
		protected var _nAccumulatedTime:Number = 0;
		protected var _nAccumulatedEmission:Number = 0;
		
		protected var _cFirstParticle:GSimpleParticle;
		protected var _cLastParticle:GSimpleParticle;
		
		protected var _iActiveParticles:int = 0;
		
		private var __nLastUpdateTime:Number;
		private var __cTexture:GTexture;
		public function get textureId():String {
			return (__cTexture) ? __cTexture.id : "";
		}
		public function set textureId(p_value:String):void {
			__cTexture = GTexture.getTextureById(p_value);
		}
		public function setTexture(p_texture:GTexture):void {
			__cTexture = p_texture;
		}
		
		protected function setInitialParticlePosition(p_particle:GSimpleParticle):void {
			/*
			if (useWorldSpace) {
				p_particleNode.cTransform.x = cNode.cTransform.nWorldX + Math.random() * dispersionXVariance - dispersionXVariance * .5;
				p_particleNode.cTransform.y = cNode.cTransform.nWorldY + Math.random() * dispersionYVariance-  dispersionYVariance * .5;
			} else {
				p_particleNode.cTransform.x = Math.random() * dispersionXVariance - dispersionXVariance * .5;
				p_particleNode.cTransform.y = Math.random() * dispersionYVariance - dispersionYVariance * .5;
			}
			/**/
			p_particle.nX = cNode.cTransform.nWorldX;
			if (dispersionXVariance>0) p_particle.nX += dispersionXVariance*Math.random() - dispersionXVariance*.5; 
			p_particle.nY = cNode.cTransform.nWorldY;
			if (dispersionYVariance>0) p_particle.nY += dispersionYVariance*Math.random() - dispersionYVariance*.5; 
			p_particle.nRotation = initialAngle;
			if (initialAngleVariance>0) p_particle.nRotation += initialAngleVariance*Math.random();
			p_particle.nScaleX = p_particle.nScaleY = initialScale;
			if (initialScaleVariance>0) {
				var sd:Number = initialScaleVariance*Math.random();
				p_particle.nScaleX += sd;
				p_particle.nScaleY += sd;
			}
		}
		
		/**
		 * 	@private
		 */
		public function GSimpleEmitter(p_node:GNode) {
			super(p_node);
		}
		
		public function init(p_maxCount:int = 0, p_precacheCount:int = 0, p_disposeImmediately:Boolean = true):void {
			_nAccumulatedTime = 0;
			_nAccumulatedEmission = 0;
		}
		
		private function createParticle():GSimpleParticle {
			var particle:GSimpleParticle = GSimpleParticle.get();
			if (_cFirstParticle) {
				particle.cNext = _cFirstParticle;
				_cFirstParticle.cPrevious = particle;
				_cFirstParticle = particle;
			} else {
				_cFirstParticle = particle;
				_cLastParticle = particle;
			}
			
			return particle;
		}
		
		public function forceBurst():void {
			var currentEmission:int = emission + emissionVariance * Math.random();

			for (var i:int = 0; i < currentEmission; ++i) {
				activateParticle();
			}
			emit = false;
		}
		
		override public function update(p_deltaTime:Number, p_parentTransformUpdate:Boolean, p_parentColorUpdate:Boolean):void {
			__nLastUpdateTime = p_deltaTime;

			if (emit) {
				if (burst) {
					forceBurst();
				} else {
					_nAccumulatedTime += p_deltaTime * .001;
					var time:Number = _nAccumulatedTime%(emissionTime+emissionDelay);
		
					
					if (time<=emissionTime) {
						var updateEmission:int = emission;
						if (emissionVariance>0) updateEmission += emissionVariance * Math.random(); 
						_nAccumulatedEmission += updateEmission * p_deltaTime * .001;
		
						while (_nAccumulatedEmission > 0) {
							activateParticle();
							_nAccumulatedEmission--;
						}
					}
				}
			}
			
			for (var particle:GSimpleParticle = _cFirstParticle; particle;) {
				var next:GSimpleParticle = particle.cNext;
				particle.update(this, __nLastUpdateTime);
				particle = next;
			}
		}
		
		override public function render(p_context:GContext, p_camera:GCamera, p_maskRect:Rectangle):void {
			if (__cTexture == null) return;
			var i:int = 0;

			for (var particle:GSimpleParticle = _cFirstParticle; particle;) {
				var next:GSimpleParticle = particle.cNext;

				var tx:Number = cNode.cTransform.nWorldX + (particle.nX-cNode.cTransform.nWorldX)*1//cNode.cTransform.nWorldScaleX;
				var ty:Number = cNode.cTransform.nWorldY + (particle.nY-cNode.cTransform.nWorldY)*1//cNode.cTransform.nWorldScaleY;
				
				p_context.draw(__cTexture, tx, ty, particle.nScaleX*cNode.cTransform.nWorldScaleX, particle.nScaleY*cNode.cTransform.nWorldScaleY, particle.nRotation, particle.nRed, particle.nGreen, particle.nBlue, particle.nAlpha, iBlendMode, p_maskRect);

				particle = next;
			}
		}
		
		private function activateParticle():void {
			var particle:GSimpleParticle = createParticle();
			setInitialParticlePosition(particle);
			
			particle.init(this);
		}
		
		g2d function deactivateParticle(p_particle:GSimpleParticle):void {
			if (p_particle == _cLastParticle) _cLastParticle = _cLastParticle.cPrevious;
			if (p_particle == _cFirstParticle) _cFirstParticle = _cFirstParticle.cNext;
			p_particle.dispose();
		}

		override public function dispose():void {
			// TODO
			
			super.dispose();
		}
		
		public function clear(p_disposeCachedParticles:Boolean = false):void {
			// TODO
		}
		
		g2d var iFieldsCount:int = 0;
		g2d var aFields:Vector.<GField> = new Vector.<GField>();
		public function addField(p_field:GField):void {
			if (p_field == null) throw new Error("Field cannot be null.");
			iFieldsCount++;
			aFields.push(p_field);
		}
	}
}