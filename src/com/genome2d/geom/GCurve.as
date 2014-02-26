package com.genome2d.geom {

public class GCurve {
    public var start:Number;

    private var g2d_segments:Vector.<Segment>;
    private var g2d_pathLength:int;
    private var g2d_totalStrength:Number;


    public function GCurve(p_start:Number = 0) {
        start = p_start;
        g2d_segments = new Vector.<Segment>();
        g2d_pathLength = 0;
        g2d_totalStrength = 0;
    }

    private function addSegment (p_segment:Segment):void {
        g2d_segments.push(p_segment);
        g2d_totalStrength += p_segment.strength;
        g2d_pathLength++;
    }

    public function clear():void {
        g2d_pathLength = 0;
        g2d_segments = new Vector.<Segment>();
        g2d_totalStrength = 0;
    }

    public function line(p_end:Number, p_strength:Number = 1):GCurve {
        addSegment(new LinearSegment(p_end, p_strength));

        return this;
    }

    public function getEnd():Number {
        return (g2d_pathLength>0) ? g2d_segments[g2d_pathLength-1].end : NaN;
    }

    public function calculate(k:Number):Number {
        if (g2d_pathLength == 0) {
            return start;
        } else if (g2d_pathLength == 1) {
            return g2d_segments[0].calculate(start, k);
        } else {
            var ratio:Number = k * g2d_totalStrength;
            var lastEnd:Number = start;

            for (var i:int = 0; i<g2d_pathLength; ++i) {
                var path:Segment = g2d_segments[i];
                if (ratio > path.strength) {
                    ratio -= path.strength;
                    lastEnd = path.end;
                } else {
                    return path.calculate(lastEnd, ratio / path.strength);
                }
            }
        }

        return 0;
    }

    static public function createLine(p_end:Number, p_strength:Number = 1):GCurve {
        return new GCurve().line(p_end, p_strength);
    }

    public function quadraticBezier(p_end:Number, p_control:Number, p_strength:Number = 1):GCurve {
        addSegment(new QuadraticBezierSegment(p_end, p_strength, p_control));
        return this;
    }

    public function cubicBezier(p_end:Number, p_control1:Number, p_control2:Number, p_strength:Number = 1):GCurve {
        addSegment(new CubicBezierSegment(p_end, p_strength, p_control1, p_control2));
        return this;
    }
}
}

class Segment {
    public var end:Number;
    public var strength:Number;

    public function Segment(p_end:Number, p_strength:Number) {
        end = p_end;
        strength = p_strength;
    }

    public function calculate (p_start:Number, p_d:Number):Number {
        return NaN;
    }
}

class LinearSegment extends Segment {
    public function LinearSegment(p_end:Number, p_strength:Number) {
        super (p_end, p_strength);
    }

    override public function calculate (p_start:Number, p_d:Number):Number {
        return p_start + p_d * (end - p_start);
    }
}

class QuadraticBezierSegment extends Segment {
    public var control:Number;

    public function QuadraticBezierSegment(p_end:Number, p_strength:Number, p_control:Number) {
        super(p_end, p_strength);

        control = p_control;
    }


    override public function calculate (p_start:Number, p_d:Number):Number {
        var inv:Number = (1 - p_d);
        return inv * inv * p_start + 2 * inv * p_d * control + p_d * p_d * end;
    }
}

class CubicBezierSegment extends Segment {

    public var control1:Number;
    public var control2:Number;

    public function CubicBezierSegment(p_end:Number, p_strength:Number, p_control1:Number, p_control2:Number) {
        super(p_end, p_strength);

        control1 = p_control1;
        control2 = p_control2;
    }


    override public function calculate (p_start:Number, p_d:Number):Number {
        var inv:Number = (1 - p_d);
        var inv2:Number = inv*inv;
        var d2:Number = p_d*p_d;
        return inv2 * inv * p_start + 3 * inv2 * p_d * control1 + 3 * inv * d2 * control2 + d2 * p_d * end;
    }
}