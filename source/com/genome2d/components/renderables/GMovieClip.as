/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.components.renderables
{
	import avmplus.getQualifiedClassName;
	
	import com.genome2d.core.GNode;
	import com.genome2d.g2d;
	import com.genome2d.textures.GTextureAtlas;
	import com.genome2d.textures.GTextureBase;

	use namespace g2d;
	
	public class GMovieClip extends GTexturedQuad
	{
		private var _nSpeed:Number = 1000/30;
		private var _nAccumulatedTime:Number = 0;
		
		private var _iCurrentFrame:int = -1;
		public function get currentFrame():int {
			return _iCurrentFrame;
		}
		
		private var _iStartIndex:int = -1;
		private var _iEndIndex:int = -1; 
		private var _bPlaying:Boolean = true;
		
		private var __cTextureAtlas:GTextureAtlas;
		public function get textureAtlasId():String {
			return (__cTextureAtlas) ? __cTextureAtlas.id : "";
		}
		public function set textureAtlasId(p_value:String):void {
			__cTextureAtlas = (p_value != "") ? GTextureAtlas.getTextureAtlasById(p_value) : null;
			if (__aFrameIds) cTexture = __cTextureAtlas.getTexture(__aFrameIds[0]);
		}
		
		private var __aFrameIds:Array;
		private var __iFrameIdsLength:int = 0;
		public function get frames():Array {
			return __aFrameIds;
		}
		public function set frames(p_value:Array):void {
			__aFrameIds = p_value;
			__iFrameIdsLength = __aFrameIds.length;
			_iCurrentFrame = 0;
			if (__cTextureAtlas) cTexture = __cTextureAtlas.getTexture(__aFrameIds[0]);
		}
		
		public var repeatable:Boolean = true;
		
		static private var __iCount:int = 0;
		
		/**
		 * 	@private
		 */
		public function GMovieClip(p_node:GNode) {
			super(p_node);
		}
		
		/**
		 * 	Set texture atlas that should be used by this movie clip
		 */
		public function setTextureAtlas(p_textureAtlas:GTextureAtlas):void {
			__cTextureAtlas = p_textureAtlas;
			if (__aFrameIds) cTexture = __cTextureAtlas.getTexture(__aFrameIds[0]);
		}
		
		public function get frameRate():int {
			return 1000/_nSpeed;
		}
		/**
		 * 	Set framerate at which this clip should play
		 */
		public function set frameRate(p_frameRate:int):void {
			_nSpeed = 1000/p_frameRate;
		}
		
		public function get numFrames():int {
			return __iFrameIdsLength;
		}
		
		/**
		 * 	Go to a specified frame of this movie clip
		 */
		public function gotoFrame(p_frame:int):void {
			if (__aFrameIds == null) return;
			_iCurrentFrame = p_frame;
			_iCurrentFrame %= __aFrameIds.length;
			cTexture = __cTextureAtlas.getTexture(__aFrameIds[_iCurrentFrame]);
		}
		
		public function gotoAndPlay(p_frame:int):void {
			gotoFrame(p_frame);
			play();
		}
		
		/**
		 * 	Stop playback of this movie clip
		 */
		public function stop():void {
			_bPlaying = false;
		}
		
		/**
		 * 	Start the playback of this movie clip
		 */
		public function play():void {
			_bPlaying = true;
		}
		
		/**
		 * 	@private
		 */
		override public function update(p_deltaTime:Number, p_parentTransformUpdate:Boolean, p_parentColorUpdate:Boolean):void {
			if (cTexture == null) return;
			
			if (_bPlaying) {
				_nAccumulatedTime += p_deltaTime;
				 
				if (_nAccumulatedTime >= _nSpeed) {
					_iCurrentFrame += _nAccumulatedTime/_nSpeed; 
					if (_iCurrentFrame<__iFrameIdsLength || repeatable) {
						_iCurrentFrame %= __aFrameIds.length;
					} else {
						_iCurrentFrame = __iFrameIdsLength-1;
					}				

					cTexture = __cTextureAtlas.getTexture(__aFrameIds[_iCurrentFrame]);
				}
				_nAccumulatedTime %= _nSpeed;
			}
		}
	}
}