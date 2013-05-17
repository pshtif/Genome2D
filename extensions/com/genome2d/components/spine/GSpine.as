/**
 * Created with IntelliJ IDEA.
 * User: Peter "sHTiF" Stefcek
 * Date: 17.5.2013
 * Time: 14:03
 * To change this template use File | Settings | File Templates.
 */
package com.genome2d.components.spine {
import com.genome2d.components.GCamera;
import com.genome2d.components.GComponent;
import com.genome2d.context.GContext;
import com.genome2d.core.GNode;
import com.genome2d.g2d;
import com.genome2d.textures.GTexture;

import flash.geom.Rectangle;

import spine.AnimationState;
import spine.Bone;

import spine.Skeleton;
import spine.Slot;
import spine.attachments.RegionAttachment;

use namespace g2d;

public class GSpine extends GComponent {
    public var skeleton:Skeleton;
    public var state:AnimationState;

    public function GSpine(p_node:GNode) {
        super(p_node);
    }

    override public function update(p_deltaTime:Number, p_invalidateTransform:Boolean, p_invalidateColor:Boolean):void {
        state.update(p_deltaTime/1000);
        state.apply(skeleton);
        skeleton.updateWorldTransform();
    }

    override public function render(p_context:GContext, p_camera:GCamera, p_maskRect:Rectangle):void {
        var rotate:Boolean = (cNode.cTransform.nWorldRotation != 0);
        var cos:Number = Math.cos(cNode.cTransform.nWorldRotation);
        var sin:Number = Math.sin(cNode.cTransform.nWorldRotation);

        var drawOrder:Vector.<Slot> = skeleton.drawOrder;
        for (var i:int = 0, n:int = drawOrder.length; i < n; i++) {
            var slot:Slot = drawOrder[i];
            var regionAttachment:RegionAttachment = slot.attachment as RegionAttachment;
            if (regionAttachment != null) {
                var bone:Bone = slot.bone;
                var sx:Number = cNode.cTransform.nWorldScaleX;
                var sy:Number = cNode.cTransform.nWorldScaleY;
                var tx:Number = bone.worldX + regionAttachment.x * bone.m00 + regionAttachment.y * bone.m01;
                var ty:Number = bone.worldY + regionAttachment.x * bone.m10 + regionAttachment.y * bone.m11;
                var tr:Number = -(bone.worldRotation + regionAttachment.rotation)*Math.PI/180;
                var tsx:Number = bone.worldScaleX + regionAttachment.scaleX - 1;
                var tsy:Number = bone.worldScaleY + regionAttachment.scaleY - 1;

                if (rotate) {
                    var tx2:Number = tx;
                    tx = tx*cos - ty*sin;
                    ty = tx2*sin + ty*cos;
                }

                p_context.draw(regionAttachment.rendererObject as GTexture, tx*sx+cNode.cTransform.nWorldX, ty*sy+cNode.cTransform.nWorldY, tsx*sx, tsy*sy, tr+cNode.cTransform.nWorldRotation);
            }
        }
    }
}
}
