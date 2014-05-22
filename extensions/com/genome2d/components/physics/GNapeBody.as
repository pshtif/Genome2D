/**
 * Genome2D - 2D games engine based on Molehill API
 *
 * Author: Peter "sHTiF" Stefcek
 *
 * License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)NNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *
 * GNapeBody
 * Component to encapsulate Nape physics bodies
 */
package com.genome2d.components.physics {
import com.genome2d.Genome2D;
import com.genome2d.components.GComponent;
import com.genome2d.node.GNode;

import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;

public class GNapeBody extends GComponent {
    private var body:Body;

    public function set x(p_value:Number):void {
        body.position.x = p_value;
    }

    public function set y(p_value:Number):void {
        body.position.y = p_value;
    }

    public function GNapeBody(p_node:GNode) {
        super(p_node);

        body = new Body(BodyType.DYNAMIC);
        body.shapes.add(new Polygon(Polygon.box(32,32)));
        body.space = (node.core.root.getComponent(GNapePhysics) as GNapePhysics).space;

        node.core.onUpdate.add(updateHandler);
    }

    private function updateHandler(p_deltaTime:Number):void {
        node.transform.x = body.position.x;
        node.transform.y = body.position.y;
        node.transform.rotation = body.rotation;
    }
}
}
