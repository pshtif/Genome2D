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
import com.genome2d.context.GContextFeature;
import com.genome2d.context.IContext;
import com.genome2d.context.stats.GStats;
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
    static private var g2d_activeMasks:Vector.<GNode>;

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
    private var g2d_usedAsMask:int = 0;
    private var g2d_mask:GNode;
    public function get mask():GNode {
        return g2d_mask;
    }
    public function set mask(p_value:GNode):void {
        if (g2d_core.g2d_context.hasFeature(GContextFeature.STENCIL_MASKING)) new GError("Stencil masking feature not supported.");
        if (g2d_mask != null) g2d_mask.g2d_usedAsMask--;
        g2d_mask = p_value;
        g2d_mask.g2d_usedAsMask++;
    }
	
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

    public function setActive(p_value:Boolean):void {
        if (p_value != g2d_active) {
            if (g2d_disposed) throw new GError();

            g2d_active = p_value;
            g2d_transform.setActive(g2d_active);

            if (g2d_pool != null) {
                if (p_value) {
                    g2d_pool.g2d_putToBack(this);
                } else {
                    g2d_pool.g2d_putToFront(this);
                }
            }

            //if (g2d_body != null) g2d_body.setActive(g2d_active);

            var i:int;
            for (i=0; i<g2d_numComponents; ++i) {
                g2d_components[i].setActive(p_value);
            }

            var child:GNode = g2d_firstChild;
            while (child != null) {
                var next:GNode = child.g2d_nextNode;
                child.setActive(p_value);
                child = next;
            }
        }
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
            g2d_activeMasks = new Vector.<GNode>();
        }

        g2d_transform = new GTransform(this);
        g2d_transform.g2d_lookupClass = GTransform;
	}
	/**
	 * 	@private
	 */
	public function render(p_parentTransformUpdate:Boolean, p_parentColorUpdate:Boolean, p_camera:GContextCamera, p_renderAsMask:Boolean, p_useMatrix:Boolean):void {
		if (g2d_active) {
            var context:IContext = core.getContext();
            var previousMaskRect:Rectangle = null;
            var hasMask:Boolean = false;
            if (maskRect != null && maskRect != g2d_parent.maskRect) {
                hasMask = true;
                previousMaskRect = (context.getMaskRect() == null) ? null : context.getMaskRect().clone();
                if (g2d_parent.maskRect!=null) {
                    var intersection:Rectangle = g2d_parent.maskRect.intersection(maskRect);
                    context.setMaskRect(intersection);
                } else {
                    context.setMaskRect(maskRect);
                }
            }

            var invalidateTransform:Boolean = p_parentTransformUpdate || g2d_transform.g2d_transformDirty;
            var invalidateColor:Boolean = p_parentColorUpdate || g2d_transform.g2d_colorDirty;

            if (invalidateTransform || invalidateColor || (g2d_body != null && g2d_body.isDynamic())) {
                g2d_transform.invalidate(p_parentTransformUpdate, p_parentColorUpdate);
            }

            //if (g2d_body != null) g2d_body.update(p_deltaTime, invalidateTransform, invalidateColor);

            if (!g2d_active || !g2d_transform.visible || ((cameraGroup&p_camera.mask) == 0 && cameraGroup != 0)) return;

            if (!p_renderAsMask) {
                if (mask != null) {
                    context.renderToStencil(g2d_activeMasks.length);
                    mask.render(true, false, p_camera, true, false);
                    g2d_activeMasks.push(mask);
                    context.renderToColor(g2d_activeMasks.length);
                }
            }

            // Use matrix
            var useMatrix:Boolean = p_useMatrix || g2d_transform.g2d_useMatrix > 0;
            if (useMatrix) {
                if (core.g2d_renderMatrixArray.length<=core.g2d_renderMatrixIndex) core.g2d_renderMatrixArray[core.g2d_renderMatrixIndex] = new Matrix();
                core.g2d_renderMatrixArray[core.g2d_renderMatrixIndex].copyFrom(core.g2d_renderMatrix);
                GMatrixUtils.prependMatrix(core.g2d_renderMatrix, transform.matrix);
                core.g2d_renderMatrixIndex++;
            }

            if (g2d_renderable != null) {
                g2d_renderable.render(p_camera, useMatrix);
            }

            var child:GNode = g2d_firstChild;
            while (child != null) {
                var next:GNode = child.g2d_nextNode;
                if (child.postProcess != null) {
                    child.postProcess.render(invalidateTransform, invalidateColor, p_camera, child);
                } else {
                    child.render(invalidateTransform, invalidateColor, p_camera, p_renderAsMask, useMatrix);
                }
                child = next;
            }

            if (hasMask) {
                context.setMaskRect(previousMaskRect);
            }

            if (!p_renderAsMask) {
                if (mask != null) {
                    g2d_activeMasks.pop();
                    if (g2d_activeMasks.length==0) context.clearStencil();
                    context.renderToColor(g2d_activeMasks.length);
                }
            }

            // Use matrix
            if (useMatrix) {
                g2d_core.g2d_renderMatrixIndex--;
                g2d_core.g2d_renderMatrix.copyFrom(core.g2d_renderMatrixArray[g2d_core.g2d_renderMatrixIndex]);
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

        var child:GNode = g2d_firstChild;
        while (child != null) {
            var next:GNode = child.g2d_nextNode;
            prototype.children.appendChild(child.getPrototype());
            child = next;
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
	public function get onMouseOver():Signal {
		if (g2d_onMouseOver == null) g2d_onMouseOver = new Signal(GNodeMouseSignal);
		return g2d_onMouseOver;
	}
	private var g2d_onMouseOut:Signal;
	public function get onMouseOut():Signal {
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

        if (mouseChildren) {
            var child:GNode = g2d_lastChild;
            while (child != null) {
                var previous:GNode = child.g2d_previousNode;
                p_captured = child.processContextMouseSignal(p_captured, p_cameraX, p_cameraY, p_signal, p_camera) || p_captured;
                child = previous;
            }
        }
		
		if (mouseEnabled) {
            for (var i:int = 0; i<g2d_numComponents; ++i) {
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
                    break;
                case GMouseSignalType.MOUSE_MOVE:
                    if (g2d_onMouseMove != null) g2d_onMouseMove.dispatch(mouseSignal);
                    break;
                case GMouseSignalType.MOUSE_UP:
                    if (g2d_mouseDownNode == p_object && g2d_onMouseClick != null) {
                        var mouseClickSignal:GNodeMouseSignal = new GNodeMouseSignal(GMouseSignalType.MOUSE_UP, this, p_object, p_localX, p_localY, p_contextSignal);
                        g2d_onMouseClick.dispatch(mouseClickSignal);
                    }
                    g2d_mouseDownNode = null;
                    if (g2d_onMouseUp != null) g2d_onMouseUp.dispatch(mouseSignal);
                    break;
                case GMouseSignalType.MOUSE_OVER:
                    g2d_mouseOverNode = p_object;
                    if (g2d_onMouseOver != null) g2d_onMouseOver.dispatch(mouseSignal);
                    break;
                case GMouseSignalType.MOUSE_OUT:
                    g2d_mouseOverNode = null;
                    if (g2d_onMouseOut != null) g2d_onMouseOut.dispatch(mouseSignal);
                    break;
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
    private var g2d_firstChild:GNode;
    private var g2d_lastChild:GNode;
    private var g2d_nextNode:GNode;
    private var g2d_previousNode:GNode;

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
	public function addChild(p_child:GNode, p_before:GNode = null):void {
        if (g2d_disposed) new GError("Node already disposed.");
        if (p_child == this) new GError("Can't add child to itself.");
        if (p_child.g2d_parent != null) p_child.g2d_parent.removeChild(p_child);

        p_child.g2d_parent = this;

        if (g2d_firstChild == null) {
            g2d_firstChild = p_child;
            g2d_lastChild = p_child;
        } else {
            if (p_before == null) {
                g2d_lastChild.g2d_nextNode = p_child;
                p_child.g2d_previousNode = g2d_lastChild;
                g2d_lastChild = p_child;
            } else {
                if (p_before != g2d_firstChild) {
                    p_before.g2d_previousNode.g2d_nextNode = p_child;
                } else {
                    g2d_firstChild = p_child;
                }
                p_child.g2d_previousNode = p_before.g2d_previousNode;
                p_child.g2d_nextNode = p_before;
                p_before.g2d_previousNode = p_child;
            }
        }

        g2d_numChildren++;
        if (g2d_numChildren == 1 && transform.hasUniformRotation()) transform.g2d_useMatrix++;

        if (isOnStage()) p_child.g2d_addedToStage();
	}

    public function addChildAt(p_child:GNode, p_index:int):void {
        if (g2d_disposed) new GError("Node already disposed.");
        if (p_child == this) new GError("Can't add child to itself.");
        if (p_child.g2d_parent != null) p_child.g2d_parent.removeChild(p_child);

        p_child.g2d_parent = this;

        var i:int = 0;
        var after:GNode = g2d_firstChild;
        while (i<p_index && after != null) {
            after = after.g2d_nextNode;
            i++;
        }
        addChild(p_child, (after == null) ? null : after.g2d_nextNode);
    }
	
	public function getChildAt(p_index:int):GNode {
        if (p_index>=g2d_numChildren) new GError("Index out of bounds.");
        var child:GNode = g2d_firstChild;
        for (var i:int = 0; i<p_index; ++i) {
            child = child.g2d_nextNode;
        }
        return child;
	}

    public function getChildIndex(p_child:GNode):int {
        if (p_child.g2d_parent != this) return -1;
        var child:GNode = g2d_firstChild;
        for (var i:int = 0; i<g2d_numChildren; ++i) {
            if (child == p_child) return i;
            child = child.g2d_nextNode;
        }
        return -1;
    }

    public function setChildIndex(p_child:GNode, p_index:int):void {
        if (p_child.g2d_parent != this) new GError("Not a child of this node.");
        if (p_index>=g2d_numChildren) new GError("Index out of bounds.");

        var index:int = 0;
        var child:GNode = g2d_firstChild;
        while (child!=null && index<p_index) {
            child = child.g2d_nextNode;
            index++;
        }
        if (index == p_index && child != p_child) {
            // Remove child from current index
            if (p_child != g2d_lastChild) {
                p_child.g2d_nextNode.g2d_previousNode = p_child.g2d_previousNode;
            } else {
                g2d_lastChild = p_child.g2d_previousNode;
            }
            if (p_child != g2d_firstChild) {
                p_child.g2d_previousNode.g2d_nextNode = p_child.g2d_nextNode;
            } else {
                g2d_firstChild = p_child.g2d_nextNode;
            }
            // Insert it before the found one
            if (child != g2d_firstChild) {
                child.g2d_previousNode.g2d_nextNode = p_child;
            } else {
                g2d_firstChild = p_child;
            }
            p_child.g2d_previousNode = child.g2d_previousNode;
            p_child.g2d_nextNode = child;
            child.g2d_previousNode = p_child;
        }
    }

    public function swapChildrenAt(p_index1:int, p_index2:int):void {
        swapChildren(getChildAt(p_index1), getChildAt(p_index2));
    }

    public function swapChildren(p_child1:GNode, p_child2:GNode):void {
        if (p_child1.g2d_parent != this || p_child2.g2d_parent != this) return;

        var temp:GNode = p_child1.g2d_nextNode;
        if (p_child2.g2d_nextNode == p_child1) {
            p_child1.g2d_nextNode = p_child2;
        } else {
            p_child1.g2d_nextNode = p_child2.g2d_nextNode;
            if (p_child1.g2d_nextNode != null) p_child1.g2d_nextNode.g2d_previousNode = p_child1;
        }
        if (temp == p_child2) {
            p_child2.g2d_nextNode = p_child1;
        } else {
            p_child2.g2d_nextNode = temp;
            if (p_child2.g2d_nextNode != null)  p_child2.g2d_nextNode.g2d_previousNode = p_child2;
        }

        temp = p_child1.g2d_previousNode;
        if (p_child2.g2d_previousNode == p_child1) {
            p_child1.g2d_previousNode = p_child2;
        } else {
            p_child1.g2d_previousNode = p_child2.g2d_previousNode;
            if (p_child1.g2d_previousNode != null)  p_child1.g2d_previousNode.g2d_nextNode = p_child1;
        }
        if (temp == p_child2) {
            p_child2.g2d_previousNode = p_child1;
        } else {
            p_child2.g2d_previousNode = temp;
            if (p_child2.g2d_previousNode != null) p_child2.g2d_previousNode.g2d_nextNode = p_child2;
        }

        if (p_child1 == g2d_firstChild) g2d_firstChild = p_child2;
        else if (p_child2 == g2d_firstChild) g2d_firstChild = p_child1;
        if (p_child1 == g2d_lastChild) g2d_lastChild = p_child2;
        else if (p_child2 == g2d_lastChild) g2d_lastChild = p_child1;
    }

    public function putChildToFront(p_child:GNode):void {
        if (p_child.parent != this || p_child == g2d_lastChild) return;

        if (p_child.g2d_nextNode != null) p_child.g2d_nextNode.g2d_previousNode = p_child.g2d_previousNode;
        if (p_child.g2d_previousNode != null) p_child.g2d_previousNode.g2d_nextNode = p_child.g2d_nextNode;
        if (p_child == g2d_firstChild) g2d_firstChild = g2d_firstChild.g2d_nextNode;

        if (g2d_lastChild != null) g2d_lastChild.g2d_nextNode = p_child;
        p_child.g2d_previousNode = g2d_lastChild;
        p_child.g2d_nextNode = null;
        g2d_lastChild = p_child;
    }

    public function putChildToBack(p_child:GNode):void {
        if (p_child.parent != this || p_child == g2d_firstChild) return;

        if (p_child.g2d_nextNode != null) p_child.g2d_nextNode.g2d_previousNode = p_child.g2d_previousNode;
        if (p_child.g2d_previousNode != null) p_child.g2d_previousNode.g2d_nextNode = p_child.g2d_nextNode;
        if (p_child == g2d_lastChild) g2d_lastChild = g2d_lastChild.g2d_previousNode;

        if (g2d_firstChild != null) g2d_firstChild.g2d_previousNode = p_child;
        p_child.g2d_previousNode = null;
        p_child.g2d_nextNode = g2d_firstChild;
        g2d_firstChild = p_child;
    }

	/**
	 * 	Remove a child node from this node
	 * 
	 * 	@param p_child node that should be removed
	 */
	public function removeChild(p_child:GNode):void {
        if (g2d_disposed) new GError("Node already disposed.");
        if (p_child.g2d_parent != this) return;

        if (p_child.g2d_previousNode != null) {
            p_child.g2d_previousNode.g2d_nextNode = p_child.g2d_nextNode;
        } else {
            g2d_firstChild = g2d_firstChild.g2d_nextNode;
        }
        if (p_child.g2d_nextNode != null) {
            p_child.g2d_nextNode.g2d_previousNode = p_child.g2d_previousNode;
        } else {
            g2d_lastChild = g2d_lastChild.g2d_previousNode;
        }

        p_child.g2d_nextNode = p_child.g2d_previousNode = p_child.g2d_parent = null;

        g2d_numChildren--;
        if (g2d_numChildren == 0 && transform.hasUniformRotation()) transform.g2d_useMatrix--;

        if (isOnStage()) p_child.g2d_removedFromStage();
	}
	
	public function removeChildAt(p_index:int):void {
        if (p_index>=g2d_numChildren) new GError("Index out of bounds.");
        var index:int = 0;
        var child:GNode = g2d_firstChild;
        while (child != null && index<p_index) {
            child = child.g2d_nextNode;
            index++;
        }
        removeChild(child);
	}

    /**
	 * 	This method will call dispose on all children of this node which will remove them
	 */
    public function disposeChildren():void {
        while (g2d_firstChild != null) {
            g2d_firstChild.dispose();
        }
    }

	private function g2d_addedToStage():void {
		if (g2d_onAddedToStage != null) g2d_onAddedToStage.dispatch();
        GStats.nodeCount++;

        //if (g2d_body != null) g2d_body.addToSpace();

        var child:GNode = g2d_firstChild;
        while (child != null) {
            var next:GNode = child.g2d_nextNode;
            child.g2d_addedToStage();
            child = next;
        }
	}

	private function g2d_removedFromStage():void {
		if (g2d_onRemovedFromStage != null) g2d_onRemovedFromStage.dispatch();
        GStats.nodeCount--;

        //if (g2d_body != null) g2d_body.removeFromSpace();

        var child:GNode = g2d_firstChild;
        while (child != null) {
            var next:GNode = child.g2d_nextNode;
            child.g2d_removedFromStage();
            child = next;
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
        var minX:Number = Infinity;
        var maxX:Number = -Infinity;
        var minY:Number = Infinity;
        var maxY:Number = -Infinity;
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

        var child:GNode = g2d_firstChild;
        while (child != null) {
            var next:GNode = child.g2d_nextNode;
            child.getBounds(p_targetSpace, aabb);
            if (aabb.width == 0 || aabb.height == 0) {
                child = next;
                continue;
            }
            if (minX > aabb.x) minX = aabb.x;
            if (maxX < aabb.right) maxX = aabb.right;
            if (minY > aabb.y) minY = aabb.y;
            if (maxY < aabb.bottom) maxY = aabb.bottom;
            found = true;
            child = next;
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

    public function sortChildrenOnUserData(p_property:String, p_ascending:Boolean = true):void {
        if (g2d_firstChild == null) return;

        var insize:int = 1;
        var psize:int;
        var qsize:int;
        var nmerges:int;
        var p:GNode;
        var q:GNode;
        var e:GNode;

        while (true) {
            p = g2d_firstChild;
            g2d_firstChild = null;
            g2d_lastChild = null;

            nmerges = 0;

            while (p != null) {
                nmerges++;
                q = p;
                psize = 0;
                for (var i:int = 0; i<insize; ++i) {
                    psize++;
                    q = q.g2d_nextNode;
                    if (q == null) break;
                }

                qsize = insize;

                while (psize > 0 || (qsize > 0 && q != null)) {
                    if (psize == 0) {
                        e = q;
                        q = q.g2d_nextNode;
                        qsize--;
                    } else if (qsize == 0 || q == null) {
                        e = p;
                        p = p.g2d_nextNode;
                        psize--;
                    } else if (p_ascending) {
                        if (p.userData[p_property] >= q.userData[p_property]) {
                            e = p;
                            p = p.g2d_nextNode;
                            psize--;
                        } else {
                            e = q;
                            q = q.g2d_nextNode;
                            qsize--;
                        }
                    } else {
                        if (p.userData[p_property] <= q.userData[p_property]) {
                            e = p;
                            p = p.g2d_nextNode;
                            psize--;
                        } else {
                            e = q;
                            q = q.g2d_nextNode;
                            qsize--;
                        }
                    }

                    if (g2d_lastChild != null) {
                        g2d_lastChild.g2d_nextNode = e;
                    } else {
                        g2d_firstChild = e;
                    }

                    e.g2d_previousNode = g2d_lastChild;

                    g2d_lastChild = e;
                }

                p = q;
            }

            g2d_lastChild.g2d_nextNode = null;

            if (nmerges <= 1) return;

            insize *= 2;
        }
    }

    public function toString():String {
        return "[GNode "+name+"]";
    }
}
}
