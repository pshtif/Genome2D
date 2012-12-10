package com.genome2d.components.renderables
{
	import com.genome2d.g2d;
	import com.genome2d.components.GCamera;
	import com.genome2d.components.renderables.GRenderable;
	import com.genome2d.context.GContext;
	import com.genome2d.core.GNode;
	import com.genome2d.textures.GTexture;
	import com.genome2d.textures.GTextureAtlas;
	
	import flash.geom.Rectangle;
	import flash.utils.clearTimeout;
	
	use namespace g2d;
	
	public class GTileMap extends GRenderable
	{
		private var __iWidth:int;
		private var __iHeight:int;
		private var __aTiles:Vector.<GTile>;
		
		private var __iTileWidth:int = 0;
		private var __iTileHeight:int = 0;
		private var __bIso:Boolean = false;
		
		public function GTileMap(p_node:GNode) {
			super(p_node);
		}
		
		public function setTiles(p_tiles:Vector.<GTile>, p_mapWidth:int, p_mapHeight:int, p_tileWidth:int, p_tileHeight:int,  p_iso:Boolean = false):void {
			if (p_mapWidth*p_mapHeight != p_tiles.length) throw new Error("Invalid tile map.");
			
			__aTiles = p_tiles;
			__iWidth = p_mapWidth;
			__iHeight = p_mapHeight;
			__bIso = p_iso;
			
			setTileSize(p_tileWidth, p_tileHeight);
		}
		
		public function setTile(p_tileIndex:int, p_tile:int):void {
			if (p_tileIndex<0 || p_tileIndex>= __aTiles.length) return; 
			__aTiles[p_tileIndex] = p_tile;
		}
		
		public function setTileSize(p_width:int, p_height:int):void {
			__iTileWidth = p_width;
			__iTileHeight = p_height;
		}
		
		override public function render(p_context:GContext, p_camera:GCamera, p_maskRect:Rectangle):void {
			if (__aTiles == null) return;
			
			var mapHalfWidth:Number = __iTileWidth * __iWidth * .5;
			var mapHalfHeight:Number = __iTileHeight * __iHeight * (__bIso ? .25 : .5);
			
			// Position of top left visible tile from 0,0
			var startX:Number =	p_camera.cNode.cTransform.nWorldX - cNode.cTransform.nWorldX - p_camera.rViewRectangle.width *.5;
			var startY:Number = p_camera.cNode.cTransform.nWorldY - cNode.cTransform.nWorldY - p_camera.rViewRectangle.height *.5;
			// Position of top left tile from map center
			var firstX:Number = -mapHalfWidth + (__bIso ? __iTileWidth/2 : 0);
			var firstY:Number = -mapHalfHeight + (__bIso ? __iTileHeight/2 : 0);
			
			// Index of top left visible tile
			var indexX:int = (startX - firstX) / __iTileWidth;
			if (indexX<0) indexX = 0;
			var indexY:int = (startY - firstY) / (__bIso ? __iTileHeight/2 : __iTileHeight);
			if (indexY<0) indexY = 0;
			
			// Position of bottom right tile from map center
			var endX:Number = p_camera.cNode.cTransform.nWorldX - cNode.cTransform.nWorldX + p_camera.rViewRectangle.width * .5 - (__bIso ? __iTileWidth/2 : __iTileWidth);
			var endY:Number = p_camera.cNode.cTransform.nWorldY - cNode.cTransform.nWorldY + p_camera.rViewRectangle.height * .5 - (__bIso ? 0 : __iTileHeight);
		
			var indexWidth:int = (endX - firstX) / __iTileWidth - indexX+2;
			if (indexWidth>__iWidth-indexX) indexWidth = __iWidth - indexX;
			
			var indexHeight:int = (endY - firstY) / (__bIso ? __iTileHeight/2 : __iTileHeight) - indexY+2;
			if (indexHeight>__iHeight-indexY) indexHeight = __iHeight - indexY;
			//trace(indexX, indexY, indexWidth, indexHeight);
			var tileCount:int = indexWidth*indexHeight;
			for (var i:int=0; i<tileCount; ++i) {
				var row:int = int(i / indexWidth);
				var x:Number = cNode.cTransform.nWorldX + (indexX + (i % indexWidth)) * __iTileWidth - mapHalfWidth + (__bIso && (indexY+row)%2 == 1 ? __iTileWidth : __iTileWidth/2);
				var y:Number = cNode.cTransform.nWorldY + (indexY + row) * (__bIso ? __iTileHeight/2 : __iTileHeight) - mapHalfHeight + __iTileHeight/2;
				
				var index:int = indexY * __iWidth + indexX + int(i / indexWidth) * __iWidth + i % indexWidth;
				var tile:GTile = __aTiles[index];
				// TODO: All transforms
				if (tile != null && tile.textureId != null) p_context.draw(GTexture.getTextureById(tile.textureId), x, y, 1, 1, 0, 1, 1, 1, 1, 1, p_maskRect); 
			}
		}
		
		public function getTileAt(p_x:Number, p_y:Number, p_camera:GCamera = null):void {
			if (p_camera == null) p_camera = node.core.defaultCamera;
			
			p_x -= p_camera.rViewRectangle.x + p_camera.rViewRectangle.width/2;
			p_y -= p_camera.rViewRectangle.y + p_camera.rViewRectangle.height/2;
			
			var mapHalfWidth:Number = __iTileWidth * __iWidth * .5;
			var mapHalfHeight:Number = __iTileHeight * __iHeight * (__bIso ? .25 : .5);
			
			var firstX:Number = -mapHalfWidth + (__bIso ? __iTileWidth/2 : 0);
			var firstY:Number = -mapHalfHeight + (__bIso ? __iTileHeight/2 : 0);
			trace(firstX, firstY);
			var tx:Number = p_camera.cNode.cTransform.nWorldX - cNode.cTransform.nWorldX + p_x;
			var ty:Number = p_camera.cNode.cTransform.nWorldY - cNode.cTransform.nWorldY + p_y;
			trace(tx, ty);
			var indexX:int = (tx - firstX) / __iTileWidth;
			var indexY:int = (ty - firstY) / __iTileHeight;
			trace(indexX, indexY);
		}
	}
}
