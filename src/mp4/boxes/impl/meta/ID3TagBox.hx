package mp4.boxes.impl.meta;
import haxe.io.BytesData;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class ID3TagBox extends FullBox
{

	private var language : String;
	private var id3Data : BytesData;

	public function new()
	{
		super("ID3 Tag Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		//1 bit padding, 5*3 bits language code (ISO-639-2/T)
		var l : Int = input.readBytes(2);
		/*
		char[] c = new char[3];
		c[0] = (char) (((l>>10)&31)+0x60);
		c[1] = (char) (((l>>5)&31)+0x60);
		c[2] = (char) ((l&31)+0x60);
		*/
		language = String.fromCharCode(((l >> 10) & 31) + 0x60)
					+ String.fromCharCode(((l >> 5) & 31) + 0x60)
					+ String.fromCharCode((l & 31) + 0x60);
		left -= 2;

		id3Data = new BytesData();
		id3Data.length = left;
		input.readBytes_(id3Data);
		left = 0;
	}

	public function getID3Data() : BytesData
	{
		return id3Data;
	}

	public function getLanguage() : String
	{
		return language;
	}
	
}