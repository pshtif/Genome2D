package com.genome2d.postprocesses {

import com.genome2d.Genome2D;
import com.genome2d.context.IContext;
import com.genome2d.context.GContextCamera;
import flash.geom.Matrix3D;
import com.genome2d.textures.GTextureFilteringType;
import com.genome2d.textures.factories.GTextureFactory;
import com.genome2d.node.GNode;
import flash.geom.Rectangle;
import com.genome2d.textures.GTexture;
import com.genome2d.context.filters.GFilter;
public class GPostProcess {
    private var g2d_passes:int = 1;
    public function getPassCount():int {
        return g2d_passes;
    }

    private var g2d_passFilters:Vector.<GFilter>;
    private var g2d_passTextures:Vector.<GTexture>;
    private var g2d_definedBounds:Rectangle;
    private var g2d_activeBounds:Rectangle;

    private var g2d_leftMargin:int = 0;
    private var g2d_rightMargin:int = 0;
    private var g2d_topMargin:int = 0;
    private var g2d_bottomMargin:int = 0;

    private var g2d_matrix:Matrix3D;

    static private var g2d_count:int = 0;
    private var g2d_id:String;
    public function GPostProcess(p_passes:int = 1, p_filters:Vector.<GFilter> = null) {
        g2d_id = String(g2d_count++);
        if (p_passes<1) throw "There are no passes";

        g2d_passes = p_passes;
        g2d_matrix = new Matrix3D();

        g2d_passFilters = p_filters;
        g2d_passTextures = new Vector.<GTexture>();
        for (var i:int = 0; i<g2d_passes; ++i) {
            g2d_passTextures.push(null);
        }
        createPassTextures();
    }

    public function setBounds(p_bounds:Rectangle):void {
        g2d_definedBounds = p_bounds;
    }

    public function setMargins(p_leftMargin:int = 0, p_rightMargin:int = 0, p_topMargin:int = 0, p_bottomMargin:int = 0):void {
        g2d_leftMargin = p_leftMargin;
        g2d_rightMargin = p_rightMargin;
        g2d_topMargin = p_topMargin;
        g2d_bottomMargin = p_bottomMargin;
    }

    public function render(p_parentTransformUpdate:Boolean, p_parentColorUpdate:Boolean, p_camera:GContextCamera, p_node:GNode, p_bounds:Rectangle = null, p_source:GTexture = null, p_target:GTexture = null):void {
        var bounds:Rectangle = p_bounds;
        if (bounds == null) bounds = (g2d_definedBounds != null) ? g2d_definedBounds : p_node.getBounds(null, g2d_activeBounds);

        // Invalid bounds
        if (bounds.x >= 4096) return;

        updatePassTextures(bounds);

        var context:IContext = Genome2D.getInstance().getContext();

        if (p_source == null) {
            g2d_matrix.identity();
            g2d_matrix.prependTranslation(-bounds.x+g2d_leftMargin, -bounds.y+g2d_topMargin, 0);
            context.setRenderTarget(g2d_passTextures[0], g2d_matrix);
            p_node.render(true, true, p_camera, false, false);
        }

        var zero:GTexture = g2d_passTextures[0];
        if (p_source != null) g2d_passTextures[0] = p_source;

        for (var i:int = 1; i<g2d_passes; ++i) {
            context.setRenderTarget(g2d_passTextures[i]);
            context.draw(g2d_passTextures[i-1], 0, 0, 1, 1, 0, 1, 1, 1, 1, 1, g2d_passFilters[i-1]);
        }

        context.setRenderTarget(p_target);
        if (p_target == null) {
            context.setCamera(p_camera);
            context.draw(g2d_passTextures[g2d_passes-1], bounds.x-g2d_leftMargin, bounds.y-g2d_topMargin, 1, 1, 0, 1, 1, 1, 1, 1, g2d_passFilters[g2d_passes-1]);
        } else {
            context.draw(g2d_passTextures[g2d_passes-1], 0, 0, 1, 1, 0, 1, 1, 1, 1, 1, g2d_passFilters[g2d_passes-1]);
        }
        g2d_passTextures[0] = zero;
    }

    public function getPassTexture(p_pass:int):GTexture {
        return g2d_passTextures[p_pass];
    }

    public function getPassFilter(p_pass:int):GFilter {
        return g2d_passFilters[p_pass];
    }

    private function updatePassTextures(p_bounds:Rectangle):void {
        var w:int = (p_bounds.width + g2d_leftMargin + g2d_rightMargin);
        var h:int = (p_bounds.height + g2d_topMargin + g2d_bottomMargin);
        if (g2d_passTextures[0].width != w || g2d_passTextures[0].height != h) {
            var i:int = g2d_passTextures.length-1;
            while (i>=0) {
                var texture:GTexture = g2d_passTextures[i];
                texture.setRegion(new Rectangle(0, 0, w, h));
                texture.pivotX = -texture.width/2;
                texture.pivotY = -texture.height/2;
                texture.invalidateNativeTexture(true);
                i--;
            }
        }
    }

    private function createPassTextures():void {
        for (var i:int = 0; i<g2d_passes; ++i) {
            var texture:GTexture = GTextureFactory.createRenderTexture("g2d_pp_"+g2d_id+"_"+i, 2, 2);
            texture.setFilteringType(GTextureFilteringType.NEAREST);
            texture.pivotX = -texture.width/2;
            texture.pivotY = -texture.height/2;
            g2d_passTextures[i] = texture;
        }
    }

    public function dispose():void {
        var i:int = g2d_passTextures.length-1;
        while (i>=0) {
            g2d_passTextures[i].dispose();
            i--;
        }
    }
}
}