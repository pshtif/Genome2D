/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.components.renderables.flash
{
import com.genome2d.node.GNode;

import flash.text.TextField;
import flash.text.TextFormat;

public class GFlashText extends GFlashObject
	{
		private var __tfoTextFormat:TextFormat;
		private var __tfTextField:TextField;
		
		public function set textFormat(p_textFormat:TextFormat):void {
			__tfTextField.defaultTextFormat = p_textFormat;
			if (__tfTextField.text.length > 0) __tfTextField.setTextFormat(p_textFormat, 0, __tfTextField.text.length-1);
			
			g2d_invalidate = true;
		}
		
		public function set embedFonts(p_value:Boolean):void {
			__tfTextField.embedFonts = p_value;
		}
		
		public function set background(p_background:Boolean):void {
			__tfTextField.background = p_background;
			
			g2d_invalidate = true;
		}
		
		public function set wordWrap(p_wordWrap:Boolean):void {
			__tfTextField.wordWrap = p_wordWrap;
			
			g2d_invalidate = true;
		}
		
		public function set backgroundColor(p_backgroundColor:int):void {
			__tfTextField.backgroundColor = p_backgroundColor;
			
			g2d_invalidate = true;
		}
		
		public function set htmlText(p_htmlText:String):void {
			__tfTextField.htmlText = p_htmlText;

			g2d_invalidate = true;
		}
		
		public function set text(p_text:String):void {
			__tfTextField.text = p_text;
			
			g2d_invalidate = true;
		}
		
		public function set multiLine(p_multiline:Boolean):void {
			__tfTextField.multiline = p_multiline;
			
			g2d_invalidate = true;
		}
		
		public function set textColor(p_textColor:int):void {
			__tfTextField.textColor = p_textColor;
			
			g2d_invalidate = true;
		}
		
		public function set autoSize(p_autoSize:String):void {
			__tfTextField.autoSize = p_autoSize;
			
			g2d_invalidate = true;
		}
		
		public function get width():Number {
			return __tfTextField.width;
		}
		public function set width(p_width:Number):void {
			__tfTextField.width = p_width;
			
			g2d_invalidate = true;
		}
		
		public function get height():Number {
			return __tfTextField.height;
		}
		public function set height(p_height:Number):void {
			__tfTextField.height = p_height;
			
			g2d_invalidate = true;
		}
		
		static private var __iCount:int = 0;		
		/**
		 * 	@private
		 */
		public function GFlashText(p_node:GNode) {
			super(p_node);
			
			updateFrameRate = 0;

			__tfTextField = new TextField();
			nativeObject = __tfTextField;
		}
	}
}