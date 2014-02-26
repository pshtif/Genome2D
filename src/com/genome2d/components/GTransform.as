package com.genome2d.components {
import com.genome2d.node.GNode;

import flash.geom.Matrix;
import flash.geom.Point;

/**
 * ...
 * @author Peter "sHTiF" Stefcek
 */
public class GTransform extends GComponent
{
    static private var g2d_cachedMatrix:Matrix;

	public var useWorldSpace:Boolean = false;
	public var useWorldColor:Boolean = false;

    private var g2d_matrixDirty:Boolean = true;
	public var g2d_transformDirty:Boolean = false;
	public var g2d_colorDirty:Boolean = false;
	
	private var g2d_visible:Boolean = true;
	public function get visible():Boolean {
		return g2d_visible;
	}
	public function set visible(p_value:Boolean):void {
		g2d_visible = p_value;
	}
	
	public var g2d_worldX:Number = 0;
	public var g2d_localX:Number = 0;
	public function get x():Number {
		return g2d_localX;
	}
	public function set x(p_value:Number):void {
		g2d_transformDirty = g2d_matrixDirty = true;
		if (node.g2d_body != null) node.g2d_body.x = p_value;
		g2d_localX = g2d_worldX = p_value;
	}
	
	public var g2d_worldY:Number = 0;
	public var g2d_localY:Number = 0;
	public function get y():Number {
		return g2d_localY;
	}
	public function set y(p_value:Number):void {
		g2d_transformDirty = g2d_matrixDirty = true;
		if (node.g2d_body != null) node.g2d_body.y = p_value;
		g2d_localY = g2d_worldY = p_value;
	}

    public function hasUniformRotation():Boolean {
        return (g2d_localScaleX != g2d_localScaleY && g2d_localRotation != 0);
    }
    private var g2d_localUseMatrix:int = 0;
    public function get g2d_useMatrix():int {
        return g2d_localUseMatrix;
    }
    public function set g2d_useMatrix(p_value:int):void {
        if (node.parent != null) node.parent.transform.g2d_useMatrix += p_value-g2d_useMatrix;
        g2d_localUseMatrix = p_value;
    }
	
	public var g2d_worldScaleX:Number = 1;
	public var g2d_localScaleX:Number = 1;
	public function get scaleX():Number {
		return g2d_localScaleX;
	}
	public function set scaleX(p_value:Number):void {
        if (g2d_localScaleX == g2d_localScaleY && p_value != g2d_localScaleY && g2d_localRotation != 0 && node.numChildren>0) g2d_useMatrix++;
        if (g2d_localScaleX == g2d_localScaleY && p_value == g2d_localScaleY && g2d_localRotation != 0 && node.numChildren>0) g2d_useMatrix--;

		g2d_transformDirty = g2d_matrixDirty = true;
		if (node.g2d_body != null) node.g2d_body.scaleX = p_value;
		g2d_localScaleX = g2d_worldScaleX = p_value;
	}
	
	public var g2d_worldScaleY:Number = 1;
	public var g2d_localScaleY:Number = 1;
	public function get scaleY():Number {
		return g2d_localScaleY;
	}
	public function set scaleY(p_value:Number):void {
        if (g2d_localScaleX == g2d_localScaleY && p_value != g2d_localScaleX && g2d_localRotation != 0 && node.numChildren>0) g2d_useMatrix++;
        if (g2d_localScaleX == g2d_localScaleY && p_value == g2d_localScaleX && g2d_localRotation != 0 && node.numChildren>0) g2d_useMatrix--;

		g2d_transformDirty = g2d_matrixDirty = true;
		if (node.g2d_body != null) node.g2d_body.scaleY = p_value;
		g2d_localScaleY = g2d_worldScaleY = p_value;
	}
	
	public var g2d_worldRotation:Number = 0;
	public var g2d_localRotation:Number = 0;
	public function get rotation():Number {
		return g2d_localRotation;
	}
	public function set rotation(p_value:Number):void {
        if (g2d_localRotation == 0 && p_value != 0 && g2d_localScaleX != g2d_localScaleY && node.numChildren>0) g2d_useMatrix++;
        if (g2d_localRotation != 0 && p_value == 0 && g2d_localScaleX != g2d_localScaleY && node.numChildren>0) g2d_useMatrix--;

		g2d_transformDirty = g2d_matrixDirty = true;
		if (node.g2d_body != null) node.g2d_body.rotation = p_value;
		g2d_localRotation = g2d_worldRotation = p_value;
	}	
	
	public var g2d_worldRed:Number = 1;
	public var g2d_localRed:Number = 1;
	public function get red():Number {
		return g2d_localRed;
	}
	public function set red(p_value:Number):void {
		g2d_colorDirty = true;
		g2d_localRed = g2d_worldRed = p_value;
	}
	
	public var g2d_worldGreen:Number = 1;
	public var g2d_localGreen:Number = 1;
	public function get green():Number {
		return g2d_localGreen;
	}
	public function set green(p_value:Number):void {
		g2d_colorDirty = true;
		g2d_localGreen = g2d_worldGreen = p_value;
	}
	
	public var g2d_worldBlue:Number = 1;
	public var g2d_localBlue:Number = 1;
	public function get blue():Number {
		return g2d_localBlue;
	}
	public function set blue(p_value:Number):void {
		g2d_colorDirty = true;
		g2d_localBlue = g2d_worldBlue = p_value;
	}
	
	public var g2d_worldAlpha:Number = 1;
	public var g2d_localAlpha:Number = 1;
	public function get alpha():Number {
		return g2d_localAlpha;
	}
	public function set alpha(p_value:Number):void {
		g2d_colorDirty = true;
		g2d_localAlpha = g2d_worldAlpha = p_value;
	}

	public function set color(p_value:int):void {
		red = (p_value >> 16 & 0xFF) / 0xFF;
		green = (p_value >> 8 & 0xFF) / 0xFF;
		blue = (p_value & 0xFF) / 0xFF;
	}

    private var g2d_matrix:Matrix;
    public function get matrix():Matrix {
        if (g2d_matrixDirty) {
            if (g2d_matrix == null) g2d_matrix = new Matrix();
            if (g2d_localRotation == 0.0) {
                g2d_matrix.setTo(g2d_localScaleX, 0.0, 0.0, g2d_localScaleY, g2d_localX, g2d_localY);
            } else {
                var cos:Number = Math.cos(g2d_localRotation);
                var sin:Number = Math.sin(g2d_localRotation);
                var a:Number = g2d_localScaleX * cos;
                var b:Number = g2d_localScaleX * sin;
                var c:Number = g2d_localScaleY * -sin;
                var d:Number = g2d_localScaleY * cos;
                var tx:Number = g2d_localX;
                var ty:Number = g2d_localY;

                g2d_matrix.setTo(a, b, c, d, tx, ty);
            }

            g2d_matrixDirty = false;
        }

        return g2d_matrix;
    }

    public function getTransformationMatrix(p_targetSpace:GNode, p_resultMatrix:Matrix = null):Matrix {
        if (p_resultMatrix == null) {
            p_resultMatrix = new Matrix();
        } else {
            p_resultMatrix.identity();
        }

        if (p_targetSpace == node.parent) {
            p_resultMatrix.copyFrom(matrix);
        } else if (p_targetSpace != node) {
            var common:GNode = node.getCommonParent(p_targetSpace);
            if (common != null) {
                var current:GNode = node;
                while (common != current) {
                    p_resultMatrix.concat(current.transform.matrix);
                    current = current.parent;
                }
                // If its not in parent hierarchy we need to continue down the target
                if (common != p_targetSpace) {
                    g2d_cachedMatrix.identity();
                    while (p_targetSpace != common) {
                        g2d_cachedMatrix.concat(p_targetSpace.transform.matrix);
                        p_targetSpace = p_targetSpace.parent;
                    }
                    g2d_cachedMatrix.invert();
                    p_resultMatrix.concat(g2d_cachedMatrix);
                }
            }
        }

        return p_resultMatrix;
    }

    public function localToGlobal(p_local:Point, p_result:Point = null):Point {
        getTransformationMatrix(node.core.root, g2d_cachedMatrix);
        if (p_result == null) p_result = new Point();
        p_result.x = g2d_cachedMatrix.a * p_local.x + g2d_cachedMatrix.c * p_local.y + g2d_cachedMatrix.tx;
        p_result.y = g2d_cachedMatrix.d * p_local.y + g2d_cachedMatrix.b * p_local.x + g2d_cachedMatrix.ty;
        return p_result;
    }

    public function globalToLocal(p_global:Point, p_result:Point = null):Point {
        getTransformationMatrix(node.core.root, g2d_cachedMatrix);
        g2d_cachedMatrix.invert();
        if (p_result == null) p_result = new Point();
        p_result.x = g2d_cachedMatrix.a * p_global.x + g2d_cachedMatrix.c * p_global.y + g2d_cachedMatrix.tx;
        p_result.y = g2d_cachedMatrix.d * p_global.y + g2d_cachedMatrix.b * p_global.x + g2d_cachedMatrix.ty;
        return p_result;
    }
	
	public function GTransform(p_node:GNode) {
		super(p_node);

        if (g2d_cachedMatrix == null) g2d_cachedMatrix = new Matrix();
	}
	
	public function setPosition(p_x:Number, p_y:Number):void {
		g2d_transformDirty = true;
		if (node.g2d_body != null) {
			node.g2d_body.x = p_x;
			node.g2d_body.y = p_y;
		}
		g2d_localX = g2d_worldX = p_x;
		g2d_localY = g2d_worldY = p_y;
	}
	
	public function setScale(p_scaleX:Number, p_scaleY:Number):void {
		g2d_transformDirty = true;
		if (node.g2d_body != null) {
			node.g2d_body.scaleX = p_scaleX;
			node.g2d_body.scaleY = p_scaleY;
		}
		g2d_localScaleX = g2d_worldScaleX = p_scaleX;
		g2d_localScaleY = g2d_worldScaleY = p_scaleY;
	}
	
	public function invalidate(p_invalidateTransform:Boolean, p_invalidateColor:Boolean):void {
        var parentTransform:GTransform = node.parent.transform;

        if (node.g2d_body != null && node.g2d_body.isDynamic()) {
            x = node.g2d_body.x;
            y = node.g2d_body.y;
            rotation = node.g2d_body.rotation;
        } else {
            if (p_invalidateTransform && !useWorldSpace) {
                if (parentTransform.g2d_worldRotation != 0) {
                    var cos:Number = Math.cos(parentTransform.g2d_worldRotation);
                    var sin:Number = Math.sin(parentTransform.g2d_worldRotation);

                    g2d_worldX = (x * cos - y * sin) * parentTransform.g2d_worldScaleX + parentTransform.g2d_worldX;
                    g2d_worldY = (y * cos + x * sin) * parentTransform.g2d_worldScaleY + parentTransform.g2d_worldY;
                } else {
                    g2d_worldX = g2d_localX * parentTransform.g2d_worldScaleX + parentTransform.g2d_worldX;
                    g2d_worldY = g2d_localY * parentTransform.g2d_worldScaleY + parentTransform.g2d_worldY;
                }

                g2d_worldScaleX = g2d_localScaleX * parentTransform.g2d_worldScaleX;
                g2d_worldScaleY = g2d_localScaleY * parentTransform.g2d_worldScaleY;
                g2d_worldRotation = g2d_localRotation + parentTransform.g2d_worldRotation;

                if (node.g2d_body != null && node.g2d_body.isKinematic()) {
                    node.g2d_body.x = g2d_worldX;
                    node.g2d_body.y = g2d_worldY;
                    node.g2d_body.rotation = g2d_worldRotation;
                }

                g2d_transformDirty = false;
            }

            if (p_invalidateColor && !useWorldColor) {
                g2d_worldRed = g2d_localRed * parentTransform.g2d_worldRed;
                g2d_worldGreen = g2d_localGreen * parentTransform.g2d_worldGreen;
                g2d_worldBlue = g2d_localBlue * parentTransform.g2d_worldBlue;
                g2d_worldAlpha = g2d_localAlpha * parentTransform.g2d_worldAlpha;

                g2d_colorDirty = false;
            }
        }
	}
}
}