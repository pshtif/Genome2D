package
{
	import assets.Assets;
	
	import com.genome2d.components.GCamera;
	import com.genome2d.components.renderables.flash.GFlashObject;
	import com.genome2d.components.renderables.flash.GFlashText;
	import com.genome2d.context.GContextConfig;
	import com.genome2d.core.GNode;
	import com.genome2d.core.Genome2D;
	import com.genome2d.signals.GMouseSignal;
	import com.genome2d.textures.GTextureBase;
	import com.genome2d.textures.GTextureFilteringType;
	
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
	import flash.ui.Keyboard;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	[SWF(backgroundColor="#000000", frameRate="60", width="800", height="600")]
	public class Genome2DExamples extends Sprite
	{	
		private var __aExamples:Vector.<Example> = new Vector.<Example>();
		private var __iCurrentExample:int = 0;
		
		public var ui:GNode;
		public var content:GNode;
		
		private var __cExample:GFlashText;
		private var __cVersion:GFlashText;
		private var __cInfo:GFlashText;
		private var __cStats:GFlashObject;
		private var __cHideable:GNode;
		private var __cHideButton:GFlashText;
		
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
		
		private function sortOnDepth(a:Object, b:Object):Number {
			var adepth:Number = a.depth;
			var bdepth:Number = b.depth;
			
			if(adepth > bdepth) {
				return 1;
			} else if(adepth < bdepth) {
				return -1;
			} else  {
				//aPrice == bPrice
				return 0;
			}
		}
		
		private function onAddedToStage(event:Event):void {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
		
			__aExamples.push(new RenderExample(this));
			__aExamples.push(new BlittingExample(this));
			__aExamples.push(new MouseExample(this));
			__aExamples.push(new HierarchyExample(this));
			__aExamples.push(new CollisionExample(this));
			__aExamples.push(new CameraInterpolateExample(this));
			__aExamples.push(new CameraViewPortsExample(this));
			__aExamples.push(new CameraMouseExample(this));
			__aExamples.push(new CameraViewExample(this));
			__aExamples.push(new TextureExample(this));
			__aExamples.push(new ParticlesExample(this));
			__aExamples.push(new ParticlesGPUExample(this));
			__aExamples.push(new VideoExample(this));		
			__aExamples.push(new DepthSortExample(this));
			/**/
			GTextureBase.defaultFilteringType = GTextureFilteringType.NEAREST;
			
			Genome2D.getInstance().autoResize = true;
			// Setup a signal callback for initialization
			Genome2D.getInstance().onInitialized.addOnce(onGenomeInitialized);
			Genome2D.getInstance().onFailed.addOnce(onGenomeFailed);
			// Initialize genome with a selected renderer
			var config:GContextConfig = new GContextConfig();
			config.separateNoAlphaShaders = true;
			Genome2D.getInstance().init(stage, config);
			
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
			failed.text = "Genome2D initialization failed device doesn't support Stage3D renderer.";
			addChild(failed);
		}
		
		private function onGenomeInitialized():void {
			Assets.init();
				
			content = new GNode("content");
			Genome2D.getInstance().root.addChild(content);
			
			createUI();
			
			__aExamples[__iCurrentExample].init();
			
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		private function createUI():void {
			ui = new GNode("ui");
			var uiCamera:GCamera = ui.addComponent(GCamera) as GCamera;
			uiCamera.mask = 2;
			uiCamera.backgroundAlpha = 0;
			ui.transform.x = stage.stageWidth/2;
			ui.transform.y = stage.stageHeight/2;
			ui.cameraGroup = 2;
			Genome2D.getInstance().root.addChild(ui);
			
			__cHideable = new GNode();
			__cHideable.cameraGroup = 2;
			ui.addChild(__cHideable);
			
			var statsNode:GNode = new GNode("stats");
			statsNode.transform.x = -stage.stageWidth/2+45;
			statsNode.transform.y = -stage.stageHeight/2+60;
			statsNode.cameraGroup = 2;
			__cStats = statsNode.addComponent(GFlashObject) as GFlashObject;
			__cStats.node.active = false;
			__cStats.native = new Stats();
			__cStats.updateFrameRate = 1;
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
			
			var labelNode:GNode = new GNode();
			labelNode.cameraGroup = 2;
			__cExample = labelNode.addComponent(GFlashText) as GFlashText;
			__cExample.textFormat = dtf;
			__cExample.background = true;
			__cExample.backgroundColor = 0xBBBBBB;
			__cExample.autoSize = TextFieldAutoSize.LEFT;
			__cHideable.addChild(labelNode);
			__cExample.htmlText = "<font color='#000000'>["+(__iCurrentExample+1)+"/"+__aExamples.length+"] press Space for next, press H to hide UI";
			labelNode.transform.x = -stage.stageWidth/2+11+__cExample.width/2;
			labelNode.transform.y = stage.stageHeight/2-112.5;
			
			var versionNode:GNode = new GNode();
			versionNode.cameraGroup = 2;
			__cVersion = versionNode.addComponent(GFlashText) as GFlashText;
			__cVersion.textFormat = dtf;
			__cVersion.background = true;
			__cVersion.backgroundColor = 0xBBBBBB;
			__cVersion.autoSize = TextFieldAutoSize.LEFT;
			__cHideable.addChild(versionNode);
			__cVersion.htmlText = "<b>Genome2D v"+Genome2D.VERSION+"</b>";
			versionNode.transform.x = stage.stageWidth/2-10-__cVersion.width/2;
			versionNode.transform.y = stage.stageHeight/2-112.5;
			
			dtf.bold = false;			
			dtf.align = TextFormatAlign.LEFT;
			
			var infoNode:GNode = new GNode();
			infoNode.transform.x = 0;
			infoNode.transform.y = stage.stageHeight/2 - 55;		
			infoNode.cameraGroup = 2;
			__cInfo = infoNode.addComponent(GFlashText) as GFlashText;
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
			__cHideButton = createButton(-stage.stageWidth/2 + 78.5, stage.stageHeight/2 - 32, "HIDE INFO", 0x00FFFF, switchUIVisiblity, false);
			
			createButton(stage.stageWidth/2 - 600, stage.stageHeight/2 - 32.5, "ACTION", 0xFF0000, onActionClick, true);
			createButton(stage.stageWidth/2 - 515, stage.stageHeight/2 - 32.5, "UP", 0xFF0000, onUpClick, true);
			createButton(stage.stageWidth/2 - 450, stage.stageHeight/2 - 32.5, "DOWN", 0xFF0000, onDownClick, true);
		}
		
		private function createButton(p_x:Number, p_y:Number, p_label:String, p_color:uint, p_callback:Function, p_hideable:Boolean):GFlashText {
			var dtf:TextFormat = new TextFormat("Arial", 24);
			dtf.align = TextFormatAlign.RIGHT;
			dtf.bold = true;
			
			var buttonNode:GNode = new GNode();
			buttonNode.mouseEnabled = true;
			buttonNode.cameraGroup = 2;
			buttonNode.transform.x = p_x;
			buttonNode.transform.y = p_y;
			buttonNode.onMouseClick.add(p_callback);
			
			var label:GFlashText = buttonNode.addComponent(GFlashText) as GFlashText;
			label.textFormat = dtf;
			label.background = true;
			label.backgroundColor = p_color;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.htmlText = p_label;
			
			if (p_hideable) __cHideable.addChild(buttonNode);
			else ui.addChild(buttonNode);
			
			return label;
		}
		
		private function nextExample(p_mouseSignal:GMouseSignal = null):void {
			__aExamples[__iCurrentExample].dispose();
			++__iCurrentExample;
			
			if (__iCurrentExample==__aExamples.length) __iCurrentExample = 0;
			__aExamples[__iCurrentExample].init();
			
			if (__cExample == null) return;
			__cExample.htmlText = "<font color='#000000'>["+(__iCurrentExample+1)+"/"+__aExamples.length+"] press Space for next";
			__cExample.node.transform.x = -stage.stageWidth/2+10+__cExample.width/2;
		}
		
		private function onUpClick(signal:GMouseSignal):void {
			stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 0, 38));
		}
		
		private function onDownClick(signal:GMouseSignal):void {
			stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 0, 40));
		}
		
		private function onActionClick(signal:GMouseSignal):void {
			stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 0, 65));
		}
		
		private function onKeyUp(event:KeyboardEvent):void {
			switch (event.keyCode) {
				case 32:
					nextExample();
					break;
				case 67:
					break;
				case 72:
					switchUIVisiblity();
					break;
				case Keyboard.S:
					Genome2D.getInstance().context.config.enableStats = !Genome2D.getInstance().context.config.enableStats;
					break;
			}
		}
		
		private function switchUIVisiblity(p_mouseSignal:GMouseSignal = null):void {
			__cHideable.active = !__cHideable.active;

			if (__cHideable.active) {
				if (__cHideButton) __cHideButton.text = "HIDE INFO";
			} else {
				if (__cHideButton) __cHideButton.text = "SHOW INFO";
			}
		}
	}  
}