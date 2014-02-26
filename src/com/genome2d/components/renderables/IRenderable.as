package com.genome2d.components.renderables {

import com.genome2d.context.GContextCamera;

import flash.geom.Rectangle;

public interface IRenderable {
    function render(p_camera:GContextCamera, p_useMatrix:Boolean):void;

    function getBounds(p_target:Rectangle = null):Rectangle;
}
}