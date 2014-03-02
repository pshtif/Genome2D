/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.components {
import com.genome2d.node.GNode;
import com.genome2d.signals.GMouseSignal;

import flash.utils.describeType;

import flash.utils.getQualifiedClassName;

public class GComponent
{
	protected var g2d_active:Boolean = true;
	
	public function isActive():Boolean {
		return g2d_active;
	}
	public function setActive(p_value:Boolean):void {
		g2d_active = p_value;
	}

	public var id:String = "";
	
	public var g2d_lookupClass:Class;
	
	protected var g2d_node:GNode;
	public function get node():GNode {
		return g2d_node;
	}
	
	/**
	 *  @private
	 */
	public function GComponent(p_node:GNode) {
		g2d_node = p_node;

	    g2d_prototypableProperties = new Vector.<String>();
	}
	
	/****************************************************************************************************
	 * 	PROTOTYPE CODE
	 ****************************************************************************************************/	
	protected var g2d_prototypableProperties:Vector.<String>;
    protected var g2d_prototypeXml:XML;
	 
	public function getPrototype():XML {
        g2d_prototypeXml = <component/>;
        g2d_prototypeXml.@id = id;
        g2d_prototypeXml.@componentClass = getQualifiedClassName(this).split("::").join("-");
        g2d_prototypeXml.@componentLookupClass = getQualifiedClassName(this.g2d_lookupClass).split("::").join("-");

        g2d_prototypeXml.properties = <properties/>;

        var describe:XML = describeType(this);
        var variables:XMLList = describe.variable;
        var i:int;
        for (i=0; i<variables.length(); ++i) {
            var variable:XML = variables[i];
            g2d_addPrototypeProperty(variable.@name, this[variable.@name], variable.@type);
        }

        var accessors:XMLList = describe.accessor;
        for (i=0; i<accessors.length(); ++i) {
            var accessor:XML = accessors[i];
            if (accessor.@access != "readwrite") continue;
            g2d_addPrototypeProperty(accessor.@name, this[accessor.@name], accessor.@type);
        }

        return g2d_prototypeXml;

    }
	
	private function g2d_addPrototypeProperty(p_name:String, p_value:*, p_type:String, p_prototype:XML = null):void {
        var node:XML;
        p_type = p_type.toLowerCase();
        var valueType:String = typeof(p_value);
        // Discard complex types
        if (valueType == "object" && (p_type!="array" && p_type!="object")) return;
        if (valueType != "object") {
            node = <{p_name} value={String(p_value)} type={p_type}/>;
        }
        /* Creation of simple arrays and objects not implemented yet */
        else {
            node = <{p_name} type={p_type}/>;
            for (var it:String in  p_value) {
                g2d_addPrototypeProperty(it, p_value[it], typeof(p_value[it]), node);
            }
        }
        /**/

        if (p_prototype == null) g2d_prototypeXml.properties.appendChild(node);
        else p_prototype.appendChild(node);

    }
	
	
	public function bindFromPrototype(p_prototypeXml:XML):void {
        id = p_prototypeXml.@id;

        var properties:XMLList = p_prototypeXml.properties;
        var count:int = properties.children().length();
        for (var i:int = 0; i<count; ++i) {
            bindPrototypeProperty(properties.children()[i], this);
        }

    }
	
	public function bindPrototypeProperty(p_property:XML, p_object:Object):void {
        var value:* = null;

        if (p_property.@type == "object") {
            // Not implemented yet
        }

        if (p_property.@type == "array") {
            value = new Array();
            var count:int = p_property.children().length();
            for (var i:int = 0; i<count; ++i) bindPrototypeProperty(p_property.children()[i], value);
        }

        if (p_property.@type == "boolean") {
            value = (p_property.@value == "false") ? false : true;
        }

        try {
            p_object[p_property.name()] = (value == null) ? p_property.@value : value;
        } catch (e:Error) {
            trace("bindPrototypeProperty", e, p_object, p_property.name(), value);
        }

    }
	
	/**
	 * 	Abstract method that should be overriden and implemented if you are creating your own components, its called each time a node that uses this component is processing mouse events
	 */
	public function processContextMouseSignal(p_captured:Boolean, p_cameraX:Number, p_cameraY:Number, p_contextSignal:GMouseSignal):Boolean {
		return false;	
	}
	
	/**
	 * 	Base dispose method, if there is a disposing you need to do in your extending component you should override it and always call super.dispose() its used when a node using this component is being disposed
	 */
	public function dispose():void {
		g2d_active = false;
		g2d_node = null;
	}
}
}