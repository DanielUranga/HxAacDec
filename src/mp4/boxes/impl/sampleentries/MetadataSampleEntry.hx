package mp4.boxes.impl.sampleentries;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class MetadataSampleEntry extends SampleEntry
{

	private var contentEncoding : String;

	public function new(name : String)
	{
		super(name);
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		contentEncoding = input.readUTFString(left, MP4InputStream.UTF8);
		left -= contentEncoding.length+1;
	}

	/**
	 * A string providing a MIME type which identifies the content encoding of
	 * the timed metadata. If not present (an empty string is supplied) the
	 * timed metadata is not encoded.
	 * An example for this field is 'application/zip'.
	 * @return the encoding's MIME-type
	 */
	public function getContentEncoding() : String
	{
		return contentEncoding;
	}
	
}