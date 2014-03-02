/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.textures {

import com.genome2d.textures.GContextTexture;
import com.genome2d.context.IContext;

import flash.geom.Rectangle;

public class GTexture extends GContextTexture
{
    static public function getTextureById(p_id:String):GTexture {
        return GContextTexture.getContextTextureById(p_id) as GTexture;
    }

    public function getParentAtlas():GTextureAtlas {
        return g2d_parentAtlas as GTextureAtlas;
    }
	
	public var g2d_subId:String = "";

    public function getRegion():Rectangle {
        return g2d_region;
    }
	public function setRegion(p_value:Rectangle):void {
		if (g2d_parentAtlas != null) {
			uvX = p_value.x / g2d_parentAtlas.width;
			uvY = p_value.y / g2d_parentAtlas.height;
			
			uvScaleX = width / g2d_parentAtlas.width;
			uvScaleY = height / g2d_parentAtlas.height;	
		} else {
            uvScaleX = width / GTextureUtils.getNextValidTextureSize(width);
            uvScaleY = height / GTextureUtils.getNextValidTextureSize(height);
        }

		g2d_region = p_value;
	}

	public function GTexture(p_context:IContext, p_id:String, p_sourceType:int, p_source:*, p_region:Rectangle, p_format:String, p_pivotX:Number = 0, p_pivotY:Number = 0, p_parentAtlas:GTextureAtlas = null) {
		super(p_context, p_id, p_sourceType, p_source, p_region, p_format, p_pivotX, p_pivotY);
		
		g2d_parentAtlas = p_parentAtlas;
        g2d_type = (g2d_parentAtlas == null) ? GTextureType.STANDALONE : GTextureType.SUBTEXTURE;
		
		setRegion(p_region);
		
		pivotX = p_pivotX;
		pivotY = p_pivotY;
				
		invalidateNativeTexture(false);
	}

    override public function invalidateNativeTexture(p_reinitialize:Boolean):void {
        super.invalidateNativeTexture(p_reinitialize);

        if (g2d_type == GTextureType.SUBTEXTURE) {
            g2d_gpuWidth = g2d_parentAtlas.gpuWidth;
            g2d_gpuHeight = g2d_parentAtlas.gpuHeight;
        }
    }
	
	/**
	 * 	Dispose this textures
	 */
	override public function dispose():void {
		g2d_parentAtlas = null;
		
		super.dispose();
	}
}
}