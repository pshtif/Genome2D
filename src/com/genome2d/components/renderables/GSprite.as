package com.genome2d.components.renderables {
import com.genome2d.node.GNode;
import com.genome2d.textures.GTexture;

/**
 * ...
 * @author 
 */
public class GSprite extends GTexturedQuad
{
    /**
     *  Texture id used by this sprite
     **/
    public function get textureId():String {
        var id:String = "";
        if (texture != null) id = texture.getId();
        return id;
    }
    public function set textureId(p_value:String):void {
        texture = GTexture.getTextureById(p_value);
    }

    /**
     *  @private
     **/
	public function GSprite(p_node:GNode) {
		super(p_node);

        g2d_prototypableProperties.push("textureId");
	}
	
}
}