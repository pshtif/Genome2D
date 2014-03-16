package com.genome2d.geom {

import com.genome2d.geom.GVector2;
import flash.geom.Rectangle;

public class GLine {
    public var start:GVector2;
    public var end:GVector2;
    public var normal:GVector2;
    public var vec:GVector2;
    public var aabb:Rectangle;

    public function GLine(p_start:GVector2, p_end:GVector2) {
        start = p_start;
        end = p_end;
        normal = new GVector2(p_end.y - p_start.y, -p_end.x + p_start.x);
        normal.normalize();
        vec = new GVector2(p_end.x - p_start.x, p_end.y - p_start.y);
        aabb = new Rectangle((start.x<end.x)?start.x:end.x, (start.y<end.y)?start.y:end.y, ((start.x>end.x)?start.x:end.x) - ((start.x<end.x)?start.x:end.x), ((start.y>end.y)?start.y:end.y) - ((start.y<end.y)?start.y:end.y));
    }

    public function side(p_px:Number, p_py:Number):Number {
        var vx:Number = -end.y + start.y;
        var vy:Number =  end.x - start.x;

        var px:Number = p_px - start.x;
        var py:Number = p_py - start.y;

        var dot:Number = vx*px + vy*py;

        return dot;
    }

    public function intersect(p_line:GLine, p_v1seg:Boolean=true, p_v2seg:Boolean=true):GVector2 {
        var d:Number   =  vec.y*p_line.vec.x - vec.x*p_line.vec.y;

        if(d == 0) {
            return null;
        }

        var n_a:Number =   vec.x*(p_line.start.y - start.y) - vec.y*(p_line.start.x - start.x);

        var n_b:Number =   p_line.vec.x*(p_line.start.y - start.y) - p_line.vec.y*(p_line.start.x - start.x);

        var ua:Number = n_a/d;
        var ub:Number = n_b/d;

        if (!p_v1seg && !p_v2seg) {
            return new GVector2(p_line.start.x + (ua * p_line.vec.x), p_line.start.y + (ua * p_line.vec.y));
        }

        if(!p_v1seg && ua >=0 && ua <= 1) {
            return new GVector2(p_line.start.x + (ua * p_line.vec.x), p_line.start.y + (ua * p_line.vec.y));
        }

        if(!p_v2seg && ub >= 0 && ub <= 1) {
            return new GVector2(p_line.start.x + (ua * p_line.vec.x), p_line.start.y + (ua * p_line.vec.y));
        }

        if(ua >=0 && ua <= 1 && ub >= 0 && ub <= 1) {
            return new GVector2(p_line.start.x + (ua * p_line.vec.x), p_line.start.y + (ua * p_line.vec.y));
        }

        return null;
    }

    public function toString():String {
        return start+" : "+end;
    }
}
}