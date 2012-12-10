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
	import com.genome2d.textures.GTextureResampleType;
	
	import flash.display.Shape;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	use namespace g2d;
	
	public class GFlashVideo extends GFlashObject
	{
		private var __ncConnection:NetConnection;
		
		private var __nsStream:NetStream;
		public function get netStream():NetStream {
			return __nsStream;
		}
		
		private var __vNativeVideo:Video;
		public function get nativeVideo():Video {
			return __vNativeVideo;
		}

		private var __nAccumulatedTime:int;
		
		private var __bPlaying:Boolean = false;
		private var __sTextureId:String;
		
		static private var __iCount:int = 0;
		/**
		 * 	@private
		 */
		public function GFlashVideo(p_node:GNode) {
			super(p_node);
			
			_iResampleType = GTextureResampleType.NEAREST_DOWN_RESAMPLE_UP_CROP;
			__sTextureId = "G2DVideo#"+__iCount++;
			
			__ncConnection = new NetConnection();
			__ncConnection.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			__ncConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			__ncConnection.connect(null);
			
			__nsStream = new NetStream(__ncConnection);
			__nsStream.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			__nsStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			__nsStream.client = this;
			
			__vNativeVideo = new Video();
			__vNativeVideo.attachNetStream(__nsStream);
			_doNative = __vNativeVideo;
		}
		
		public function onMetaData(p_data:Object, ... args):void {
			__vNativeVideo.width = (p_data.width!=undefined) ? p_data.width : 320;
			__vNativeVideo.height = (p_data.height!=undefined) ? p_data.height : 240;

			if (updateFrameRate != 0 && p_data.framerate != undefined) updateFrameRate = p_data.framerate;
		}
		
		public function onPlayStatus(p_data:Object):void {
			if (p_data.code == "Netstream.Play.Complete") __bPlaying = false;
		}
		
		public function onTransition(... args):void {
		}
		
		public function playVideo(p_url:String):void {
			__nsStream.play(p_url);
		}
		
		private function onIOError(event:IOErrorEvent):void {
		}
		
		private function onNetStatus(event:NetStatusEvent):void {
			switch (event.info.code) {
				case "NetStream.Play.Stop":
					__nsStream.seek(0);
					break;
			}
		}
		
		override public function dispose():void {
			__vNativeVideo = null;
			
			__nsStream.close();
			__nsStream = null;
			
			__ncConnection.close();
			__ncConnection = null;
		}
	}
}