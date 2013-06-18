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
		protected var _cTextureAtlas:GTextureAtlas;
		
		protected var _bInvalidate:Boolean = false;
		
		protected var _nTracking:Number = 0;
		public function get tracking():Number {
			return _nTracking;
		}
		public function set tracking(p_tracking:Number):void {
			_nTracking = p_tracking;
			_bInvalidate = true;
		}
		
		protected var _nLineSpace:Number = 0;
		public function get lineSpace():Number {
			return _nLineSpace;
		}
		public function set lineSpace(p_value:Number):void {
			_nLineSpace = p_value;
			_bInvalidate = true;
		}
		
		protected var _iAlign:int = GTextureTextAlignType.TOP_LEFT;
		public function get align():int {
			return _iAlign;
		}
		public function set align(p_align:int):void {
			_iAlign = p_align;
			_bInvalidate = true;
		}
		
		public var maxWidth:Number = 0;
		
		/**
		 * 	@private
		 */
		public function GTextureText(p_node:GNode) {
			super(p_node);
		}
		
		public function get textureAtlasId():String {
			if (_cTextureAtlas) return _cTextureAtlas.id;
			return "";
		}
		
		public function set textureAtlasId(p_value:String):void {
			setTextureAtlas(GTextureAtlas.getTextureAtlasById(p_value));
		}
		
		public function setTextureAtlas(p_textureAtlas:GTextureAtlas):void {
			_cTextureAtlas = p_textureAtlas;
			_bInvalidate = true;
		}
		
		protected var _sText:String = "";
		public function get text():String {
			return _sText;
		}
		public function set text(p_text:String):void {
			_sText = p_text;
			_bInvalidate = true;
		}
		
		protected var _nWidth:Number = 0;
		public function get width():Number {
			if (_bInvalidate) invalidateText();
			
			return _nWidth*cNode.cTransform.nWorldScaleX;
		}
		
		protected var _nHeight:Number = 0;
		public function get height():Number {		
			if (_bInvalidate) invalidateText();
			
			return _nHeight*cNode.cTransform.nWorldScaleY;
		}
			
		override public function update(p_deltaTime:Number, p_parentTransformUpdate:Boolean, p_parentColorUpdate:Boolean):void {
			if (!_bInvalidate) return;
		
			invalidateText();
		}
			
		protected function invalidateText():void {
			if (_cTextureAtlas == null) return;
			
			_nWidth = 0;
			var offsetX:Number = 0;
			var offsetY:Number =  0;
			var charNode:GNode = cNode.firstChild;
			var charSprite:GSprite;
			var texture:GTexture;
			
			for (var i:int = 0; i<_sText.length; ++i) {
				if (_sText.charCodeAt(i) == 10) {
					_nWidth = (offsetX>_nWidth) ? offsetX : _nWidth;
					offsetX = 0;
					offsetY+=texture.height+_nLineSpace;
					continue;
				}
				texture = _cTextureAtlas.getTexture(String(_sText.charCodeAt(i)));
				if (texture == null) throw new GError("Texture for character "+_sText.charAt(i)+" with code "+_sText.charCodeAt(i)+" not found!");
				if (charNode == null) {
					charSprite = GNodeFactory.createNodeWithComponent(GSprite) as GSprite;
					charNode = charSprite.cNode;
					cNode.addChild(charNode);
				} else {
					charSprite = charNode.getComponent(GSprite) as GSprite;
				}
				charSprite.node.cameraGroup = node.cameraGroup;
				charSprite.setTexture(texture);
				if (maxWidth>0 && offsetX + texture.width>maxWidth) {
					_nWidth = (offsetX>_nWidth) ? offsetX : _nWidth;
					offsetX = 0;
					offsetY+=texture.height+_nLineSpace;
				}
				offsetX += texture.width/2;
				charSprite.cNode.cTransform.x = offsetX;
				charSprite.cNode.cTransform.y = offsetY+texture.height/2;
				offsetX += texture.width/2 + _nTracking;
				charNode = charNode.next;
			}
			
			_nWidth = (offsetX>_nWidth) ? offsetX : _nWidth;
			_nHeight = offsetY + (texture!=null ? texture.height : 0);
			while (charNode) {
				var next:GNode = charNode.next;
				cNode.removeChild(charNode);
				charNode = next;
			}
			
			invalidateAlign();
			
			_bInvalidate = false;
		}
		
		private function invalidateAlign():void {
			var node:GNode;
			switch (_iAlign) {
				case GTextureTextAlignType.MIDDLE_CENTER:
					for (node = cNode.firstChild; node; node = node.next) {
						node.transform.x -= _nWidth/2;
						node.transform.y -= _nHeight/2;
					}
					break;
				case GTextureTextAlignType.TOP_RIGHT:
					for (node = cNode.firstChild; node; node = node.next) {
						node.transform.x -= _nWidth;
					}
					break;
				case GTextureTextAlignType.TOP_LEFT:	
					break;
				case GTextureTextAlignType.MIDDLE_RIGHT:
					for (node = cNode.firstChild; node; node = node.next) {
						node.transform.x -= _nWidth
						node.transform.y -= _nHeight/2;
					}
					break;
                case GTextureTextAlignType.MIDDLE_LEFT:
                    for (node = cNode.firstChild; node; node = node.next) {
                        node.transform.y -= _nHeight/2;
                    }
                    break;
			}
		}
		
		/**
		 * 	@private
		 */
		override public function processMouseEvent(p_captured:Boolean, p_event:MouseEvent, p_position:Vector3D):Boolean {
			if (_nWidth == 0 || _nHeight == 0) return false;
			if (p_captured) {
				if (cNode.cMouseOver == cNode) cNode.handleMouseEvent(cNode, MouseEvent.MOUSE_OUT, Number.NaN, Number.NaN, p_event.buttonDown, p_event.ctrlKey);
				return false;
			}
			
			var transformMatrix:Matrix3D = cNode.cTransform.getTransformedWorldTransformMatrix(_nWidth, _nHeight, 0, true);
			
			var localMousePosition:Vector3D = transformMatrix.transformVector(p_position);
			
			transformMatrix.prependScale(1/_nWidth, 1/_nHeight, 1);
			
			var tx:Number = 0;
			var ty:Number = 0;
			switch (_iAlign) {
				case GTextureTextAlignType.MIDDLE_CENTER:
					tx = -.5;
					ty = -.5;
					break;
			}
			
			if (localMousePosition.x >= tx && localMousePosition.x <= 1+tx && localMousePosition.y >= ty && localMousePosition.y <= 1+ty) {
				cNode.handleMouseEvent(cNode, p_event.type, localMousePosition.x*_nWidth, localMousePosition.y*_nHeight, p_event.buttonDown, p_event.ctrlKey);
				if (cNode.cMouseOver != cNode) {
					cNode.handleMouseEvent(cNode, MouseEvent.MOUSE_OVER, localMousePosition.x*_nWidth, localMousePosition.y*_nHeight, p_event.buttonDown, p_event.ctrlKey);
				}
				
				return true;
			} else {
				if (cNode.cMouseOver == cNode) {
					cNode.handleMouseEvent(cNode, MouseEvent.MOUSE_OUT, localMousePosition.x*_nWidth, localMousePosition.y*_nHeight, p_event.buttonDown, p_event.ctrlKey);
				}
			}
			
			return false;
		}
	}
}