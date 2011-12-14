package examples
{
	import com.flashcore.g2d.components.G2DComponent;
	import com.flashcore.g2d.components.G2DMovieClip;
	import com.flashcore.g2d.components.G2DSprite;
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
	import flash.events.KeyboardEvent;
	import flash.geom.Matrix;
	
	public class TextureExample extends Example
	{
		private var __cCustomTexture:G2DTexture;
		private var __cColorTexture:G2DTexture;
		
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
	
			__cCustomTexture = G2DTexture.createFromBitmapData("custom", new BitmapData(256, 256, true, 0xFFFFFFFF));
			
			var node:G2DNode = new G2DNode();
			node.transform.x = 400;
			node.transform.y = 300;
			node.transform.scaleX = node.transform.scaleY = 1.5;
			var sprite:G2DSprite = node.addComponent(G2DSprite) as G2DSprite;
			sprite.setTexture(__cCustomTexture);
			node.mouseEnabled = true;
			node.onMouseMove.add(onMouseMove);
			_cContainer.addChild(node);
			
			__cColorTexture = G2DTexture.createFromBitmapData("color", new BitmapData(16,16, true, 0xFFFFFFFF));
			
			createColor(760,100, 1, 1, 1);
			createColor(760,140, 1, 0, 0);
			createColor(760,180, 0, 1, 0);
			createColor(760,220, 0, 0, 1);
			createColor(760,260, 1, 1, 0);
			createColor(760,300, 1, 0, 1);
			createColor(760,340, 0, 1, 1);
			
			_cGenome.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_cGenome.onUpdated.add(onUpdate);
			
			updateInfo();
		}
		
		private function createColor(p_x:int, p_y:int, p_red:Number, p_green:Number, p_blue:Number):void {
			var node:G2DNode = new G2DNode();
			node.transform.x = p_x;
			node.transform.y = p_y;
			node.transform.red = p_red;
			node.transform.green = p_green;
			node.transform.blue = p_blue;
			node.transform.rotation = Math.random()*Math.PI*2;
			var sprite:G2DSprite = node.addComponent(G2DSprite) as G2DSprite;
			sprite.setTexture(__cColorTexture);
			node.mouseEnabled = true;
			node.onMouseClick.add(onColorClick);
			node.onMouseOver.add(onColorOver);
			node.onMouseOut.add(onColorOut);
			_cContainer.addChild(node);
		}
		
		override public function dispose():void {
			super.dispose();
			
			__cCustomTexture.dispose();
			__cColorTexture.dispose();
			
			_cGenome.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_cGenome.onUpdated.removeAll();
		}
		
		private function onMouseMove(p_signal:G2DMouseSignal):void {
			if (!p_signal.buttonDown) return;
			var shape:Shape = new Shape();
			shape.graphics.beginFill(__iColor);
			shape.graphics.drawCircle(0,0, __iSize);
			
			var matrix:Matrix = new Matrix();
			matrix.translate(p_signal.localX, p_signal.localY);
			
			__cCustomTexture.bitmapData.draw(shape, matrix);
			__cCustomTexture.invalidate();
		}
		
		private function onColorClick(p_signal:G2DMouseSignal):void {
			__iColor = ((p_signal.dispatcher.transform.red*255)<<16) + ((p_signal.dispatcher.transform.green*255)<<8) + (p_signal.dispatcher.transform.blue*255);
		}
		
		private function onColorOver(p_signal:G2DMouseSignal):void {
			TweenLite.to(p_signal.dispatcher.transform, .25, {scaleX:2, scaleY:2});
		}
		
		private function onColorOut(p_signal:G2DMouseSignal):void {
			TweenLite.to(p_signal.dispatcher.transform, .25, {scaleX:1, scaleY:1});
		}
		
		private function onUpdate(p_deltaTime:Number):void {
			if (!__bMove) return;
			var length:int = _cContainer.numChildren;
			for (var i:int = 0; i<length; ++i) {
				_cContainer.getChildAt(i).transform.rotation+=.01;
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