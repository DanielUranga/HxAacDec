package ;

/**
 * ...
 * @author Daniel Uranga
 */

class SampleFrequency
{
	public static var SAMPLE_FREQUENCY_NONE : SampleFrequency = new SampleFrequency( -1, 0, [0, 0], [0, 0] );
	public static var SAMPLE_FREQUENCY_96000 : SampleFrequency = new SampleFrequency(0, 96000, [33, 512], [31, 9]);
	public static var SAMPLE_FREQUENCY_88200 : SampleFrequency = new SampleFrequency(1, 88200, [33, 512], [31, 9]);
	public static var SAMPLE_FREQUENCY_64000 : SampleFrequency = new SampleFrequency(2, 64000, [38, 664], [34, 10]);
	public static var SAMPLE_FREQUENCY_48000 : SampleFrequency = new SampleFrequency(3, 48000, [40, 672], [40, 14]);
	public static var SAMPLE_FREQUENCY_44100 : SampleFrequency = new SampleFrequency(4, 44100, [40, 672], [42, 14]);
	public static var SAMPLE_FREQUENCY_32000 : SampleFrequency = new SampleFrequency(5, 32000, [40, 672], [51, 14]);
	public static var SAMPLE_FREQUENCY_24000 : SampleFrequency = new SampleFrequency(6, 24000, [41, 652], [46, 14]);
	public static var SAMPLE_FREQUENCY_22050 : SampleFrequency = new SampleFrequency(7, 22050, [41, 652], [46, 14]);
	public static var SAMPLE_FREQUENCY_16000 : SampleFrequency = new SampleFrequency(8, 16000, [37, 664], [42, 14]);
	public static var SAMPLE_FREQUENCY_12000 : SampleFrequency = new SampleFrequency(9, 12000, [37, 664], [42, 14]);
	public static var SAMPLE_FREQUENCY_11025 : SampleFrequency = new SampleFrequency(10, 11025, [37, 664], [42, 14]);
	public static var SAMPLE_FREQUENCY_8000 : SampleFrequency = new SampleFrequency(11, 8000, [34, 664], [39, 14]);

	/**
	 * Returns a sample frequency instance for the given index. If the index
	 * is not between 0 and 11 inclusive, SAMPLE_FREQUENCY_NONE is returned.
	 * @return a sample frequency with the given index
	 */
	public static function forInt(i : Int) : SampleFrequency
	{
		var freq : SampleFrequency;
		switch(i) {
			case 0:
				freq = SAMPLE_FREQUENCY_96000;
			case 1:
				freq = SAMPLE_FREQUENCY_88200;
			case 2:
				freq = SAMPLE_FREQUENCY_64000;
			case 3:
				freq = SAMPLE_FREQUENCY_48000;
			case 4:
				freq = SAMPLE_FREQUENCY_44100;
			case 5:
				freq = SAMPLE_FREQUENCY_32000;
			case 6:
				freq = SAMPLE_FREQUENCY_24000;
			case 7:
				freq = SAMPLE_FREQUENCY_22050;
			case 8:
				freq = SAMPLE_FREQUENCY_16000;
			case 9:
				freq = SAMPLE_FREQUENCY_12000;
			case 10:
				freq = SAMPLE_FREQUENCY_11025;
			case 11:
				freq = SAMPLE_FREQUENCY_8000;
			default:
				throw ("invalid sample frequency index: "+i);
		}
		return freq;
	}
	
	private var index : Int;
	private var frequency : Int;
	private var prediction : Array<Int>;
	private var maxTNS_SFB : Array<Int>;

	private function new(index : Int, freqency : Int, prediction : Array<Int>, maxTNS_SFB : Array<Int>)
	{
		this.index = index;
		this.frequency = freqency;
		this.prediction = prediction;
		this.maxTNS_SFB = maxTNS_SFB;
	}
	
	/**
	 * Returns this sample frequency's index between 0 (96000) and 11 (8000)
	 * or -1 if this is SAMPLE_FREQUENCY_NONE.
	 * @return the sample frequency's index
	 */
	public function getIndex() : Int
	{
		return index;
	}

	/**
	 * Returns the sample frequency as integer value. This may be a value
	 * between 96000 and 8000, or 0 if this is SAMPLE_FREQUENCY_NONE.
	 * @return the sample frequency
	 */
	public function getFrequency() : Int
	{
		return frequency;
	}

	/**
	 * Returns the highest scale factor band allowed for ICPrediction at this
	 * sample frequency.
	 * This method is mainly used internally.
	 * @return the highest prediction SFB
	 */
	public function getMaximalPredictionSFB() : Int
	{
		return prediction[0];
	}

	/**
	 * Returns the number of predictors allowed for ICPrediction at this
	 * sample frequency.
	 * This method is mainly used internally.
	 * @return the number of ICPredictors
	 */
	public function getPredictorCount() : Int
	{
		return prediction[1];
	}

	/**
	 * Returns the highest scale factor band allowed for TNS at this
	 * sample frequency.
	 * This method is mainly used internally.
	 * @return the highest SFB for TNS
	 */
	public function getMaximalTNS_SFB(shortWindow : Bool) : Int
	{
		return maxTNS_SFB[shortWindow ? 1 : 0];
	}

	/**
	 * Returns a string representation of this sample frequency.
	 * The method is identical to <code>getDescription()</code>.
	 * @return the sample frequency's description
	 */
	public function toString() : String
	{
		return Std.string(frequency);
	}
}
