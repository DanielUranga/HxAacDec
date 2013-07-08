package mp4.boxes.impl;
import flash.Vector;
import impl.VectorTools;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class ShadowSyncSampleBox extends FullBox
{

	private var sampleNumbers : Vector<Vector<Int>>;

	public function new()
	{
		super("Shadow Sync Sample Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);
		
		var entryCount : Int = input.readBytes(4);
		//sampleNumbers = new long[entryCount][2];
		sampleNumbers = VectorTools.newMatrixVectorI(entryCount, 2);
		left -= 4;

		for (i in 0...entryCount)
		{
			sampleNumbers[i][0] = input.readBytes(4); //shadowedSampleNumber;
			sampleNumbers[i][1] = input.readBytes(4); //syncSampleNumber;
		}
		left -= entryCount*8;
	}

	/**
	 * A map of sample number pairs:
	 * 0 (shadowed-sample-number): gives the number of a sample for which there
	 * is an alternative sync sample.
	 * 1 (sync-sample-number): gives the number of the alternative sync sample.
	 *
	 * @return the sample number pairs
	 */
	public function getSampleNumbers() : Vector<Vector<Int>>
	{
		return sampleNumbers;
	}
	
}