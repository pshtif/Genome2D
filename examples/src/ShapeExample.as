package
{
	import com.genome2d.components.renderables.GShape;
	import com.genome2d.core.GConfig;
	import com.genome2d.core.GNodeFactory;
	import com.genome2d.core.Genome2D;
	import com.genome2d.textures.GTexture;
	import com.genome2d.textures.factories.GTextureFactory;
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	[SWF(width="800", height="600", backgroundColor="#000000", frameRate="60")]
	public class ShapeExample extends Sprite
	{
		[Embed(source = "../assets/crate.jpg")]
		static private const CrateGFX:Class;
		
		
		
		public function ShapeExample() {
			// Hook up a callback once initialization is done
			Genome2D.getInstance().onInitialized.addOnce(onGenome2DInitialized);
			
			// Initialize Genome2D config, we need to specify area where Genome2D will be rendered
			// if we want the whole stage simply put the stage size there
			var config:GConfig = new GConfig(new Rectangle(0,0,stage.stageWidth, stage.stageHeight));
			
			// Initiaiize Genome2D
			Genome2D.getInstance().init(stage, config);
		}
		
		// Initialization callback
		protected function onGenome2DInitialized():void {
			// Create a red texture
			GTextureFactory.createFromColor("red", 0xFF0000, 32, 32);
			// Create crate texture from embedded asset to showcase textured shape
			GTextureFactory.createFromAsset("crate", CrateGFX);
			
			createTriangle();
			createHexagon();
		}
		
		protected function createTriangle():void {
			// Create a node with shape component
			var shape:GShape = GNodeFactory.createNodeWithComponent(GShape) as GShape;
			// Set the shape texture to red
			shape.setTexture(GTexture.getTextureById("red"));
			
			// Initialize vertices
			var vertices:Vector.<Number> = new <Number>[-100,100,0,-100,100,100];
			// Initialize texture coordinates
			var uvs:Vector.<Number> = new <Number>[-1,1,.5,-1,1,1];
			// Initialize shape with our vertices and coords
			shape.init(vertices, uvs);
			
			shape.node.transform.setPosition(200,300);
			// Add shape to the render list
			Genome2D.getInstance().root.addChild(shape.node);
		}
		
		protected function createHexagon():void {
			// Create a node with shape component
			var shape:GShape = GNodeFactory.createNodeWithComponent(GShape) as GShape;
			// Set the shape texture to red
			shape.setTexture(GTexture.getTextureById("crate"));
			
			// Initialize vertices
			// As you can see every triangle needs to be specified instead of just a polygon, this is because GPU can only handle triangles.
			var vertices:Vector.<Number> = new <Number>[-100,50,-100,-50,0,0, 
														-100,-50,-50,-100,0,0,
														-50,-100,50,-100,0,0,
														50,-100,100,-50,0,0,
														100,-50,100,50,0,0,
														100,50,50,100,0,0,
														50,100,-50,100,0,0,
													    -50,100,-100,50,0,0];
			// Initialize texture coordinates
			// Each pair refers to UV coordinates of the same index vertex pair
			var uvs:Vector.<Number> = new <Number>[0,0.75,0,0.25,0.5,0.5,
												   0,0.25,0.25,0,0.5,0.5,
												   0.25,0,0.75,0,0.5,0.5,
												   0.75,0,1,0.25,0.5,0.5,
												   1,0.25,1,0.75,0.5,0.5,
												   1,0.75,0.75,1,0.5,0.5,
												   0.75,1,0.25,1,0.5,0.5,
												   0.25,1,0,0.75,0.5,0.5];
			// Initialize shape with our vertices and coords
			shape.init(vertices, uvs);			

			shape.node.transform.setPosition(600,300);
			// Add shape to the render list
			Genome2D.getInstance().root.addChild(shape.node);
		}
	}
}