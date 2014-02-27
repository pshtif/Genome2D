/**
 * Created by sHTiF on 27.2.2014.
 */
package com.genome2d.assets {
import org.osflash.signals.Signal;

public class GAsset {
    protected var g2d_url:String;

    public var onLoaded:Signal;

    protected var g2d_id:String;
    public function get id():String {
        return g2d_id;
    }

    public function GAsset(p_id:String, p_url:String) {
    g2d_id = p_id;
    g2d_url = p_url;

    onLoaded = new Signal();
}

    public function load(p_url:String = null):void {
        if (p_url != null) g2d_url = p_url;
    }
}
}
