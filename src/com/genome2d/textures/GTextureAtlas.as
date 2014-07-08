package com.genome2d.textures {
import com.genome2d.context.IContext;

import flash.geom.Rectangle;
import flash.utils.Dictionary;

public class GTextureAtlas extends GContextTexture {
    static public function getTextureAtlasById(p_id:String):GTextureAtlas {
        return GContextTexture.getContextTextureById(p_id) as GTextureAtlas;
    }

    private var g2d_textures:Dictionary;
    private var g2d_textureIdsVector : Vector.<String>;
    
    public function getSubTexture(p_subId:String):GTexture {
        return g2d_textures[p_subId];
    }

    public function GTextureAtlas(p_context:IContext, p_id:String, p_sourceType:int, p_source:Object, p_region:Rectangle, p_format:String, p_uploadCallback:Function) {
        super(p_context, p_id, p_sourceType, p_source, p_region, p_format);

        g2d_type = GTextureType.ATLAS;
        g2d_textures = new Dictionary(false);
        g2d_textureIdsVector = new Vector.<String>();
    }

    override public function invalidateNativeTexture(p_reinitialize:Boolean):void {
        super.invalidateNativeTexture(p_reinitialize);

        for each (var texture:GTexture in g2d_textures) {
            texture.nativeTexture = nativeTexture;
            texture.atfType = atfType;
        }
    }

    public function addSubTexture(p_subId:String, p_region:Rectangle, p_pivotX:Number = 0, p_pivotY:Number = 0):GTexture {
        var texture:GTexture = new GTexture(g2d_context, g2d_id+"_"+p_subId, g2d_sourceType, g2d_nativeSource, p_region, g2d_format, false, p_pivotX, p_pivotY, this);
        texture.g2d_subId = p_subId;
        texture.g2d_filteringType = g2d_filteringType;
        texture.nativeTexture = nativeTexture;

        g2d_textures[p_subId] = texture;
        g2d_textureIdsVector.push(p_subId);

        return texture;
    }

    public function removeSubTexture(p_subId:String):void {
        g2d_textures[p_subId].dispose();
        g2d_textureIdsVector.splice(g2d_textureIdsVector.indexOf(p_subId), 1);
        delete g2d_textures[p_subId];
    }

    private function g2d_disposeSubTextures():void {
        var n : uint = g2d_textureIdsVector.length;
	while(n--){
	    var id:String = g2d_textureIdsVector[n];
	    var texture : GTexture = g2d_textures[id];
	    texture.dispose();
	    delete g2d_textures[id];
	}
	g2d_textureIdsVector.length = 0;
	g2d_textures = new Dictionary();
    }

    /**
	 * 	Dispose this atlas and all its sub textures
	 */
    override public function dispose():void {
        g2d_disposeSubTextures();

        super.dispose();
    }
    
    public function getAllSubTextures() : Vector.<GTexture> {
	var gTextures : Vector.<GTexture> = new Vector.<GTexture>();
	var length : uint = g2d_textureIdsVector.length;
        for(var i:uint = 0; i < length; i++){
            gTextures.push(g2d_textures[g2d_textureIdsVector[i]]);
        }
        return  gTextures;
    }
	
    public function getTextureNames() : Vector.<String> {
        return g2d_textureIdsVector.concat();
    }
}
}
