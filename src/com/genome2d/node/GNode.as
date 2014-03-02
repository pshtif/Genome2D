/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.node {

import com.genome2d.Genome2D;
import com.genome2d.components.GComponent;
import com.genome2d.components.GTransform;
import com.genome2d.components.renderables.IRenderable;
import com.genome2d.context.GContextCamera;
import com.genome2d.error.GError;
import com.genome2d.geom.GMatrixUtils;
import com.genome2d.physics.GBody;
import com.genome2d.postprocesses.GPostProcess;
import com.genome2d.signals.GMouseSignal;
import com.genome2d.signals.GMouseSignalType;
import com.genome2d.signals.GNodeMouseSignal;

import flash.geom.Matrix;
import flash.geom.Rectangle;

import org.osflash.signals.Signal;

public class GNode
{
    static private var g2d_cachedArray:Vector.<GNode>;
    static private var g2d_cachedMatrix:Matrix;

    static private var g2d_core:Genome2D;
    public function get core():Genome2D {
        if (g2d_core == null) g2d_core = Genome2D.getInstance();
        return g2d_core;
    }
	
	/**
	 * 	Camera group this node belongs to, a node is rendered through this camera if camera.mask&node.cameraGroup != 0
	 */
	public var cameraGroup:int = 0;

	public var g2d_pool:GNodePool;
	public var g2d_poolNext:GNode;
	public var g2d_poolPrevious:GNode;


    public var maskRect:Rectangle;
	
	/**
	 * 	Abstract reference to user defined data, if you want keep some custom data binded to G2DNode instance use it.
	 */
	private var g2d_userData:Object;
	public function get userData():Object {
		if (g2d_userData == null) g2d_userData = {};
		return g2d_userData;
	}

	private var g2d_active:Boolean = true;
	public function isActive():Boolean {
        return g2d_active;
	}

    /**
     *  internal node id
     **/
	private var g2d_id:int;
    public function get id():int {
        return g2d_id;
    }

	/**
	 * 	Node name
	 */
	public var name:String;

    // Node transform
	private var g2d_transform:GTransform;
	public function get transform():GTransform {
		return g2d_transform;
	}

    public var postProcess:GPostProcess;

    // Node parent
	private var g2d_parent:GNode;
	public function get parent():GNode {
		return g2d_parent;
	}

    // Physics body
	public var g2d_body:GBody;

	private var g2d_disposed:Boolean = false;

    // internal node count
	static private var g2d_nodeCount:int = 0;
	/**
	 * 	Constructor
	 */
	public function GNode(p_name:String = "") {
		g2d_id = g2d_nodeCount++;
		name = (p_name == "") ? "GNode#"+g2d_id : p_name;
        // Create cached instances
        if (g2d_cachedMatrix == null)  {
            g2d_cachedMatrix = new Matrix();
        }

        g2d_transform = new GTransform(this);
	}
	/**
	 * 	@private
	 */
	public function render(p_parentTransformUpdate:Boolean, p_parentColorUpdate:Boolean, p_camera:GContextCamera, p_renderAsMask:Boolean, p_useMatrix:Boolean):void {
		if (g2d_active) {
            var previousMaskRect:Rectangle = null;
            var hasMask:Boolean = false;
            if (maskRect != null && maskRect != parent.maskRect) {
                hasMask = true;
                previousMaskRect = (core.getContext().getMaskRect() == null) ? null : core.getContext().getMaskRect().clone();
                if (parent.maskRect!=null) {
                    var intersection:Rectangle = parent.maskRect.intersection(maskRect);
                    core.getContext().setMaskRect(intersection);
                } else {
                    core.getContext().setMaskRect(maskRect);
                }
            }

            var invalidateTransform:Boolean = p_parentTransformUpdate || transform.g2d_transformDirty;
            var invalidateColor:Boolean = p_parentColorUpdate || transform.g2d_colorDirty;

            if (invalidateTransform || invalidateColor || (g2d_body != null && g2d_body.isDynamic())) {
                transform.invalidate(p_parentTransformUpdate, p_parentColorUpdate);
            }

            //if (g2d_body != null) g2d_body.update(p_deltaTime, invalidateTransform, invalidateColor);

            if (!g2d_active || !g2d_transform.visible || ((cameraGroup&p_camera.mask) == 0 && cameraGroup != 0)) return;

            // Use matrix
            var useMatrix:Boolean = p_useMatrix || transform.g2d_useMatrix > 0;
            if (useMatrix) {
                if (core.g2d_renderMatrixArray.length<=core.g2d_renderMatrixIndex) core.g2d_renderMatrixArray[core.g2d_renderMatrixIndex] = new Matrix();
                core.g2d_renderMatrixArray[core.g2d_renderMatrixIndex].copyFrom(core.g2d_renderMatrix);
                GMatrixUtils.prependMatrix(core.g2d_renderMatrix, transform.matrix);
                core.g2d_renderMatrixIndex++;
            }

            if (g2d_renderable != null) {
                g2d_renderable.render(p_camera, useMatrix);
            }

            for (var i:int = 0; i<g2d_numChildren; ++i) {
                var child:GNode = g2d_children[i];
                if (child.postProcess != null) {
                    child.postProcess.render(invalidateTransform, invalidateColor, p_camera, child);
                } else {
                    child.render(invalidateTransform, invalidateColor, p_camera, p_renderAsMask, useMatrix);
                }
            }

            if (hasMask) {
                core.getContext().setMaskRect(previousMaskRect);
            }

            // Use matrix
            if (useMatrix) {
                core.g2d_renderMatrixIndex--;
                core.g2d_renderMatrix.copyFrom(core.g2d_renderMatrixArray[core.g2d_renderMatrixIndex]);
            }
        }
	}
	
	/**
	 * 	This method disposes this node, this will also dispose all of its children, components and signals
	 */
	public function dispose():void {
		if (g2d_disposed) return;
		
		disposeChildren();

        while (g2d_numComponents>0) {
            g2d_components.pop().dispose();
            g2d_numComponents--;
        }
		
		g2d_body = null;
		g2d_transform = null;
		
		if (parent != null) {
			parent.removeChild(this);
		}
		
		g2d_disposed = true;
	}
	
	/****************************************************************************************************
	 * 	PROTOTYPE CODE
	 ****************************************************************************************************/
	
	public function getPrototype():XML {
        if (g2d_disposed) throw new GError("Node already disposed.");

        var prototype:XML = <node/>;

        prototype.@name = name;
        prototype.@mouseEnabled = mouseEnabled;
        prototype.@mouseChildren = mouseChildren;
        prototype.components = <components/>

        prototype.components.appendChild(g2d_transform.getPrototype());

        if (g2d_body) prototype.components.appendChild(g2d_body.getPrototype());

        var i:int;
        for (i = 0; i<g2d_components.length; ++i) {
            prototype.components.appendChild(g2d_components[i].getPrototype());
        }

        prototype.children = <children/>;

        for (i = 0; i<g2d_children; ++i) {
            prototype.children.appendChild(g2d_children[i].getPrototype());
        }

        return prototype;

    }

	/****************************************************************************************************
	 * 	MOUSE CODE
	 ****************************************************************************************************/
	public var mouseChildren:Boolean = true;
	public var mouseEnabled:Boolean = false;
	
	// Mouse signals
	private var g2d_onMouseDown:Signal;
	public function get onMouseDown():Signal {
		if (g2d_onMouseDown == null) g2d_onMouseDown = new Signal(GNodeMouseSignal);
		return g2d_onMouseDown;
	}
	private var g2d_onMouseMove:Signal;
	public function get onMouseMove():Signal {
		if (g2d_onMouseMove == null) g2d_onMouseMove = new Signal(GNodeMouseSignal);
		return g2d_onMouseMove;
	}
	private var g2d_onMouseClick:Signal;
	public function get onMouseClick():Signal {
		if (g2d_onMouseClick == null) g2d_onMouseClick = new Signal(GNodeMouseSignal);
		return g2d_onMouseClick;
	}
	private var g2d_onMouseUp:Signal;
	public function get onMouseUp():Signal {
		if (g2d_onMouseUp == null) g2d_onMouseUp = new Signal(GNodeMouseSignal);
		return g2d_onMouseUp;
	}
	private var g2d_onMouseOver:Signal;
	public function get_onMouseOver():Signal {
		if (g2d_onMouseOver == null) g2d_onMouseOver = new Signal(GNodeMouseSignal);
		return g2d_onMouseOver;
	}
	private var g2d_onMouseOut:Signal;
	public function get_onMouseOut():Signal {
		if (g2d_onMouseOut == null) g2d_onMouseOut = new Signal(GNodeMouseSignal);
		return g2d_onMouseOut;
	}

	public var g2d_mouseDownNode:GNode;
	public var g2d_mouseOverNode:GNode;
	public var g2d_rightMouseDownNode:GNode;

	/**
     *  Process context mouse signal
     **/
	public function processContextMouseSignal(p_captured:Boolean, p_cameraX:Number, p_cameraY:Number, p_signal:GMouseSignal, p_camera:GContextCamera):Boolean {
		if (!isActive() || !transform.visible || (p_camera != null && (cameraGroup&p_camera.mask) == 0 && cameraGroup != 0)) return false;

        var i:int;
		if (mouseChildren) {
			for (i = g2d_numChildren-1; i>=0; --i) {
				p_captured = g2d_children[i].processContextMouseSignal(p_captured, p_cameraX, p_cameraY, p_signal, p_camera) || p_captured;
			}
		}
		
		if (mouseEnabled) {
            for (i = 0; i<g2d_numComponents; ++i) {
				p_captured = g2d_components[i].processContextMouseSignal(p_captured, p_cameraX, p_cameraY, p_signal) || p_captured;
			}
		}
		
		return p_captured;
	}

	/**
     *  Dispatch node mouse signal
     **/
	public function dispatchNodeMouseSignal(p_type:String, p_object:GNode, p_localX:Number, p_localY:Number, p_contextSignal:GMouseSignal):void {
		if (mouseEnabled) { 
			var mouseSignal:GNodeMouseSignal = new GNodeMouseSignal(p_type, this, p_object, p_localX, p_localY, p_contextSignal);

            switch (p_type) {
                case GMouseSignalType.MOUSE_DOWN:
                    g2d_mouseDownNode = p_object;
                    if (g2d_onMouseDown != null) g2d_onMouseDown.dispatch(mouseSignal);
                case GMouseSignalType.MOUSE_MOVE:
                    if (g2d_onMouseMove != null) g2d_onMouseMove.dispatch(mouseSignal);
                case GMouseSignalType.MOUSE_UP:
                    if (g2d_mouseDownNode == p_object && g2d_onMouseClick != null) {
                        var mouseClickSignal:GNodeMouseSignal = new GNodeMouseSignal(GMouseSignalType.MOUSE_UP, this, p_object, p_localX, p_localY, p_contextSignal);
                        g2d_onMouseClick.dispatch(mouseClickSignal);
                    }
                    g2d_mouseDownNode = null;
                    if (g2d_onMouseUp != null) g2d_onMouseUp.dispatch(mouseSignal);
                case GMouseSignalType.MOUSE_OVER:
                    g2d_mouseOverNode = p_object;
                    if (g2d_onMouseOver != null) g2d_onMouseOver.dispatch(mouseSignal);
                case GMouseSignalType.MOUSE_OUT:
                    g2d_mouseOverNode = null;
                    if (g2d_onMouseOut != null) g2d_onMouseOut.dispatch(mouseSignal);
            }
		}
		
		if (parent != null) parent.dispatchNodeMouseSignal(p_type, p_object, p_localX, p_localY, p_contextSignal);
	}
	
	/****************************************************************************************************
	 * 	COMPONENT CODE
	 ****************************************************************************************************/
    private var g2d_renderable:IRenderable;
	private var g2d_components:Vector.<GComponent>;
	private var g2d_numComponents:int = 0;
	
	/**
	 * 	Get a component of specified type attached to this node
	 * 
	 * 	@param p_componentClass Component type that should be retrieved
	 */
	public function getComponent(p_componentLookupClass:Class):GComponent {
        // TODO use Lambda
		if (g2d_disposed) throw new GError();
        for (var i:int = 0; i<g2d_numComponents; ++i) {
            var component:GComponent = g2d_components[i];
            if (component.g2d_lookupClass == p_componentLookupClass) return component;
        }
		return null;
	}

	/**
     *  Has component
     **/
	public function hasComponent(p_componentLookupClass:Class):Boolean {
		if (g2d_disposed) throw new GError();
        return getComponent(p_componentLookupClass) != null;
	}
	
	/**
	 * 	Add a component of specified type to this node, node can always have only a single component of a specific class to avoid redundancy
	 * 
	 *	@param p_componentClass Component type that should be instanced and attached to this node
	 */
	public function addComponent(p_componentClass:Class, p_componentLookupClass:Class = null):GComponent {
		if (g2d_disposed) throw new GError();
		if (p_componentLookupClass == null) p_componentLookupClass = p_componentClass;
        var lookup:GComponent = getComponent(p_componentLookupClass);
		if (lookup != null) return lookup;
		
		var component:GComponent = new p_componentClass(this);
		if (component == null) throw new GError();
		component.g2d_lookupClass = p_componentLookupClass;

        if (component is IRenderable) {
            g2d_renderable = component as IRenderable;
        }

		/*
		if (Std.is(component, GBody)) {
			g2d_body = cast component;
			return component;
		}
		/**/

        if (g2d_components == null)g2d_components = new Vector.<GComponent>();
		g2d_components.push(component);
		g2d_numComponents++;
		
		return component;
	}
	
	/**
	 * 	Remove component of specified type from this node
	 * 
	 * 	@param p_componentClass Component type that should be removed
	 */
	public function removeComponent(p_componentLookupClass:Class):void {
		if (g2d_disposed) throw new GError();
		var component:GComponent = getComponent(p_componentLookupClass);

		if (component == null || component == transform) return;

        g2d_components.splice(g2d_components.indexOf(component), 1);
		
		component.dispose();
	}
	
	/****************************************************************************************************
	 * 	CONTAINER CODE
	 ****************************************************************************************************/
	private var g2d_children:Vector.<GNode>;
    private var g2d_numChildren:int = 0;
    public function get numChildren():int {
        return g2d_numChildren;
    }

    private var g2d_onAddedToStage:Signal;
    public function get onAddedToStage():Signal {
        if (g2d_onAddedToStage == null) g2d_onAddedToStage = new Signal();
        return g2d_onAddedToStage;
    }

    private var g2d_onRemovedFromStage:Signal;
    public function get onRemovedFromStage():Signal {
        if (g2d_onRemovedFromStage == null) g2d_onRemovedFromStage = new Signal();
        return g2d_onRemovedFromStage;
    }
	
	/**
	 * 	Add a child node to this node
	 * 
	 * 	@param p_child node that should be added
	 */
	public function addChild(p_child:GNode):void {
		if (g2d_disposed) throw new GError();
		if (p_child == this) throw new GError();
		if (p_child.parent != null) p_child.parent.removeChild(p_child);

		p_child.g2d_parent = this;

        if (g2d_children == null) g2d_children = new Vector.<GNode>();
		g2d_children.push(p_child);
		g2d_numChildren++;
        if (g2d_numChildren == 1 && transform.hasUniformRotation()) transform.g2d_useMatrix++;
		
		if (isOnStage()) p_child.g2d_addedToStage();
	}

    public function addChildAt(p_child:GNode, p_index:int):void {
        if (g2d_disposed) throw new GError();
        if (p_child == this) throw new GError();
        if (p_child.parent != null) p_child.parent.removeChild(p_child);

        p_child.g2d_parent = this;

        if (g2d_children == null) g2d_children = new Vector.<GNode>();
        g2d_children.splice(p_index, 0, p_child);
        g2d_numChildren++;
        if (g2d_numChildren == 1 && transform.hasUniformRotation()) transform.g2d_useMatrix++;

        if (isOnStage()) p_child.g2d_addedToStage();
    }
	
	public function getChildAt(p_index:int):GNode {
        if (g2d_children == null) throw new GError();
        if (p_index>=g2d_numChildren) throw new GError();
		return g2d_children[p_index];
	}

    public function getChildIndex(p_child:GNode):int {
        return g2d_children.indexOf(p_child);
    }

    public function setChildIndex(p_child:GNode, p_index:int):void {
        if (p_child.parent != this) throw new GError();

        g2d_children.splice(g2d_children.indexOf(p_child), 1);
        g2d_children.splice(p_index, 0, p_child);
    }

    public function swapChildren(p_child1:GNode, p_child2:GNode):void {
        if (p_child1.parent != this || p_child2.parent != this) throw new GError();
        swapChildrenAt(g2d_children.indexOf(p_child1), g2d_children.indexOf(p_child2));
    }

    public function swapChildrenAt(p_index1:int, p_index2:int):void {
        var child1:GNode = getChildAt(p_index1);
        var child2:GNode = getChildAt(p_index2);
        g2d_children[p_index1] = child2;
        g2d_children[p_index2] = child1;
    }

	/**
	 * 	Remove a child node from this node
	 * 
	 * 	@param p_child node that should be removed
	 */
	public function removeChild(p_child:GNode):void {
		if (g2d_disposed) throw new GError();
		if (p_child.parent != this) return;

        g2d_children.splice(g2d_children.indexOf(p_child), 1);
		
		p_child.g2d_parent = null;
		
		g2d_numChildren--;
        if (g2d_numChildren == 0 && transform.hasUniformRotation()) transform.g2d_useMatrix--;

		if (isOnStage()) p_child.g2d_removedFromStage();
	}
	
	public function removeChildAt(p_index:int):void {
		if (g2d_children == null || (p_index > 0 && p_index < g2d_children.length)) return;
		removeChild(g2d_children[p_index]);
	}

    /**
	 * 	This method will call dispose on all children of this node which will remove them
	 */
    public function disposeChildren():void {
        while (g2d_numChildren>0) {
            g2d_children.pop().dispose();
            g2d_numChildren--;
        }
    }

	private function g2d_addedToStage():void {
		if (g2d_onAddedToStage != null) g2d_onAddedToStage.dispatch();
		
		//if (g2d_body != null) g2d_body.addToSpace();

		for (var i:int = 0; i<g2d_numChildren; ++i) {
			g2d_children[i].g2d_addedToStage();
		}
	}

	private function g2d_removedFromStage():void {
		if (g2d_onRemovedFromStage != null) g2d_onRemovedFromStage.dispatch();
		
		//if (g2d_body != null) g2d_body.removeFromSpace();
		
		for (var i:int = 0; i<g2d_numChildren; ++i) {
			g2d_children[i].g2d_removedFromStage();
		}
	}
	
	/**
	 * 	Returns true if this node is attached to Genome2D render tree false otherwise
	 */
	public function isOnStage():Boolean {
		if (this == core.root) {
            return true;
        } else if (parent == null) {
            return false;
        } else {
            return parent.isOnStage();
        }
	}

    public function getBounds(p_targetSpace:GNode, p_bounds:Rectangle = null):Rectangle {
        if (p_bounds == null) p_bounds = new Rectangle();
        var found:Boolean = false;
        var minX:Number = 10000000;
        var maxX:Number = -10000000;
        var minY:Number = 10000000;
        var maxY:Number = -10000000;
        var aabb:Rectangle = new Rectangle(0,0,0,0);

        if (g2d_renderable != null) {
            g2d_renderable.getBounds(aabb);
            if (aabb.width != 0 && aabb.height != 0) {
                var m:Matrix = transform.getTransformationMatrix(p_targetSpace, g2d_cachedMatrix);

                var tx1:Number = g2d_cachedMatrix.a * aabb.x + g2d_cachedMatrix.c * aabb.y + g2d_cachedMatrix.tx;
                var ty1:Number = g2d_cachedMatrix.d * aabb.y + g2d_cachedMatrix.b * aabb.x + g2d_cachedMatrix.ty;
                var tx2:Number = g2d_cachedMatrix.a * aabb.x + g2d_cachedMatrix.c * aabb.bottom + g2d_cachedMatrix.tx;
                var ty2:Number = g2d_cachedMatrix.d * aabb.bottom + g2d_cachedMatrix.b * aabb.x + g2d_cachedMatrix.ty;
                var tx3:Number = g2d_cachedMatrix.a * aabb.right + g2d_cachedMatrix.c * aabb.y + g2d_cachedMatrix.tx;
                var ty3:Number = g2d_cachedMatrix.d * aabb.y + g2d_cachedMatrix.b * aabb.right + g2d_cachedMatrix.ty;
                var tx4:Number = g2d_cachedMatrix.a * aabb.right + g2d_cachedMatrix.c * aabb.bottom + g2d_cachedMatrix.tx;
                var ty4:Number = g2d_cachedMatrix.d * aabb.bottom + g2d_cachedMatrix.b * aabb.right + g2d_cachedMatrix.ty;
                if (minX > tx1) minX = tx1; if (minX > tx2) minX = tx2; if (minX > tx3) minX = tx3; if (minX > tx4) minX = tx4;
                if (minY > ty1) minY = ty1; if (minY > ty2) minY = ty2; if (minY > ty3) minY = ty3; if (minY > ty4) minY = ty4;
                if (maxX < tx1) maxX = tx1; if (maxX < tx2) maxX = tx2; if (maxX < tx3) maxX = tx3; if (maxX < tx4) maxX = tx4;
                if (maxY < ty1) maxY = ty1; if (maxY < ty2) maxY = ty2; if (maxY < ty3) maxY = ty3; if (maxY < ty4) maxY = ty4;
                found = true;
            }
        }

        for (var i:int = 0; i<g2d_numChildren; ++i) {
            g2d_children[i].getBounds(p_targetSpace, aabb);
            if (aabb.width == 0 || aabb.height == 0) continue;
            if (minX > aabb.x) minX = aabb.x;
            if (maxX < aabb.right) maxX = aabb.right;
            if (minY > aabb.y) minY = aabb.y;
            if (maxY < aabb.bottom) maxY = aabb.bottom;
            found = true;
        }

        if (found) p_bounds.setTo(minX, minY, maxX-minX, maxY-minY);


        return p_bounds;
    }

    public function getCommonParent(p_node:GNode):GNode {
        // Store this hierarchy
        var current:GNode = this;
        // TODO optimize for targets where length = 0 is possible?
        g2d_cachedArray = new Vector.<GNode>();
        while (current != null) {
            g2d_cachedArray.push(current);
            current = current.parent;
        }

        // Iterate from target to common
        current = p_node;
        while (current!=null && g2d_cachedArray.indexOf(current) == -1) {
            current = current.parent;
        }

        return current;
    }

    private var g2d_cachedSortProperty:String;
    public function sortChildrenOnUserData(p_property:String):void {
        g2d_cachedSortProperty = p_property;
        g2d_children.sort(sortOnUserData);
    }

    private function sortOnUserData(p_x:GNode, p_y:GNode):int {
        var x:Number = p_x.userData.get(g2d_cachedSortProperty);
        var y:Number = p_y.userData.get(g2d_cachedSortProperty);
        if (x>y) {
            return 1;
        } else if (x<y) {
            return -1;
        }
        return 0;
    }

    public function toString():String {
        return "[GNode "+name+"]";
    }
}
}