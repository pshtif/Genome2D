/**
 * Created with IntelliJ IDEA.
 * User: sHTiF
 * Date: 25.5.2013
 * Time: 14:31
 * To change this template use File | Settings | File Templates.
 */
package com.genome2d.context.filters {
import com.genome2d.g2d;
import com.genome2d.textures.GTexture;

import flash.display3D.Context3D;

use namespace g2d;

public class GMaskPassFilter extends GFilter {
    protected var _cMaskTexture:GTexture;

    public function GMaskPassFilter(p_maskTexture:GTexture) {
        super();

        _cMaskTexture = p_maskTexture;

        fragmentCode =
                "tex ft1, v0, fs1 <2d,clamp,linear,mipnone>	\n" +
                "mul ft0, ft0, ft1.wwww                     \n";
    }

    override public function bind(p_context:Context3D, p_texture:GTexture):void {
        super.bind(p_context, p_texture);
        if (_cMaskTexture == null) throw Error("There is no mask set.");
        p_context.setTextureAt(1, _cMaskTexture.cContextTexture.tTexture);
    }

    override public function clear(p_context:Context3D):void {
        p_context.setTextureAt(1, null);
    }
}
}
