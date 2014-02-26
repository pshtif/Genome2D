package com.genome2d.components.renderables.particles {

/**
 * ...
 * @author Peter "sHTiF" Stefcek
 */
public class GParticlePool
{
    static public var g2d_defaultPool:GParticlePool = new GParticlePool();

    public var g2d_availableInstance:GParticle;
    private var g2d_count:int = 0;

    private var g2d_particleClass:Class;

    public function GParticlePool(p_particleClass:Class = null):void {
        g2d_particleClass = (p_particleClass==null) ? GParticle : p_particleClass;
    }

    public function precache(p_precacheCount:int):void {
        if (p_precacheCount < g2d_count) return;

        var precached:GParticle = get();
        while (g2d_count<p_precacheCount) {
            var n:GParticle = get();
            n.g2d_previous = precached;
            precached = n;
        }

        while (precached != null) {
            var d:GParticle = precached;
            precached = d.g2d_previous;
            d.dispose();
        }
    }

    public function get():GParticle {
        var instance:GParticle = g2d_availableInstance;
        if (instance != null) {
            g2d_availableInstance = instance.g2d_nextAvailableInstance;
            instance.g2d_nextAvailableInstance = null;
        } else {
            instance = new g2d_particleClass(this);
            g2d_count++;
        }

        return instance;
    }
}
}