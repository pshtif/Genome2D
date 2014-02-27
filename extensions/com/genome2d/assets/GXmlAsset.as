/**
 * Created by sHTiF on 27.2.2014.
 */
package com.genome2d.assets {
import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLRequest;

public class GXmlAsset extends GAsset {
    public var xml:XML;

    public function GXmlAsset(p_id:String, p_url:String) {
    super(p_id, p_url);
}

    override public function load(p_url:String = null):void {
        super.load(p_url);

        var urlLoader:URLLoader = new URLLoader();
        urlLoader.addEventListener(Event.COMPLETE, hasLoaded);
        urlLoader.load(new URLRequest(g2d_url));
    }

    private function hasLoaded(p_event:Event):void {
        xml = XML(p_event.target.data);
        onLoaded.dispatch(this);
    }
}
}
