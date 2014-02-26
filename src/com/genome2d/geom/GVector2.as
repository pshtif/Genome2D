package com.genome2d.geom {

public class GVector2 {
    public var x:Number;
    public var y:Number;

    public function get length():Number {
        return Math.sqrt(x * x + y * y);
    }

    public function GVector2(p_x:Number = 0, p_y:Number = 0 ) {
        x = p_x;
        y = p_y;
    }

    public function addEq(p_vector:GVector2):void {
        x += p_vector.x;
        y += p_vector.y;
    }

    public function subEq(p_vector:GVector2):void {
        x -= p_vector.x;
        y -= p_vector.y;
    }

    public function mulEq(p_s:Number):void {
        x *= p_s;
        y *= p_s;
    }

    public function dot(p_vector:GVector2):Number {
        return x * p_vector.x + y * p_vector.y;
    }

    public function normalize():GVector2 {
        var l:Number = Math.sqrt(x * x + y * y);
        if(l != 0) {
            x /= l;
            y /= l;
        }
        return this;
    }

    public function toString():String {
        return "["+x+","+y+"]";
    }
}
}