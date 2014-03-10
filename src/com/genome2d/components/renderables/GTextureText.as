package com.genome2d.components.renderables {

import com.genome2d.components.GComponent;
import com.genome2d.node.GNode;
import com.genome2d.node.factory.GNodeFactory;
import com.genome2d.signals.GMouseSignal;
import com.genome2d.textures.GTexture;
import com.genome2d.textures.GTextureAtlas;
import com.genome2d.context.GContextCamera;

import flash.geom.Rectangle;

/**
 * ...
 * @author 
 */
public class GTextureText extends GComponent implements IRenderable
{
    /**
     *  Blend mode used for rendering
     **/
    public var blendMode:int = 1;
		
	private var g2d_invalidate:Boolean = false;
	
	private var g2d_tracking:Number = 0;
    /**
     *  Character tracking
     *  Default 0
     **/
	public function get tracking():Number {
		return g2d_tracking;
	}
	public function set tracking(p_tracking:Number):void {
		g2d_tracking = p_tracking;
		g2d_invalidate = true;
	}
	
	private var g2d_lineSpace:Number = 0;
    /**
     *  Line spacing
     *  Default 0
     **/
	public function get lineSpace():Number {
		return g2d_lineSpace;
	}
	public function set lineSpace(p_value:Number):void {
		g2d_lineSpace = p_value;
		g2d_invalidate = true;
	}
	
	private var g2d_align:int;
    /**
     *  Text alignment
     **/
	public function get align():int {
		return g2d_align;
	}
    public function set align(p_align:int):void {
		g2d_align = p_align;
		g2d_invalidate = true;
	}

    /**
     *  Maximum width of the text
     **/
	public var maxWidth:Number = 0;
	
	/**
	 * 	@private
	 */
	public function GTextureText(p_node:GNode) {
		super(p_node);

        g2d_align = GTextureTextAlignType.TOP_LEFT;
	}

    private var g2d_textureAtlas:GTextureAtlas;
    /**
     *  Texture atlas id used for character textures lookup
     **/
    public function get textureAtlasId():String {
		if (g2d_textureAtlas != null) return g2d_textureAtlas.getId();
		return "";
	}
	public function set textureAtlasId(p_value:String):void {
		setTextureAtlas(GTextureAtlas.getTextureAtlasById(p_value));
	}

    /**
     *  Set texture atlas that will be used for character textures lookup
     **/
	public function setTextureAtlas(p_textureAtlas:GTextureAtlas):void {
		g2d_textureAtlas = p_textureAtlas;
		g2d_invalidate = true;
	}
	
	private var g2d_text:String = "";
    /**
     *  Text
     **/
	public function get text():String {
		return g2d_text;
	}
	public function set text(p_text:String):void {
		g2d_text = p_text;
		g2d_invalidate = true;
	}
	
	private var g2d_width:Number = 0;
    /**
     *  Width of the text
     **/
	public function get width():Number {
		if (g2d_invalidate) invalidateText();
		
		return g2d_width*node.transform.g2d_worldScaleX;
	}
	
	private var g2d_height:Number = 0;
    /**
     *  Height of the text
     **/
	public function get height():Number {
		if (g2d_invalidate) invalidateText();
		
		return g2d_height * node.transform.g2d_worldScaleY;
	}

    /**
     *  @private
     **/
	public function render(p_camera:GContextCamera, p_useMatrix:Boolean):void {
		if (g2d_invalidate) invalidateText();
	}
		
	private function invalidateText():void {
		if (g2d_textureAtlas == null) return;
		
		g2d_width = 0;
		var offsetX:Number = 0;
		var offsetY:Number =  0;
		var charSprite:GSprite;
		var texture:GTexture = null;

        var textLength:int = g2d_text.length;
		for (var i:int = 0; i<textLength; ++i) {
			if (g2d_text.charCodeAt(i) == 10) {
				g2d_width = (offsetX>g2d_width) ? offsetX : g2d_width;
				offsetX = 0;
				offsetY += (texture != null ? texture.height + g2d_lineSpace : g2d_lineSpace);
				continue;
            }
			texture = g2d_textureAtlas.getSubTexture(String(g2d_text.charCodeAt(i)));
			if (texture == null) continue;//throw new GError("Texture for character "+g2d_text.charAt(i)+" with code "+g2d_text.charCodeAt(i)+" not found!");
			if (i>=node.numChildren) {
				charSprite = GNodeFactory.createNodeWithComponent(GSprite) as GSprite;
				node.addChild(charSprite.node);
			} else {
				charSprite = node.getChildAt(i).getComponent(GSprite) as GSprite;
			}

			charSprite.texture = texture;
			if (maxWidth>0 && offsetX + texture.width>maxWidth) {
				g2d_width = (offsetX>g2d_width) ? offsetX : g2d_width;
				offsetX = 0;
				offsetY+=texture.height+g2d_lineSpace;
			}
			offsetX += texture.width / 2;
			charSprite.node.transform.visible = true;
			charSprite.node.transform.x = offsetX;
			charSprite.node.transform.y = offsetY+texture.height/2;
			offsetX += texture.width/2 + g2d_tracking;
		}
		
		g2d_width = (offsetX>g2d_width) ? offsetX : g2d_width;
		g2d_height = offsetY + (texture!=null ? texture.height : 0);
		for (var i:int = textLength; i<node.numChildren; ++i) {
			node.getChildAt(i).transform.visible = false;
		}
		/**/
		invalidateAlign();
		
		g2d_invalidate = false;
	}
	
	private function invalidateAlign():void {
		switch (g2d_align) {
			case GTextureTextAlignType.MIDDLE:
				for (var i:int = 0; i<node.numChildren; ++i) {
					var child:GNode = node.getChildAt(i);
					child.transform.x -= g2d_width/2;
					child.transform.y -= g2d_height/2;
				}
                break;
			case GTextureTextAlignType.TOP_RIGHT:
				for (var i:int = 0; i<node.numChildren; ++i) {
					node.getChildAt(i).transform.x -= g2d_width;
				}
                break;
		}
	}
	
	/**
	 * 	@private
	 */
    override public function processContextMouseSignal(p_captured:Boolean, p_cameraX:Number, p_cameraY:Number, p_contextSignal:GMouseSignal):Boolean {
		/*
		if (g2d_width == 0 || g2d_height == 0) return false;
		if (p_captured) {
			if (node.cMouseOver == node) node.handleMouseEvent(node, MouseEvent.MOUSE_OUT, Number.NaN, Number.NaN, p_event.buttonDown, p_event.ctrlKey);
			return false;
		}
		
		var transformMatrix:Matrix3D = node.cTransform.getTransformedWorldTransformMatrix(g2d_width, g2d_height, 0, true);
		
		var localMousePosition:Vector3D = transformMatrix.transformVector(p_position);
		
		transformMatrix.prependScale(1/g2d_width, 1/g2d_height, 1);
		
		var tx:Number = 0;
		var ty:Number = 0;
		switch (g2d_align) {
			case GTextureTextAlignType.MIDDLE:
				tx = -.5;
				ty = -.5;
				break;
		}
		
		if (localMousePosition.x >= tx && localMousePosition.x <= 1+tx && localMousePosition.y >= ty && localMousePosition.y <= 1+ty) {
			node.handleMouseEvent(node, p_event.type, localMousePosition.x*g2d_width, localMousePosition.y*g2d_height, p_event.buttonDown, p_event.ctrlKey);
			if (node.cMouseOver != node) {
				node.handleMouseEvent(node, MouseEvent.MOUSE_OVER, localMousePosition.x*g2d_width, localMousePosition.y*g2d_height, p_event.buttonDown, p_event.ctrlKey);
			}
			
			return true;
		} else {
			if (node.cMouseOver == node) {
				node.handleMouseEvent(node, MouseEvent.MOUSE_OUT, localMousePosition.x*g2d_width, localMousePosition.y*g2d_height, p_event.buttonDown, p_event.ctrlKey);
			}
		}
		/**/
		return false;
	}

    /**
     *  @private
     **/
    public function getBounds(p_target:Rectangle = null):Rectangle {
        // TODO
        return null;
    }
}
}