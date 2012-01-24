package
{
	import assets.Assets;
	
	import com.flashcore.g2d.components.G2DCamera;
	import com.flashcore.g2d.components.renderables.G2DNativeObject;
	import com.flashcore.g2d.components.renderables.G2DNativeText;
	import com.flashcore.g2d.context.blitting.G2DBlittingContext;
	import com.flashcore.g2d.context.stage3d.G2DStage3DContext;
	import com.flashcore.g2d.context.stage3d.G2DStage3DContextConfig;
	import com.flashcore.g2d.core.G2DNode;
	import com.flashcore.g2d.core.Genome2D;
	import com.flashcore.g2d.signals.G2DMouseSignal;
	import com.flashcore.g2d.textures.G2DTextureBase;
	import com.flashcore.g2d.textures.G2DTextureFilteringType;
	
	import custom.Stats;
	
	import examples.*;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.system.Capabilities;
	import flash.system.TouchscreenType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	[SWF(backgroundColor="#0000FF", frameRate="60", width="800", height="600")]
	public class Genome2DExamples extends Sprite
	{	
		private var __aExamples:Vector.<Example> = new Vector.<Example>();
		private var __iCurrentExample:int = 0;
		
		private var __aContexts:Vector.<Class> = new <Class>[G2DBlittingContext];
		private var __aContextsConfig:Vector.<Object> = new <Object>[null];
		private var __aContextsNames:Vector.<String> = new <String>["Blitting (FlashPlayer 10)"];
		private var __iCurrentContext:int = 0;
		
		public var ui:G2DNode;
		public var content:G2DNode;
		
		private var __cExample:G2DNativeText;
		private var __cVersion:G2DNativeText;
		private var __cContext:G2DNativeText;
		private var __cInfo:G2DNativeText;
		private var __cStats:G2DNativeObject;
		private var __cHideable:G2DNode;
		private var __cHideButton:G2DNativeText;
		
		public function getFps():uint {
			return (__cStats.native as Stats).currentFps;
		}
		
		public function getFilePath(p_file:String):String {
			if (parent is Stage) return loaderInfo.url.substr(0, loaderInfo.url.lastIndexOf("/"))+p_file;
			
			return parent["getFilePath"](p_file);
		}
		
		public function set info(p_info:String):void {
			if (__cInfo) __cInfo.htmlText = p_info;
		}
		
		public function Genome2DExamples() {
			if (stage == null) this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			else onAddedToStage(null);
		}
		
		private function initializeVersionDependency():void {
			var version:int = Capabilities.version.split(" ")[1].split(",")[0];
			if (version>10) {
				__aContexts = new <Class>[G2DStage3DContext, G2DBlittingContext];
				__aContextsConfig = new <Object>[{mode:G2DStage3DContextConfig.AUTO}, null];
				__aContextsNames = new <String>["Stage3D (FlashPlayer 11)", "Blitting (FlashPlayer 10)"];
			}
		}
		
		private function onAddedToStage(event:Event):void {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			initializeVersionDependency();
			/**/
			__aExamples.push(new RenderExample(this));
			__aExamples.push(new BlittingExample(this));
			
			__aExamples.push(new MouseExample(this));
			__aExamples.push(new HierarchyExample(this));
			__aExamples.push(new CollisionExample(this));
			__aExamples.push(new CameraInterpolateExample(this));
			__aExamples.push(new CameraBasicExample(this));
			__aExamples.push(new CameraMouseExample(this));
			__aExamples.push(new CameraViewExample(this));
			__aExamples.push(new TextureExample(this));
			__aExamples.push(new ParticlesExample(this));
			__aExamples.push(new ParticlesGPUExample(this));
			__aExamples.push(new VideoExample(this));
			/**/
			G2DTextureBase.defaultFilteringType = G2DTextureFilteringType.NEAREST;
			
			// Setup a signal callback for initialization
			Genome2D.getInstance().onInitialized.addOnce(onGenomeInitialized);
			Genome2D.getInstance().onFailed.addOnce(onGenomeFailed);
			// Initialize genome with a selected renderer
			Genome2D.getInstance().init(stage, __aContexts[__iCurrentContext], __aContextsConfig[__iCurrentContext]);
			
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
		}
		
		private function onEnterFrame(event:Event):void {
			(__cStats.native as Stats).update(stage);
		}
		
		private function onGenomeFailed():void {
			var dtf:TextFormat = new TextFormat("Arial", 12);
			dtf.align = TextFormatAlign.CENTER;
			dtf.bold = true;
			dtf.color = 0xFFFFFF;
			
			var failed:TextField = new TextField();
			failed.defaultTextFormat = dtf;
			failed.width = stage.stageWidth;
			failed.height = 30;
			failed.y = (stage.stageHeight-30)/2;
			var contextString:String = String(__aContexts[__iCurrentContext]);
			failed.text = "Genome2D initialization failed device doesn't support "+contextString.substring(7, contextString.length-8)+" renderer.";
			addChild(failed);
		}
		
		private function onGenomeInitialized():void {
			Assets.init();
				
			content = new G2DNode("content");
			Genome2D.getInstance().root.addChild(content);
			
			createUI();
			
			__aExamples[__iCurrentExample].init();
			
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		private function createUI():void {
			ui = new G2DNode("ui");
			var uiCamera:G2DCamera = ui.addComponent(G2DCamera) as G2DCamera;
			uiCamera.mask = 2;
			uiCamera.backgroundAlpha = 0;
			ui.transform.x = stage.stageWidth/2;
			ui.transform.y = stage.stageHeight/2;
			ui.cameraGroup = 0xFFFFFF;
			Genome2D.getInstance().root.addChild(ui);
			
			__cHideable = new G2DNode();
			__cHideable.cameraGroup = 2;
			ui.addChild(__cHideable);
			
			var statsNode:G2DNode = new G2DNode();
			statsNode.transform.x = -stage.stageWidth/2+45;
			statsNode.transform.y = -stage.stageHeight/2+60;
			statsNode.cameraGroup = 2;
			statsNode.mouseEnabled = true;
			__cStats = statsNode.addComponent(G2DNativeObject) as G2DNativeObject;
			__cStats.native = new Stats();
			__cStats.updateFrameRate = 5;
			ui.addChild(statsNode);
			
			createDesktopUI();
			if (Capabilities.touchscreenType == TouchscreenType.FINGER) 
				createMobileUI();
			
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function createDesktopUI():void {
			var dtf:TextFormat = new TextFormat("Arial", 12);
			dtf.align = TextFormatAlign.RIGHT;
			dtf.bold = true;
			
			var labelNode:G2DNode = new G2DNode();
			labelNode.cameraGroup = 2;
			__cExample = labelNode.addComponent(G2DNativeText) as G2DNativeText;
			__cExample.textFormat = dtf;
			__cExample.background = true;
			__cExample.backgroundColor = 0xBBBBBB;
			__cExample.autoSize = TextFieldAutoSize.LEFT;
			__cHideable.addChild(labelNode);
			__cExample.htmlText = "<font color='#000000'>["+(__iCurrentExample+1)+"/"+__aExamples.length+"] press Space for next, press H to hide UI";
			labelNode.transform.x = -stage.stageWidth/2+11+__cExample.width/2;
			labelNode.transform.y = stage.stageHeight/2-112.5;
			
			var versionNode:G2DNode = new G2DNode();
			versionNode.cameraGroup = 2;
			__cVersion = versionNode.addComponent(G2DNativeText) as G2DNativeText;
			__cVersion.textFormat = dtf;
			__cVersion.background = true;
			__cVersion.backgroundColor = 0xBBBBBB;
			__cVersion.autoSize = TextFieldAutoSize.LEFT;
			__cHideable.addChild(versionNode);
			__cVersion.htmlText = "<b>Genome2D v"+Genome2D.VERSION+"</b>";
			versionNode.transform.x = stage.stageWidth/2-10-__cVersion.width/2;
			versionNode.transform.y = stage.stageHeight/2-112.5;
			
			dtf.bold = false;
			var contextNode:G2DNode = new G2DNode();
			contextNode.cameraGroup = 2;
			__cContext = contextNode.addComponent(G2DNativeText) as G2DNativeText;
			__cContext.textFormat = dtf;
			__cContext.width = 190;
			__cContext.autoSize = TextFieldAutoSize.LEFT;
			__cContext.background = true;
			__cHideable.addChild(contextNode);
			
			var contextString:String = String(__aContexts[__iCurrentContext]);
			__cContext.htmlText = "[Press C to switch] Renderer: <b>"+__aContextsNames[__iCurrentContext]+"</b>";
			__cContext.node.transform.x = stage.stageWidth/2-__cContext.width/2 - 10;
			__cContext.node.transform.y = -stage.stageHeight/2+10+__cContext.height/2;
			
			dtf.align = TextFormatAlign.LEFT;
			
			var infoNode:G2DNode = new G2DNode();
			infoNode.transform.x = 0;
			infoNode.transform.y = stage.stageHeight/2 - 55;		
			infoNode.cameraGroup = 2;
			__cInfo = infoNode.addComponent(G2DNativeText) as G2DNativeText;
			__cInfo.textFormat = dtf;
			__cInfo.textColor = 0xFFFFFF;
			__cInfo.width = stage.stageWidth-20;
			__cInfo.height = 90;
			__cInfo.background = true;
			__cInfo.backgroundColor = 0x0;
			__cInfo.wordWrap = true;
			__cHideable.addChild(infoNode);
		}
		
		private function createMobileUI():void {
			__cExample.node.transform.y -= 45;
			__cInfo.node.transform.y -= 45;
			__cVersion.node.transform.y -= 45;
			
			createButton(stage.stageWidth/2 - 103, stage.stageHeight/2 - 32.5, "NEXT EXAMPLE", 0xFFFF00, nextExample, false);
			createButton(stage.stageWidth/2 - 300.5, stage.stageHeight/2 - 32.5, "NEXT CONTEXT", 0xFFFF00, nextContext, true);
			__cHideButton = createButton(-stage.stageWidth/2 + 78.5, stage.stageHeight/2 - 32, "HIDE INFO", 0x00FFFF, switchUIVisiblity, false);
			
			createButton(stage.stageWidth/2 - 515, stage.stageHeight/2 - 32.5, "UP", 0xFF0000, onUpClick, true);
			createButton(stage.stageWidth/2 - 450, stage.stageHeight/2 - 32.5, "DOWN", 0xFF0000, onDownClick, true);
		}
		
		private function createButton(p_x:Number, p_y:Number, p_label:String, p_color:uint, p_callback:Function, p_hideable:Boolean):G2DNativeText {
			var dtf:TextFormat = new TextFormat("Arial", 24);
			dtf.align = TextFormatAlign.RIGHT;
			dtf.bold = true;
			
			var buttonNode:G2DNode = new G2DNode();
			buttonNode.mouseEnabled = true;
			buttonNode.cameraGroup = 2;
			buttonNode.transform.x = p_x;
			buttonNode.transform.y = p_y;
			buttonNode.onMouseClick.add(p_callback);
			
			var label:G2DNativeText = buttonNode.addComponent(G2DNativeText) as G2DNativeText;
			label.textFormat = dtf;
			label.background = true;
			label.backgroundColor = p_color;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.htmlText = p_label;
			
			if (p_hideable) __cHideable.addChild(buttonNode);
			else ui.addChild(buttonNode);
			
			return label;
		}
		
		private function nextExample(p_mouseSignal:G2DMouseSignal = null):void {
			__aExamples[__iCurrentExample].dispose();
			++__iCurrentExample;
			
			if (__iCurrentExample==__aExamples.length) __iCurrentExample = 0;
			__aExamples[__iCurrentExample].init();
			
			if (__cExample == null) return;
			__cExample.htmlText = "<font color='#000000'>["+(__iCurrentExample+1)+"/"+__aExamples.length+"] press Space for next";
			__cExample.node.transform.x = -stage.stageWidth/2+10+__cExample.width/2;
		}
		
		private function nextContext(p_mouseSignal:G2DMouseSignal = null):void {
			++__iCurrentContext;
			if (__iCurrentContext==__aContexts.length) __iCurrentContext = 0;
			Genome2D.getInstance().init(stage, __aContexts[__iCurrentContext], __aContextsConfig[__iCurrentContext]);
			
			var contextString:String = String(__aContexts[__iCurrentContext]);
			var configString:String = (__aContextsConfig[__iCurrentContext] == null) ? "" : String(__aContextsConfig[__iCurrentContext].mode);
			if (__cContext == null) return;
			__cContext.htmlText = "[Press C to switch] Renderer: <b>"+__aContextsNames[__iCurrentContext]+"</b>";
			__cContext.node.transform.x = stage.stageWidth/2-__cContext.width/2 - 10;
		}
		
		private function onUpClick(signal:G2DMouseSignal):void {
			stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 0, 38));
		}
		
		private function onDownClick(signal:G2DMouseSignal):void {
			stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 0, 40));
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
					switchUIVisiblity();
					break;
			}
		}
		
		private function switchUIVisiblity(p_mouseSignal:G2DMouseSignal = null):void {
			__cHideable.active = !__cHideable.active;

			if (__cHideable.active) {
				if (__cHideButton) __cHideButton.text = "HIDE INFO";
			} else {
				if (__cHideButton) __cHideButton.text = "SHOW INFO";
			}
		}
	}
}