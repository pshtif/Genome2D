package com.genome2d.components.renderables.particles {

import com.genome2d.context.GContextCamera;
import com.genome2d.node.GNode;
import com.genome2d.textures.GTexture;

/**
 * ...
 * @author Peter "sHTiF" Stefcek
 */
public class GParticle
{
    public var g2d_next:GParticle;
    public var g2d_previous:GParticle;

    public var texture:GTexture;

    public var overrideRender:Boolean = false;

    public var scaleX:Number;
    public var scaleY:Number;

    public var x:Number = 0;
    public var y:Number = 0;
    public var rotation:Number = 0;
    public var red:Number = 1;
    public var green:Number = 1;
    public var blue:Number = 1;
    public var alpha:Number = 1;

    public var velocityX:Number = 0;
    public var velocityY:Number = 0;

    public var totalEnergy:Number = 0;
    public var accumulatedEnergy:Number = 0;

    public var accumulatedTime:Number;
    public var currentFrame:Number;

    public var overrideUvs:Boolean = false;
    public var uvX:Number;
    public var uvY:Number;
    public var uvScaleX:Number;
    public var uvScaleY:Number;

    public var die:Boolean = false;

    public var g2d_nextAvailableInstance:GParticle;

    private var g2d_id:int = 0;
    private var g2d_pool:GParticlePool;

    public function GParticle(p_pool:GParticlePool):void {
        g2d_pool = p_pool;
    }
    public function toString():String {
        return "["+g2d_id+"]";
    }

    public function init(p_particleSystem:GParticleSystem):void {
        texture = p_particleSystem.texture;
        x = p_particleSystem.node.transform.g2d_worldX;
        y = p_particleSystem.node.transform.g2d_worldY;
        scaleX = scaleY = 1;
        rotation = 0;
        velocityX = 0;
        velocityY = 0;
        totalEnergy = 0;
        accumulatedEnergy = 0;
        red = 1;
        green = 1;
        blue = 1;
        alpha = 1;

        accumulatedTime = 0;
        currentFrame = 0;
    }

    public function dispose():void {
        die = false;
        if (g2d_next != null) g2d_next.g2d_previous = g2d_previous;
        if (g2d_previous != null) g2d_previous.g2d_next = g2d_next;
        g2d_next = null;
        g2d_previous = null;
        g2d_nextAvailableInstance = g2d_pool.g2d_availableInstance;
        g2d_pool.g2d_availableInstance = this;
    }

    public function render(p_camera:GContextCamera, p_particleSystem:GParticleSystem):void {}
}
}