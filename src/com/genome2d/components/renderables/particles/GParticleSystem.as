package com.genome2d.components.renderables.particles {

import flash.display3D.textures.RectangleTexture;
import flash.geom.Rectangle;
import com.genome2d.geom.GCurve;
import com.genome2d.components.GComponent;
import com.genome2d.node.GNode;
import com.genome2d.textures.GTexture;
import com.genome2d.components.renderables.IRenderable;
import com.genome2d.context.GContextCamera;

/**
 * ...
 * @author Peter "sHTiF" Stefcek
 */
public class GParticleSystem extends GComponent implements IRenderable
{
    public var blendMode:int = 1;

    override public function bindFromPrototype(p_prototype:XML):void {
        super.bindFromPrototype(p_prototype);
    }

    public var emit:Boolean = true;

    private var g2d_initializers:Vector.<IGInitializer>;
    private var g2d_initializersCount:int = 0;
    public function addInitializer(p_initializer:IGInitializer):void {
        g2d_initializers.push(p_initializer);
        g2d_initializersCount++;
    }

    private var g2d_affectors:Vector.<IGAffector>;
    private var g2d_affectorsCount:int = 0;
    public function addAffector(p_affector:IGAffector):void {
        g2d_affectors.push(p_affector);
        g2d_affectorsCount++;
    }

/**
         *  Duration of the particle system in seconds
         */
    public var duration:Number = 0;
    public var loop:Boolean = true;

    public var emission:GCurve;
    public var emissionPerDuration:Boolean = true;

    public var particlePool:GParticlePool;

    public var g2d_accumulatedTime:Number = 0;
    public var g2d_accumulatedSecond:Number = 0;
    public var g2d_accumulatedEmission:Number = 0;

    public var g2d_firstParticle:GParticle;
    public var g2d_lastParticle:GParticle;

    public var texture:GTexture;

    public function GParticleSystem(p_node:GNode) {
        super(p_node);

        particlePool = GParticlePool.g2d_defaultPool;

        g2d_initializers = new Vector.<IGInitializer>();
        g2d_affectors = new Vector.<IGAffector>();

        node.core.onUpdate.add(update);
    }

    public function reset():void {
        g2d_accumulatedTime = 0;
        g2d_accumulatedSecond = 0;
        g2d_accumulatedEmission = 0;
    }

    public function burst(p_emission:int):void {
        for (var i:int = 0; i<p_emission; ++i) {
            activateParticle();
        }
    }

    private function update(p_deltaTime:Number):void {
        if (emit && emission != null ) {
            var dt:Number = p_deltaTime * .001;
            g2d_accumulatedTime += dt;
            g2d_accumulatedSecond += dt;
            if (loop && duration!=0 && g2d_accumulatedTime>duration) g2d_accumulatedTime-=duration;
            if (duration==0 || g2d_accumulatedTime<duration) {
                //while (nAccumulatedTime>duration) nAccumulatedTime-=duration;
                //var currentEmission:Number = emission.calculate(nAccumulatedTime/duration);
                while (g2d_accumulatedSecond>1) g2d_accumulatedSecond-=1;
                var currentEmission:Number = (emissionPerDuration && duration!=0) ? emission.calculate(g2d_accumulatedTime/duration) : emission.calculate(g2d_accumulatedSecond);

                if (currentEmission<0) currentEmission = 0;
                g2d_accumulatedEmission += currentEmission * dt;

                while (g2d_accumulatedEmission > 0) {
                    activateParticle();
                    g2d_accumulatedEmission--;
                }
            }
        }
        var particle:GParticle = g2d_firstParticle;
        while (particle!=null) {
            var next:GParticle = particle.g2d_next;
            for (var i:int = 0; i<g2d_affectorsCount; ++i) {
                g2d_affectors[i].update(this, particle, p_deltaTime);
            }
            // If particle died during update remove it
            if (particle.die) deactivateParticle(particle);
            particle = next;
        }
    }

    // TODO add matrix transformations
    public function render(p_camera:GContextCamera, p_useMatrix:Boolean):void {
        var particle:GParticle = g2d_firstParticle;
        while (particle!=null) {
            var next:GParticle = particle.g2d_next;

            if (particle.overrideRender) {
                particle.render(p_camera, this);
            } else {
                var tx:Number = node.transform.g2d_worldX + (particle.x-node.transform.g2d_worldX)*1;//node.transform.g2d_worldScaleX;
                    var ty:Number = node.transform.g2d_worldY + (particle.y-node.transform.g2d_worldY)*1;//node.transform.g2d_worldScaleY;

                if (particle.overrideUvs) {
                    var zuvX:Number = particle.texture.uvX;
                    particle.texture.uvX = particle.uvX;
                    var zuvY:Number = particle.texture.uvY;
                    particle.texture.uvY = particle.uvY;
                    var zuvScaleX:Number = particle.texture.uvScaleX;
                    particle.texture.uvScaleX = particle.uvScaleX;
                    var zuvScaleY:Number = particle.texture.uvScaleY;
                    particle.texture.uvScaleY = particle.uvScaleY;
                    node.core.getContext().draw(particle.texture, tx, ty, particle.scaleX*node.transform.g2d_worldScaleX, particle.scaleY*node.transform.g2d_worldScaleY, particle.rotation, particle.red*node.transform.g2d_worldRed, particle.green*node.transform.g2d_worldGreen, particle.blue*node.transform.g2d_worldBlue, particle.alpha*node.transform.g2d_worldAlpha, blendMode);
                    particle.texture.uvX = zuvX;
                    particle.texture.uvY = zuvY;
                    particle.texture.uvScaleX = zuvScaleX;
                    particle.texture.uvScaleY = zuvScaleY;
                } else {
                    node.core.getContext().draw(particle.texture, tx, ty, particle.scaleX*node.transform.g2d_worldScaleX, particle.scaleY*node.transform.g2d_worldScaleY, particle.rotation, particle.red*node.transform.g2d_worldRed, particle.green*node.transform.g2d_worldGreen, particle.blue*node.transform.g2d_worldBlue, particle.alpha*node.transform.g2d_worldAlpha, blendMode);
                }
            }

            particle = next;
        }
    }

    private function activateParticle():void {
        var particle:GParticle = particlePool.get();
        if (g2d_firstParticle != null) {
            particle.g2d_next = g2d_firstParticle;
            g2d_firstParticle.g2d_previous = particle;
            g2d_firstParticle = particle;
        } else {
            g2d_firstParticle = particle;
            g2d_lastParticle = particle;
        }

        particle.init(this);

        for (var i:int = 0; i<g2d_initializersCount; ++i) {
            g2d_initializers[i].initialize(this, particle);
        }
    }

    public function deactivateParticle(p_particle:GParticle):void {
        if (p_particle == g2d_lastParticle) g2d_lastParticle = g2d_lastParticle.g2d_previous;
        if (p_particle == g2d_firstParticle) g2d_firstParticle = g2d_firstParticle.g2d_next;
        p_particle.dispose();
    }

    public function getBounds(p_target:Rectangle = null):Rectangle {
        return null;
    }
}
}