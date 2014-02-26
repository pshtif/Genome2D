package com.genome2d.physics {

/**
 * ...
 * @author 
 */
public class GPhysics
{
	private var g2d_running:Boolean = true;
	
	public var minimumTimeStep:int = 0;
	
	public function GPhysics() {
		
	}
	
	public function step(p_deltaTime:Number):void {
		
	}
	
	public function setGravity(p_x:Number, p_y:Number):void {
		
	}
	
	public function stop():void {
		g2d_running = false;
	}
	
	public function start():void {
		g2d_running = true;
	}
	
	public function dispose():void {
		
	}
}
}