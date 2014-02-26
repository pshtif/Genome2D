/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.components.renderables {

import com.genome2d.textures.GTexture;
import com.genome2d.context.GContextCamera;
import com.genome2d.node.GNode;

public class GMovieClip extends GTexturedQuad
{
	protected var g2d_speed:Number = 1000/30;
	protected var g2d_accumulatedTime:Number = 0;
	
	protected var g2d_currentFrame:int = -1;

    protected var g2d_lastUpdatedFrameId:int = 0;

    /**
     *  Get the current frame index the movieclip is at
     **/
	public function get currentFrame():int {
		return g2d_currentFrame;
	}
	
	protected var g2d_startIndex:int = -1;
	protected var g2d_endIndex:int = -1;
	protected var g2d_playing:Boolean = true;

    /**
     *  Texture ids used for movieclip frames
     **/
	public function set frameTextureIds(p_value:Vector.<String>):void {
        g2d_frameTextures = new Vector.<GTexture>();
	    g2d_frameTexturesCount = p_value.length;
        for (var i:int = 0; i<g2d_frameTexturesCount; ++i) {
            g2d_frameTextures.push(GTexture.getTextureById(p_value[i]));
        }
		g2d_currentFrame = 0;
        if (g2d_frameTextures.length>0) {
            texture = g2d_frameTextures[0];
        } else {
            texture = null;
        }
	}

    protected var g2d_frameTextures:Vector.<GTexture>;
    protected var g2d_frameTexturesCount:int;

    /**
     *  Textures used for movieclip frames
     **/
    public function set frameTextures(p_value:Vector.<GTexture>):void {
        g2d_frameTextures = p_value;
        g2d_frameTexturesCount = p_value.length;
        g2d_currentFrame = 0;
        if (g2d_frameTextures.length>0) {
            texture = g2d_frameTextures[0];
        } else {
            texture = null;
        }
    }

    /**
     *  Is movieclip repeating after reaching the last frame, default true
     **/
	public var repeatable:Boolean = true;
	
	static protected var g2d_count:int = 0;
	
	/**
	 * 	@private
	 */
	public function GMovieClip(p_node:GNode) {
		super(p_node);
	}

    /**
     *  Framerate the movieclips is playing at, default 30
     **/
	public function get frameRate():int {
		return (1000 / g2d_speed);
	}
	public function set frameRate(p_value :int):void {
		g2d_speed = 1000 / p_value;
	}

    /**
     *  Number of frames in this movieclip
     **/
	public function get numFrames():int {
		return g2d_frameTexturesCount;
	}
	
	/**
	 * 	Go to a specified frame of this movie clip
	 */
	public function gotoFrame(p_frame:int):void {
		if (g2d_frameTextures == null) return;
		g2d_currentFrame = p_frame;
		g2d_currentFrame %= g2d_frameTexturesCount;
		texture = g2d_frameTextures[g2d_currentFrame];
	}

    /**
     *  Go to a specified frame of this movieclip and start playing
     **/
	public function gotoAndPlay(p_frame:int):void {
		gotoFrame(p_frame);
		play();
	}

    /**
     *  Go to a specified frame of this movieclip and stop playing
     **/
	public function gotoAndStop(p_frame:int):void {
		gotoFrame(p_frame);
		stop();
	}
	
	/**
	 * 	Stop playback of this movie clip
	 */
	public function stop():void {
		g2d_playing = false;
	}
	
	/**
	 * 	Start the playback of this movie clip
	 */
	public function play():void {
		g2d_playing = true;
	}
	
	/**
	 * 	@private
	 */
	override public function render(p_camera:GContextCamera, p_useMatrix:Boolean):void {
		if (texture != null) {
            var currentFrameId:int = node.core.getCurrentFrameId();
            if (g2d_playing && currentFrameId != g2d_lastUpdatedFrameId) {
                g2d_lastUpdatedFrameId = currentFrameId;
                g2d_accumulatedTime += g2d_node.core.getCurrentFrameDeltaTime();

                if (g2d_accumulatedTime >= g2d_speed) {
                    g2d_currentFrame += int(g2d_accumulatedTime / g2d_speed);
                    if (g2d_currentFrame<g2d_frameTexturesCount || repeatable) {
                        g2d_currentFrame %= g2d_frameTexturesCount;
                    } else {
                        g2d_currentFrame = g2d_frameTexturesCount-1;
                    }
                    texture = g2d_frameTextures[g2d_currentFrame];
                }
                g2d_accumulatedTime %= g2d_speed;
            }
            super.render(p_camera, p_useMatrix);
        }
	}
}
}