package mp4.boxes.impl.sampleentries;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class XMLMetadataSampleEntry extends MetadataSampleEntry
{

	private var namespace : String;
	private var schemaLocation : String;

	public function new()
	{
		super("XML Metadata Sample Entry");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		namespace = input.readUTFString(left, MP4InputStream.UTF8);
		schemaLocation = input.readUTFString(left, MP4InputStream.UTF8);

		left = 0;
	}

	/**
	 * Gives the namespace of the schema for the timed XML metadata. This is
	 * needed for identifying the type of metadata, e.g. gBSD or AQoS
	 * (MPEG-21-7) and for decoding using XML aware encoding mechanisms such as
	 * BiM.
	 * @return the namespace
	 */
	public function getNamespace() : String
	{
		return namespace;
	}

	/**
	 * Optionally provides an URL to find the schema corresponding to the
	 * namespace. This is needed for decoding of the timed metadata by XML aware
	 * encoding mechanisms such as BiM.
	 * @return the schema's URL
	 */
	public function getSchemaLocation() : String
	{
		return schemaLocation;
	}
	
}