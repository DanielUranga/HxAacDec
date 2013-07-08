package mp4.boxes.impl;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class CopyrightBox extends FullBox
{

	private var languageCode : String;
	private var notice : String;

	public function new()
	{
		super("Copyright Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		//1 bit padding, 5*3 bits language code (ISO-639-2/T)
		var l : Int = input.readBytes(2);
		var c1 : Int = ((l>>10)&31)+0x60;
		var c2 : Int = ((l>>5)&31)+0x60;
		var c3 : Int = (l&31)+0x60;
		languageCode = String.fromCharCode(c1) + String.fromCharCode(c2) + String.fromCharCode(c3);

		notice = input.readUTFString1(left); //UTF8 or UTF16

		left -= 3+notice.length;
	}

	/**
	 * The language code for the following text. See ISO 639-2/T for the set of
	 * three character codes.
	 */
	public function getLanguageCode() : String
	{
		return languageCode;
	}

	/**
	 * The copyright notice.
	 */
	public function getNotice() : String
	{
		return notice;
	}
	
}