/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.textures
{
	import com.genome2d.g2d;
	import com.genome2d.error.GError;
	
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	use namespace g2d;
	
	public class GTextureAtlas extends GTextureBase
	{		
		static public function getTextureAtlasById(p_id:String):GTextureAtlas {
			return GTextureBase.getTextureBaseById(p_id) as GTextureAtlas;
		}
		
		private var __dTextures:Dictionary;
		public function get textures():Dictionary {
			return __dTextures;
		}
		
		override public function set filteringType(p_type:int):void {
			super.filteringType = p_type;
			for each (var texture:GTexture in __dTextures) texture.iFilteringType = p_type;  
		}	
		
		/**
		 * 	Get a subtexture within this atlas
		 * 
		 * 	@param p_id
		 */
		public function getTexture(p_id:String):GTexture {
			return __dTextures[p_id];
		}
		
		/**
		 * 	@private
		 */
		public function GTextureAtlas(p_id:String, p_sourceType:int, p_width:int, p_height:int, p_source:*, p_transparent:Boolean, p_uploadCallback:Function) {
			super(p_id, p_sourceType, p_source, p_transparent, p_uploadCallback);
			
			if (!GTextureUtils.isValidTextureSize(p_width) || !GTextureUtils.isValidTextureSize(p_height)) throw new GError(GError.INVALID_ATLAS_SIZE);
			
			iWidth = p_width;
			iHeight = p_height;
			
			__dTextures = new Dictionary();
		}
		
		override protected function invalidateContextTexture(p_reinitialize:Boolean):void {
			super.invalidateContextTexture(p_reinitialize);
			
			for each (var texture:GTexture in __dTextures) {
				texture.cContextTexture = cContextTexture;
				texture.sAtfType = sAtfType;
			}
		}
		
		public function addSubTexture(p_subId:String, p_region:Rectangle, p_pivotX:Number = 0, p_pivotY:Number = 0, p_invalidate:Boolean = false):GTexture {
			var texture:GTexture = new GTexture(_sId+"_"+p_subId, iSourceType, getSource(), p_region, bTransparent, p_pivotX, p_pivotY, null, this);
			texture.sSubId = p_subId;
			texture.filteringType = filteringType;
			texture.cContextTexture = cContextTexture;
			__dTextures[p_subId] = texture;
			
			if (p_invalidate) invalidate();
			
			return texture;
		}
		
		public function removeSubTexture(p_subId:String):void {
			__dTextures[p_subId] = null;
		}
		
		private function disposeSubTextures():void {
			for (var it:String in __dTextures) {
				var texture:GTexture = __dTextures[it];
				texture.dispose();
				
				delete __dTextures[it];
			}
			
			__dTextures = new Dictionary();
		}
		
		/**
		 * 	Dispose this atlas and all its sub textures
		 */
		override public function dispose():void {			
			disposeSubTextures();
			
			if (baByteArray) baByteArray = null;
			if (bdBitmapData) bdBitmapData = null;
			if (cContextTexture) cContextTexture.dispose();
			
			super.dispose();
		}
	}
}