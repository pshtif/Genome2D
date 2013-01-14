package
{
	import com.genome2d.components.GCamera;
	import com.genome2d.components.particles.GSimpleEmitter;
	import com.genome2d.components.particles.fields.GForceField;
	import com.genome2d.components.particles.fields.GGravityField;
	import com.genome2d.components.renderables.GSprite;
	import com.genome2d.context.GBlendMode;
	import com.genome2d.core.GConfig;
	import com.genome2d.core.GNode;
	import com.genome2d.core.GNodeFactory;
	import com.genome2d.core.Genome2D;
	import com.genome2d.textures.factories.GTextureFactory;
	import com.greensock.TweenLite;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	[SWF(width="800", height="600", backgroundColor="#000000", frameRate="60")]	
	public class FireWorks extends Sprite
	{
		[Embed(source = "../assets/wall2.png")]
		static private const WallGFX:Class;
		[Embed(source = "../assets/particle16.png")]
		static private const SparkleGFX:Class;
		[Embed(source = "../assets/smoke32.png")]
		static private const SmokeGFX:Class;
		
		protected var _cGenome2D:Genome2D;
		protected var _cSparklesGravity:GForceField;
		protected var _cSmokeGravity:GForceField;
		protected var _cCamera:GCamera;
		protected var _cExplode:GGravityField;
		protected var _bExploding:Boolean = false;
		
		
		public function FireWorks() {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			_cGenome2D = Genome2D.getInstance();
			
			// Hook up a callback once initialization is done
			_cGenome2D.onInitialized.addOnce(onGenome2DInitialized);
			
			// Initialize Genome2D config, we need to specify area where Genome2D will be rendered
			// if we want the whole stage simply put the stage size there
			var config:GConfig = new GConfig(new Rectangle(0,0,stage.stageWidth, stage.stageHeight));
			config.enableStats = true;
			
			// Initiaiize Genome2D
			_cGenome2D.init(stage, config);
		}
		
		// Initialization callback
		protected function onGenome2DInitialized():void {
			GTextureFactory.createFromAsset("wall", WallGFX);
			GTextureFactory.createFromAsset("sparkle", SparkleGFX);
			GTextureFactory.createFromAsset("smoke", SmokeGFX);
			
			_cCamera = GNodeFactory.createNodeWithComponent(GCamera) as GCamera;
			_cCamera.node.transform.setPosition(400,300);
			_cGenome2D.root.addChild(_cCamera.node);
			
			var wall:GSprite = GNodeFactory.createNodeWithComponent(GSprite) as GSprite;
			wall.textureId = "wall";
			wall.node.transform.setPosition(400,300);
			wall.blendMode = GBlendMode.NONE;
			_cGenome2D.root.addChild(wall.node);
			
			_cExplode = GNodeFactory.createNodeWithComponent(GGravityField) as GGravityField;
			_cExplode.inverseGravity = true;
			_cExplode.radius = 120;
			_cExplode.gravity = 0;
			_cExplode.node.transform.setPosition(400,300);
			_cGenome2D.root.addChild(_cExplode.node);
			
			_cSparklesGravity = GNodeFactory.createNodeWithComponent(GForceField) as GForceField;
			_cSparklesGravity.forceY = 0.09;
			_cGenome2D.root.addChild(_cSparklesGravity.node);
			
			_cSmokeGravity = GNodeFactory.createNodeWithComponent(GForceField) as GForceField;
			_cSmokeGravity.forceY = 0.05;
			_cGenome2D.root.addChild(_cSmokeGravity.node);
			
			stage.addEventListener(MouseEvent.CLICK, onMouseClick);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen);
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			fireRocket();
		}
		
		protected function fireRocket():void {
			createRocket(10+Math.random()*780, 10+Math.random()*300);
			
			TweenLite.delayedCall(Math.random(), fireRocket);
		}
		
		private function onMouseClick(event:MouseEvent):void {
			createRocket(event.stageX/_cCamera.zoom, event.stageY/_cCamera.zoom);
		}
		
		private function onKeyDown(event:KeyboardEvent):void {
			switch (event.keyCode) {
				case Keyboard.F:
					if (stage.displayState != StageDisplayState.FULL_SCREEN) stage.displayState = StageDisplayState.FULL_SCREEN
					else stage.displayState = StageDisplayState.NORMAL;
					break;
			}
		}
		
		private function onFullScreen(event:FullScreenEvent):void {
			if (event.fullScreen) {
				_cGenome2D.config.viewRect = new Rectangle(0,0,stage.fullScreenWidth,stage.fullScreenHeight);
				_cCamera.zoom = 1920/800;
			} else {
				_cGenome2D.config.viewRect = new Rectangle(0,0,800,600);
				_cCamera.zoom = 1;
			}
		}
		
		protected function createRocket(p_x:int, p_y:int):void {
			var node:GNode = GNodeFactory.createNode();
			
			var smoke:GSimpleEmitter = GNodeFactory.createNodeWithComponent(GSimpleEmitter) as GSimpleEmitter;
			smoke.textureId = "smoke";
			smoke.emit = true;
			smoke.emission = 40;
			smoke.energy = 2;
			smoke.energyVariance = 1;
			smoke.blendMode = GBlendMode.NORMAL;
			smoke.initialVelocity = 2;
			smoke.initialVelocityVariance = 5;
			smoke.dispersionAngleVariance = 2*Math.PI;
			smoke.initialScale = .25;
			smoke.initialScaleVariance = .25;
			smoke.initialAlpha = .2;
			smoke.initialColor = 0xAAAAAA;
			smoke.endAlpha = 0;
			smoke.endScale = .5;
			smoke.endScaleVariance = .5;
			smoke.addField(_cSmokeGravity);
			node.addChild(smoke.node);
			
			var sparkles:GSimpleEmitter = GNodeFactory.createNodeWithComponent(GSimpleEmitter) as GSimpleEmitter;
			sparkles.textureId = "sparkle";
			sparkles.emit = true;
			sparkles.emission = 40;
			sparkles.energy = .5;
			sparkles.energyVariance = .8;
			sparkles.blendMode = GBlendMode.ADD;
			sparkles.initialVelocity = 25;
			sparkles.initialVelocityVariance = 15;
			sparkles.dispersionAngleVariance = 2*Math.PI
			sparkles.initialScale = .2;
			sparkles.initialScaleVariance = .5;
			sparkles.initialColor = 0xFFAA44;
			sparkles.endColor = 0xFF4400;
			sparkles.endAlpha = 0;
			sparkles.endScale = .2;
			sparkles.endScaleVariance = .3;
			sparkles.addField(_cSparklesGravity);
			node.addChild(sparkles.node);
			
			node.transform.setPosition(p_x,600);
			TweenLite.to(node.transform, 2+Math.random()*2, {x:p_x+Math.random()*100-50, y:Math.random()*250+50, onComplete:explode, onCompleteParams:[smoke, sparkles]});
			_cGenome2D.root.addChild(node);
		}
		
		protected function explode(p_smoke:GSimpleEmitter, p_sparkles:GSimpleEmitter):void {
			p_smoke.emission = 100;
			p_smoke.initialVelocity = 5;
			p_smoke.initialVelocityVariance = 100;
			p_smoke.initialAlpha = .1;
			p_smoke.endScale = 1;
			p_smoke.endScaleVariance = 2;
			p_smoke.forceBurst();
			
			p_sparkles.initialColor = Math.random()*0xFFFFFF;
			p_sparkles.emission = 200;
			p_sparkles.energy = 1.5;
			p_sparkles.energyVariance = 1.5
			p_sparkles.initialScale = .2;
			p_sparkles.initialScaleVariance = .4;
			p_sparkles.endScale = .1;
			p_sparkles.initialVelocity = 80;
			p_sparkles.initialVelocityVariance = 150;
			p_sparkles.special = true;
			p_sparkles.forceBurst();
			
			_cExplode.node.transform.setPosition(p_smoke.node.parent.transform.x, p_smoke.node.parent.transform.y);
			_bExploding = true;
		}
		
		protected function onEnterFrame(event:Event):void {
			if (_bExploding) {
				_cExplode.gravity = 5;
				_cExplode.gravityVariance = 5;
			} else {
				_cExplode.gravity = 0;
				_cExplode.gravityVariance = 0;
			}
			
			_bExploding = false;
		}
	}
}