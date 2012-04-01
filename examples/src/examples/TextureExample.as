package examples
{
	import assets.Assets;
	
	import com.genome2d.components.renderables.GSprite;
	import com.genome2d.core.GNode;
	import com.genome2d.signals.GMouseSignal;
	import com.greensock.TweenLite;
	
	import flash.display.Shape;
	import flash.events.KeyboardEvent;
	import flash.geom.Matrix;
	
	public class TextureExample extends Example
	{
		private var __iColor:int = 0;
		private var __iSize:int = 16;
		private var __bMove:Boolean = true;
		
		public function TextureExample(p_wrapper:Genome2DExamples):void {
			super(p_wrapper);
		}
		
		private function updateInfo():void {
			_cWrapper.info = "<font color='#00FFFF'><b>TextureExample</b>[ "+__iSize+" ]\n"+
			"<font color='#FFFFFF'>This is a demo of dynamic texture internal bitmap data and its invalidation to GPU.\n"+
			"<font color='#FFFF00'>Paint into the texture using mouse. Us ARROW UP/DOWN to increase/decrease brush size. Press P to pause movement.";
		}
		
		override public function init():void {
			super.init();
	
			
			
			var node:GNode = new GNode();
			node.transform.x = _iWidth/2;
			node.transform.y = _iHeight/2;
			node.transform.scaleX = node.transform.scaleY = 1.5;
			var sprite:GSprite = node.addComponent(GSprite) as GSprite;
			sprite.setTexture(Assets.customTexture);
			node.mouseEnabled = true;
			node.onMouseMove.add(onMouseMove);
			_cContainer.addChild(node);
			
			createColor(_iWidth-40,100, 1, 1, 1);
			createColor(_iWidth-40,140, 1, 0, 0);
			createColor(_iWidth-40,180, 0, 1, 0);
			createColor(_iWidth-40,220, 0, 0, 1);
			createColor(_iWidth-40,260, 1, 1, 0);
			createColor(_iWidth-40,300, 1, 0, 1);
			createColor(_iWidth-40,340, 0, 1, 1);
			
			_cGenome.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_cGenome.onPreUpdate.add(onUpdate);
			
			updateInfo();
		}
		
		private function createColor(p_x:int, p_y:int, p_red:Number, p_green:Number, p_blue:Number):void {
			var node:GNode = new GNode();
			node.transform.x = p_x;
			node.transform.y = p_y;
			node.transform.red = p_red;
			node.transform.green = p_green;
			node.transform.blue = p_blue;
			node.transform.rotation = Math.random()*Math.PI*2;
			var sprite:GSprite = node.addComponent(GSprite) as GSprite;
			sprite.setTexture(Assets.whiteTexture);
			node.mouseEnabled = true;
			node.onMouseClick.add(onColorClick);
			node.onMouseOver.add(onColorOver);
			node.onMouseOut.add(onColorOut);
			_cContainer.addChild(node);
		}
		
		override public function dispose():void {
			super.dispose();
			
			_cGenome.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_cGenome.onPreUpdate.removeAll();
		}
		
		private function onMouseMove(p_signal:GMouseSignal):void {
			if (!p_signal.buttonDown) return;
			var shape:Shape = new Shape();
			shape.graphics.beginFill(__iColor);
			shape.graphics.drawCircle(0,0, __iSize);
			
			var matrix:Matrix = new Matrix();
			matrix.translate(p_signal.localX, p_signal.localY);
			
			Assets.customTexture.bitmapData.draw(shape, matrix);
			Assets.customTexture.invalidate();
		}
		
		private function onColorClick(p_signal:GMouseSignal):void {
			__iColor = ((p_signal.dispatcher.transform.red*255)<<16) + ((p_signal.dispatcher.transform.green*255)<<8) + (p_signal.dispatcher.transform.blue*255);
		}
		
		private function onColorOver(p_signal:GMouseSignal):void {
			TweenLite.to(p_signal.dispatcher, .25, {scaleX:2, scaleY:2});
		}
		
		private function onColorOut(p_signal:GMouseSignal):void {
			TweenLite.to(p_signal.dispatcher, .25, {scaleX:1, scaleY:1});
		}
		
		private function onUpdate(p_deltaTime:Number):void {
			if (!__bMove) return;
			var length:int = _cContainer.numChildren;
			for (var node:GNode = _cContainer.firstChild; node; node = node.next) {
				node.transform.rotation+=.01;
			}
		}
		
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