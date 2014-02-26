package com.genome2d.physics {

import com.genome2d.node.GNode;
import com.genome2d.components.GComponent;

/**
 * ...
 * @author 
 */
public class GBody extends GComponent
{
	public function get x():Number {
		return 0;
	}
	public function set x(p_value:Number):void {
	}

	public function get y():Number {
		return 0;
	}
	public function set y(p_value:Number):void {
	}
	
	public function get scaleX():Number {
		return 0;
	}
	public function set scaleX(p_value:Number):void {
	}

	public function get scaleY():Number {
		return 0;
	}
	public function set scaleY(p_value:Number):void {
	}

	public function get rotation():Number {
		return 0;
	}
	public function set rotation(p_value:Number):void {
	}
	
	public function isDynamic():Boolean {
		return false;
	}
	
	public function isKinematic():Boolean {
		return false;
	}
	
	public function addToSpace():void {
	}

	public function removeFromSpace():void {
	}
		
	public function GBody(p_node:GNode) {
		super(p_node);
	}
	
}
}