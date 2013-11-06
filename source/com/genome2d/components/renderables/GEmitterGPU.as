/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.components.renderables
{
	import com.genome2d.g2d;
	import com.genome2d.components.GCamera;
	import com.genome2d.components.GTransform;
	import com.genome2d.context.GContext;
	import com.genome2d.context.materials.GCameraTexturedParticlesBatchMaterial;
	import com.genome2d.core.GNode;
	import com.genome2d.textures.GTexture;
	
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	use namespace g2d;
	
	public class GEmitterGPU extends GRenderable
	{
		static private var __aCached:Dictionary = new Dictionary();
		
		/**
		 * 	@private
		 */
		g2d var aParticles:Vector.<Number>;
		/**
		 * 	@private
		 */
		g2d var nCurrentTime:int = 0;
		/**
		 * 	@private
		 */
		g2d var iMaxParticles:int;
		/**
		 * 	@private
		 */
		g2d var iActiveParticles:int;
		public function get activeParticles():int {
			return iActiveParticles;
		}
		public function set activeParticles(p_particleCount:int):void {
			iActiveParticles = p_particleCount;
		}
		/**
		 * 	@private
		 */
		g2d var cTexture:GTexture;
		/**
		 * 	@private
		 */
		g2d var sHash:String;
		/**
		 * 	@private
		 */
		public function GEmitterGPU(p_node:GNode) {
			super(p_node);
		}
		
		public function setTexture(p_texture:GTexture):void {
			cTexture = p_texture;
		}
		
		public function get textureId():String {
			if (cTexture) return cTexture.id;
			return "";
		}
		public function set textureId(p_value:String):void {
			cTexture = GTexture.getTextureById(p_value);
		}
		
		public function initialize(p_timeOffset:Number, p_offsetX:Number, p_offsetY:Number, p_emitAngle:Number, p_minVelocity:int, p_maxVelocity:int, p_minStartScale:Number, p_maxStartScale:Number, p_minEndScale:Number, p_maxEndScale:Number, p_sameScale:Boolean, p_startAlpha:Number, p_endAlpha:Number, p_minEnergy:int, p_maxEnergy:int, p_maxParticles:int, p_seed:int = 0):void {
			sHash = p_timeOffset+"|"+p_offsetX+"|"+p_offsetY+"|"+p_emitAngle+"|"+p_minVelocity+"|"+p_maxVelocity+"|"+p_minStartScale+"|"+p_maxStartScale+"|"+p_minEndScale+"|"+p_maxEndScale+"|"+p_sameScale+"|"+p_startAlpha+"|"+p_endAlpha+"|"+p_minEnergy+"|"+p_maxEnergy+"|"+p_maxParticles+"|"+p_seed;
			
			iMaxParticles = p_maxParticles;
			
			aParticles = __aCached[sHash];
			
			if (aParticles != null) return;
			
			aParticles = new Vector.<Number>();
			cRenderData = null;
			
			for (var i:int = 0; i < iMaxParticles; ++i) {
				// Position offset
				aParticles.push(Math.random() * p_offsetX - p_offsetX * .5, Math.random() * p_offsetY - p_offsetY * .5);
				
				// Velocity
				var angle:Number = Math.random() * p_emitAngle - p_emitAngle * .5;
				var sin:Number = Math.sin(angle);
				var cos:Number = Math.cos(angle);			
				var velocity:Number = Math.random() * (p_maxVelocity - p_minVelocity) + p_minVelocity;
				aParticles.push(velocity * cos, velocity * sin);

				// Initial and final scale
				if (!p_sameScale) {
					aParticles.push(Math.random()*(p_maxStartScale - p_minStartScale) + p_minStartScale, Math.random() * (p_maxEndScale - p_minEndScale) + p_minEndScale);
				} else {
					var scale:Number = Math.random()*(p_maxStartScale - p_minStartScale) + p_minStartScale; 
					aParticles.push(scale, scale);
				}
				// Initial and final alpha
				aParticles.push(p_startAlpha, p_endAlpha);		
				
				// Initial time, energy
				aParticles.push(i*p_timeOffset, Math.random()*(p_maxEnergy - p_minEnergy) + p_minEnergy);
			}

			__aCached[sHash] = aParticles;
			
			iActiveParticles = iMaxParticles;
			
			_cMaterial = GCameraTexturedParticlesBatchMaterial.getByHash(sHash);
		}
		
		override public function update(p_deltaTime:Number):void {
			nCurrentTime += p_deltaTime;
		}
		
		protected var _cMaterial:GCameraTexturedParticlesBatchMaterial;
		static g2d var aTransformVector:Vector.<Number> = new <Number>[0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0];
		
		override public function render(p_context:GContext, p_camera:GCamera, p_maskRect:Rectangle):void {
			if (cTexture == null || iMaxParticles == 0 || _cMaterial == null) return;
			
			if (p_context.checkAndSetupRender(_cMaterial, iBlendMode, cTexture.premultiplied, p_maskRect)) _cMaterial.bind(p_context.cContext, p_context.bReinitialize, p_camera, aParticles);
			
			var transform:GTransform = cNode.cTransform;
			
			aTransformVector[0] = transform.nWorldX;
			aTransformVector[1] = transform.nWorldY;
			aTransformVector[2] = cTexture.iWidth * transform.nWorldScaleX;
			aTransformVector[3] = cTexture.iHeight * transform.nWorldScaleY;
			
			aTransformVector[4] = cTexture.nUvX;
			aTransformVector[5] = cTexture.nUvY;
			aTransformVector[6] = cTexture.nUvScaleX;
			aTransformVector[7] = cTexture.nUvScaleY;
			
			aTransformVector[8] = transform.nWorldRotation;
			aTransformVector[9] = nCurrentTime;
			aTransformVector[10] = 2;
			aTransformVector[11] = 1;
			
			aTransformVector[12] = 1;
			aTransformVector[13] = 1;
			aTransformVector[14] = 1;
			aTransformVector[15] = .1;
			
			_cMaterial.draw(aTransformVector, cTexture.cContextTexture.tTexture, cTexture.iFilteringType, iActiveParticles);
		}
	}
}