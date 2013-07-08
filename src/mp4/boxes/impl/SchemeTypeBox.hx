package mp4.boxes.impl;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class SchemeTypeBox extends FullBox
{

	private var schemeType : Int;
	private var schemeVersion : Int;
	private var schemeURI : String;

	public function new()
	{
		super("Scheme Type Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		schemeType = input.readBytes(4);
		schemeVersion = input.readBytes(4);
		left -= 8;

		if ((flags & 1) == 1)
		{
			schemeURI = input.readUTFString(left, MP4InputStream.UTF8);
			left -= schemeURI.length+1;
		}
		else schemeURI = null;
	}

	/**
	 * The scheme type is the code defining the protection scheme.
	 *
	 * @return the scheme type
	 */
	public function getSchemeType() : Int
	{
		return schemeType;
	}

	/**
	 * The scheme version is the version of the scheme used to create the
	 * content.
	 *
	 * @return the scheme version
	 */
	public function getSchemeVersion() : Int
	{
		return schemeVersion;
	}

	/**
	 * The optional scheme URI allows for the option of directing the user to a
	 * web-page if they do not have the scheme installed on their system. It is
	 * an absolute URI.
	 * If the scheme URI is not present, this method returns null.
	 *
	 * @return the scheme URI or null, if no URI is present
	 */
	public function getSchemeURI() : String
	{
		return schemeURI;
	}
	
}