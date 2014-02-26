package com.genome2d.node.factory {
import com.genome2d.components.GComponent;
import com.genome2d.components.GTransform;
import com.genome2d.error.GError;
import com.genome2d.node.GNode;

import flash.utils.getDefinitionByName;

/**
 * ...
 * @author 
 */
public class GNodeFactory
{
	static public function createNode(p_name:String = ""):GNode {
		return new GNode(p_name);
	}
	
	static public function createNodeWithComponent(p_componentClass:Class, p_name:String = "", p_lookupClass:Class = null):GComponent {
		var node:GNode = new GNode(p_name);
			
		return node.addComponent(p_componentClass, p_lookupClass);
	}
	
	static public function createFromPrototype(p_prototypeXml:XML, p_name:String = ""):GNode {
        if (p_prototypeXml == null) throw new GError("Prototype cannot be null.");

        var i:int = 0;
        var node:GNode = new GNode(p_name);
        node.mouseEnabled = (p_prototypeXml.@mouseEnabled == "true") ? true : false;
        node.mouseChildren = (p_prototypeXml.@mouseChildren == "true") ? true : false;

        var xmlNode:XML;
        for (i=0; i<p_prototypeXml.components.children().length(); ++i) {
            xmlNode = p_prototypeXml.components.children()[i];

            var componentClass:* = getDefinitionByName(String(xmlNode.@componentClass).split("-").join("::"));
            if (componentClass == GTransform) {
                node.transform.bindFromPrototype(xmlNode);
            } else {
                var componentLookupClass:* = getDefinitionByName(String(xmlNode.@componentLookupClass).split("-").join("::"));
                var component:GComponent = node.addComponent(componentClass, componentLookupClass);
                component.bindFromPrototype(xmlNode);
            }
        }

        for (i=0; i<p_prototypeXml.children.children().length(); ++i) {
            xmlNode = p_prototypeXml.children.children()[i];
            node.addChild(GNodeFactory.createFromPrototype(xmlNode));
        }

        return node;
    }
}
}