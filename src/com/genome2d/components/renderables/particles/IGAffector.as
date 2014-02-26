package com.genome2d.components.renderables.particles {

public interface IGAffector {
    function update(p_system:GParticleSystem, p_particle:GParticle, p_deltaTime:Number):void;
}
}