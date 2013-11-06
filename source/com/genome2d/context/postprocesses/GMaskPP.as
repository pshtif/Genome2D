/**
 * Author: Peter "sHTiF" Stefcek
 * Date: 31.7.2013
 * Time: 22:12
 */
package com.genome2d.context.postprocesses {
import com.genome2d.components.GCamera;
import com.genome2d.context.GContext;
import com.genome2d.context.filters.GMaskPassFilter;
import com.genome2d.core.GNode;
import com.genome2d.core.Genome2D;
import com.genome2d.g2d;
import com.genome2d.textures.GTexture;

import flash.geom.Rectangle;

use namespace g2d;

public class GMaskPP extends GPostProcess {
    protected var _cMask:GNode;
    public function get mask():GNode {
        return _cMask;
    }
    public function set mask(p_value:GNode):void {
        if (_cMask != null) _cMask.iUsedAsPPMask--;
        _cMask = p_value;
        _cMask.iUsedAsPPMask++;
    }

    protected var _cMaskFilter:GMaskPassFilter;

    public function GMaskPP() {
        super(2);

        _cMaskFilter = new GMaskPassFilter(_aPassTextures[1]);
    }

    override public function render(p_context:GContext, p_camera:GCamera, p_maskRect:Rectangle, p_node:GNode, p_bounds:Rectangle = null, p_source:GTexture = null, p_target:GTexture = null):void {
        var bounds:Rectangle = p_bounds;
        if (bounds == null) bounds = (_rDefinedBounds) ? _rDefinedBounds : p_node.getWorldBounds(_rActiveBounds);

        // Invalid bounds
        if (bounds.x == Number.MAX_VALUE) return;

        updatePassTextures(bounds);

        if (p_source == null) {
            _cMatrix.identity();
            _cMatrix.prependTranslation(-bounds.x+_iLeftMargin, -bounds.y+_iTopMargin, 0);
            p_context.setRenderTarget(_aPassTextures[0], _cMatrix);

            p_context.setCamera(Genome2D.getInstance().defaultCamera);
            p_node.render(p_context, true, true, p_camera, _aPassTextures[0].region, false);
        }

        var zero:GTexture = _aPassTextures[0];
        if (p_source) _aPassTextures[0] = p_source;
        var filter:GMaskPassFilter = null;

        if (_cMask != null) {
            p_context.setRenderTarget(_aPassTextures[1]);
            var z:int = _cMask.iUsedAsPPMask;
            _cMask.iUsedAsPPMask = 0;
            _cMask.render(p_context, true, true, p_camera, _aPassTextures[1].region, false);
            _cMask.iUsedAsPPMask = z;
            filter = _cMaskFilter;
        }

        if (p_target == null) {
            p_context.setRenderTarget(null);
            p_context.setCamera(p_camera);
            p_context.draw(_aPassTextures[0], bounds.x-_iLeftMargin, bounds.y-_iTopMargin, 1, 1, 0, 1, 1, 1, 1, 1, p_maskRect, filter);
        } else {
            p_context.setRenderTarget(p_target);
            p_context.draw(_aPassTextures[0], 0, 0, 1, 1, 0, 1, 1, 1, 1, 1, p_target.region, filter);
        }
        _aPassTextures[0] = zero;
    }
}
}
