package mp4.boxes.impl;
import flash.Vector;
import mp4.boxes.BoxImpl;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class FileTypeBox extends BoxImpl
{
	
	public static inline var BRAND_ISO_BASE_MEDIA : String = "isom";
	public static inline var BRAND_ISO_BASE_MEDIA_2 : String = "iso2";
	public static inline var BRAND_ISO_BASE_MEDIA_3 : String = "iso3";
	public static inline var BRAND_MP4_1 : String = "mp41";
	public static inline var BRAND_MP4_2 : String = "mp42";
	public static inline var BRAND_MOBILE_MP4 : String = "mmp4";
	public static inline var BRAND_QUICKTIME : String = "qm  ";
	public static inline var BRAND_AVC : String = "avc1";
	public static inline var BRAND_AUDIO : String = "M4A ";
	public static inline var BRAND_AUDIO_2 : String = "M4B ";
	public static inline var BRAND_AUDIO_ENCRYPTED : String = "M4P ";
	public static inline var BRAND_MP7 : String = "mp71";
	private var majorBrand : String;
	private var minorVersion : String;
	private var compatibleBrands : Vector<String>;

	public function new()
	{
		super("File Type Box");
	}

	override public function decode(input : MP4InputStream)
	{
		majorBrand = input.readString(4);
		minorVersion = input.readString(4);
		//trace("brand=" + majorBrand + ", version="+minorVersion);
		left -= 8;
		compatibleBrands = new Vector<String>(Std.int(left / 4));
		for (i in 0...compatibleBrands.length)
		{
			compatibleBrands[i] = input.readString(4);
			left -= 4;
		}
	}

	public function getMajorBrand() : String
	{
		return majorBrand;
	}

	public function getMinorVersion() : String
	{
		return minorVersion;
	}

	public function getCompatibleBrands() : Vector<String>
	{
		return compatibleBrands;
	}
	
}