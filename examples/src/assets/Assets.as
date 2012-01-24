package assets
{
	import com.flashcore.g2d.textures.G2DTexture;
	import com.flashcore.g2d.textures.G2DTextureAtlas;
	
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
		
	
		static public var mineTextureAtlas:G2DTextureAtlas;
		static public var ninjaTextureAtlas:G2DTextureAtlas;
		static public var explosionTextureAtlas:G2DTexture;
		
		static public var crateTexture:G2DTexture;
		static public var whiteTexture:G2DTexture;
		static public var particleTexture:G2DTexture;
		
		static public var customTexture:G2DTexture;
		
		static public function init():void {
			mineTextureAtlas = G2DTextureAtlas.createFromBitmapDataAndXML("mine", (new MinesGFX()).bitmapData, XML(new MinesXML()));
			ninjaTextureAtlas = G2DTextureAtlas.createFromBitmapDataAndXML("ninja", (new NinjaGFX()).bitmapData, XML(new NinjaXML()));

			crateTexture = G2DTexture.createFromBitmapData("crate", (new CrateGFX()).bitmapData);
			particleTexture = G2DTexture.createFromBitmapData("particle", new ParticleGFX().bitmapData);
			
			var rect:BitmapData = new BitmapData(16, 16, false, 0xFFFFFF);
			whiteTexture = G2DTexture.createFromBitmapData("white", rect);
			
			customTexture = G2DTexture.createFromBitmapData("custom", new BitmapData(256, 256, true, 0xFFFFFFFF));
		}
	}
}