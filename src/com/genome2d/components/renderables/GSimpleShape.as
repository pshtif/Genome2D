package com.genome2d.components.renderables {

import com.genome2d.components.GComponent;
import com.genome2d.components.GTransform;
import com.genome2d.context.GBlendMode;
import com.genome2d.context.GContextCamera;
import com.genome2d.node.GNode;
import com.genome2d.textures.GTexture;

import flash.geom.Rectangle;

/**
 * ...
 * @author 
 */
public class GSimpleShape extends GComponent implements IRenderable
{
    public var texture:GTexture;
    public var blendMode:int = GBlendMode.NORMAL;

    protected var g2d_vertices:Array;
    protected var g2d_uvs:Array;

    public function GSimpleShape(p_node:GNode) {
        super(p_node);
    }

    public function render(p_camera:GContextCamera, p_useMatrix:Boolean):void {
        if (texture == null || g2d_vertices == null || g2d_uvs == null) return;
        var transform:GTransform = node.transform;
        node.core.getContext().drawPoly(texture, g2d_vertices, g2d_uvs, transform.g2d_worldX, transform.g2d_worldY, transform.g2d_worldScaleX, transform.g2d_worldScaleY, transform.g2d_worldRotation, transform.g2d_worldRed, transform.g2d_worldGreen, transform.g2d_worldBlue, transform.g2d_worldAlpha, blendMode);
    }

    public function init(p_vertices:Array, p_uvs:Array):void {
        g2d_vertices = p_vertices;
        g2d_uvs = p_uvs;
    }

    public function getBounds(p_target:Rectangle = null):Rectangle {
        return null;
    }
}
}