package mp4.boxes.impl;
import flash.Vector;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class SampleToGroupBox extends FullBox
{

	private var groupingType : Int;
	private var sampleCount : Vector<Int>;
	private var groupDescriptionIndex : Vector<Int>;

	public function new()
	{
		super("Sample To Group Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		groupingType = input.readBytes(4);
		var entryCount : Int = input.readBytes(4);
		sampleCount = new Vector<Int>(entryCount);
		groupDescriptionIndex = new Vector<Int>(entryCount);

		for (i in 0...entryCount)
		{
			sampleCount[i] = input.readBytes(4);
			groupDescriptionIndex[i] = input.readBytes(4);
		}

		left -= (entryCount+1)*8;
	}

	/**
	 * The grouping type is an integer that identifies the type (i.e. criterion
	 * used to form the sample groups) of the sample grouping and links it to
	 * its sample group description table with the same value for grouping type.
	 * At most one occurrence of this box with the same value for 'grouping
	 * type' shall exist for a track.
	 */
	public function getGroupingType() : Int
	{
		return groupingType;
	}

	/**
	 * The sample count is an integer that gives the number of consecutive
	 * samples with the same sample group descriptor for a specific entry. If
	 * the sum of the sample count in this box is less than the total sample
	 * count, then the reader should effectively extend it with an entry that
	 * associates the remaining samples with no group.
	 * It is an error for the total in this box to be greater than the sample
	 * count documented elsewhere, and the reader behaviour would then be
	 * undefined.
	 */
	public function getSampleCount() : Vector<Int>
	{
		return sampleCount;
	}

	/**
	 * The group description index is an integer that gives the index of the
	 * sample group entry which describes the samples in this group for a
	 * specific entry. The index ranges from 1 to the number of sample group
	 * entries in the SampleGroupDescriptionBox, or takes the value 0 to
	 * indicate that this sample is a member of no group of this type.
	 */
	public function getGroupDescriptionIndex() : Vector<Int>
	{
		return groupDescriptionIndex;
	}
	
}