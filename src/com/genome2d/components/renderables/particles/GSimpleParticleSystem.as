package com.genome2d.components.renderables.particles {

import com.genome2d.components.GComponent;
import com.genome2d.node.GNode;
import com.genome2d.textures.GTexture;
import com.genome2d.components.renderables.IRenderable;
import com.genome2d.context.GContextCamera;

import flash.geom.Rectangle;

/**
 * ...
 * @author 
 */
public class GSimpleParticleSystem extends GComponent implements IRenderable
{
    public var blendMode:int = 1;

	/**
	 * 	Emitting particles
	 */
	public var emit:Boolean = false;

	public var initialScale:Number = 1;
	public var initialScaleVariance:Number = 0;
	public var endScale:Number = 1;
	public var endScaleVariance:Number = 0;

	public var energy:Number = 0;
	public var energyVariance:Number = 0;

	public var emission:int = 1;
	public var emissionVariance:int = 0;
	public var emissionTime:Number = 1;
	public var emissionDelay:Number = 0;

	public var initialVelocity:Number = 0;
	public var initialVelocityVariance:Number = 0;
	public var initialAcceleration:Number = 0;
	public var initialAccelerationVariance:Number = 0;

	public var initialAngularVelocity:Number = 0;
	public var initialAngularVelocityVariance:Number = 0;

	public var initialRed:Number = 1;
	public var initialRedVariance:Number = 0;
	public var initialGreen:Number = 1;
	public var initialGreenVariance:Number = 0;
	public var initialBlue:Number = 1;
	public var initialBlueVariance:Number = 0;
	public var initialAlpha:Number = 1;
	public var initialAlphaVariance:Number = 0;

	public function get initialColor():int {
		var red:int = int(initialRed * 0xFF) << 16;
		var green:int = int(initialGreen * 0xFF) << 8;
		var blue:int = int(initialBlue * 0xFF);
		return red+green+blue;
	}
	public function set initialColor(p_value:int):void {
		initialRed = int(p_value >> 16 & 0xFF) / 0xFF;
		initialGreen = int(p_value >> 8 & 0xFF) / 0xFF;
		initialBlue = int(p_value & 0xFF) / 0xFF;
	}

	public var endRed:Number = 1;
	public var endRedVariance:Number = 0;
	public var endGreen:Number = 1;
	public var endGreenVariance:Number = 0;
	public var endBlue:Number = 1;
	public var endBlueVariance:Number = 0;
	public var endAlpha:Number = 1;
	public var endAlphaVariance:Number = 0;

	public function get endColor():int {
		var red:int = int(endRed * 0xFF) << 16;
		var green:int = int(endGreen * 0xFF) << 8;
		var blue:int = int(endBlue * 0xFF);
		return int(red + green + blue);
    }
	public function set endColor(p_value:int):void {
		endRed = (p_value>>16&0xFF)/0xFF;
		endGreen = (p_value>>8&0xFF)/0xFF;
		endBlue = (p_value & 0xFF) / 0xFF;
	}

	public var dispersionXVariance:Number = 0;
	public var dispersionYVariance:Number = 0;
	public var dispersionAngle:Number = 0;
	public var dispersionAngleVariance:Number = 0;

	public var initialAngle:Number = 0;
	public var initialAngleVariance:Number = 0;

	public var burst:Boolean = false;

	public var special:Boolean = false;

    public var useWorldSpace:Boolean = true;

	private var g2d_accumulatedTime:Number = 0;
	private var g2d_accumulatedEmission:Number = 0;

	private var g2d_firstParticle:GSimpleParticle;
	private var g2d_lastParticle:GSimpleParticle;

	private var g2d_activeParticles:int = 0;

	private var g2d_lastUpdateTime:Number;
	
	public var texture:GTexture;

	public function get_textureId():String {
		return (texture != null) ? texture.getId() : "";
	}
	public function set_textureId(p_value:String):void {
		texture = GTexture.getTextureById(p_value);
	}

	private function setInitialParticlePosition(p_particle:GSimpleParticle):void {
		p_particle.g2d_x = (useWorldSpace) ? node.transform.g2d_worldX : 0;
		if (dispersionXVariance>0) p_particle.g2d_x += dispersionXVariance*Math.random() - dispersionXVariance*.5; 
		p_particle.g2d_y = (useWorldSpace) ? node.transform.g2d_worldY : 0;
		if (dispersionYVariance>0) p_particle.g2d_y += dispersionYVariance*Math.random() - dispersionYVariance*.5; 
		p_particle.g2d_rotation = initialAngle;
		if (initialAngleVariance>0) p_particle.g2d_rotation += initialAngleVariance*Math.random();
		p_particle.g2d_scaleX = p_particle.g2d_scaleY = initialScale;
		if (initialScaleVariance>0) {
			var sd:Number = initialScaleVariance*Math.random();
			p_particle.g2d_scaleX += sd;
			p_particle.g2d_scaleY += sd;
		}
	}

	/**
	 * 	@private
	 */
	public function GSimpleParticleSystem(p_node:GNode) {
		super(p_node);

        node.core.onUpdate.add(update);
	}

	public function init(p_maxCount:int = 0, p_precacheCount:int = 0, p_disposeImmediately:Boolean = true):void {
		g2d_accumulatedTime = 0;
		g2d_accumulatedEmission = 0;
	}

	private function createParticle():GSimpleParticle {
		var particle:GSimpleParticle = GSimpleParticle.get();
		if (g2d_firstParticle != null) {
			particle.g2d_next = g2d_firstParticle;
			g2d_firstParticle.g2d_previous = particle;
			g2d_firstParticle = particle;
		} else {
			g2d_firstParticle = particle;
			g2d_lastParticle = particle;
		}

		return particle;
	}

	public function forceBurst():void {
		var currentEmission:int = int(emission + emissionVariance * Math.random());

		for (var i:int = 0; i<currentEmission; ++i) {
			activateParticle();
		}
		emit = false;
	}

	public function update(p_deltaTime:Number):void {
		g2d_lastUpdateTime = p_deltaTime;

		if (emit) {
			if (burst) {
				forceBurst();
			} else {
				g2d_accumulatedTime += p_deltaTime * .001;
				var time:Number = g2d_accumulatedTime%(emissionTime+emissionDelay);

				if (time <= emissionTime) {
					var updateEmission:Number = emission;
					if (emissionVariance>0) updateEmission += emissionVariance * Math.random(); 
					g2d_accumulatedEmission += updateEmission * p_deltaTime * .001;

					while (g2d_accumulatedEmission > 0) {
						activateParticle();
						g2d_accumulatedEmission--;
					}
				}
			}
		}
		
		var particle:GSimpleParticle = g2d_firstParticle;
		while (particle != null) {
			var next:GSimpleParticle = particle.g2d_next;

			particle.update(this, g2d_lastUpdateTime);
			particle = next;
		}	
	}

    // TODO add matrix transformations
	public function render(p_camera:GContextCamera, p_useMatrix:Boolean):void {
		if (texture == null) return;
		
		var particle:GSimpleParticle = g2d_firstParticle;

		while (particle != null) {
			var next:GSimpleParticle = particle.g2d_next;

            var tx:Number;
            var ty:Number;
            if (useWorldSpace) {
                tx = particle.g2d_x;
                ty = particle.g2d_y;
            } else {
                tx = node.transform.g2d_worldX + particle.g2d_x;
                ty = node.transform.g2d_worldY + particle.g2d_y;
            }
		
			node.core.getContext().draw(texture, tx, ty, particle.g2d_scaleX*node.transform.g2d_worldScaleX, particle.g2d_scaleY*node.transform.g2d_worldScaleY, particle.g2d_rotation, particle.g2d_red, particle.g2d_green, particle.g2d_blue, particle.g2d_alpha, blendMode);

			particle = next;
		}
	}

	private function activateParticle():void {
		var particle:GSimpleParticle = createParticle();
		setInitialParticlePosition(particle);
		
		particle.init(this);
	}

	public function deactivateParticle(p_particle:GSimpleParticle):void {
		if (p_particle == g2d_lastParticle) g2d_lastParticle = g2d_lastParticle.g2d_previous;
		if (p_particle == g2d_firstParticle) g2d_firstParticle = g2d_firstParticle.g2d_next;
		p_particle.dispose();
	}

	override public function dispose():void {
        while (g2d_firstParticle) deactivateParticle(g2d_firstParticle);
        node.core.onUpdate.remove(update);
		
		super.dispose();
	}

	public function clear(p_disposeCachedParticles:Boolean = false):void {
		// TODO
	}

    public function getBounds(p_target:Rectangle = null):Rectangle {
        // TODO
        return null;
    }
}
}