package examples
{
	import assets.Assets;
	
	import com.genome2d.components.GComponent;
	import com.genome2d.components.particles.GEmitter;
	import com.genome2d.components.particles.GParticle;
	import com.genome2d.components.renderables.GSprite;
	import com.genome2d.context.GBlendMode;
	import com.genome2d.core.GNode;
	
	import flash.events.KeyboardEvent;
	
	public class ParticlesExample extends Example
	{
		private var __iColor:int = 0;
		private var __iSize:int = 16;
		private var __bMove:Boolean = true;
		
		private var __cParticles:GNode;
		
		public function ParticlesExample(p_wrapper:Genome2DExamples):void {
			super(p_wrapper);
		}
		
		private function updateInfo():void {
			_cWrapper.info = "<font color='#00FFFF'><b>ParticlesExample</b>\n"+
			"<font color='#FFFFFF'>This is just a simple demo of particle system using additive blending and particle prototype.\n"+
			"<font color='#FFFF00'>Just move your mouse around and enjoy.";
		}
		
		/**
		 * 	Initialize example
		 */
		override public function init():void {
			super.init();
			
			// Hook up a key event
			_cGenome.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			// Hook up a Genome update signal
			_cGenome.onPreUpdate.add(onUpdate);
			
			// Create a particle for prototype
			var particle:GNode = new GNode();
			// Each particle needs to have G2DParticle component
			particle.addComponent(GParticle);
			// Add sprite texture for our particle
			var sprite:GSprite = particle.addComponent(GSprite) as GSprite;
			sprite.setTexture(Assets.particleTexture);
			sprite.blendMode = GBlendMode.ADD;
			
			// Create our particle emitter
			__cParticles = new GNode("particles");
			__cParticles.mouseChildren = false;
			var emitter:GEmitter = __cParticles.addComponent(GEmitter) as GEmitter;
			// Set the particle prototype
			emitter.setParticlePrototype(particle.getPrototype());
			// This means that generated particles will use world space instead of local space therefore moving the emitter will not move the already generated partciles
			// Just for fun try to set it to false and you'll see
			emitter.useWorldSpace = true;
			// Velocity
			emitter.maxWorldVelocityY = 200;
			// Minimum number of particles generated per second
			emitter.minEmission = 32;
			// Maximum number of particles generated per second
			emitter.maxEmission = 64;
			// Maximum size of the particle, what this means is the scale of the prototype
			emitter.maxScaleX = 6;
			emitter.minScaleX = 1;
			// Maximum energy of a particle, this means particles will live for 2 seconds
			emitter.maxEnergy = 2;
			// Angle of emission, this will set a 360 degree emission
			emitter.angle = Math.PI*2;
			
			emitter.initialParticleRed = 1;
			emitter.initialParticleGreen = 1;
			emitter.initialParticleBlue = 0;
			emitter.initialParticleAlpha = 1;
			
			emitter.endParticleRed = 1;
			emitter.endParticleGreen = 0;
			emitter.endParticleBlue = 0;
			emitter.endParticleAlpha = 0;
			
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
			
			_cGenome.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_cGenome.onPreUpdate.removeAll();
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