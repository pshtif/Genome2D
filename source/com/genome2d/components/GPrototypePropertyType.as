package com.genome2d.components
{
	public class GPrototypePropertyType
	{
		static public const UNKNOWN:String = "unknown";
		static public const NUMBER:String = "number";
		static public const INT:String = "int";
		static public const BOOLEAN:String = "boolean";
		static public const OBJECT:String = "object";
		static public const STRING:String = "string";
		
		static public function getPrototypeType(p_value:*):String {
			var type:String = typeof(p_value);

			switch (type) {
				case "number":
					return NUMBER;
				case "boolean":
					return BOOLEAN;
				case "string":
					return STRING;					
				case "object":
					return OBJECT;
			}
	
			return "unknown";
		}
	}
}