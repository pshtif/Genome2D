package examples
{
	import com.flashcore.g2d.components.G2DComponent;
	import com.flashcore.g2d.components.G2DEmitter;
	import com.flashcore.g2d.components.G2DMovieClip;
	import com.flashcore.g2d.components.G2DParticle;
	import com.flashcore.g2d.components.G2DSprite;
	import com.flashcore.g2d.context.G2DBlendMode;
	import com.flashcore.g2d.core.G2DNode;
	import com.flashcore.g2d.core.Genome2D;
	import com.flashcore.g2d.g2d;
	import com.flashcore.g2d.signals.G2DMouseSignal;
	import com.flashcore.g2d.textures.G2DTexture;
	import com.flashcore.g2d.textures.G2DTextureAtlas;
	import com.flashcore.g2d.textures.G2DTextureLibrary;
	import com.greensock.TweenLite;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.geom.Matrix;
	import examples.components.CustomParticle;
	
	public class ParticleExample extends Example
	{
		private var __cMineTexture:G2DTextureAtlas;
		private var __cParticleTexture:G2DTexture;
		
		private var __iColor:int = 0;
		private var __iSize:int = 16;
		private var __bMove:Boolean = true;
		
		private var __cParticles:G2DNode;
		
		public function ParticleExample(p_wrapper:Genome2DExamples):void {
			super(p_wrapper);
		}
		
		private function updateInfo():void {
			_cWrapper.info = "<font color='#00FFFF'><b>ParticleExample</b>\n"+
			"<font color='#FFFFFF'>This is just a simple demo of particle system using additive blending and particle prototype.\n"+
			"<font color='#FFFF00'>Just move your mouse around and enjoy.";
		}
		
		/**
		 * 	Initialize example
		 */
		override public function init():void {
			super.init();
	
			// Create a G2D texture based on our embedded asset bitmap
			__cParticleTexture = G2DTexture.createFromBitmapData("particle", new Assets.ParticleGFX().bitmapData);
			
			// Hook up a key event
			_cGenome.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			// Hook up a Genome update signal
			_cGenome.onUpdated.add(onUpdate);
			
			// Create a particle for prototype
			var particle:G2DNode = new G2DNode();
			// Each particle needs to have G2DParticle component
			particle.addComponent(G2DParticle);
			// This is our custom component just for show, it actually only sets custom colors to each particle
			particle.addComponent(CustomParticle);
			// Add sprite texture for our particle
			var sprite:G2DSprite = particle.addComponent(G2DSprite) as G2DSprite;
			sprite.setTexture(__cParticleTexture);
			sprite.blendMode = G2DBlendMode.ADDITIVE;
			
			// Create our particle emitter
			__cParticles = new G2DNode("particles");
			__cParticles.mouseChildren = false;
			var emitter:G2DEmitter = __cParticles.addComponent(G2DEmitter) as G2DEmitter;
			// Set the particle prototype
			emitter.particlePrototype = particle.getPrototype();
			// This means that generated particles will use world space instead of local space therefore moving the emitter will not move the already generated partciles
			// Just for fun try to set it to false and you'll see
			emitter.useWorldSpace = true;
			// Velocity
			emitter.worldVelocityY = 200;
			// Minimum number of particles generated per second
			emitter.minEmission = 50;
			// Maximum number of particles generated per second
			emitter.maxEmission = 100;
			// Maximum size of the particle, what this means is the scale of the prototype
			emitter.maxSize = 4;
			// Maximum energy of a particle, this means particle will live for 2 seconds
			emitter.maxEnergy = 2;
			// Angle of emission, this will set a 360 degree emission
			emitter.angle = Math.PI*2;
			_cContainer.addChild(__cParticles);
			
			/**
			 * 	There are other properties of G2DEmitter that can be utilized, you can try them out as well
			 */
			
			updateInfo();
		}
		
		/**
		 * 	Dispose example resources
		 */
		override public function dispose():void {
			super.dispose();
			
			__cParticleTexture.dispose();
			
			_cGenome.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_cGenome.onUpdated.removeAll();
		}
		
		/**
		 * 	Update singal callback
		 */
		private function onUpdate(p_deltaTime:Number):void {
			// Move particle emitter to mouse position
			__cParticles.transform.x = _cWrapper.stage.mouseX;
			__cParticles.transform.y = _cWrapper.stage.mouseY;
		}
		
		/**
		 * 	Keyboard event callback
		 */
		private function onKeyDown(event:KeyboardEvent):void {
			switch (event.keyCode) {
				case 40:
					__iSize = (__iSize>1) ? __iSize-1 : 1;
					break;
				case 38:
					__iSize++;
					break;
				case 80:
					__bMove = !__bMove;
					break;
			}
			
			updateInfo();
		}
	}
}