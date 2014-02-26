/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.components {

import com.genome2d.context.IContext;
import com.genome2d.context.GContextCamera;
import com.genome2d.node.GNode;
import com.genome2d.signals.GMouseSignal;

import flash.geom.Rectangle;

public class GCameraController extends GComponent
{
	/**
	 * 	Red component of viewport background color
	 */
	public var backgroundRed:Number = 0;
	/**
	 * 	Green component of viewport background color
	 */
	public var backgroundGreen:Number = 0;
	/**
	 * 	Blue component of viewport background color
	 */
	public var backgroundBlue:Number = 0;
	/**
	 * 	@private
	 */
	public var backgroundAlpha:Number = 0;
	
	/**
	 * 	Get a viewport color
	 */
	public function getBackgroundColor():int {
		var alpha:int = (backgroundAlpha*255)<<24;
		var red:int = (backgroundRed*255)<<16;
		var green:int = (backgroundGreen*255)<<8;
		var blue:int = (backgroundBlue*255);

		return alpha+red+green+blue;
	}

    private var g2d_viewRectangle:Rectangle;

	/**
	 * 	@private
	 */	
	public var g2d_capturedThisFrame:Boolean = false;
	
	public var g2d_renderedNodesCount:int;

    private var g2d_contextCamera:GContextCamera;

    public function setView(p_normalizedX:Number, p_normalizedY:Number, p_normalizedWidth:Number, p_normalizedHeight:Number):void {
        // TODO can't add to >1
        g2d_contextCamera.normalizedViewX = p_normalizedX;
        g2d_contextCamera.normalizedViewY = p_normalizedY;
        g2d_contextCamera.normalizedViewWidth = p_normalizedWidth;
        g2d_contextCamera.normalizedViewHeight = p_normalizedHeight;
    }

	public function get zoom():Number {
		return g2d_contextCamera.scaleX;
	}
	public function set zoom(p_value:Number):void {
		g2d_contextCamera.scaleX = g2d_contextCamera.scaleY = p_value;
	}
	
	/**
	 * 	@private
	 */
	public function GCameraController(p_node:GNode) {
		super(p_node);

        g2d_contextCamera = new GContextCamera();
        g2d_viewRectangle = new Rectangle();

		if (node != node.core.root && node.isOnStage()) node.core.g2d_addCamera(this);
		
		node.onAddedToStage.add(onAddedToStage);
		node.onRemovedFromStage.add(onRemovedFromStage);
	}
	
	/**
	 * 	@private
	 */
	public function render():void {
		if (!node.isActive()) return;
		g2d_renderedNodesCount = 0;

		g2d_contextCamera.x = node.transform.g2d_worldX;
        g2d_contextCamera.y = node.transform.g2d_worldY;
        g2d_contextCamera.rotation = node.transform.g2d_worldRotation;

		node.core.getContext().setCamera(g2d_contextCamera);
		node.core.root.render(false, false, g2d_contextCamera, false, false);
	}
	
	/**
	 * 	@private
	 */
	public function captureMouseEvent(p_context:IContext, p_captured:Boolean, p_signal:GMouseSignal):Boolean {
		if (g2d_capturedThisFrame || !node.isActive()) return false;
		g2d_capturedThisFrame = true;

        var stageRect:Rectangle = p_context.getStageViewRect();
        g2d_viewRectangle.setTo(stageRect.width*g2d_contextCamera.normalizedViewX,
                                stageRect.height*g2d_contextCamera.normalizedViewY,
                                stageRect.width*g2d_contextCamera.normalizedViewWidth,
                                stageRect.height*g2d_contextCamera.normalizedViewHeight);

		if (!g2d_viewRectangle.contains(p_signal.x, p_signal.y)) return false;

	    var tx:Number = p_signal.x - g2d_viewRectangle.x - g2d_viewRectangle.width/2;
        var ty:Number = p_signal.y - g2d_viewRectangle.y - g2d_viewRectangle.height/2;

		var cos:Number = Math.cos(-node.transform.g2d_worldRotation);
		var sin:Number = Math.sin(-node.transform.g2d_worldRotation);
		
		var rx:Number = (tx*cos - ty*sin);
		var ry:Number = (ty*cos + tx*sin);
		
		rx /= zoom;
		ry /= zoom;

		return node.core.root.processContextMouseSignal(p_captured, rx+node.transform.g2d_worldX, ry+node.transform.g2d_worldY, p_signal, g2d_contextCamera);
	}
	
	/**
	 *
	 */
	override public function dispose():void {
		node.core.g2d_removeCamera(this);
		
		node.onAddedToStage.remove(onAddedToStage);
		node.onRemovedFromStage.remove(onRemovedFromStage);

		super.dispose();
	}
	
	private function onAddedToStage():void {
		node.core.g2d_addCamera(this);
	}
	
	private function onRemovedFromStage():void {
		node.core.g2d_removeCamera(this);
	}
}
}