package ;
import haxe.io.BytesData;

/**
 * ...
 * @author Daniel Uranga
 */

/**
 * This class represents the format of the raw PCM data stored in the
 * sample buffer.
 */
class Format
{

	public var sampleRate : Int;
	public var channels : Int;
	public var bitsPerSample : Int;

	public function new(sampleRate : Int, channels : Int, bitsPerSample : Int)
	{
		this.sampleRate = sampleRate;
		this.channels = channels;
		this.bitsPerSample = bitsPerSample;
	}

	public function getSampleRate() : Int
	{
		return sampleRate;
	}

	public function getChannels() : Int
	{
		return channels;
	}

	public function getBitsPerSample() : Int
	{
		return bitsPerSample;
	}
}
 
class SampleBuffer 
{

	private var format : Format;
	private var data : BytesData;

	public function new()
	{
		data = new BytesData();
		format = new Format(0, 0, 0);
	}

	/**
	 * Returns the format of this sample buffer's data.
	 * @return the audio format
	 */
	public function getFormat() : Format
	{
		return format;
	}

	public function setFormat(sampleRate : Int, channels : Int, bitsPerSample : Int)
	{
		format.sampleRate = sampleRate;
		format.channels = channels;
		format.bitsPerSample = bitsPerSample;
	}

	/**
	 * Returns the buffer's PCM data.
	 * @return the audio data
	 */
	public function getData() : BytesData
	{
		return data;
	}

	public function setData(data : BytesData)
	{
		this.data = data;
	}
	
}