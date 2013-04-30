/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.textures.factories
{
	import com.genome2d.g2d;
	import com.genome2d.error.GError;
	import com.genome2d.textures.GTextureAtlas;
	import com.genome2d.textures.GTextureSourceType;
	import com.genome2d.textures.GTextureUtils;
	import com.genome2d.utils.GMaxRectPacker;
	import com.genome2d.utils.GPacker;
	import com.genome2d.utils.GPackerRectangle;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;

	use namespace g2d;
	
	public class GTextureAtlasFactory
	{
		/**
		 * 	Factory method that will create atlas from movie clip instance
		 * 
		 * 	@param p_id id of the atlas
		 * 	@param p_movieClip
		 */
		static public function createFromMovieClip(p_id:String, p_movieClip:MovieClip, p_forceMod2:Boolean = false):GTextureAtlas {
			var bitmaps:Vector.<BitmapData> = new Vector.<BitmapData>();
			var ids:Vector.<String> = new Vector.<String>();
			var matrix:Matrix = new Matrix();
			for (var i:int = 1; i<p_movieClip.totalFrames; ++i) {
				p_movieClip.gotoAndStop(i);
				var width:int = (p_movieClip.width%2 != 0 && p_forceMod2) ? p_movieClip.width+1 : p_movieClip.width;
				var height:int = (p_movieClip.height%2 != 0 && p_forceMod2) ? p_movieClip.height+1 : p_movieClip.height;
				var bitmapData:BitmapData = new BitmapData(p_movieClip.width, p_movieClip.height, true, 0x0);
				var bounds:Rectangle = p_movieClip.getBounds(p_movieClip);
				matrix.identity();
				matrix.translate(-bounds.x, -bounds.y);
				bitmapData.draw(p_movieClip, matrix);
				bitmaps.push(bitmapData);
				ids.push(i);
			}
			
			return createFromBitmapDatas(p_id, bitmaps, ids);
		}
		
		/**
		 *	Factory method that will create atlas from specified font
         *
         *  @param p_id id of the atlas
         *  @param p_format text format specifying the format of the font
         *  @param p_chars characters to be included
         *  @param p_forceMod2 force characters to be of even size to avoid floating point centers
		 */
		static public function createFromFont(p_id:String, p_format:TextFormat, p_chars:String, p_forceMod2:Boolean = false):GTextureAtlas {			
			var text:TextField = new TextField();
			text.embedFonts = true;
			text.defaultTextFormat = p_format;
			text.multiline = false;
			text.autoSize = TextFieldAutoSize.LEFT;
			
			var bitmaps:Vector.<BitmapData> = new Vector.<BitmapData>();
			var ids:Vector.<String> = new Vector.<String>();
			
			for (var i:int = 0; i<p_chars.length; ++i) {
				text.text = p_chars.charAt(i);
				var width:int = (text.width%2 != 0 && p_forceMod2) ? text.width+1 : text.width;
				var height:int = (text.height%2 != 0 && p_forceMod2) ? text.height+1 : text.height;
				var bitmapData:BitmapData = new BitmapData(width, height, true, 0x0);
				bitmapData.draw(text);
				bitmaps.push(bitmapData);
				
				ids.push(p_chars.charCodeAt(i));
			}
			
			return createFromBitmapDatas(p_id, bitmaps, ids);
		}
		
		/**
		 *  Factory method that will create atlas from bitmap datas
         *
         *  @param p_id id of the atlas
         *  @param p_bitmaps vector of bitmap data instances
         *  @param p_ids vector of subtexture is
         *  @param p_packer texture packer to be used
         *  @param p_padding padding between packed textures
		 */
		static public function createFromBitmapDatas(p_id:String, p_bitmaps:Vector.<BitmapData>, p_ids:Vector.<String>, p_packer:GPacker = null, p_padding:int = 2):GTextureAtlas {			
			var rectangles:Vector.<GPackerRectangle> = new Vector.<GPackerRectangle>();
            var i:int;
            var rect:GPackerRectangle;
			for (i = 0; i<p_bitmaps.length; ++i) {
				var bitmap:BitmapData = p_bitmaps[i];
				rect = GPackerRectangle.get(0,0,bitmap.width,bitmap.height,p_ids[i],bitmap);
				rectangles.push(rect);
			}
			
			if (p_packer == null) {
				p_packer = new GMaxRectPacker(1,1,2048,2048,true);
			}
			
			p_packer.packRectangles(rectangles, p_padding);

			if (p_packer.rectangles.length != p_bitmaps.length) return null;
			var packed:BitmapData = new BitmapData(p_packer.width, p_packer.height, true, 0x0);
			p_packer.draw(packed);
			
			var textureAtlas:GTextureAtlas = new GTextureAtlas(p_id, GTextureSourceType.BITMAPDATA, packed.width, packed.height, packed, GTextureUtils.isBitmapDataTransparent(packed), null);
			
			var count:int = p_packer.rectangles.length;
			for (i = 0; i<count; ++i) {
				rect = p_packer.rectangles[i];
				textureAtlas.addSubTexture(rect.id, rect.rect, rect.pivotX, rect.pivotY);
			}
			
			textureAtlas.invalidate();
			return textureAtlas;
		}
		
		/**
		 * 	Factory method that will create atlas from bitmap data source and regions defined within an XML [Sparrow format]
		 * 
		 * 	@param p_id id of the atlas
		 * 	@param p_bitmapData bitmap data
		 * 	@param p_xml
		 */
		static public function createFromBitmapDataAndXML(p_id:String, p_bitmapData:BitmapData, p_xml:XML):GTextureAtlas {
			var textureAtlas:GTextureAtlas = new GTextureAtlas(p_id, GTextureSourceType.BITMAPDATA, p_bitmapData.width, p_bitmapData.height, p_bitmapData, GTextureUtils.isBitmapDataTransparent(p_bitmapData), null);
			
			for (var i:int = 0; i<p_xml.children().length(); ++i) {
				var node:XML = p_xml.children()[i];
		
				var region:Rectangle = new Rectangle(int(node.@x), int(node.@y), int(node.@width), int(node.@height));
				
				var pivotX:Number = (node.@frameX == undefined && node.@frameWidth == undefined) ? 0 : Number(node.@frameWidth-region.width)/2 + Number(node.@frameX);
				var pivotY:Number = (node.@frameY == undefined && node.@frameHeight == undefined) ? 0 : Number(node.@frameHeight-region.height)/2 + Number(node.@frameY);

				textureAtlas.addSubTexture(node.@name, region, pivotX, pivotY);
			}
			textureAtlas.invalidate();
			return textureAtlas;
		}
		
		static public function createFromAssets(p_id:String, p_bitmapAsset:Class, p_xmlAsset:Class):GTextureAtlas {
			var bitmap:Bitmap = new p_bitmapAsset();
			var xml:XML = XML(new p_xmlAsset());
			
			return createFromBitmapDataAndXML(p_id, bitmap.bitmapData, xml);			
		}
		
		static public function createFromBitmapDataAndFontXML(p_id:String, p_bitmapData:BitmapData, p_fontXml:XML):GTextureAtlas {
			var textureAtlas:GTextureAtlas = new GTextureAtlas(p_id, GTextureSourceType.BITMAPDATA, p_bitmapData.width, p_bitmapData.height, p_bitmapData, GTextureUtils.isBitmapDataTransparent(p_bitmapData), null);
			
			for (var i:int = 0; i<p_fontXml.chars.children().length(); ++i) {
				var node:XML = p_fontXml.chars.children()[i];
				var region:Rectangle = new Rectangle(int(node.@x), int(node.@y), int(node.@width), int(node.@height));
				
				var pivotX:int = -Number(node.@xoffset);
				var pivotY:int = -Number(node.@yoffset);
				
				textureAtlas.addSubTexture(node.@id, region, pivotX, pivotY);
			}
			textureAtlas.invalidate();
			return textureAtlas;
		}
		
		/**
		 * 	Factory method that will create atlas from bitmap data source and regions defined within an XML [Sparrow format]
		 * 
		 * 	@param p_id id of the atlas
		 * 	@param p_bitmapData bitmap data
		 * 	@param p_xml
         * 	@param p_uploadCallback callback to be called once the texture is uploaded to GPU
		 */
		static public function createFromATFAndXML(p_id:String, p_atfData:ByteArray, p_xml:XML, p_uploadCallback:Function = null):GTextureAtlas {
			var atf:String = String.fromCharCode(p_atfData[0], p_atfData[1], p_atfData[2]);
			if (atf != "ATF") throw new GError(GError.INVALID_ATF_DATA);
			
			var type:int;
			var transparent:Boolean = true;
			switch (p_atfData[6]) {
				case 1:
					type = GTextureSourceType.ATF_BGRA;
					break;
				case 3:
					type = GTextureSourceType.ATF_COMPRESSED;
					transparent = false;
					break;
				case 5:
					type = GTextureSourceType.ATF_COMPRESSEDALPHA;
					break;
			}
			var width:int = Math.pow(2, p_atfData[7]);
			var height:int = Math.pow(2, p_atfData[8]);
			
			var textureAtlas:GTextureAtlas = new GTextureAtlas(p_id, type, width, height, p_atfData, transparent, p_uploadCallback);
			
			for (var i:int = 0; i<p_xml.children().length(); ++i) {
				var node:XML = p_xml.children()[i];
				var region:Rectangle = new Rectangle(int(node.@x), int(node.@y), int(node.@width), int(node.@height));
				
				var pivotX:Number = (node.@frameX == undefined && node.@frameWidth == undefined) ? 0 : Number(node.@frameWidth-region.width)/2 + Number(node.@frameX);
				var pivotY:Number = (node.@frameY == undefined && node.@frameHeight == undefined) ? 0 : Number(node.@frameHeight-region.height)/2 + Number(node.@frameY);
				
				textureAtlas.addSubTexture(node.@name, region, pivotX, pivotY);
			}
			textureAtlas.invalidate();
			return textureAtlas;
		}
		
		/**
		 * 	Factory method that will create atlas from bitmap data source and regions defined within a vector
		 * 
		 * 	@param p_id id of the atlas
		 * 	@param p_bitmapData bitmap data
		 */
		static public function createFromBitmapDataAndRegions(p_id:String, p_bitmapData:BitmapData, p_regions:Vector.<Rectangle>, p_ids:Vector.<String> = null, p_pivots:Vector.<Point> = null):GTextureAtlas {
			var textureAtlas:GTextureAtlas = new GTextureAtlas(p_id, GTextureSourceType.BITMAPDATA, p_bitmapData.width, p_bitmapData.height, p_bitmapData, GTextureUtils.isBitmapDataTransparent(p_bitmapData), null);
			
			for (var i:int = 0; i<p_regions.length; ++i) {
				var id:String = (p_ids == null) ? String(i) : p_ids[i];
				var transparent:Boolean = (p_bitmapData.histogram(p_regions[i])[3][255] != p_regions[i].width*p_regions[i].height);
				if (p_pivots) textureAtlas.addSubTexture(id, p_regions[i], p_pivots[i].x, p_pivots[i].y);
				else textureAtlas.addSubTexture(id, p_regions[i]);
			}
			textureAtlas.invalidate();
			return textureAtlas;
		}
	}
}