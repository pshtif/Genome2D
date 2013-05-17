/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.components
{
	import com.genome2d.context.GContext;
	import com.genome2d.core.GNode;
	import com.genome2d.g2d;
	
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	
	use namespace g2d;
	
	public class GComponent
	{							
		protected var _xPrototype:XML;
		public function getPrototype():XML {
			_xPrototype = <component/>;			
			_xPrototype.@id = _sId;
			_xPrototype.@componentClass = getQualifiedClassName(this).split("::").join("-");
			_xPrototype.@componentLookupClass = getQualifiedClassName(this.cLookupClass).split("::").join("-");
			
			_xPrototype.properties = <properties/>;
			
			var describe:XML = describeType(this);
			var variables:XMLList = describe.variable;
			var i:int;
			for (i=0; i<variables.length(); ++i) {
				var variable:XML = variables[i];
				addPrototypeProperty(variable.@name, this[variable.@name], variable.@type);
			}
			
			var accessors:XMLList = describe.accessor;
			for (i=0; i<accessors.length(); ++i) {
				var accessor:XML = accessors[i];
				if (accessor.@access != "readwrite") continue;
				addPrototypeProperty(accessor.@name, this[accessor.@name], accessor.@type);
			}
			
			return _xPrototype;
		}
		
		protected function addPrototypeProperty(p_name:String, p_value:*, p_type:String, p_prototype:XML = null):void {
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
				for (var it:* in  p_value) {
					addPrototypeProperty(it, p_value[it], typeof(p_value[it]), node);
				}
			}
			/**/
			
			if (p_prototype == null) _xPrototype.properties.appendChild(node); 
			else p_prototype.appendChild(node);
		}
			
		public function bindFromPrototype(p_prototype:XML):void {
			_sId = p_prototype.@id;
			
			var properties:XMLList = p_prototype.properties;
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
		
		protected var _bActive:Boolean = true;
		/**
		 *	@private
		 */
		public function set active(p_value:Boolean):void {
			_bActive = p_value;
		}
		/**
		 * 	@private
		 */
		public function get active():Boolean {
			return _bActive;
		}
		
		protected var _sId:String = "";
		/**
		 * 	Component id, this property is read only
		 */
		public function get id():String {
			return _sId;
		}
		
		g2d var cLookupClass:Class;
		
		/**
		 * 	@private
		 */
		g2d var cPrevious:GComponent;
		/**
		 * 	@private
		 */
		g2d var cNext:GComponent;
		
		/**
		 * 	@private
		 */
		g2d var cNode:GNode;
		
		/**
		 * 	@private
		 * 	This is used internally by a renderer to avoid direct referencing of renderer specific data, crucial for FP10 compatibility
		 */
		g2d var cRenderData:Object
		
		/**
		 * 	Get a node instance that is using this component
		 */
		public function get node():GNode {
			return cNode;
		}
		
		/**
		 *  @private
		 */
		public function GComponent(p_node:GNode) {
			cNode = p_node;
		}
		
		/**
		 * 	Abstract method that should be overriden and implemented if you are creating your own components, its called each time a node that uses this component is being updated
		 */
		public function update(p_deltaTime:Number, p_parentTransformUpdate:Boolean, p_parentColorUpdate:Boolean):void {
			
		}
		/**
		 * 	Abstract method that should be overriden and implemented if you are creating your own components, its called each time a node that uses this component is being rendered
		 */
		public function render(p_context:GContext, p_camera:GCamera, p_maskRect:Rectangle):void {
			
		}
		
		/**
		 * 	Abstract method that should be overriden and implemented if you are creating your own components, its called each time a node that uses this component is processing mouse events
		 */
		public function processMouseEvent(p_captured:Boolean, p_event:MouseEvent, p_position:Vector3D):Boolean {
			return false;	
		}
		
		/**
		 * 	Base dispose method, if there is a disposing you need to do in your extending component you should override it and always call super.dispose() its used when a node using this component is being disposed
		 */
		public function dispose():void {
			_bActive = false;
			
			cNode = null;
			
			cNext = null;
			cPrevious = null;
		}
	}
}
