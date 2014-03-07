package com.genome2d.textures.factories {

import com.genome2d.context.IContext;
import com.genome2d.error.GError;
import com.genome2d.textures.GTextureAtlas;
import com.genome2d.textures.GTextureSourceType;
import com.genome2d.textures.GTextureUtils;
import com.genome2d.utils.GMaxRectPacker;
import com.genome2d.utils.GPackerRectangle;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.utils.ByteArray;

/**
 * @author  Peter "sHTiF" Stefcek
 */
public class GTextureAtlasFactory
{
    static public var g2d_context:IContext;

    static public function createFromEmbedded(p_id:String, p_bitmapAsset:Class, p_xmlAsset:Class):GTextureAtlas {
        var bitmap:Bitmap = new p_bitmapAsset();
        var data:String = new p_xmlAsset();
        var xml:XML = XML(data);
        return createFromBitmapDataAndXml(p_id, bitmap.bitmapData, xml);
    }

	/**
	 * 	Helper function that will create atlas from bitmap data source and regions defined within an XML [Sparrow format]
	 * 
	 * 	@param p_id id of the atlas
	 * 	@param p_bitmapData bitmap data
	 * 	@param p_xml
	 */	
	static public function createFromBitmapDataAndXml(p_id:String, p_bitmapData:BitmapData, p_xml:XML, p_format:String = "bgra"):GTextureAtlas {
        if (!GTextureUtils.isValidTextureSize(p_bitmapData.width) || !GTextureUtils.isValidTextureSize(p_bitmapData.height)) throw new GError("Atlas bitmap needs to have power of 2 size.");
		var textureAtlas:GTextureAtlas = new GTextureAtlas(g2d_context, p_id, GTextureSourceType.BITMAPDATA, p_bitmapData, p_bitmapData.rect, p_format, null);

        for (var i:int = 0; i<p_xml.children().length(); ++i) {
            var node:XML = p_xml.children()[i];

            var region:Rectangle = new Rectangle(int(node.@x), int(node.@y), int(node.@width), int(node.@height));

            var pivotX:Number = (node.@frameX == undefined && node.@frameWidth == undefined) ? 0 : Number(node.@frameWidth-region.width)/2 + Number(node.@frameX);
            var pivotY:Number = (node.@frameY == undefined && node.@frameHeight == undefined) ? 0 : Number(node.@frameHeight-region.height)/2 + Number(node.@frameY);

            textureAtlas.addSubTexture(node.@name, region, pivotX, pivotY);
        }

		textureAtlas.invalidateNativeTexture(false);
		return textureAtlas;
	}

    static public function createFromFont(p_id:String, p_format:TextFormat, p_chars:String, p_embedded:Boolean = true, p_horizontalPadding:int = 0, p_verticalPadding:int = 0, p_filters:Array = null, p_forceMod2:Boolean = false):GTextureAtlas {
        var text:TextField = new TextField();
        text.embedFonts = p_embedded;
        text.defaultTextFormat = p_format;
        text.multiline = false;
        text.autoSize = TextFieldAutoSize.LEFT;

        if (p_filters != null) {
            text.filters = p_filters;
        }

        var bitmaps:Vector.<BitmapData> = new Vector.<BitmapData>();
        var ids:Vector.<String> = new Vector.<String>();
        var matrix:Matrix = new Matrix();
        matrix.translate(p_horizontalPadding, p_verticalPadding);

        var charCount:int = p_chars.length;
        for (var i:int = 0; i<charCount; ++i) {
            text.text = p_chars.charAt(i);
            var width:Number = (text.width%2 != 0 && p_forceMod2) ? text.width+1 : text.width;
            var height:Number = (text.height%2 != 0 && p_forceMod2) ? text.height+1 : text.height;
            var bitmapData:BitmapData = new BitmapData((width+p_horizontalPadding*2), (height+p_verticalPadding*2), true, 0x0);
            bitmapData.draw(text, matrix);
            bitmaps.push(bitmapData);

            ids.push(p_chars.charCodeAt(i));
        }

        return createFromBitmapDatas(p_id, bitmaps, ids);
    }

    static public function createFromBitmapDatas(p_id:String, p_bitmaps:Vector.<BitmapData>, p_ids:Vector.<String>, p_packer:GMaxRectPacker = null, p_padding:int = 2, p_format:String = "bgra"):GTextureAtlas {
        var rectangles:Array = [];
        var i:int;
        var rect:GPackerRectangle;
        var bitmapCount:int = p_bitmaps.length;
        for (i = 0; i<bitmapCount; ++i) {
            var bitmap:BitmapData = p_bitmaps[i];
            rect = GPackerRectangle.get(0,0,bitmap.width,bitmap.height,p_ids[i],bitmap);
            rectangles.push(rect);
        }

        if (p_packer == null) {
            p_packer = new GMaxRectPacker(1,1,2048,2048,true);
        }

        p_packer.g2d_packRectangles(rectangles, p_padding);

        if (p_packer.getRectangles().length != p_bitmaps.length) return null;
        var packed:BitmapData = new BitmapData(p_packer.getWidth(), p_packer.getHeight(), true, 0x0);
        p_packer.draw(packed);

        var textureAtlas:GTextureAtlas = new GTextureAtlas(g2d_context, p_id, GTextureSourceType.BITMAPDATA, packed, packed.rect, p_format, null);

        var count:int = p_packer.getRectangles().length;
        for (i = 0; i<count; ++i) {
            rect = p_packer.getRectangles()[i];
            textureAtlas.addSubTexture(rect.id, rect.getRect(), rect.pivotX, rect.pivotY);
        }

        textureAtlas.invalidateNativeTexture(false);
        return textureAtlas;
    }

    static public function createFromATFAndXML(p_id:String, p_atfData:ByteArray, p_xml:XML):GTextureAtlas {
        var atf:String = String.fromCharCode(p_atfData[0]) + String.fromCharCode(p_atfData[1]) + String.fromCharCode(p_atfData[2]);
        if (atf != "ATF") throw new GError("Invalid ATF data.");

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

        var textureAtlas:GTextureAtlas = new GTextureAtlas(g2d_context, p_id, type, p_atfData, new Rectangle(0,0,width,height), null, null);

        for (var i:int = 0; i<p_xml.children().length(); ++i) {
            var node:XML = p_xml.children()[i];

            var region:Rectangle = new Rectangle(int(node.@x), int(node.@y), int(node.@width), int(node.@height));

            var pivotX:Number = (node.@frameX == undefined && node.@frameWidth == undefined) ? 0 : Number(node.@frameWidth-region.width)/2 + Number(node.@frameX);
            var pivotY:Number = (node.@frameY == undefined && node.@frameHeight == undefined) ? 0 : Number(node.@frameHeight-region.height)/2 + Number(node.@frameY);

            textureAtlas.addSubTexture(node.@name, region, pivotX, pivotY);
        }
/**/
        textureAtlas.invalidateNativeTexture(false);
        return textureAtlas;
    }

}
}