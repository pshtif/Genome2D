package
{
	import com.flashcore.g2d.context.bitmap.G2DBitmapContext;
	import com.flashcore.g2d.context.blitting.G2DBlittingContext;
	import com.flashcore.g2d.context.stage3d.G2DStage3DContext;
	import com.flashcore.g2d.context.stage3d.G2DStage3DContextConfig;
	import com.flashcore.g2d.core.G2DNode;
	import com.flashcore.g2d.core.Genome2D;
	
	import examples.*;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import net.hires.debug.Stats;
	
	[SWF(backgroundColor="#000000", frameRate="60", width="800", height="600")]
	public class Genome2DExamples extends Sprite
	{
		private var __aExamples:Vector.<Example> = new Vector.<Example>();
		private var __iCurrentExample:int = 9;
		
		private var __aContexts:Vector.<Class> = new <Class>[G2DStage3DContext, G2DStage3DContext, G2DBitmapContext, G2DBlittingContext];
		private var __aContextsConfig:Vector.<Object> = new <Object>[{mode:G2DStage3DContextConfig.AUTO}, {mode:G2DStage3DContextConfig.SOFTWARE}, null, null];
		private var __iCurrentContext:int = 0;
		
		private var __spUI:Sprite;
		private var __tfLabel:TextField;
		private var __tfContext:TextField;
		private var __tfInfo:TextField;
		
		public function set info(p_info:String):void {
			if (__tfInfo) __tfInfo.htmlText = p_info;
		}
		
		public function Genome2DExamples() {
			if (stage == null) this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			else onAddedToStage(null);
		}
		
		private function onAddedToStage(event:Event):void {
			__aExamples.push(new BasicExample(this));
			__aExamples.push(new MouseExample(this));
			__aExamples.push(new HierarchyExample(this));
			__aExamples.push(new CollisionExample(this));
			__aExamples.push(new CameraInterpolateExample(this));
			__aExamples.push(new CameraBasicExample(this));
			__aExamples.push(new CameraMouseExample(this));
			__aExamples.push(new CameraViewExample(this));
			__aExamples.push(new TextureExample(this));
			__aExamples.push(new ParticleExample(this));
			__aExamples.push(new BlittingExample(this));
			createUI();
			
			// Setup a signal callback for initialization
			Genome2D.getInstance().onInitialized.addOnce(onInitialized);
			// Initialize genome with a selected renderer
			Genome2D.getInstance().init(stage, __aContexts[__iCurrentContext], __aContextsConfig[__iCurrentContext]);
		}
		
		private function createUI():void {
			__spUI = new Sprite();
			addChild(__spUI);
			
			var dtf:TextFormat = new TextFormat("Arial", 12);
			dtf.align = TextFormatAlign.RIGHT;
			dtf.bold = true;
			
			__tfLabel = new TextField();
			__tfLabel.defaultTextFormat = dtf;
			__tfLabel.background = true;
			__tfLabel.backgroundColor = 0xBBBBBB;
			__tfLabel.x = 10;
			__tfLabel.y = 478;
			__tfLabel.autoSize = TextFieldAutoSize.LEFT;
			__tfLabel.htmlText = "<font color='#000000'>["+(__iCurrentExample+1)+"/"+__aExamples.length+"] press Space for next, press H to hide UI";
			__spUI.addChild(__tfLabel);
			
			dtf.bold = false;
			__tfContext = new TextField();
			__tfContext.defaultTextFormat = dtf;
			__tfContext.selectable = false;
			__tfContext.x = 600;
			__tfContext.width = 190;
			__tfContext.y = 10;
			__tfContext.autoSize = TextFieldAutoSize.RIGHT;
			__tfContext.background = true;
			
			var contextString:String = String(__aContexts[__iCurrentContext]);
			var configString:String = (__aContextsConfig[__iCurrentContext] == null) ? "" : String(__aContextsConfig[__iCurrentContext].mode);
			__tfContext.htmlText = "[Press C to switch] Renderer: <b>"+contextString.substring(7, contextString.length-8)+" "+configString.toUpperCase()+"</b>";
			__spUI.addChild(__tfContext);
			
			dtf.align = TextFormatAlign.LEFT;
			
			__tfInfo = new TextField();
			__tfInfo.defaultTextFormat = dtf;
			__tfInfo.selectable = false;
			__tfInfo.x = 10;
			__tfInfo.y = 500;
			__tfInfo.textColor = 0xFFFFFF;
			__tfInfo.width = 780;
			__tfInfo.height = 90;
			__tfInfo.background = true;
			__tfInfo.backgroundColor = 0x0;
			__tfInfo.wordWrap = true;
			__spUI.addChild(__tfInfo);
			
			__spUI.addChild(new Stats());
		}
		
		private function onInitialized():void {
			__aExamples[__iCurrentExample].init();
			
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		private function nextExample():void {
			__aExamples[__iCurrentExample].dispose();
			++__iCurrentExample;
			if (__iCurrentExample==__aExamples.length) __iCurrentExample = 0;
			__aExamples[__iCurrentExample].init();
			
			__tfLabel.htmlText = "<font color='#000000'>["+(__iCurrentExample+1)+"/"+__aExamples.length+"] press Space for next";
		}
		
		private function nextContext():void {
			++__iCurrentContext;
			if (__iCurrentContext==__aContexts.length) __iCurrentContext = 0;
			Genome2D.getInstance().init(stage, __aContexts[__iCurrentContext], __aContextsConfig[__iCurrentContext]);
			
			var contextString:String = String(__aContexts[__iCurrentContext]);
			var configString:String = (__aContextsConfig[__iCurrentContext] == null) ? "" : String(__aContextsConfig[__iCurrentContext].mode);
			__tfContext.htmlText = "[Press C to switch] Renderer: <b>"+contextString.substring(7, contextString.length-8)+" "+configString.toUpperCase()+"</b>";
		}
		
		private function onKeyUp(event:KeyboardEvent):void {
			switch (event.keyCode) {
				case 32:
					nextExample();
					break;
				case 67:
					nextContext();
					break;
				case 72:
					__spUI.visible = !__spUI.visible;
					break;
			}
		}
	}
}