package com.genome2d.components.renderables
{
	import com.genome2d.g2d;
	import com.genome2d.components.GCamera;
	import com.genome2d.context.GContext;
	import com.genome2d.core.GNode;
	import com.genome2d.textures.GTexture;
	
	import flash.geom.Rectangle;
	
	use namespace g2d;
	
	public class GTileMap extends GRenderable
	{
		protected var _iWidth:int;
		protected var _iHeight:int;
		protected var _aTiles:Vector.<GTile>;
		
		protected var _iTileWidth:int = 0;
		protected var _iTileHeight:int = 0;
		protected var _bIso:Boolean = false;
		
		public function GTileMap(p_node:GNode) {
			super(p_node);
		}
		
		public function setTiles(p_tiles:Vector.<GTile>, p_mapWidth:int, p_mapHeight:int, p_tileWidth:int, p_tileHeight:int,  p_iso:Boolean = false):void {
			if (p_mapWidth*p_mapHeight != p_tiles.length) throw new Error("Invalid tile map.");
			
			_aTiles = p_tiles;
			_iWidth = p_mapWidth;
			_iHeight = p_mapHeight;
			_bIso = p_iso;
			
			setTileSize(p_tileWidth, p_tileHeight);
		}
		
		public function setTile(p_tileIndex:int, p_tile:int):void {
			if (p_tileIndex<0 || p_tileIndex>= _aTiles.length) return; 
			_aTiles[p_tileIndex] = p_tile;
		}
		
		public function setTileSize(p_width:int, p_height:int):void {
			_iTileWidth = p_width;
			_iTileHeight = p_height;
		}
		
		override public function render(p_context:GContext, p_camera:GCamera, p_maskRect:Rectangle):void {
			if (_aTiles == null) return;
			
			var mapHalfWidth:Number = _iTileWidth * _iWidth * .5;
			var mapHalfHeight:Number = _iTileHeight * _iHeight * (_bIso ? .25 : .5);
			
			// Position of top left visible tile from 0,0
			var startX:Number =	p_camera.cNode.cTransform.nWorldX - cNode.cTransform.nWorldX - p_camera.rViewRectangle.width *.5;
			var startY:Number = p_camera.cNode.cTransform.nWorldY - cNode.cTransform.nWorldY - p_camera.rViewRectangle.height *.5;
			// Position of top left tile from map center
			var firstX:Number = -mapHalfWidth + (_bIso ? _iTileWidth/2 : 0);
			var firstY:Number = -mapHalfHeight + (_bIso ? _iTileHeight/2 : 0);
			
			// Index of top left visible tile
			var indexX:int = (startX - firstX) / _iTileWidth;
			if (indexX<0) indexX = 0;
			var indexY:int = (startY - firstY) / (_bIso ? _iTileHeight/2 : _iTileHeight);
			if (indexY<0) indexY = 0;
			
			// Position of bottom right tile from map center
			var endX:Number = p_camera.cNode.cTransform.nWorldX - cNode.cTransform.nWorldX + p_camera.rViewRectangle.width * .5 - (_bIso ? _iTileWidth/2 : _iTileWidth);
			var endY:Number = p_camera.cNode.cTransform.nWorldY - cNode.cTransform.nWorldY + p_camera.rViewRectangle.height * .5 - (_bIso ? 0 : _iTileHeight);
		
			var indexWidth:int = (endX - firstX) / _iTileWidth - indexX+2;
			if (indexWidth>_iWidth-indexX) indexWidth = _iWidth - indexX;
			
			var indexHeight:int = (endY - firstY) / (_bIso ? _iTileHeight/2 : _iTileHeight) - indexY+2;
			if (indexHeight>_iHeight-indexY) indexHeight = _iHeight - indexY;
			//trace(indexX, indexY, indexWidth, indexHeight);
			var tileCount:int = indexWidth*indexHeight;
			for (var i:int=0; i<tileCount; ++i) {
				var row:int = int(i / indexWidth);
				var x:Number = cNode.cTransform.nWorldX + (indexX + (i % indexWidth)) * _iTileWidth - mapHalfWidth + (_bIso && (indexY+row)%2 == 1 ? _iTileWidth : _iTileWidth/2);
				var y:Number = cNode.cTransform.nWorldY + (indexY + row) * (_bIso ? _iTileHeight/2 : _iTileHeight) - mapHalfHeight + _iTileHeight/2;
				
				var index:int = indexY * _iWidth + indexX + int(i / indexWidth) * _iWidth + i % indexWidth;
				var tile:GTile = _aTiles[index];
				// TODO: All transforms
				if (tile != null && tile.textureId != null) p_context.draw(GTexture.getTextureById(tile.textureId), x, y, 1, 1, 0, 1, 1, 1, 1, 1, p_maskRect); 
			}
		}
		
		public function getTileAt(p_x:Number, p_y:Number, p_camera:GCamera = null):GTile {
			if (p_camera == null) p_camera = node.core.defaultCamera;
			
			p_x -= p_camera.rViewRectangle.x + p_camera.rViewRectangle.width/2;
			p_y -= p_camera.rViewRectangle.y + p_camera.rViewRectangle.height/2;
			
			var mapHalfWidth:Number = _iTileWidth * _iWidth * .5;
			var mapHalfHeight:Number = _iTileHeight * _iHeight * (_bIso ? .25 : .5);
			
			var firstX:Number = -mapHalfWidth + (_bIso ? _iTileWidth/2 : 0);
			var firstY:Number = -mapHalfHeight + (_bIso ? _iTileHeight/2 : 0);

			var tx:Number = p_camera.cNode.cTransform.nWorldX - cNode.cTransform.nWorldX + p_x;
			var ty:Number = p_camera.cNode.cTransform.nWorldY - cNode.cTransform.nWorldY + p_y;
			
			var indexX:int = Math.floor((tx - firstX) / _iTileWidth);
			var indexY:int = Math.floor((ty - firstY) / _iTileHeight);
			
			if (indexX<0 || indexX>=_iWidth || indexY<0 || indexY>=_iHeight) return null;
			return _aTiles[indexY*_iWidth+indexX];
		}
	}
}
