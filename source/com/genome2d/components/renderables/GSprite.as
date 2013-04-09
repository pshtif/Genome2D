/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.components.renderables
{
	import com.genome2d.core.GNode;
	import com.genome2d.error.GError;
	import com.genome2d.g2d;
	import com.genome2d.textures.GTexture;
	import com.genome2d.textures.GTextureBase;
	
	use namespace g2d;
	
	public class GSprite extends GTexturedQuad
	{	
		public function get textureId():String {
			if (cTexture) return cTexture.id;
			return "";
		}
		public function set textureId(p_value:String):void {
			cTexture = GTextureBase.getTextureBaseById(p_value) as GTexture;
			//if (cTexture == null) throw new GError(GError.TEXTURE_ID_DOESNT_EXIST, p_value);		
		}
		
		/**
		 * 	Set a texture that should be used by this sprite
		 */
		public function setTexture(p_texture:GTexture):void {
			cTexture = p_texture;
		}
		/**
		 * 	@private
		 */
		public function GSprite(p_node:GNode)
		{
			super(p_node);
		}
	}
}