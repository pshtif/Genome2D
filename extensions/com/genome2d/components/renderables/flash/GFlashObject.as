/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.components.renderables.flash
{
import com.genome2d.components.renderables.GTexturedQuad;
import com.genome2d.context.GBlendMode;
import com.genome2d.node.GNode;
import com.genome2d.textures.GTextureUtils;
import com.genome2d.textures.factories.GTextureFactory;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.geom.Matrix;
import flash.geom.Rectangle;

public class GFlashObject extends GTexturedQuad
	{
		static public var defaultUpdateFrameRate:int = 20;
		
		public var nativeObject:DisplayObject;

        private var g2d_forceMod2:Boolean = true;
        public function get forceMod2():Boolean {
            return g2d_forceMod2;
        }
        public function set forceMod2(p_value:Boolean):void {
            g2d_forceMod2 = p_value;
            g2d_invalidate = true;
        }

        private var g2d_align:int = GFlashObjectAlign.CENTER;
        public function get align():int {
            return g2d_align;
        }
        public function set align(p_value:int):void {
            g2d_align = p_value;
            invalidateAlign();
        }
		
		private var g2d_nativeMatrix:Matrix;
		
		private var g2d_textureId:String;
		
		protected var g2d_invalidate:Boolean = false;
		public function invalidate(p_force:Boolean = false):void {
			if (p_force) invalidateTexture(true);
			else g2d_invalidate = true;
		}

		private var g2d_lastNativeWidth:Number = 0;
		private var g2d_lastNativeHeight:Number = 0;
		private var g2d_accumulatedTime:Number = 0;
		
		public var updateFrameRate:int = defaultUpdateFrameRate;
		protected var _bTransparent:Boolean = false;
		public function set transparent(p_transparent:Boolean):void {
			_bTransparent = p_transparent;
			if (nativeObject != null) invalidateTexture(true);
		}
		public function get transparent():Boolean {
			return _bTransparent;
		}
		
		static private var __iCount:int = 0;
		/**
		 * 	@private
		 */
		public function GFlashObject(p_node:GNode) {
			super(p_node);
			
			blendMode = GBlendMode.NONE;
			g2d_textureId = "GFlashObject#"+__iCount++;
			g2d_nativeMatrix = new Matrix();

            node.core.onUpdate.add(updateHandler);
		}

        private function updateHandler(p_deltaTime:Number):void {
            if (nativeObject != null && (updateFrameRate != 0 || g2d_invalidate)) {
                invalidateTexture(false);

                g2d_accumulatedTime += p_deltaTime;
                var updateTime:Number = 1000/updateFrameRate;
                if (g2d_invalidate || g2d_accumulatedTime > updateTime) {
                    texture.g2d_bitmapData.fillRect(texture.g2d_bitmapData.rect, 0x0);
                    var bounds:Rectangle = nativeObject.getBounds(nativeObject);
                    g2d_nativeMatrix.tx = -bounds.x;
                    g2d_nativeMatrix.ty = -bounds.y;
                    texture.g2d_bitmapData.draw(nativeObject, g2d_nativeMatrix);
                    texture.invalidateNativeTexture(false);

                    g2d_accumulatedTime %= updateTime;
                }

                g2d_invalidate = false;
            }
        }

		public function invalidateTexture(p_force:Boolean):void {
            if (nativeObject == null) return;
            if (!p_force && g2d_lastNativeWidth == nativeObject.width && g2d_lastNativeHeight == nativeObject.height) return;

            g2d_lastNativeWidth = nativeObject.width;
            g2d_lastNativeHeight = nativeObject.height;

            var bitmapData:BitmapData;
            if (forceMod2) {
                bitmapData = new BitmapData((g2d_lastNativeWidth%2==0) ? g2d_lastNativeWidth : g2d_lastNativeWidth+1, (g2d_lastNativeHeight%2==0) ? g2d_lastNativeHeight : g2d_lastNativeHeight+1, _bTransparent, 0x0);
            } else {
                bitmapData = new BitmapData(g2d_lastNativeWidth, g2d_lastNativeHeight, _bTransparent, 0x0);
            }

			if (texture == null || texture.gpuWidth != GTextureUtils.getNextValidTextureSize(g2d_lastNativeWidth) || texture.gpuHeight != GTextureUtils.getNearestValidTextureSize(g2d_lastNativeHeight)) {
                if(texture != null) texture.dispose();
				texture = GTextureFactory.createFromBitmapData(g2d_textureId, bitmapData);
			} else {
				texture.g2d_bitmapData = bitmapData;
                texture.setRegion(bitmapData.rect);
			}

            invalidateAlign();

			g2d_invalidate = true;
		}

        protected function invalidateAlign():void {
            switch (align) {
                case GFlashObjectAlign.TOP_LEFT:
                    texture.pivotX = -texture.width/2;
                    texture.pivotY = -texture.height/2;
                    break;
                case GFlashObjectAlign.CENTER:
                    texture.pivotX = 0;
                    texture.pivotY = 0;
                    break;
            }
        }
		
		override public function dispose():void {
            node.core.onUpdate.remove(updateHandler);
			texture.dispose();
			
			super.dispose();
		}
	}
}