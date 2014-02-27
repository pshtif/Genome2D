/**
 * Created by sHTiF on 27.2.2014.
 */
package com.genome2d.assets {
import flash.display.Loader;
import flash.events.Event;
import flash.net.URLRequest;

public class GImageAsset extends GAsset {
    public var g2d_nativeImage:Loader;

    public function GImageAsset(p_id:String, p_url:String) {
    super(p_id, p_url);
}

    override public function load(p_url:String = null):void {
        super.load(p_url);

        g2d_nativeImage = new Loader();
        g2d_nativeImage.contentLoaderInfo.addEventListener(Event.COMPLETE, loadHandler);
        g2d_nativeImage.load(new URLRequest(g2d_url));
    }

    private function loadHandler(event:Event):void {
        onLoaded.dispatch(this);
    }
}
}
