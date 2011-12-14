package examples
{
	public class Assets
	{
		[Embed(source = "./assets/mines.xml", mimeType = "application/octet-stream")]
		static public const MinesXML:Class;
		
		[Embed(source = "./assets/mines.png")]
		static public const MinesGFX:Class;
		
		[Embed(source = "./assets/ninja.xml", mimeType = "application/octet-stream")]
		static public const NinjaXML:Class;
		
		[Embed(source = "./assets/ninja.png")]
		static public const NinjaGFX:Class;
		
		[Embed(source = "./assets/crate.jpg")]
		static public const CrateGFX:Class;
		
		[Embed(source = "./assets/ball.png")]
		static public const ParticleGFX:Class;
	}
}