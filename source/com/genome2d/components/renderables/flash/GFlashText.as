/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.components.renderables.flash
{
	import com.genome2d.core.GNode;
	import com.genome2d.g2d;
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	use namespace g2d;
	
	public class GFlashText extends GFlashObject
	{
		private var __tfoTextFormat:TextFormat;
		private var __tfTextField:TextField;
		
		public function set textFormat(p_textFormat:TextFormat):void {
			__tfTextField.defaultTextFormat = p_textFormat;
			if (__tfTextField.text.length > 0) __tfTextField.setTextFormat(p_textFormat, 0, __tfTextField.text.length);
			
			_bInvalidate = true;
		}
		
		public function set embedFonts(p_value:Boolean):void {
			__tfTextField.embedFonts = p_value;
		}
		
		public function set background(p_background:Boolean):void {
			__tfTextField.background = p_background;
			
			_bInvalidate = true;
		}
		
		public function set wordWrap(p_wordWrap:Boolean):void {
			__tfTextField.wordWrap = p_wordWrap;
			
			_bInvalidate = true;
		}
		
		public function set backgroundColor(p_backgroundColor:int):void {
			__tfTextField.backgroundColor = p_backgroundColor;
			
			_bInvalidate = true;
		}
		
		public function set htmlText(p_htmlText:String):void {
			__tfTextField.htmlText = p_htmlText;

			_bInvalidate = true;
		}
		
		public function set text(p_text:String):void {
			__tfTextField.text = p_text;
			
			_bInvalidate = true;
		}
		
		public function set multiLine(p_multiline:Boolean):void {
			__tfTextField.multiline = p_multiline;
			
			_bInvalidate = true;
		}
		
		public function set textColor(p_textColor:int):void {
			__tfTextField.textColor = p_textColor;
			
			_bInvalidate = true;
		}
		
		public function set autoSize(p_autoSize:String):void {
			__tfTextField.autoSize = p_autoSize;
			
			_bInvalidate = true;
		}
		
		public function get width():Number {
			return __tfTextField.width;
		}
		public function set width(p_width:Number):void {
			__tfTextField.width = p_width;
			
			_bInvalidate = true;
		}
		
		public function get height():Number {
			return __tfTextField.height;
		}
		public function set height(p_height:Number):void {
			__tfTextField.height = p_height;
			
			_bInvalidate = true;
		}
		
		static private var __iCount:int = 0;		
		/**
		 * 	@private
		 */
		public function GFlashText(p_node:GNode) {
			super(p_node);
			
			updateFrameRate = 0;

			__tfTextField = new TextField();
			_doNative = __tfTextField;
		}
	}
}
