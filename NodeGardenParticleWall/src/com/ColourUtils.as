package com
{
	/**
	 * @author Tal
	 */
	public class ColourUtils
	{
		
		/**
		 * combine two colours and return the produced colour
		 * @param	colour1		The first colour
		 * @param	colour2		The second colour
		 */
		public static function combineColours( colour1 : uint, colour2 : uint ) : uint 
		{
			var RGB1:Object = Hex24ToRGB( colour1 );
			var RGB2:Object = Hex24ToRGB( colour2 );
			
			var r : int = RGB1.red + RGB2.red;
			var g : int = RGB1.green + RGB2.green; 
			var b : int = RGB1.blue + RGB2.blue;
			
			return (r<<16)|(g << 8)|b; 
		}
		
		/**
		 * return the strongest colour
		 * @param	colour1		The first colour
		 * @param	colour2		The second colour
		 */
		public static function strongestColour( colour1 : uint, colour2 : uint ) : uint 
		{
			var RGB1:Object = Hex24ToRGB( colour1 );
			var RGB2:Object = Hex24ToRGB( colour2 );
			var winningColour : Object;
			
			var total1 : int =  RGB1.red +  RGB1.green +  RGB1.blue;
			var total2 : int =  RGB2.red +  RGB2.green +  RGB2.blue;
			// return the strongest colour  - one closest to white
			winningColour = ( total1 > total2 )? RGB1 : RGB2;
			return (winningColour.red<<16)|(winningColour.green << 8)|winningColour.blue; 
		}
		
		
		/**
		 * Converts a 24bit Hexidecimal to a red, green, blue Object
		 * 
		 * @param	hex		A 24bit Hexidecimal to convert
		 * @return	Object	An Object containign values for red, green and blue
		 */
		public static function Hex24ToRGB( hex:uint ):Object
		{
			var R:Number = hex >> 16 & 0xFF;
			var G:Number = hex >> 8 & 0xFF;
			var B:Number = hex & 0xFF;
			
			return { red:R, green:G, blue:B };
		}
	}
}
