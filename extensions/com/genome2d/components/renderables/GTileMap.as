package com.genome2d.components.renderables
{
import com.genome2d.components.GComponent;
import com.genome2d.context.GContextCamera;
import com.genome2d.node.GNode;
import com.genome2d.textures.GTexture;

import flash.geom.Rectangle;

public class GTileMap extends GComponent implements IRenderable
	{
		protected var g2d_width:int;
		protected var g2d_height:int;
		protected var g2d_tiles:Vector.<GTile>;
        public function get tiles():Vector.<GTile> {
            return g2d_tiles;
        }
		
		protected var g2d_tileWidth:int = 0;
		protected var g2d_tileHeight:int = 0;
		protected var g2d_iso:Boolean = false;
		
		public function GTileMap(p_node:GNode) {
			super(p_node);
		}
		
		public function setTiles(p_tiles:Vector.<GTile>, p_mapWidth:int, p_mapHeight:int, p_tileWidth:int, p_tileHeight:int,  p_iso:Boolean = false):void {
			if (p_mapWidth*p_mapHeight != p_tiles.length) throw new Error("Invalid tile map.");
			
			g2d_tiles = p_tiles;
			g2d_width = p_mapWidth;
			g2d_height = p_mapHeight;
			g2d_iso = p_iso;
			
			setTileSize(p_tileWidth, p_tileHeight);
		}
		
		public function setTile(p_tileIndex:int, p_tile:GTile):void {
			if (p_tileIndex<0 || p_tileIndex>= g2d_tiles.length) return;
			g2d_tiles[p_tileIndex] = p_tile;
		}
		
		public function setTileSize(p_width:int, p_height:int):void {
			g2d_tileWidth = p_width;
			g2d_tileHeight = p_height;
		}
		
		public function render(p_camera:GContextCamera, p_useMatrix:Boolean):void {
			if (g2d_tiles == null) return;
			
			var mapHalfWidth:Number = g2d_tileWidth * g2d_width * .5;
			var mapHalfHeight:Number = g2d_tileHeight * g2d_height * (g2d_iso ? .25 : .5);
			
			// Position of top left visible tile from 0,0
            var cameraWidth:Number = node.core.getContext().getStageViewRect().width*p_camera.normalizedViewWidth / p_camera.scaleX;
            var cameraHeight:Number = node.core.getContext().getStageViewRect().height*p_camera.normalizedViewHeight / p_camera.scaleY;
			var startX:Number =	p_camera.x - g2d_node.transform.g2d_worldX - cameraWidth *.5;
			var startY:Number = p_camera.y - g2d_node.transform.g2d_worldY - cameraHeight *.5;
			// Position of top left tile from map center
			var firstX:Number = -mapHalfWidth + (g2d_iso ? g2d_tileWidth/2 : 0);
			var firstY:Number = -mapHalfHeight + (g2d_iso ? g2d_tileHeight/2 : 0);
			
			// Index of top left visible tile
			var indexX:int = (startX - firstX) / g2d_tileWidth;
			if (indexX<0) indexX = 0;
			var indexY:int = (startY - firstY) / (g2d_iso ? g2d_tileHeight/2 : g2d_tileHeight);
			if (indexY<0) indexY = 0;
			
			// Position of bottom right tile from map center
			var endX:Number = p_camera.x - g2d_node.transform.g2d_worldX + cameraWidth * .5 - (g2d_iso ? g2d_tileWidth/2 : g2d_tileWidth);
			var endY:Number = p_camera.y - g2d_node.transform.g2d_worldY + cameraHeight * .5 - (g2d_iso ? 0 : g2d_tileHeight);
		
			var indexWidth:int = (endX - firstX) / g2d_tileWidth - indexX+2;
			if (indexWidth>g2d_width-indexX) indexWidth = g2d_width - indexX;
			
			var indexHeight:int = (endY - firstY) / (g2d_iso ? g2d_tileHeight/2 : g2d_tileHeight) - indexY+2;
			if (indexHeight>g2d_height-indexY) indexHeight = g2d_height - indexY;
			//trace(indexX, indexY, indexWidth, indexHeight);
			var tileCount:int = indexWidth*indexHeight;
			for (var i:int=0; i<tileCount; ++i) {
				var row:int = int(i / indexWidth);
				var x:Number = g2d_node.transform.g2d_worldX + (indexX + (i % indexWidth)) * g2d_tileWidth - mapHalfWidth + (g2d_iso && (indexY+row)%2 == 1 ? g2d_tileWidth : g2d_tileWidth/2);
				var y:Number = g2d_node.transform.g2d_worldY + (indexY + row) * (g2d_iso ? g2d_tileHeight/2 : g2d_tileHeight) - mapHalfHeight + g2d_tileHeight/2;
				
				var index:int = indexY * g2d_width + indexX + int(i / indexWidth) * g2d_width + i % indexWidth;
				var tile:GTile = g2d_tiles[index];
				// TODO: All transforms
				if (tile != null && tile.textureId != null) node.core.getContext().draw(GTexture.getTextureById(tile.textureId), x, y, 1, 1, 0, 1, 1, 1, 1, 1);
			}
		}
		
		public function getTileAt(p_x:Number, p_y:Number, p_camera:GContextCamera = null):GTile {
			if (p_camera == null) p_camera = node.core.getContext().getDefaultCamera();

            var cameraX:Number = node.core.getContext().getStageViewRect().width*p_camera.normalizedViewX;
            var cameraY:Number = node.core.getContext().getStageViewRect().height*p_camera.normalizedViewY;
            var cameraWidth:Number = node.core.getContext().getStageViewRect().width*p_camera.normalizedViewWidth;
            var cameraHeight:Number = node.core.getContext().getStageViewRect().height*p_camera.normalizedViewHeight;
			p_x -= cameraX + cameraWidth*.5;
			p_y -= cameraY + cameraHeight*.5;

			var mapHalfWidth:Number = (g2d_tileWidth * p_camera.scaleX) * g2d_width * .5;
			var mapHalfHeight:Number = (g2d_tileHeight * p_camera.scaleY) * g2d_height * (g2d_iso ? .25 : .5);
			
			var firstX:Number = -mapHalfWidth + (g2d_iso ? (g2d_tileWidth * p_camera.scaleX) / 2 : 0);
			var firstY:Number = -mapHalfHeight + (g2d_iso ? (g2d_tileHeight * p_camera.scaleY) / 2 : 0);

			var tx:Number = p_camera.x - g2d_node.transform.g2d_worldX + p_x;
			var ty:Number = p_camera.y - g2d_node.transform.g2d_worldY + p_y;
			
			var indexX:int = Math.floor((tx - firstX) / (g2d_tileWidth * p_camera.scaleX));
			var indexY:int = Math.floor((ty - firstY) / (g2d_tileHeight * p_camera.scaleY));

			if (indexX<0 || indexX>=g2d_width || indexY<0 || indexY>=g2d_height) return null;
			return g2d_tiles[indexY*g2d_width+indexX];
		}

        public function getBounds(p_bounds:Rectangle = null):Rectangle {
            return null;
        }
	}
}