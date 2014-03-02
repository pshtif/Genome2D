package com.genome2d.textures.factories {

import com.genome2d.context.IContext;
import com.genome2d.textures.GTextureSourceType;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import com.genome2d.error.GError;
import flash.display.Bitmap;
import flash.display.BitmapData;

import com.genome2d.textures.GTexture;

public class GTextureFactory {
    static public var g2d_context:IContext;

    static public function createFromEmbedded(p_id:String, p_asset:Class, p_format:String = "bgra"):GTexture {
        var bitmap:Bitmap = new p_asset();

        return new GTexture(g2d_context, p_id, GTextureSourceType.BITMAPDATA, bitmap.bitmapData, bitmap.bitmapData.rect, p_format);
    }

	static public function createFromBitmapData(p_id:String, p_bitmapData:BitmapData, p_format:String = "bgra"):GTexture {
		return new GTexture(g2d_context, p_id, GTextureSourceType.BITMAPDATA, p_bitmapData, p_bitmapData.rect, p_format);
	}

    static public function createFromATF(p_id:String, p_atfData:ByteArray, p_uploadCallback:Function = null):GTexture {
        var atf:String = String.fromCharCode(p_atfData[0]) + String.fromCharCode(p_atfData[1]) + String.fromCharCode(p_atfData[2]);
        if (atf != "ATF") throw new GError("Invalid ATF data");
        var type:int = GTextureSourceType.ATF_BGRA;
        var offset:int = p_atfData[6] == 255 ? 12 : 6;
        switch (p_atfData[offset]) {
            case 0:
            case 1:
                type = GTextureSourceType.ATF_BGRA;
                break;
            case 2:
            case 3:
                type = GTextureSourceType.ATF_COMPRESSED;
                break;
            case 4:
            case 5:
                type = GTextureSourceType.ATF_COMPRESSEDALPHA;
                break;
        }
        var width:Number = Math.pow(2, p_atfData[offset+1]);
        var height:Number = Math.pow(2, p_atfData[offset+2]);

        return new GTexture(g2d_context, p_id, type, p_atfData, new Rectangle(0, 0, width, height), null, 0, 0, null);
    }

    static public function createRenderTexture(p_id:String, p_width:int, p_height:int):GTexture {
        return new GTexture(g2d_context, p_id, GTextureSourceType.RENDER_TARGET, null, new Rectangle(0,0,p_width, p_height), null);
    }
}
}