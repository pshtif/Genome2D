package com.genome2d.node {

/**
 * ...
 * @author 
 */
import com.genome2d.node.factory.GNodeFactory;
public class GNodePool
{
	private var g2d_first:GNode;
	private var g2d_last:GNode;
	
	private var g2d_prototype:XML;
	
	private var g2d_maxCount:int;
	
	private var g2d_cachedCount:int = 0;
    public function getCachedCount():int {
        return g2d_cachedCount;
    }

	public function GNodePool(p_prototype:XML, p_maxCount:int = 0, p_precacheCount:int = 0) {
		g2d_prototype = p_prototype;
		g2d_maxCount = p_maxCount;
		
		for (var i:int = 0; i<p_precacheCount; ++i) {
			g2d_createNew(true);
		}
	}
	
	public function getNext():GNode {
		var node:GNode;

		if (g2d_first == null || g2d_first.isActive()) {
			node = g2d_createNew();
		} else {
			node = g2d_first;
            node.setActive(true);
		}

		return node;
	}
	
	/**
	 *	@private
	 */
	public function g2d_putToFront(p_node:GNode):void {
		if (p_node == g2d_first) return;
		
		if (p_node.g2d_poolNext != null) p_node.g2d_poolNext.g2d_poolPrevious = p_node.g2d_poolPrevious;
		if (p_node.g2d_poolPrevious != null) p_node.g2d_poolPrevious.g2d_poolNext = p_node.g2d_poolNext;
		if (p_node == g2d_last) g2d_last = g2d_last.g2d_poolPrevious;
		
		if (g2d_first != null) g2d_first.g2d_poolPrevious = p_node;
		p_node.g2d_poolPrevious = null;
		p_node.g2d_poolNext = g2d_first;
		g2d_first = p_node;
	}
	
	/**
	 *  @private
	 */	
	public function g2d_putToBack(p_node:GNode):void {
		if (p_node == g2d_last) return;
		
		if (p_node.g2d_poolNext != null) p_node.g2d_poolNext.g2d_poolPrevious = p_node.g2d_poolPrevious;
		if (p_node.g2d_poolPrevious != null) p_node.g2d_poolPrevious.g2d_poolNext = p_node.g2d_poolNext;
		if (p_node == g2d_first) g2d_first = g2d_first.g2d_poolNext;
			
		if (g2d_last != null) g2d_last.g2d_poolNext = p_node;
		p_node.g2d_poolPrevious = g2d_last;
		p_node.g2d_poolNext = null;
		g2d_last = p_node;
	}
	
	private function g2d_createNew(p_precache:Boolean = false):GNode {
		var node:GNode = null;
		if (g2d_maxCount == 0 || g2d_cachedCount < g2d_maxCount) {
			g2d_cachedCount++;
			node = GNodeFactory.createFromPrototype(g2d_prototype);
            if (p_precache) node.setActive(false);
			node.g2d_pool = this;
			
			if (g2d_first == null) {
				g2d_first = node;
				g2d_last = node;
			} else {
				node.g2d_poolPrevious = g2d_last;
				g2d_last.g2d_poolNext = node;
				g2d_last = node;
			}
		}
		
		return node;
	}
	
	public function dispose():void {
		while (g2d_first != null) {
			var next:GNode = g2d_first.g2d_poolNext;
			g2d_first.dispose();
			g2d_first = next;
		}
	}
}
}