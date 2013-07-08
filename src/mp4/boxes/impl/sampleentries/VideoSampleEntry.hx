package mp4.boxes.impl.sampleentries;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class VideoSampleEntry extends SampleEntry
{

	private var width : Int;
	private var height : Int;
	private var horizontalResolution : Float;
	private var verticalResolution : Float;
	private var frameCount : Int;
	private var depth : Int;
	private var compressorName : String;

	public function new()
	{
		super("Video Sample Entry");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		input.skipBytes(2); //pre-defined: 0
		input.skipBytes(2); //reserved
		//3x32 pre_defined
		input.skipBytes(4); //pre-defined: 0
		input.skipBytes(4); //pre-defined: 0
		input.skipBytes(4); //pre-defined: 0

		width = input.readBytes(2);
		height = input.readBytes(2);
		horizontalResolution = input.readFixedPoint(4, MP4InputStream.MASK16);
		verticalResolution = input.readFixedPoint(4, MP4InputStream.MASK16);
		input.skipBytes(4); //reserved
		frameCount = input.readBytes(2);

		var len : Int = input.read();
		compressorName = input.readString(len);
		input.skipBytes(31-len);

		depth = input.readBytes(2);
		input.skipBytes(2); //pre-defined: -1

		left -= 70;

		readChildren(input);
	}

	/**
	 * The width is the maximum visual width of the stream described by this
	 * sample description, in pixels.
	 */
	public function getWidth() : Int
	{
		return width;
	}

	/**
	 * The height is the maximum visual height of the stream described by this
	 * sample description, in pixels.
	 */
	public function getHeight() : Int
	{
		return height;
	}

	/**
	 * The horizontal resolution of the image in pixels-per-inch, as a floating
	 * point value.
	 */
	public function getHorizontalResolution() : Float
	{
		return horizontalResolution;
	}

	/**
	 * The vertical resolution of the image in pixels-per-inch, as a floating
	 * point value.
	 */
	public function getVerticalResolution() : Float
	{
		return verticalResolution;
	}

	/**
	 * The frame count indicates how many frames of compressed video are stored 
	 * in each sample.
	 */
	public function getFrameCount() : Int
	{
		return frameCount;
	}

	/**
	 * The compressor name, for informative purposes.
	 */
	public function getCompressorName() : String
	{
		return compressorName;
	}

	/**
	 * The depth takes one of the following values
	 * DEFAULT_DEPTH (0x18) – images are in colour with no alpha
	 */
	public function getDepth() : Int
	{
		return depth;
	}
	
}