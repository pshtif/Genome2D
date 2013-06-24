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
	import com.genome2d.core.GNodePool;
	import com.genome2d.error.GError;
	import com.genome2d.g2d;
	
	import flash.display.BitmapData;
	import com.genome2d.components.particles.fields.GField;
	
	use namespace g2d;
	
	public class GEmitter extends GComponent
	{
		override public function getPrototype():XML {
			_xPrototype = super.getPrototype();

			if (_xParticlePrototype !=null) {
				_xPrototype.particlePrototype = <particlePrototype/>
				_xPrototype.particlePrototype.appendChild(_xParticlePrototype);
			}
			
			return _xPrototype;
		}
		
		override public function bindFromPrototype(p_prototype:XML):void {
			super.bindFromPrototype(p_prototype);
			
			if (p_prototype.particlesPrototype != null) setParticlePrototype(p_prototype.particlePrototype.node[0]);
		}
		
		/**
		 * 	Emitting particles
		 */
		public var emit:Boolean = true;
		/**
		 * 	Angle of emission
		 */
				
		public var initialScale:Number = 1;
		public var initialScaleVariance:Number = 0;
		public var endScale:Number = 1;
		public var endScaleVariance:Number = 0;
		
		public var energy:Number = 1;
		public var energyVariance:Number = 0;
		
		public var emission:int = 1;
		public var emissionVariance:int = 0;
		public var emissionTime:Number = 1;
		public var emissionDelay:Number = 0;
		
		public var initialVelocity:Number = 0;
		public var initialVelocityVariance:Number = 0;
		public var initialAcceleration:Number = 0;
		public var initialAccelerationVariance:Number = 0;
		
		public var angularVelocity:Number = 0;
		public var angularVelocityVariance:Number = 0;
		
		public var initialRed:Number = 1;
		public var initialRedVariance:Number = 0;
		public var initialGreen:Number = 1;
		public var initialGreenVariance:Number = 0;
		public var initialBlue:Number = 1;
		public var initialBlueVariance:Number = 0;
		public var initialAlpha:Number = 1;
		public var initialAlphaVariance:Number = 0;
		public function get initialColor():int {
			return initialRed*0xFF0000+initialGreen*0x00FF00+initialBlue*0x0000FF;
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
			return endRed*0xFF0000+endGreen*0x00FF00+endBlue*0x0000FF;
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
		
		public var useWorldSpace:Boolean = false;
		
		public var bitmapData:BitmapData;
		private var __aOffsets:Vector.<int>;
		public function invalidateBitmapData():void {
			__aOffsets = new Vector.<int>();
			var w:int = bitmapData.width;
			var colors:Vector.<uint> = bitmapData.getVector(bitmapData.rect);
			for (var i:int=0;i<colors.length;++i) {
				if ((colors[i]>>24&0xFF)>0) __aOffsets.push(i%w,i/w);
			}
		}
		
		private var _aPreviousParticlePools:Array = new Array();; 
		
		/**
		 * 
		 */
		protected var _xParticlePrototype:XML;
		public function setParticlePrototype(p_xml:XML):void {
			_xParticlePrototype = p_xml;
		}
		
		protected var _nAccumulatedTime:Number = 0;
		protected var _nAccumulatedEmission:Number = 0;
		protected var _aParticles:Vector.<GParticle> = new Vector.<GParticle>(); 
		
		protected var _iActiveParticles:int = 0;
		
		protected var _cParticlePool:GNodePool;
		public function get particlesCachedCount():int {
			if (_cParticlePool != null)	return _cParticlePool.cachedCount;
			else return 0;
		}
		
		protected function setInitialParticlePosition(p_particleNode:GNode):void {
			if (useWorldSpace) {
				p_particleNode.cTransform.x = cNode.cTransform.nWorldX + Math.random() * dispersionXVariance - dispersionXVariance * .5;
				p_particleNode.cTransform.y = cNode.cTransform.nWorldY + Math.random() * dispersionYVariance-  dispersionYVariance * .5;
			} else {
				p_particleNode.cTransform.x = Math.random() * dispersionXVariance - dispersionXVariance * .5;
				p_particleNode.cTransform.y = Math.random() * dispersionYVariance - dispersionYVariance * .5;
			}
		}
		
		protected function get initialParticleY():Number {
			return cNode.cTransform.nWorldY + Math.random() * dispersionYVariance - dispersionYVariance * .5;
		}
		
		/**
		 * 	@private
		 */
		override public function set active(p_value:Boolean):void {
			super.active = p_value;
			if (_cParticlePool) _cParticlePool.deactivate();
		}
		
		/**
		 * 	@private
		 */
		public function GEmitter(p_node:GNode) {
			super(p_node);
		}
		
		public function init(p_maxCount:int = 0, p_precacheCount:int = 0, p_disposeImmediately:Boolean = true):void {
			_nAccumulatedTime = 0;
			_nAccumulatedEmission = 0;
			
			if (_cParticlePool) {
				if (p_disposeImmediately) {
					_cParticlePool.dispose();
				} else {
					_aPreviousParticlePools.push({pool:_cParticlePool, time:(energy+energyVariance)*1000});
				}
			}
			
			_cParticlePool = new GNodePool(_xParticlePrototype, p_maxCount, p_precacheCount);
		}
		
		public function forceBurst():void {
			if (!_cParticlePool) return;
			var e:int = emission + emissionVariance * Math.random();
		
			for (var i:int = 0; i < e; ++i) {
				activateParticle();
			}
			
			emit = false;
		}
		
		override public function update(p_deltaTime:Number, p_parentTransformUpdate:Boolean, p_parentColorUpdate:Boolean):void {
			if (_aPreviousParticlePools.length>0) {
				_aPreviousParticlePools[0].time-=p_deltaTime;
				if (_aPreviousParticlePools[0].time<=0) {
					_aPreviousParticlePools[0].pool.dispose();
					_aPreviousParticlePools.shift();
				}
			}
					
			if (!emit || _cParticlePool == null) return;

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
		
		private function activateParticle():void {
			var particleNode:GNode = _cParticlePool.getNext();
			
			if (particleNode == null) return;
			
			var particle:GParticle = particleNode.getComponent(GParticle) as GParticle;
			
			if (particle == null) throw new GError(GError.CANNOT_INSTANTATE_ABSTRACT);
			
			particle.cEmitter = this;
			
			particleNode.cTransform.useWorldSpace = useWorldSpace;
			
			if (useWorldSpace) {
				if (bitmapData) {
					var offset:int = int((__aOffsets.length-1)/2*Math.random())*2;
					
					particleNode.cTransform.x = cNode.cTransform.nWorldX - bitmapData.width/2 + __aOffsets[offset];
					particleNode.cTransform.y = cNode.cTransform.nWorldY - bitmapData.height/2 + __aOffsets[offset+1];
				} else {
					setInitialParticlePosition(particleNode);
				}
			} else {
				setInitialParticlePosition(particleNode);
			}
			particleNode.cTransform.scaleX = particleNode.transform.scaleY = initialScale + initialScaleVariance*Math.random();
			particleNode.cTransform.rotation = initialAngle + Math.random() * initialAngleVariance;
						
			particle.init();
			
			cNode.addChild(particleNode);
		}

		override public function dispose():void {
			if (_cParticlePool != null) _cParticlePool.dispose();
			_cParticlePool = null;
			
			super.dispose();
		}
		
		public function clear(p_disposeCachedParticles:Boolean = false):void {
			if (_cParticlePool == null) return;
			if (p_disposeCachedParticles) _cParticlePool.dispose();
			else _cParticlePool.deactivate();
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