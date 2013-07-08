package mp4.boxes.impl.sampleentries;
import mp4.boxes.BoxImpl;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class SampleEntry extends BoxImpl
{

	private var dataReferenceIndex : Int;

	public function new(name : String)
	{
		super(name);
	}

	override public function decode(input : MP4InputStream)
	{
		//6*8 bits reserved
		input.skipBytes(6);
		dataReferenceIndex = input.readBytes(2);
		left -= 8;
	}

	/**
	 * The data reference index is an integer that contains the index of the
	 * data reference to use to retrieve data associated with samples that use
	 * this sample description. Data references are stored in Data Reference
	 * Boxes. The index ranges from 1 to the number of data references.
	 */
	public function getDataReferenceIndex() : Int
	{
		return dataReferenceIndex;
	}
	
}