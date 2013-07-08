package mp4.boxes.impl;
import flash.Vector;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class SampleDependencyBox extends FullBox
{

	private var dependencyCount : Vector<Int>;
	private var relativeSampleNumber : Vector<Vector<Int>>;

	public function new() 
	{
		super("Sample Dependency Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		var sampleCount : Int = cast(parent.getChild(BoxTypes.SAMPLE_SIZE_BOX), SampleSizeBox).getSampleCount();

		for (i in 0...sampleCount)
		{
			dependencyCount[i] = input.readBytes(2);
			for (j in 0...dependencyCount[i])
			{
				relativeSampleNumber[i][j] = input.readBytes(2);
			}
			left -= (dependencyCount[i]+1)*2;
		}
	}

	/**
	 * The dependency count is an integer that counts the number of samples
	 * in the source track on which this switching sample directly depends.
	 *
	 * @return all dependency counts
	 */
	public function getDependencyCount() : Vector<Int>
	{
		return dependencyCount;
	}

	/**
	 * The relative sample number is an integer that identifies a sample in
	 * the source track. The relative sample numbers are encoded as follows.
	 * If there is a sample in the source track with the same decoding time,
	 * it has a relative sample number of 0. Whether or not this sample
	 * exists, the sample in the source track which immediately precedes the
	 * decoding time of the switching sample has relative sample number –1,
	 * the sample before that –2, and so on. Similarly, the sample in the
	 * source track which immediately follows the decoding time of the
	 * switching sample has relative sample number +1, the sample after that
	 * +2, and so on.
	 *
	 * @return all relative sample numbers
	 */
	public function getRelativeSampleNumber() : Vector<Vector<Int>>
	{
		return relativeSampleNumber;
	}
	
}