package mp4.boxes.impl;
import flash.Vector;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class SubSampleInformationBox extends FullBox
{

	private var sampleDelta : Vector<Int>;
	private var subsampleSize : Vector<Vector<Int>>;
	private var subsamplePriority : Vector<Vector<Int>>;
	private var discardable : Vector<Vector<Bool>>;

	public function new()
	{
		super("Sub Sample Information Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		var len : Int = (version==1) ? 4 : 2;
		var entryCount : Int = input.readBytes(4);
		left -= 4;
		sampleDelta = new Vector<Int>(entryCount);
		subsampleSize = new Vector<Vector<Int>>(entryCount);
		subsamplePriority = new Vector<Vector<Int>>(entryCount);
		discardable = new Vector<Vector<Bool>>(entryCount);

		var subsampleCount : Int;
		for (i in 0...entryCount)
		{
			sampleDelta[i] = input.readBytes(4);
			subsampleCount = input.readBytes(2);
			left -= 6;
			subsampleSize[i] = new Vector<Int>(subsampleCount);
			subsamplePriority[i] = new Vector<Int>(subsampleCount);
			discardable[i] = new Vector<Bool>(subsampleCount);

			for (j in 0...subsampleCount)
			{
				subsampleSize[i][j] = input.readBytes(len);
				subsamplePriority[i][j] = input.read();
				discardable[i][j] = (input.read()&1)==1;
				input.skipBytes(4); //reserved
				left -= len+6;
			}
		}
	}

	/**
	 * The sample delta for each entry is an integer that specifies the sample 
	 * number of the sample having sub-sample structure. It is coded as the 
	 * difference between the desired sample number, and the sample number
	 * indicated in the previous entry. If the current entry is the first entry,
	 * the value indicates the sample number of the first sample having
	 * sub-sample information, that is, the value is the difference between the
	 * sample number and zero.
	 *
	 * @return the sample deltas for all entries
	 */
	public function getSampleDelta() : Vector<Int>
	{
		return sampleDelta;
	}

	/**
	 * The subsample size is an integer that specifies the size, in bytes, of a
	 * specific sub-sample in a specific entry.
	 *
	 * @return the sizes of all subsamples
	 */
	public function getSubsampleSize() : Vector<Vector<Int>>
	{
		return subsampleSize;
	}

	/**
	 * The subsample priority is an integer specifying the degradation priority
	 * for a specific sub-sample in a specific entry. Higher values indicate
	 * sub-samples which are important to, and have a greater impact on, the
	 * decoded quality.
	 *
	 * @return all subsample priorities
	 */
	public function getSubsamplePriority() : Vector<Vector<Int>>
	{
		return subsamplePriority;
	}

	/**
	 * If true, the sub-sample is required to decode the current sample, while
	 * false means the sub-sample is not required to decode the current sample 
	 * but may be used for enhancements, e.g., the sub-sample consists of
	 * supplemental enhancement information (SEI) messages.
	 *
	 * @return a list of flags indicating if a specific subsample is discardable
	 */
	public function getDiscardable() : Vector<Vector<Bool>>
	{
		return discardable;
	}
	
}