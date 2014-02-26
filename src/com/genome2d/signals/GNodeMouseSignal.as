package com.genome2d.signals {
import com.genome2d.node.GNode;
public class GNodeMouseSignal {
    public var target:GNode;
    public var dispatcher:GNode;
    public var type:String;

    public var localX:Number;
    public var localY:Number;

    public function GNodeMouseSignal(p_type:String, p_target:GNode, p_dispatcher:GNode, p_localX:Number, p_localY:Number, p_contextSignal:GMouseSignal) {
        type = p_type;
        target = p_target;
        dispatcher = p_dispatcher;

        localX = p_localX;
        localY = p_localY;
    }
}
}