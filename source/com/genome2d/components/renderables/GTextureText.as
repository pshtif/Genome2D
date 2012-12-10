/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.components.renderables
{
	import com.genome2d.g2d;
	import com.genome2d.core.GNode;
	import com.genome2d.core.GNodeFactory;
	import com.genome2d.error.GError;
	import com.genome2d.textures.GTexture;
	import com.genome2d.textures.GTextureAtlas;
	
	import flash.events.MouseEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	use namespace g2d;
	
	public class GTextureText extends GRenderable
	{
		private var __cTextureAtlas:GTextureAtlas;
		
		private var __bInvalidate:Boolean = false;
		
		private var __nTracking:Number = 0;
		public function get tracking():Number {
			return __nTracking;
		}
		public function set tracking(p_tracking:Number):void {
			__nTracking = p_tracking;
			__bInvalidate = true;
		}
		
		private var __iAlign:int = GTextureTextAlignType.TOP_LEFT;
		public function get align():int {
			return __iAlign;
		}
		public function set align(p_align:int):void {
			__iAlign = p_align;
			__bInvalidate = true;
		}
		
		/**
		 * 	@private
		 */
		public function GTextureText(p_node:GNode) {
			super(p_node);
		}
		
		public function get textureAtlasId():String {
			if (__cTextureAtlas) return __cTextureAtlas.id;
			return "";
		}
		
		public function set textureAtlasId(p_value:String):void {
			setTextureAtlas(GTextureAtlas.getTextureAtlasById(p_value));
		}
		
		public function setTextureAtlas(p_textureAtlas:GTextureAtlas):void {
			__cTextureAtlas = p_textureAtlas;
			__bInvalidate = true;
		}
		
		private var __sText:String = "";
		public function get text():String {
			return __sText;
		}
		public function set text(p_text:String):void {
			__sText = p_text;
			__bInvalidate = true;
		}
		
		private var __nWidth:Number = 0;
		public function get width():Number {
			if (__bInvalidate) invalidateText();
			
			return __nWidth*cNode.cTransform.nWorldScaleX;
		}
		
		private var __nHeight:Number = 0;
		public function get height():Number {		
			if (__bInvalidate) invalidateText();
			
			return __nHeight*cNode.cTransform.nWorldScaleY;
		}
			
		override public function update(p_deltaTime:Number, p_parentTransformUpdate:Boolean, p_parentColorUpdate:Boolean):void {
			if (!__bInvalidate) return;
		
			invalidateText();
		}
			
		private function invalidateText():void {
			if (__cTextureAtlas == null) return;
			
			var offset:int = 0;
			var charNode:GNode = cNode.firstChild;
			var charSprite:GSprite;
			var texture:GTexture;
			
			for (var i:int = 0; i<__sText.length; ++i) {
				texture = __cTextureAtlas.getTexture(String(__sText.charCodeAt(i)));
				if (texture == null) throw new GError(GError.NO_TEXTURE_FOR_CHARACTER_FOUND+__sText.charCodeAt(i)+" "+__sText.charAt(i));
				__nHeight = texture.height;
				if (charNode == null) {
					charSprite = GNodeFactory.createNodeWithComponent(GSprite) as GSprite;
					charNode = charSprite.cNode;
					cNode.addChild(charNode);
				} else {
					charSprite = charNode.getComponent(GSprite) as GSprite;
				}
				charSprite.node.cameraGroup = node.cameraGroup;
				charSprite.setTexture(texture);
				offset += texture.width/2;
				charSprite.cNode.cTransform.x = offset;
				charSprite.cNode.cTransform.y = texture.height/2;
				offset += texture.width/2 + __nTracking;
				charNode = charNode.next;
			}
			
			__nWidth = offset;
			
			while (charNode) {
				var next:GNode = charNode.next;
				cNode.removeChild(charNode);
				charNode = next;
			}
			
			invalidateAlign();
			
			__bInvalidate = false;
		}
		
		private function invalidateAlign():void {
			var node:GNode;
			switch (__iAlign) {
				case GTextureTextAlignType.MIDDLE:
					for (node = cNode.firstChild; node; node = node.next) {
						node.transform.x -= __nWidth/2;
						node.transform.y -= __nHeight/2;
					}
					break;
				case GTextureTextAlignType.TOP_RIGHT:
					for (node = cNode.firstChild; node; node = node.next) {
						node.transform.x -= __nWidth;
					}
					break;
				case GTextureTextAlignType.TOP_LEFT:	
					break;
			}
		}
		
		/**
		 * 	@private
		 */
		override public function processMouseEvent(p_captured:Boolean, p_event:MouseEvent, p_position:Vector3D):Boolean {
			if (p_captured) {
				if (cNode.cMouseOver == cNode) cNode.handleMouseEvent(cNode, MouseEvent.MOUSE_OUT, Number.NaN, Number.NaN, p_event.buttonDown, p_event.ctrlKey);
				return false;
			}
			
			var transformMatrix:Matrix3D = cNode.cTransform.getTransformedWorldTransformMatrix(__nWidth, __nHeight, 0, true);
			
			var localMousePosition:Vector3D = transformMatrix.transformVector(p_position);
			
			transformMatrix.prependScale(1/__nWidth, 1/__nHeight, 1);
			
			var tx:Number = 0;
			var ty:Number = 0;
			switch (__iAlign) {
				case GTextureTextAlignType.MIDDLE:
					tx = -.5;
					ty = -.5;
					break;
			}
			
			if (localMousePosition.x >= tx && localMousePosition.x <= 1+tx && localMousePosition.y >= ty && localMousePosition.y <= 1+ty) {
				cNode.handleMouseEvent(cNode, p_event.type, localMousePosition.x*__nWidth, localMousePosition.y*__nHeight, p_event.buttonDown, p_event.ctrlKey);
				if (cNode.cMouseOver != cNode) {
					cNode.handleMouseEvent(cNode, MouseEvent.MOUSE_OVER, localMousePosition.x*__nWidth, localMousePosition.y*__nHeight, p_event.buttonDown, p_event.ctrlKey);
				}
				
				return true;
			} else {
				if (cNode.cMouseOver == cNode) {
					cNode.handleMouseEvent(cNode, MouseEvent.MOUSE_OUT, localMousePosition.x*__nWidth, localMousePosition.y*__nHeight, p_event.buttonDown, p_event.ctrlKey);
				}
			}
			
			return false;
		}
	}
}