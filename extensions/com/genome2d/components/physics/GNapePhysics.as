/**
 * Genome2D - 2D games engine based on Molehill API
 *
 * Author: Peter "sHTiF" Stefcek
 *
 * License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)NNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *
 * GNapePhysics
 * Component to encapsulate Nape physics
 */
package com.genome2d.components.physics {
import com.genome2d.components.GComponent;
import com.genome2d.node.GNode;

import nape.geom.Vec2;

import nape.space.Space;

public class GNapePhysics extends GComponent {
    public var space:Space;

    public function GNapePhysics(p_node:GNode) {
        super(p_node);

        space = new Space(Vec2.weak(0,600));
        node.core.onUpdate.add(updateHandler);
    }

    private function updateHandler(p_deltaTime:Number):void {
        if (p_deltaTime>0) space.step(p_deltaTime/1000);
    }
}
}
