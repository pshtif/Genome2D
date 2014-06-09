/**
 * Created by sHTiF on 27.2.2014.
 */
package com.genome2d.assets {
import com.genome2d.assets.GImageAsset;

import org.osflash.signals.Signal;

public class GAssetManager {
    protected var g2d_assetsQueue:Vector.<GAsset>;
    protected var g2d_loading:Boolean;
    protected var g2d_assets:Dictionary;

    public var onLoaded:Signal;

    public function GAssetManager() {
        g2d_assetsQueue = new Vector.<GAsset>();
        g2d_assets = new Dictionary();

        onLoaded = new Signal();
    }

    public function getAssetById(p_id:String):GAsset {
        return g2d_assets[p_id];
    }

    public function getXmlAssetById(p_id:String):GXmlAsset {
        return g2d_assets[p_id] as GXmlAsset;
    }

    public function getImageAssetById(p_id:String):GImageAsset {
        return g2d_assets[p_id] as GImageAsset;
    }

    public function add(p_asset:GAsset):void {
        g2d_assetsQueue.push(p_asset);
    }

    public function load():void {
        if (g2d_loading) return;
        g2d_loadNext();
    }

    private function g2d_loadNext():void {
        if (g2d_assetsQueue.length==0) {
            g2d_loading = false;
            onLoaded.dispatch();
        } else {
            g2d_loading = true;
            var asset:GAsset = g2d_assetsQueue.shift();
            asset.onLoaded.addOnce(g2d_hasAssetLoaded);
            asset.load();
        }
    }

    private function g2d_hasAssetLoaded(p_asset:GAsset):void {
        g2d_assets[p_asset.id] = p_asset;
        g2d_loadNext();
    }
}
}
