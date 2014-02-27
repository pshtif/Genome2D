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

import flash.events.IOErrorEvent;
import flash.events.NetStatusEvent;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;

public class GFlashVideo extends GFlashObject
	{
		private var g2d_connection:NetConnection;
		
		private var g2d_stream:NetStream;
		public function get netStream():NetStream {
			return g2d_stream;
		}
		
		private var g2d_nativeVideo:Video;
		public function get nativeVideo():Video {
			return g2d_nativeVideo;
		}

		private var g2d_playing:Boolean = false;
		private var g2d_textureId:String;
		
		static private var g2d_count:int = 0;
		/**
		 * 	@private
		 */
		public function GFlashVideo(p_node:GNode) {
			super(p_node);

			g2d_textureId = "G2DVideo#"+g2d_count++;
			
			g2d_connection = new NetConnection();
			g2d_connection.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			g2d_connection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			g2d_connection.connect(null);
			
			g2d_stream = new NetStream(g2d_connection);
			g2d_stream.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			g2d_stream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			g2d_stream.client = this;
			
			g2d_nativeVideo = new Video();
			g2d_nativeVideo.attachNetStream(g2d_stream);
			nativeObject = g2d_nativeVideo;
		}
		
		public function onMetaData(p_data:Object, ... args):void {
			g2d_nativeVideo.width = (p_data.width!=undefined) ? p_data.width : 320;
			g2d_nativeVideo.height = (p_data.height!=undefined) ? p_data.height : 240;

			if (updateFrameRate != 0 && p_data.framerate != undefined) updateFrameRate = p_data.framerate;
		}
		
		public function onPlayStatus(p_data:Object):void {
			if (p_data.code == "Netstream.Play.Complete") g2d_playing = false;
		}
		
		public function onTransition(... args):void {
		}
		
		public function playVideo(p_url:String):void {
			g2d_stream.play(p_url);
		}
		
		private function onIOError(event:IOErrorEvent):void {
		}
		
		private function onNetStatus(event:NetStatusEvent):void {
			switch (event.info.code) {
				case "NetStream.Play.Stop":
					g2d_stream.seek(0);
					break;
			}
		}
		
		override public function dispose():void {
			g2d_nativeVideo = null;
			
			g2d_stream.close();
			g2d_stream = null;
			
			g2d_connection.close();
			g2d_connection = null;
		}
	}
}