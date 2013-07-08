package mp4.boxes.impl.sampleentries.codec;
import flash.Vector;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class AVCSpecificStructure extends CodecSpecificStructure
{

	private var configurationVersion : Int;
	private var profile : Int;
	private var level : Int;
	private var lengthSize : Int;
	private var profileCompatibility : Int;
	private var sequenceParameterSetNALUnit : Vector<Int>;
	private var pictureParameterSetNALUnit : Vector<Int>;

	public function new()
	{
		super(7); //at least 7 bytes are read
	}

	override public function decode(input : MP4InputStream)
	{
		configurationVersion = input.read();
		profile = input.read();
		profileCompatibility = input.read();
		level = input.read();
		//6 bits reserved, 2 bits 'length size minus one'
		lengthSize = (input.read()&3)+1;

		var len : Int;
		//3 bits reserved, 5 bits number of sequence parameter sets
		var sequenceParameterSets : Int = input.read()&31;
		sequenceParameterSetNALUnit = new Vector<Int>(sequenceParameterSets);
		for (i in 0...sequenceParameterSets)
		{
			len = input.readBytes(2);
			sequenceParameterSetNALUnit[i] = input.readBytes(len);
			size+=(len+2);
		}

		var pictureParameterSets : Int = input.read();
		pictureParameterSetNALUnit = new Vector<Int>(pictureParameterSets);
		for (i in 0...pictureParameterSets)
		{
			len = input.readBytes(2);
			pictureParameterSetNALUnit[i] = input.readBytes(len);
			size+=len+2;
		}
	}

	public function getConfigurationVersion() : Int
	{
		return configurationVersion;
	}

	/**
	 * The AVC profile code as defined in ISO/IEC 14496-10.
	 *
	 * @return the AVC profile
	 */
	public function getProfile() : Int
	{
		return profile;
	}

	/**
	 * The profileCompatibility is a byte defined exactly the same as the byte
	 * which occurs between the profileIDC and levelIDC in a sequence parameter
	 * set (SPS), as defined in ISO/IEC 14496-10.
	 *
	 * @return the profile compatibility byte
	 */
	public function getProfileCompatibility() : Int
	{
		return profileCompatibility;
	}

	public function getLevel() : Int
	{
		return level;
	}

	/**
	 * The length in bytes of the NALUnitLength field in an AVC video sample or
	 * AVC parameter set sample of the associated stream. The value of this
	 * field 1, 2, or 4 bytes.
	 *
	 * @return the NALUnitLength length in bytes
	 */
	public function getLengthSize() : Int
	{
		return lengthSize;
	}

	/**
	 * The SPS NAL units, as specified in ISO/IEC 14496-10. SPSs shall occur in
	 * order of ascending parameter set identifier with gaps being allowed.
	 *
	 * @return all SPS NAL units
	 */
	public function getSequenceParameterSetNALUnits() : Vector<Int>
	{
		return sequenceParameterSetNALUnit;
	}

	/**
	 * The PPS NAL units, as specified in ISO/IEC 14496-10. PPSs shall occur in
	 * order of ascending parameter set identifier with gaps being allowed.
	 *
	 * @return all PPS NAL units
	 */
	public function getPictureParameterSetNALUnits() : Vector<Int>
	{
		return pictureParameterSetNALUnit;
	}
	
}