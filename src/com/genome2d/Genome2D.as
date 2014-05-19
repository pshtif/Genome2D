package com.genome2d {

import com.genome2d.components.GCameraController;
import com.genome2d.context.GContextConfig;
import com.genome2d.context.IContext;
import com.genome2d.error.GError;
import com.genome2d.node.GNode;
import com.genome2d.signals.GMouseSignal;
import com.genome2d.textures.factories.GTextureAtlasFactory;
import com.genome2d.textures.factories.GTextureFactory;

import flash.geom.Matrix;

import org.osflash.signals.Signal;

/**
 * ...
 * @author Peter "sHTiF" Stefcek
 */
public class Genome2D
{
    // Genome2D version
	static public const VERSION:String = "1.0.255";

    // Singleton instance
	static private var g2d_instance:Genome2D;
    // Enforce singleton creation through getInstance
	static private var g2d_instantiable:Boolean = false;

    // Get Genome2D instance
	static public function getInstance():Genome2D {
		g2d_instantiable = true;
		if (g2d_instance == null) new Genome2D();
		g2d_instantiable = false;
		return g2d_instance;
	}

    public var autoUpdateAndRender:Boolean = true;



    // Physics instance
	//public var physics:GPhysics;

    // Genome2D signals
    private var g2d_onInitialized:Signal;
	public function get onInitialized():Signal {
        return g2d_onInitialized;
    }

    private var g2d_onFailed:Signal;
    public function get onFailed():Signal {
        return g2d_onFailed;
    }

    private var g2d_onInvalidated:Signal;
    public function get onInvalidated():Signal {
        return g2d_onInvalidated;
    }

    private var g2d_onUpdate:Signal;
    public function get onUpdate():Signal {
        return g2d_onUpdate;
    }

    private var g2d_onPreRender:Signal;
    public function get onPreRender():Signal {
        return g2d_onPreRender;
    }

    private var g2d_onPostRender:Signal;
    public function get onPostRender():Signal {
        return g2d_onPostRender;
    }

    // Current frame time
	private var g2d_currentTime:Number = 0;
    // Render frame id
	private var g2d_currentFrameId:int = 0;
    public function getCurrentFrameId():int {
        return g2d_currentFrameId;
    }

    // Last delta time
    private var g2d_currentFrameDeltaTime:Number;
    public function getCurrentFrameDeltaTime():Number {
        return g2d_currentFrameDeltaTime;
    }

    private var g2d_root:GNode;
    public function get root():GNode {
        return g2d_root;
    }

	public var g2d_context:IContext;
	public function getContext():IContext {
		return g2d_context;
	}

    private var g2d_cameras:Vector.<GCameraController>;

    public var backgroundRed:Number = 0;
    public var backgroundGreen:Number = 0;
    public var backgroundBlue:Number = 0;
    public var backgroundAlpha:Number = 1;

    public var g2d_renderMatrix:Matrix;
    public var g2d_renderMatrixIndex:int = 0;
    public var g2d_renderMatrixArray:Vector.<Matrix>;

    private var g2d_contextConfig:GContextConfig;

	/**
     *  CONSTRUCTOR
     **/
	public function Genome2D() {
		if (!g2d_instantiable) new GError("Can't instantiate singleton directly");
		g2d_instance = this;

        // Initialize signals
        g2d_onInitialized = new Signal();
        g2d_onFailed = new Signal();
        g2d_onInvalidated = new Signal();
        g2d_onUpdate = new Signal();
        g2d_onPreRender = new Signal();
        g2d_onPostRender = new Signal();
	}

    /**
     *  Initialize context
     **/
	public function init(p_config:GContextConfig):void {
        g2d_renderMatrix = new Matrix();
        g2d_renderMatrixIndex = 0;
        g2d_renderMatrixArray = new Vector.<Matrix>();

        // Initialize root
        if (g2d_root != null) g2d_root.dispose();
        g2d_root = new GNode("root");

        // Initialize camera controller array
        g2d_cameras = new Vector.<GCameraController>();

        if (g2d_context != null) g2d_context.dispose();
        g2d_contextConfig = p_config;
		g2d_context = new p_config.contextClass(g2d_contextConfig);
		g2d_context.onInitialized(g2d_contextInitializedHandler);
		g2d_context.onFailed(g2d_contextFailedHandler);
        g2d_context.onInvalidated(g2d_contextInvalidatedHandler);
		g2d_context.init();
	}

    /**
     *  Context initialized handler
     **/
	private function g2d_contextInitializedHandler():void {
        GTextureFactory.g2d_context = GTextureAtlasFactory.g2d_context = g2d_context;

		g2d_context.onFrame(g2d_frameHandler);
        g2d_context.onMouseInteraction(g2d_contextMouseSignalHandler);
		
		onInitialized.dispatch();
	}

    /**
     *  Context failed to initialize handler
     **/
	private function g2d_contextFailedHandler(p_error:String):void {
        if (g2d_contextConfig.fallbackContextClass != null) {
            g2d_context = new g2d_contextConfig.fallbackContextClass(g2d_contextConfig);
            g2d_context.onInitialized(g2d_contextInitializedHandler);
            g2d_context.onFailed(g2d_contextFailedHandler);
            g2d_context.init();
        }

		onFailed.dispatch(p_error);
	}

    private function g2d_contextInvalidatedHandler():void {
        onInvalidated.dispatch();
    }

    /**
     *  Frame handler called each frame
     **/
	private function g2d_frameHandler(p_deltaTime:Number):void {
        if (autoUpdateAndRender) {
            g2d_currentFrameId++;
		    update(p_deltaTime);
            render();
        }
	}

    /**
     *  Update node graph
     **/
	public function update(p_deltaTime:Number):void {
        g2d_currentFrameDeltaTime = p_deltaTime;
        onUpdate.dispatch(g2d_currentFrameDeltaTime);

        /*
		if (physics != null && g2d_currentDeltaTime > 0) {
			physics.step(g2d_currentDeltaTime);
		}
		/**/
	}

    /**
     *  Render node graph
     **/
	public function render():void {
        var cameraCount:int = g2d_cameras.length;
		g2d_context.begin(backgroundRed, backgroundGreen, backgroundBlue, backgroundAlpha, cameraCount==0);
		onPreRender.dispatch();

        // Check if there is matrix useage in the pipeline
        if (root.transform.g2d_useMatrix > 0) {
            g2d_renderMatrix.identity();
            g2d_renderMatrixArray = new Vector.<Matrix>();
        }

        // If there is no camera render the root node directly
		if (cameraCount==0) {
			root.render(false, false, g2d_context.getDefaultCamera(), false, false);
        // If there are cameras render the root through them
		} else {
			for (var i:int = 0; i<cameraCount; ++i) {
				g2d_cameras[i].render();
			}
		}

        g2d_context.setCamera(g2d_context.getDefaultCamera());
		onPostRender.dispatch();
		g2d_context.end();
	}

    /**
     *  Add camera
     **/
	public function g2d_addCamera(p_camera:GCameraController):void {
        var cameraCount:int = g2d_cameras.length;
        for (var i:int = 0; i<cameraCount; ++i) {
            if (g2d_cameras[i] == p_camera) return;
        }
        g2d_cameras.push(p_camera);
    }

    /**
     *  Remove camera
     **/
    public function g2d_removeCamera(p_camera:GCameraController):void {
        var cameraCount:int = g2d_cameras.length;
        for (var i:int = 0; i<cameraCount; ++i) {
            if (g2d_cameras[i] == p_camera) g2d_cameras.splice(i, 1);
        }
    }

    /**
     *  Context mouse interaction handler
     **/
	private function g2d_contextMouseSignalHandler(p_signal:GMouseSignal):void {
        // If there is no camera process the signal directly by root node
		if (g2d_cameras.length == 0) {
            root.processContextMouseSignal(p_signal.nativeCaptured, p_signal.x, p_signal.y, p_signal, null);
        // If there are cameras we need to process the signal through them
		} else {
            var i:int;
            var cameraCount:int = g2d_cameras.length;
		    for (i = 0; i<cameraCount; ++i) {
				g2d_cameras[i].g2d_capturedThisFrame = false;
			}
            for (i = 0; i<cameraCount; ++i) {
                g2d_cameras[i].captureMouseEvent(g2d_context, p_signal.nativeCaptured, p_signal);
            }
		}
	}

    public function dispose():void {
        if (g2d_root != null) g2d_root.dispose();
        g2d_root = null;

        g2d_onInitialized.removeAll();
        g2d_onFailed.removeAll();
        g2d_onInvalidated.removeAll();
        g2d_onPostRender.removeAll();
        g2d_onPreRender.removeAll();
        g2d_onUpdate.removeAll();

        g2d_context.dispose();
        g2d_context = null;
    }
}
}