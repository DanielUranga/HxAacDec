package mp4.boxes.impl;
import flash.Vector;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class SampleDependencyTypeBox extends FullBox
{

	private var sampleDependsOn : Vector<Int>;
	private var sampleIsDependedOn : Vector<Int>;
	private var sampleHasRedundancy : Vector<Int>;

	public function new()
	{
		super("Sample Dependency Type Box");
	}

	override public function decode(input : MP4InputStream )
	{
		super.decode(input);

		//get number of samples from SampleSizeBox
		var sampleCount : Int = -1;
		if(parent.hasChild(BoxTypes.SAMPLE_SIZE_BOX)) sampleCount = (cast(parent.getChild(BoxTypes.SAMPLE_SIZE_BOX), SampleSizeBox)).getSampleCount();
		//TODO: uncomment when CompactSampleSizeBox is implemented
		//else if(parent.containsChild(BoxTypes.COMPACT_SAMPLE_SIZE_BOX)) sampleCount = ((CompactSampleSizeBox)parent.getChild(BoxTypes.SAMPLE_SIZE_BOX)).getSampleSize();
		sampleHasRedundancy = new Vector<Int>(sampleCount);
		sampleIsDependedOn = new Vector<Int>(sampleCount);
		sampleDependsOn = new Vector<Int>(sampleCount);

		var b : Int;
		for (i in 0...sampleCount)
		{
			b = input.read();
			/* 2 bits reserved
			 * 2 bits sampleDependsOn
			 * 2 bits sampleIsDependedOn
			 * 2 bits sampleHasRedundancy
			 */
			sampleHasRedundancy[i] = b&3;
			sampleIsDependedOn[i] = (b>>2)&3;
			sampleDependsOn[i] = (b>>4)&3;
		}
		left -= sampleCount;
	}

	/**
	 * The 'sample depends on' field takes one of the following four values:
	 * 0: the dependency of this sample is unknown
	 * 1: this sample does depend on others (not an I picture)
	 * 2: this sample does not depend on others (I picture)
	 * 3: reserved
	 *
	 * @return a list of 'sample depends on' values for all samples
	 */
	public function getSampleDependsOn() : Vector<Int>
	{
		return sampleDependsOn;
	}

	/**
	 * The 'sample is depended on' field takes one of the following four values:
	 * 0: the dependency of other samples on this sample is unknown
	 * 1: other samples may depend on this one (not disposable)
	 * 2: no other sample depends on this one (disposable)
	 * 3: reserved
	 *
	 * @return a list of 'sample is depended on' values for all samples
	 */
	public function getSampleIsDependedOn() : Vector<Int>
	{
		return sampleIsDependedOn;
	}

	/**
	 * The 'sample has redundancy' field takes one of the following four values:
	 * 0: it is unknown whether there is redundant coding in this sample
	 * 1: there is redundant coding in this sample
	 * 2: there is no redundant coding in this sample
	 * 3: reserved
	 * 
	 * @return a list of 'sample has redundancy' values for all samples
	 */
	public function getSampleHasRedundancy() : Vector<Int>
	{
		return sampleHasRedundancy;
	}
	
}