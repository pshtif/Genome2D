/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.core
{
import com.genome2d.components.particles.GSimpleEmitter;
import com.genome2d.g2d;
	import com.genome2d.components.GCamera;
	import com.genome2d.components.GComponent;
	import com.genome2d.components.GTransform;
	import com.genome2d.components.physics.GBody;
	import com.genome2d.components.renderables.GRenderable;
	import com.genome2d.context.GContext;
	import com.genome2d.context.postprocesses.GPostProcess;
	import com.genome2d.error.GError;
	import com.genome2d.signals.GMouseSignal;

	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import org.osflash.signals.Signal;

	use namespace g2d;
	
	public class GNode
	{				
		public function getPrototype():XML {
			if (__bDisposed) throw new GError(GError.NODE_ALREADY_DISPOSED);
			
			var prototype:XML = <node/>;
			
			prototype.@name = _sName;
			prototype.@mouseEnabled = mouseEnabled;
			prototype.@mouseChildren = mouseChildren;
			prototype.@tags = __aTags.join(",");
			prototype.components = <components/>
			
			prototype.components.appendChild(cTransform.getPrototype());
			
			if (cBody) prototype.components.appendChild(cBody.getPrototype());
				
			for (var component:GComponent = __cFirstComponent; component; component = component.cNext) {
				prototype.components.appendChild(component.getPrototype());
			}
				
			prototype.children = <children/>;
			
			for (var child:GNode = _cFirstChild; child; child = child.cNext) {
				prototype.children.appendChild(child.getPrototype());
			}
			
			return prototype;
		}
		
		private var __eOnAddedToStage:Signal;
		/**
		 * 	Signal that is dispatched when the node is added to render tree
		 */
		public function get onAddedToStage():Signal {
			if (__eOnAddedToStage == null) __eOnAddedToStage = new Signal();
			return __eOnAddedToStage;
		}
		
		private var __eOnRemovedFromStage:Signal;
		/**
		 * 	Signal that is dispatched when the node is removed from render tree
		 */
		public function get onRemovedFromStage():Signal {
			if (__eOnRemovedFromStage == null) __eOnRemovedFromStage = new Signal();
			return __eOnRemovedFromStage;
		}
		
		private var __eOnComponentAdded:Signal;
		/**
		 * 	Signal that is dispatched when component is added to the node
		 */
		public function get onComponentAdded():Signal {
			if (__eOnComponentAdded == null) __eOnComponentAdded = new Signal();
			return __eOnComponentAdded;
		}
		
		private var __eOnComponentRemoved:Signal;
		/**
		 * 	Signal that is dispatched when component is removed from the node
		 */
		public function get onComponentRemoved():Signal {
			if (__eOnComponentRemoved == null) __eOnComponentRemoved = new Signal();
			return __eOnComponentRemoved;
		}
		/*
		private var __eOnChildNodeAdded:Signal;
		public function get onChildNodeAdded():Signal {
			if (__eOnChildNodeAdded == null) __eOnChildNodeAdded = new Signal();
			return __eOnChildNodeAdded;
		}
		
		private var __eOnChildNodeRemoved:Signal;
		public function get onChildNodeRemoved():Signal {
			if (__eOnChildNodeRemoved == null) __eOnChildNodeRemoved = new Signal();
			return __eOnChildNodeRemoved;
		}
		/**/
		
		g2d var cPool:GNodePool;
		
		g2d var cPoolPrevious:GNode;
		
		g2d var cPoolNext:GNode;
		
		/**
		 * 	@private
		 */
		g2d var cPrevious:GNode;
		public function get previous():GNode {
			return cPrevious;
		}
		/**
		 * 	@private
		 */
		g2d var cNext:GNode;
		public function get next():GNode {
			return cNext;
		}
		
		private var __bChangedParent:Boolean = false;
        private var __iLastFrameRendered:int = 0;
		
		/**
		 * 	Camera group this node belongs to, a node is rendered through this camera if camera.mask and nodecameraGroup != 0
		 */
		public var cameraGroup:int = 0;
	
		private var __bParentActive:Boolean = true;
		g2d function set bParentActive(p_value:Boolean):void {
			for (var child:GNode = _cFirstChild; child; child = child.cNext) {
				child.bParentActive = p_value;
			}
		}
		
		g2d var iUsedAsMask:int = 0;
        g2d var iUsedAsPPMask:int = 0;
		
		private var __bActive:Boolean = true;
		/**
		 * 	Flag if node is active, once node is not active it doesn't update and render
		 */
		public function set active(p_value:Boolean):void {
			if (p_value == __bActive) return;
			if (__bDisposed) throw new GError(GError.NODE_ALREADY_DISPOSED);
			
			__bActive = p_value;
			cTransform.active = __bActive;
			
			if (cPool) {
				if (p_value) cPool.putToBack(this);
				else cPool.putToFront(this);
			}
			
			if (cBody) cBody.active = __bActive;
			
			for (var component:GComponent = __cFirstComponent; component; component = component.cNext) {
				component.active = __bActive;
			}
			
			for (var child:GNode = _cFirstChild; child; child = child.cNext) {
				child.bParentActive = __bActive;
				//child.active = __bActive;
			}
		}
		public function get active():Boolean {
			return __bActive;
		}
		
		private var __aTags:Vector.<String> = new Vector.<String>();
		public function hasTag(p_tag:String):Boolean {
			if (__bDisposed) throw new GError(GError.NODE_ALREADY_DISPOSED);
			
			if (__aTags.indexOf(p_tag) != -1) return true;
			return false;
		}
		public function addTag(p_tag:String):void {
			if (__bDisposed) throw new GError(GError.NODE_ALREADY_DISPOSED);
			
			if (__aTags.indexOf(p_tag) != -1) return;
			__aTags.push(p_tag);
		}
		public function removeTag(p_tag:String):void {
			if (__bDisposed) throw new GError(GError.NODE_ALREADY_DISPOSED);
			
			var index:int =__aTags.indexOf(p_tag);
			if (index != -1) return;
			
			__aTags.splice(index, 1);
		}
		
		/**
		 * 	Abstract reference to user defined data, if you want keep some custom data binded to G2DNode instance use it.
		 */
		private var __oUserData:Object;
		public function get userData():Object {
			if (__oUserData == null) __oUserData = {};
			return __oUserData;
		}
		
		/**
		 * 	@private
		 */
		g2d var cCore:Genome2D;
		public function get core():Genome2D {
			return cCore;
		}
	
		protected var _iId:uint;

		/**/
		protected var _sName:String;
		/**
		 * 	Node name
		 */
		public function get name():String {
			return _sName;
		}
		public function set name(p_value:String):void {
			_sName = p_value;
		}
		
		/**
		 * 	@private
		 */
		g2d var cTransform:GTransform;
		/**
		 * 	Node transform component, this property is read only.
		 */
		public function get transform():GTransform {
			if (__bDisposed) throw new GError(GError.NODE_ALREADY_DISPOSED);
			return cTransform;
		}
		
		g2d var cBody:GBody;
		
		/**
		 * 	@private
		 */
		g2d var cParent:GNode;
		/**
		 * 	Node parent, this property is read only
		 */
		public function get parent():GNode {
			if (__bDisposed) throw new GError(GError.NODE_ALREADY_DISPOSED);
			return cParent;
		}
		
		private var __bUpdating:Boolean = false;
		private var __bDisposeAfterUpdate:Boolean = false;
		private var __bRemoveAfterUpdate:Boolean = false;
		private var __bDisposed:Boolean = false;
		private var __bRendering:Boolean = false;
	
		static private var __iCount:int = 0;
		/**
		 * 	Constructor
		 */
		public function GNode(p_name:String = "") {
			_iId = __iCount++; 
			_sName = (p_name == "") ? "GNode#"+__iCount : p_name;

			// To avoid static access later we store our reference
			cCore = Genome2D.getInstance();
			
			__dComponentsLookupTable = new Dictionary();
			
			cTransform = new GTransform(this);
			__dComponentsLookupTable[GTransform] = cTransform;
		}
		
		/**
		 * 	@private
		 */
		g2d function update(p_deltaTime:Number):void {
			if (!__bActive || !__bParentActive) return;
			__bChangedParent = false;
			__bUpdating = true;

			if (cBody != null) cBody.update(p_deltaTime);

			var component:GComponent = __cFirstComponent;
			while (component) {
				component.update(p_deltaTime);
				component = component.cNext;
			}

			var child:GNode = _cFirstChild;
			var nextChild:GNode;
			while (child) {
				child.update(p_deltaTime);
				nextChild = child.next;
				if (child.__bDisposeAfterUpdate) child.dispose();
				if (child.__bRemoveAfterUpdate) removeChild(child);
				child = nextChild;
			}
			__bUpdating = false;
		}
		
		static private var __aActiveMasks:Vector.<GNode> = new Vector.<GNode>();
		
		public var postProcess:GPostProcess;
		
		/**
		 * 	@private
		 */
		g2d function render(p_context:GContext, p_parentTransformUpdate:Boolean, p_parentColorUpdate:Boolean, p_camera:GCamera, p_maskRect:Rectangle, p_renderAsMask:Boolean):void {
            // Invalidate transform if it wasn't rendered this frame already
            if (__iLastFrameRendered != core.g2d_frameId) {
                var invalidateTransform:Boolean = p_parentTransformUpdate || cTransform.bTransformDirty;
                var invalidateColor:Boolean = p_parentColorUpdate || cTransform.bColorDirty;
                if (invalidateTransform || invalidateColor || (cBody != null && cBody.isDynamic())) cTransform.invalidate(invalidateTransform, invalidateColor);
            }

            if (!__bActive || __bChangedParent || !__bParentActive || !cTransform.visible || ((cameraGroup&p_camera.mask) == 0 && cameraGroup != 0) || (iUsedAsMask>0 && !p_renderAsMask) || iUsedAsPPMask>0) return;

			// Render as mask
			if (!p_renderAsMask) {
				if (cTransform.cMask != null){// && (__aActiveMasks.length==0 || cTransform.cMask != __aActiveMasks[__aActiveMasks.length-1])) {
					p_context.renderAsStencilMask(__aActiveMasks.length);
					cTransform.cMask.render(p_context, p_parentTransformUpdate, p_parentColorUpdate, p_camera, p_maskRect, true);
					__aActiveMasks.push(cTransform.cMask);
					p_context.renderToColor(__aActiveMasks.length);
				}
			}
			
			__bRendering = true;
			if (cTransform.rAbsoluteMaskRect != null) p_maskRect = p_maskRect.intersection(cTransform.rAbsoluteMaskRect);
			for (var component:GComponent = __cFirstComponent; component; component = component.cNext) {
				component.render(p_context, p_camera, p_maskRect);
			}
							
			var child:GNode = _cFirstChild;
            while (child) {
                if (child.postProcess) child.postProcess.render(p_context, p_camera, p_maskRect, child);
                else child.render(p_context, invalidateTransform, invalidateColor, p_camera, p_maskRect, p_renderAsMask);
                child = child.cNext;
            }
			
			if (core.cConfig.enableStats && core.cConfig.showExtendedStats) p_camera.iRenderedNodesCount++;
			
			if (!p_renderAsMask) {
				if (cTransform.cMask != null) {
					__aActiveMasks.pop();
					if (__aActiveMasks.length==0) p_context.clearStencil();
					p_context.renderToColor(__aActiveMasks.length);
				} 
			}

            __iLastFrameRendered = core.g2d_frameId;
			__bRendering = false;
		}
		
		public function toString():String {
			return "[G2DNode]"+_sName;
		}
		
		/**
		 * 	This method will call dispose on all children of this node which will remove them
		 */
		public function disposeChildren():void {	
			if (__bRendering) throw new GError(GError.CANNOT_DO_WHILE_RENDER);
			if (_cFirstChild == null) return;
			
			for (var child:GNode = _cFirstChild.cNext; child; child = child.cNext) {
				child.cPrevious.dispose();
			}
			
			_cFirstChild.dispose();
			_cFirstChild = null;
			_cLastChild = null;
		}
		
		/**
		 * 	This method disposes this node, this will also dispose all of its children, components and signals
		 */
		public function dispose():void {
			if (__bRendering) throw new GError(GError.CANNOT_DO_WHILE_RENDER);
			if (__bUpdating) {
				__bDisposeAfterUpdate = true;
				return;
			}
			
			if (__bDisposed) return;
			
			__bActive = false;
			
			disposeChildren();

			for (var it:* in __dComponentsLookupTable) {
				var component:GComponent = __dComponentsLookupTable[it];
				delete __dComponentsLookupTable[it];
				component.dispose();
			}
			
			cBody = null;
			cTransform = null;
			__cFirstComponent = null;
			__cLastComponent = null;
			
			__dComponentsLookupTable = null;
			
			if (cParent != null) {
				cParent.removeChild(this);
			}
			cNext = null;
			cPrevious = null;
			/**
			 * 	Remove from possible pool
			 */
			if (cPoolNext) cPoolNext.cPoolPrevious = cPoolPrevious;
			if (cPoolPrevious) cPoolPrevious.cPoolNext = cPoolNext;
			cPoolNext = null;
			cPoolPrevious = null;
			cPool = null;
			
			if (__eOnMouseDown) {
				__eOnMouseDown.removeAll();
				__eOnMouseDown = null;
			}
			if (__eOnMouseMove) {
				__eOnMouseMove.removeAll();
				__eOnMouseMove = null;
			}
			if (__eOnMouseUp) {
				__eOnMouseUp.removeAll();
				__eOnMouseUp = null;
			}
			if (__eOnMouseOver) {
				__eOnMouseOver.removeAll();
				__eOnMouseOver = null;
			}
			if (__eOnMouseClick) {
				__eOnMouseClick.removeAll();
				__eOnMouseClick = null;
			}
			if (__eOnMouseOut) {
				__eOnMouseOut.removeAll();
				__eOnMouseOut = null;
			}
			
			if (__eOnRemovedFromStage) {
				__eOnRemovedFromStage.removeAll();
				__eOnRemovedFromStage = null;
			}
			if (__eOnAddedToStage) {
				__eOnAddedToStage.removeAll();
				__eOnAddedToStage = null;
			}
			
			__bDisposed = true;
		}
		
		/****************************************************************************************************
		 * 	TOUCH CODE
		 ****************************************************************************************************/
		
		// Is it really needed? Examples?
		
		/****************************************************************************************************
		 * 	MOUSE CODE
		 ****************************************************************************************************/
		private var __eOnMouseDown:Signal;
		/**
		 * 	Signal that is dispatched when mouse down is detected over the node
		 */
		public function get onMouseDown():Signal {
			if (__eOnMouseDown == null) __eOnMouseDown = new Signal();
			return __eOnMouseDown;
		}
		
		private var __eOnMouseMove:Signal;
		/**
		 * 	Signal that is dispatched when mouse move is detected over the node
		 */
		public function get onMouseMove():Signal {
			if (__eOnMouseMove == null) __eOnMouseMove = new Signal();
			return __eOnMouseMove;
		}
		
		private var __eOnMouseUp:Signal;
		/**
		 * 	Signal that is dispatched when mouse up is detected over the node
		 */
		public function get onMouseUp():Signal {
			if (__eOnMouseUp == null) __eOnMouseUp = new Signal();
			return __eOnMouseUp;
		}
		
		private var __eOnMouseOver:Signal;
		/**
		 * 	Signal that is dispatched when mouse enters over the node
		 */
		public function get onMouseOver():Signal {
			if (__eOnMouseOver == null) __eOnMouseOver = new Signal();
			return __eOnMouseOver;
		}
		
		private var __eOnMouseClick:Signal;
		/**
		 * 	Signal that is dispatched when mouse click is detected over the node
		 */
		public function get onMouseClick():Signal {
			if (__eOnMouseClick == null) __eOnMouseClick = new Signal();
			return __eOnMouseClick;
		}

		private var __eOnMouseOut:Signal;
		/**
		 * 	Signal that is dispatched when mouse leaves the node
		 */
		public function get onMouseOut():Signal {
			if (__eOnMouseOut == null) __eOnMouseOut = new Signal();
			return __eOnMouseOut;
		}
		
		private var __eOnRightMouseDown:Signal;
		/**
		 *	Signal that is dispatched when right mouse button is pressed
		 */
		public function get onRightMouseDown():Signal {
			if (__eOnRightMouseDown == null) __eOnRightMouseDown = new Signal();
			core.rightClickEnabled = true;
			return __eOnRightMouseDown;
		}
		
		private var __eOnRightMouseUp:Signal;
		/**
		 *	Signal that is dispatched when right mouse button is released
		 */
		public function get onRightMouseUp():Signal {
			if (__eOnRightMouseUp == null) __eOnRightMouseUp = new Signal();
			core.rightClickEnabled = true;
			return __eOnRightMouseUp;
		}
		
		private var __eOnRightMouseClick:Signal;
		/**
		 *	Signal that is dispatched when right mouse button is clicked
		 */
		public function get onRightMouseClick():Signal {
			if (__eOnRightMouseClick == null) __eOnRightMouseClick = new Signal();
			core.rightClickEnabled = true;
			return __eOnRightMouseClick;
		}
		
		/**
		 * 	Enable mouse event handling for this node
		 * 
		 * 	@default false
		 */
		public var mouseEnabled:Boolean = false

		/**
		 * 	Enable mouse event handling for node children, for a node to process mouse signals it has to have mouseEnabled true and its parent has to have mouseChildren true
		 * 
		 * 	@default true
		 */
		public var mouseChildren:Boolean = true;
		/**
		 * 	@private
		 */
		g2d var cMouseOver:GNode;
		/**
		 * 	@private
		 */
		g2d var cMouseDown:GNode;
		/**
		 *  @private 	
		 */
		g2d var cRightMouseDown:GNode;

        public var useHandCursor:Boolean = false;
		
		/**
		 * 	@private
		 */	
		g2d function processMouseEvent(p_captured:Boolean, p_event:MouseEvent, p_position:Vector3D, p_camera:GCamera):Boolean {
			if (!active || !cTransform.visible || ((cameraGroup&p_camera.mask) == 0 && cameraGroup != 0)) return false;
			if (mouseChildren) {
				for (var child:GNode = _cLastChild; child; child = child.cPrevious) {
					p_captured = child.processMouseEvent(p_captured, p_event, p_position, p_camera) || p_captured;
				}
			}
			
			if (mouseEnabled) {
				for (var component:GComponent = __cFirstComponent; component; component = component.cNext) {
					p_captured = component.processMouseEvent(p_captured, p_event, p_position) || p_captured;
				}
			}
			
			return p_captured;
		}
		
		/**
		 * 	@private
		 */
		g2d function handleMouseEvent(p_object:GNode, p_type:String, p_x:int, p_y:int, p_buttonDown:Boolean, p_ctrlDown:Boolean):void {
			if (mouseEnabled) { 
				var mouseSignal:GMouseSignal = new GMouseSignal(this, p_object, p_x, p_y, p_buttonDown, p_ctrlDown, p_type);
		
				if (p_type == MouseEvent.MOUSE_DOWN) {
					cMouseDown = p_object;
					if (__eOnMouseDown) __eOnMouseDown.dispatch(mouseSignal);
				} else if (p_type == MouseEvent.MOUSE_MOVE) {
					if (__eOnMouseMove) __eOnMouseMove.dispatch(mouseSignal);
				} else if (p_type == MouseEvent.MOUSE_UP) {
					if (cMouseDown == p_object && __eOnMouseClick) {
						var mouseClickSignal:GMouseSignal = new GMouseSignal(this, p_object, p_x, p_y, p_buttonDown, p_ctrlDown, MouseEvent.MOUSE_UP);
						__eOnMouseClick.dispatch(mouseClickSignal);
					}
					cMouseDown = null;
					if (__eOnMouseUp) __eOnMouseUp.dispatch(mouseSignal);
				} else if (p_type == MouseEvent.MOUSE_OVER) {
					cMouseOver = p_object;
                    core.handleMouseEvent(__eOnMouseOver, mouseSignal);
					//if (__eOnMouseOver) __eOnMouseOver.dispatch(mouseSignal);
				} else if (p_type == MouseEvent.MOUSE_OUT) {
					cMouseOver = null;
                    core.handleMouseEvent(__eOnMouseOut, mouseSignal);
					//if (__eOnMouseOut) __eOnMouseOut.dispatch(mouseSignal);
				} else if (p_type == MouseEvent.RIGHT_MOUSE_DOWN) {
					cRightMouseDown = p_object;
					if (__eOnRightMouseDown) __eOnRightMouseDown.dispatch(mouseSignal);
				} else if (p_type == MouseEvent.RIGHT_MOUSE_UP) {
					if (cRightMouseDown == p_object && __eOnRightMouseClick) {
						var rightMouseClickSignal:GMouseSignal = new GMouseSignal(this, p_object, p_x, p_y, p_buttonDown, p_ctrlDown, MouseEvent.RIGHT_MOUSE_UP);
						__eOnRightMouseClick.dispatch(rightMouseClickSignal);
						cRightMouseDown = null
						if (__eOnRightMouseUp) __eOnRightMouseUp.dispatch(mouseSignal);
					}
				}
			}
			
			if (cParent) cParent.handleMouseEvent(p_object, p_type, p_x, p_y, p_buttonDown, p_ctrlDown); 
		}
		
		/****************************************************************************************************
		 * 	COMPONENT CODE
		 ****************************************************************************************************/
		
		private var __dComponentsLookupTable:Dictionary;
		public function getComponents():Dictionary {
			return __dComponentsLookupTable;
		}
		
		private var __cFirstComponent:GComponent;
		private var __cLastComponent:GComponent;
		
		/**
		 * 	Get a component of specified type attached to this node
		 * 
		 * 	@param p_componentClass Component type that should be retrieved
		 */
		public function getComponent(p_componentLookupClass:Class):GComponent {
			if (__bDisposed) throw new GError(GError.NODE_ALREADY_DISPOSED);
			return __dComponentsLookupTable[p_componentLookupClass];
		}
		
		public function hasComponent(p_componentLookupClass:Class):Boolean {
			return (__dComponentsLookupTable[p_componentLookupClass] != null);
		}
		
		/**
		 * 	Add a component of specified type to this node, node can always have only a single component of a specific class to avoid redundancy
		 * 
		 *	@param p_componentClass Component type that should be instanced and attached to this node
		 */
		public function addComponent(p_componentClass:Class, p_componentLookupClass:Class = null):GComponent {
			if (__bDisposed) throw new GError(GError.NODE_ALREADY_DISPOSED);
			if (p_componentLookupClass == null) p_componentLookupClass = p_componentClass;
			if (__dComponentsLookupTable[p_componentLookupClass] != null) return __dComponentsLookupTable[p_componentLookupClass];
			
			var component:GComponent = new p_componentClass(this);

			if (component == null) throw new GError(GError.INVALID_COMPONENT_CLASS);
			
			component.cLookupClass = p_componentLookupClass;
			
			__dComponentsLookupTable[p_componentLookupClass] = component;

			if (component is GBody) {
				if (cBody) throw new GError(GError.MULTIPLE_BODIES);
				cBody = component as GBody;
				return component;
			}
			
			if (__cFirstComponent == null) {
				__cFirstComponent = component;
				__cLastComponent = component;
			} else {
				__cLastComponent.cNext = component;
				component.cPrevious = __cLastComponent;
				__cLastComponent = component;
			}

			if (__eOnComponentAdded) __eOnComponentAdded.dispatch(p_componentLookupClass);
			
			return component;
		}
		
		public function addComponentFromPrototype(p_componentPrototype:XML):GComponent {
			var componentClass:* = getDefinitionByName(String(p_componentPrototype.@componentClass).split("-").join("::"));
			var componentLookupClass:* = getDefinitionByName(String(p_componentPrototype.@componentLookupClass).split("-").join("::"));
			var component:GComponent = addComponent(componentClass, componentLookupClass);
			component.bindFromPrototype(p_componentPrototype);
			
			return component;
		}
		
		/**
		 * 	Remove component of specified type from this node
		 * 
		 * 	@param p_componentClass Component type that should be removed
		 */
		public function removeComponent(p_componentLookupClass:Class):void {
			if (__bDisposed) throw new GError(GError.NODE_ALREADY_DISPOSED);
			var component:GComponent = __dComponentsLookupTable[p_componentLookupClass];
	
			if (component == null || component == cTransform) return;
			if (component.cPrevious != null) component.cPrevious.cNext = component.cNext;
			if (component.cNext != null) component.cNext.cPrevious = component.cPrevious;
			if (__cFirstComponent == component) __cFirstComponent = __cFirstComponent.cNext;
			if (__cLastComponent == component) __cLastComponent = __cLastComponent.cPrevious;
			
			delete __dComponentsLookupTable[p_componentLookupClass];
			
			if (component is GBody) cBody = null;
			
			component.dispose();
			
			if (__eOnComponentAdded) __eOnComponentAdded.dispatch(p_componentLookupClass);
		}
		
		/****************************************************************************************************
		 * 	CONTAINER CODE
		 ****************************************************************************************************/
		private var _iChildCount:int = 0;		
		private var _cFirstChild:GNode;
		public function get firstChild():GNode {
			return _cFirstChild;
		}
		private var _cLastChild:GNode;
		public function get lastChild():GNode {
			return _cLastChild;
		}
		//private var _aChildren:Vector.<GNode>;
		/**
		 * 	Return the number of child nodes
		 */
		public function get numChildren():int {
			if (__bDisposed) throw new GError(GError.NODE_ALREADY_DISPOSED);
			return _iChildCount;
		}
		
		/**
		 * 	Add a child node to this node
		 * 
		 * 	@param p_child node that should be added
		 */
		public function addChild(p_child:GNode, p_last:Boolean = true):void {
			if (__bDisposed) throw new GError(GError.NODE_ALREADY_DISPOSED);
			if (p_child == this) throw new GError(GError.CHILD_OF_ITSELF);
			//if (p_child.parent == this) return;
			if (p_child.parent != null) p_child.parent.removeChild(p_child);
			
			p_child.__bChangedParent = true;
			p_child.cParent = this;
			
			if (_cFirstChild == null) {
				_cFirstChild = p_child;
				_cLastChild = p_child;
			} else {
                if (p_last) {
				    _cLastChild.cNext = p_child;
				    p_child.cPrevious = _cLastChild;
				    _cLastChild = p_child;
                } else {
                    _cFirstChild.cPrevious = p_child;
                    p_child.cNext = _cFirstChild;
                    _cFirstChild = p_child;
                }
			}
			
			_iChildCount++;

			if (isOnStage()) p_child.addedToStage();
		}
		
		/**
		 * 	Remove a child node from this node
		 * 
		 * 	@param p_child node that should be removed
		 */
		public function removeChild(p_child:GNode):void {
			if (p_child.__bRendering) throw new GError(GError.CANNOT_DO_WHILE_RENDER);
			if (__bDisposed) throw new GError(GError.NODE_ALREADY_DISPOSED);
			if (p_child.cParent != this) return;
			if (p_child.__bUpdating) {
				p_child.__bRemoveAfterUpdate = true;
				return;
			}
			
			if (p_child.cPrevious != null) {
				p_child.cPrevious.cNext = p_child.cNext;
			} else {
				_cFirstChild = _cFirstChild.cNext;
			}
			if (p_child.cNext) {
				p_child.cNext.cPrevious = p_child.cPrevious;
			} else {
				_cLastChild = _cLastChild.cPrevious;
			}

			p_child.cParent = null;
			p_child.cNext = null;
			p_child.cPrevious = null;
			
			_iChildCount--;
			
			p_child.__bRemoveAfterUpdate = false;

			if (isOnStage()) p_child.removedFromStage();
		}
		
		public function swapChildren(p_child1:GNode, p_child2:GNode):void {
			if (p_child1.parent != this || p_child2.parent != this) return;
		
			var temp:GNode = p_child1.cNext;
			if (p_child2.cNext == p_child1) {
				p_child1.cNext = p_child2;
			} else {
				p_child1.cNext = p_child2.cNext;
				if (p_child1.cNext) p_child1.cNext.cPrevious = p_child1;
			}
			if (temp == p_child2) {
				p_child2.cNext = p_child1;
			} else {
				p_child2.cNext = temp;
				if (p_child2.cNext)  p_child2.cNext.cPrevious = p_child2;
			}
			
			temp = p_child1.cPrevious;
			if (p_child2.cPrevious == p_child1) {
				p_child1.cPrevious = p_child2;
			} else {
				p_child1.cPrevious = p_child2.cPrevious;
				if (p_child1.cPrevious)  p_child1.cPrevious.cNext = p_child1;
			}
			if (temp == p_child2) {
				p_child2.cPrevious = p_child1;
			} else {
				p_child2.cPrevious = temp;
				if (p_child2.cPrevious) p_child2.cPrevious.cNext = p_child2;
			}
			
			if (p_child1 == _cFirstChild) _cFirstChild = p_child2;
			else if (p_child2 == _cFirstChild) _cFirstChild = p_child1;
			if (p_child1 == _cLastChild) _cLastChild = p_child2;
			else if (p_child2 == _cLastChild) _cLastChild = p_child1;
		}
		
		/**/
		public function putChildToFront(p_child:GNode):void {
			if (p_child.parent != this || p_child == _cLastChild) return;
			
			if (p_child.cNext) p_child.cNext.cPrevious = p_child.cPrevious;
			if (p_child.cPrevious) p_child.cPrevious.cNext = p_child.cNext;
			if (p_child == _cFirstChild) _cFirstChild = _cFirstChild.cNext;
			
			if (_cLastChild != null) _cLastChild.cNext = p_child;
			p_child.cPrevious = _cLastChild;
			p_child.cNext = null;
			_cLastChild = p_child;
		}
		
		public function putChildToBack(p_child:GNode):void {
			if (p_child.parent != this || p_child == _cFirstChild) return;
			
			if (p_child.cNext) p_child.cNext.cPrevious = p_child.cPrevious;
			if (p_child.cPrevious) p_child.cPrevious.cNext = p_child.cNext;
			if (p_child == _cLastChild) _cLastChild = _cLastChild.cPrevious;
			
			if (_cFirstChild != null) _cFirstChild.cPrevious = p_child;
			p_child.cPrevious = null;
			p_child.cNext = _cFirstChild;
			_cFirstChild = p_child;
		}
		
		private function addedToStage():void {
			if (__eOnAddedToStage) __eOnAddedToStage.dispatch();
			
			if (cBody != null) cBody.addToSpace();
			
			for (var child:GNode = _cFirstChild; child; child = child.cNext) {
				child.addedToStage();
			}
		}
		
		private function removedFromStage():void {
			if (__eOnRemovedFromStage) __eOnRemovedFromStage.dispatch();

			if (cBody != null) cBody.removeFromSpace();
			
			for (var child:GNode = _cFirstChild; child; child = child.cNext) {
				child.removedFromStage();
			}
		}

		/**
		 * 	Returns true if this node is attached to Genome2D render tree false otherwise
		 */
		public function isOnStage():Boolean {
			if (this == cCore.root) return true;
			if (cParent == null) return false;
			
			return cParent.isOnStage();
		}

		/****************************************************************************************************
		 * 	SORTING CODE
		 ****************************************************************************************************/
		public function sortChildrenOnY(p_ascending:Boolean = true):void {
			// Nothing to sort
			if (_cFirstChild == null) return;
			
			var insize:int = 1;
			var psize:int;
			var qsize:int;
			var nmerges:int;
			var p:GNode;
			var q:GNode;
			var e:GNode;
			
			
			while (1) {
				p = _cFirstChild;
				_cFirstChild = null;
				_cLastChild = null;
				
				nmerges = 0;  /* count number of merges we do in this pass */
				
				while (p) {
					nmerges++;  /* there exists a merge to be done */
					/* step `insize' places along from p */
					q = p;
					psize = 0;
					for (var i:int = 0; i < insize; i++) {
						psize++;
						q = q.cNext;
						if (!q) break;
					}
					
					/* if q hasn't fallen off end, we have two lists to merge */
					qsize = insize;
					
					/* now we have two lists; merge them */
					while (psize > 0 || (qsize > 0 && q)) {
						
						/* decide whether next element of merge comes from p or q */
						if (psize == 0) {
							/* p is empty; e must come from q. */
							e = q;
							q = q.cNext;
							qsize--;
						} else if (qsize == 0 || !q) {
							/* q is empty; e must come from p. */
							e = p;
							p = p.cNext;
							psize--;
						} else if (p_ascending) {
							if (p.cTransform.nLocalY >= q.cTransform.nLocalY) {
								/* First element of p is lower (or same);
								* e must come from p. */
								e = p;
								p = p.cNext;
								psize--;
							} else {
								/* First element of q is lower; e must come from q. */
								e = q;
								q = q.cNext;
								qsize--;
							}
						} else {
							if (p.cTransform.nLocalY <= q.cTransform.nLocalY) {
								/* First element of p is lower (or same);
								* e must come from p. */
								e = p;
								p = p.cNext;
								psize--;
							} else {
								/* First element of q is lower; e must come from q. */
								e = q;
								q = q.cNext;
								qsize--;
							}
						}
						
						/* add the next element to the merged list */
						if (_cLastChild) {
							_cLastChild.cNext = e;
						} else {
							_cFirstChild = e;
						}
					
						e.cPrevious = _cLastChild;
						
						_cLastChild = e;
					}
					
					/* now p has stepped `insize' places along, and q has too */
					p = q;
				}
				
				_cLastChild.cNext = null;
				
				/* If we have done only one merge, we're finished. */
				if (nmerges <= 1) return;
				
				/* Otherwise repeat, merging lists twice the size */
				insize *= 2;
			}
		}
		
		public function sortChildrenOnX(p_ascending:Boolean = true):void {
			if (_cFirstChild == null) return;
			
			var insize:int = 1;
			var psize:int;
			var qsize:int;
			var nmerges:int;
			var p:GNode;
			var q:GNode;
			var e:GNode;
			
			
			while (1) {
				p = _cFirstChild;
				_cFirstChild = null;
				_cLastChild = null;
				
				nmerges = 0; 
				
				while (p) {
					nmerges++; 
					q = p;
					psize = 0;
					for (var i:int = 0; i < insize; i++) {
						psize++;
						q = q.cNext;
						if (!q) break;
					}

					qsize = insize;
					
					while (psize > 0 || (qsize > 0 && q)) {
						if (psize == 0) {
							e = q;
							q = q.cNext;
							qsize--;
						} else if (qsize == 0 || !q) {
							e = p;
							p = p.cNext;
							psize--;
						} else if (p_ascending) {
							if (p.cTransform.nLocalX >= q.cTransform.nLocalX) {
								e = p;
								p = p.cNext;
								psize--;
							} else {
								e = q;
								q = q.cNext;
								qsize--;
							}
						} else {
							if (p.cTransform.nLocalX <= q.cTransform.nLocalX) {
								e = p;
								p = p.cNext;
								psize--;
							} else {
								e = q;
								q = q.cNext;
								qsize--;
							}
						}
						
						if (_cLastChild) {
							_cLastChild.cNext = e;
						} else {
							_cFirstChild = e;
						}
						
						e.cPrevious = _cLastChild;
						
						_cLastChild = e;
					}
					
					p = q;
				}
				
				_cLastChild.cNext = null;

				if (nmerges <= 1) return;

				insize *= 2;
			}
		}
		
		public function sortChildrenOnUserData(p_property:String, p_ascending:Boolean = true):void {
			if (_cFirstChild == null) return;
			
			var insize:int = 1;
			var psize:int;
			var qsize:int;
			var nmerges:int;
			var p:GNode;
			var q:GNode;
			var e:GNode;
			
			
			while (1) {
				p = _cFirstChild;
				_cFirstChild = null;
				_cLastChild = null;
				
				nmerges = 0; 
				
				while (p) {
					nmerges++;  
					q = p;
					psize = 0;
					for (var i:int = 0; i < insize; i++) {
						psize++;
						q = q.cNext;
						if (!q) break;
					}
					
					qsize = insize;
					
					while (psize > 0 || (qsize > 0 && q)) {
						if (psize == 0) {
							e = q;
							q = q.cNext;
							qsize--;
						} else if (qsize == 0 || !q) {
							e = p;
							p = p.cNext;
							psize--;
						} else if (p_ascending) {
							if (p.userData[p_property] >= q.userData[p_property]) {
								e = p;
								p = p.cNext;
								psize--;
							} else {
								e = q;
								q = q.cNext;
								qsize--;
							}
						} else {
							if (p.userData[p_property] <= q.userData[p_property]) {
								e = p;
								p = p.cNext;
								psize--;
							} else {
								e = q;
								q = q.cNext;
								qsize--;
							}
						}

						if (_cLastChild) {
							_cLastChild.cNext = e;
						} else {
							_cFirstChild = e;
						}
						
						e.cPrevious = _cLastChild;
						
						_cLastChild = e;
					}

					p = q;
				}
				
				_cLastChild.cNext = null;

				if (nmerges <= 1) return;
				
				insize *= 2;
			}
		}
		
		public function getWorldBounds(p_target:Rectangle = null):Rectangle {
			if (p_target == null) p_target = new Rectangle();
			var minX:Number = Number.MAX_VALUE;
			var maxX:Number = -Number.MAX_VALUE;
			var minY:Number = Number.MAX_VALUE;
			var maxY:Number = -Number.MAX_VALUE;
			var aabb:Rectangle = new Rectangle();
			
			for (var component:GComponent = __cFirstComponent; component; component = component.cNext) {
				var renderable:GRenderable = component as GRenderable;
				if (renderable) {
					renderable.getWorldBounds(aabb);
					minX = (minX < aabb.x) ? minX : aabb.x;
					maxX = (maxX > aabb.right) ? maxX : aabb.right;
					minY = (minY < aabb.y) ? minY : aabb.y;
					maxY = (maxY > aabb.bottom) ? maxY : aabb.bottom;
				}
			}
			
			for (var node:GNode = _cFirstChild; node; node = node.cNext) {
				node.getWorldBounds(aabb);
				minX = (minX < aabb.x) ? minX : aabb.x;
				maxX = (maxX > aabb.right) ? maxX : aabb.right;
				minY = (minY < aabb.y) ? minY : aabb.y;
				maxY = (maxY > aabb.bottom) ? maxY : aabb.bottom;
			}
			
			p_target.setTo(minX, minY, maxX-minX, maxY-minY);

			return p_target;
		}
	}
}