package assets
{
	import com.genome2d.textures.GTexture;
	import com.genome2d.textures.GTextureAtlas;
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
		static public const MinesXML:Class;
		
		[Embed(source = "../assets/mines.png")]
		static public const MinesGFX:Class;
		
		[Embed(source = "../assets/ninja.xml", mimeType = "application/octet-stream")]
		static public const NinjaXML:Class;
		
		[Embed(source = "../assets/ninja.png")]
		static public const NinjaGFX:Class;
		
		[Embed(source = "../assets/crate.jpg")]
		static public const CrateGFX:Class;
		
		[Embed(source = "../assets/particle32.png")]
		static public const ParticleGFX:Class;
		
	
		static public var mineTextureAtlas:GTextureAtlas;
		static public var ninjaTextureAtlas:GTextureAtlas;
		static public var explosionTextureAtlas:GTexture;
		
		static public var crateTexture:GTexture;
		static public var whiteTexture:GTexture;
		static public var particleTexture:GTexture;
		
		static public var customTexture:GTexture;
		
		static public function init():void {
			mineTextureAtlas = GTextureAtlasFactory.createFromBitmapDataAndXML("mine", (new MinesGFX()).bitmapData, XML(new MinesXML()));
			ninjaTextureAtlas = GTextureAtlasFactory.createFromBitmapDataAndXML("ninja", (new NinjaGFX()).bitmapData, XML(new NinjaXML()));

			crateTexture = GTextureFactory.createFromBitmapData("crate", (new CrateGFX()).bitmapData);
			particleTexture = GTextureFactory.createFromBitmapData("particle", new ParticleGFX().bitmapData);
			
			var rect:BitmapData = new BitmapData(16, 16, false, 0xFFFFFF);
			whiteTexture = GTextureFactory.createFromBitmapData("white", rect);
			
			customTexture = GTextureFactory.createFromBitmapData("custom", new BitmapData(256, 256, true, 0xFFFFFFFF));
		}
	}
}