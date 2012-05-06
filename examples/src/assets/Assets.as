package assets
{
	import com.genome2d.textures.GTexture;
	import com.genome2d.textures.GTextureAtlas;
	import com.genome2d.textures.GTextureFilteringType;
	import com.genome2d.textures.factories.GTextureAtlasFactory;
	import com.genome2d.textures.factories.GTextureFactory;
	
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;

	public class Assets
	{
		[Embed(source = "../assets/mines.xml", mimeType = "application/octet-stream")]
		static private const MinesXML:Class;
		
		[Embed(source = "../assets/mines.png")]
		static private const MinesGFX:Class;
		
		[Embed(source = "../assets/ninja.xml", mimeType = "application/octet-stream")]
		static private const NinjaXML:Class;
		
		[Embed(source = "../assets/ninja.png")]
		static private const NinjaGFX:Class;
		
		[Embed(source = "../assets/crate.jpg")]
		static private const CrateGFX:Class;
		
		[Embed(source = "../assets/silhouette2.png")]
		static private const Silhouette1GFX:Class;
		
		[Embed(source = "../assets/silhouette3.png")]
		static private const Silhouette2GFX:Class;
		
		[Embed(source = "../assets/silhouette4.png")]
		static private const Silhouette3GFX:Class;
		
		[Embed(source = "../assets/particle32.png")]
		static private const ParticleGFX:Class;
		
	
		static public var mineTextureAtlas:GTextureAtlas;
		static public var ninjaTextureAtlas:GTextureAtlas;
		static public var explosionTextureAtlas:GTexture;
		
		static public var crateTexture:GTexture;
		static public var whiteTexture:GTexture;
		static public var particleTexture:GTexture;
		
		static public var silhouette1BitmapData:BitmapData;
		static public var silhouette2BitmapData:BitmapData;
		static public var silhouette3BitmapData:BitmapData;
		
		static public var customTexture:GTexture;
		
		static public function init():void {
			silhouette1BitmapData = (new Silhouette1GFX()).bitmapData;
			silhouette2BitmapData = (new Silhouette2GFX()).bitmapData;
			silhouette3BitmapData = (new Silhouette3GFX()).bitmapData;
			
			mineTextureAtlas = GTextureAtlasFactory.createFromBitmapDataAndXML("mine", (new MinesGFX()).bitmapData, XML(new MinesXML()));
			ninjaTextureAtlas = GTextureAtlasFactory.createFromBitmapDataAndXML("ninja", (new NinjaGFX()).bitmapData, XML(new NinjaXML()));

			crateTexture = GTextureFactory.createFromBitmapData("crate", (new CrateGFX()).bitmapData, false);
			particleTexture = GTextureFactory.createFromBitmapData("particle", new ParticleGFX().bitmapData, true);
			particleTexture.filteringType = GTextureFilteringType.LINEAR;
			whiteTexture = GTextureFactory.createFromColor("white", 0xFFFFFF, 16, 16);
			
			customTexture = GTextureFactory.createFromColor("custom", 0xFFFFFF, 256, 256);
		}
	}
}