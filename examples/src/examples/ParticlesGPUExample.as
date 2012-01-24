package examples
{
	import assets.Assets;
	
	import com.flashcore.g2d.components.renderables.G2DEmitterGPU;
	import com.flashcore.g2d.context.G2DBlendMode;
	import com.flashcore.g2d.core.G2DNode;
	
	import flash.events.KeyboardEvent;
	
	public class ParticlesGPUExample extends Example
	{
		private var __cEmitterContainer:G2DNode;
		private var __nRotation:Number = .005;
		
		public function ParticlesGPUExample(p_wrapper:Genome2DExamples):void {
			super(p_wrapper);
		}
		
		private function updateInfo():void {
			_cWrapper.info = "<font color='#00FFFF'><b>GPUParticlesExample</b>\n"+
			"<font color='#FFFFFF'>This is just a simple demo of G2DEmitterGPU component. Its precomputed particle systems and each step is interpolated solely by GPU it can be integrated into any node and inherits scene hierarchy.\n"+
			"<font color='#FFFF00'>It will not work when you are using software renderer if plan on using software renderer always use G2DEmitter.";
		}
		
		/**
		 * 	Initialize example
		 */
		override public function init():void {
			super.init();
			
			// Hook up a key event
			_cGenome.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			// Hook up a Genome update signal
			_cGenome.onUpdated.add(onUpdate);
			
			__cEmitterContainer = new G2DNode();
			__cEmitterContainer.transform.x = _iWidth/2;
			__cEmitterContainer.transform.y = _iHeight/2;
			_cContainer.addChild(__cEmitterContainer);
			
			createGPUEmitter(0,80,0,1,.4).initialize(5,100,100,0,200,400,.5,1.5,.1,.5,false,1,0,1000,2000,200);
			
			createGPUEmitter(200,0,0,.4,1).initialize(5,0,0,Math.PI*2,100,200,1,2,.5,1,false,1,0,2000,3000,200);
			
			createGPUEmitter(-200,100,1,.4,0).initialize(5,0,100,0.5,300,300,1,2,.5,1,false,1,0,2000,3000,200);
			
			
			updateInfo();
		}
		
		private function createGPUEmitter(p_x:Number, p_y:Number, p_red:Number, p_green:Number, p_blue:Number):G2DEmitterGPU {
			var particles:G2DNode = new G2DNode(); 
			particles.transform.x = p_x;
			particles.transform.y = p_y;
			particles.transform.rotation = -Math.PI/2;
			particles.transform.red = p_red;
			particles.transform.green = p_green;
			particles.transform.blue = p_blue;
			
			particles.mouseChildren = false;
			
			var emitter:G2DEmitterGPU = particles.addComponent(G2DEmitterGPU) as G2DEmitterGPU;
			emitter.blendMode = G2DBlendMode.ADDITIVE;
			emitter.setTexture(Assets.particleTexture);
			__cEmitterContainer.addChild(particles);
			
			return emitter;
		}
		
		/**
		 * 	Dispose example resources
		 */
		override public function dispose():void {
			super.dispose();
			
			_cGenome.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_cGenome.onUpdated.removeAll();
		}
		
		/**
		 * 	Update singal callback
		 */
		private function onUpdate(p_deltaTime:Number):void {
			if (__cEmitterContainer.transform.rotation>0.4 || __cEmitterContainer.transform.rotation<-0.4) __nRotation = -__nRotation;
				
			__cEmitterContainer.transform.rotation-=__nRotation;
		}
		
		/**
		 * 	Keyboard event callback
		 */
		private function onKeyDown(event:KeyboardEvent):void {
			switch (event.keyCode) {
				case 40:
					break;
				case 38:
					break;
				case 80:
					break;
			}
			
			updateInfo();
		}
	}
}