package mp4.boxes.impl;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class MediaHeaderBox extends FullBox
{

	private var creationTime : Int;
	private var modificationTime : Int;
	private var timeScale : Int;
	private var duration : Int;
	private var language : String;

	public function new()
	{
		super("Media Header Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);
		
		if (version == 1)
		{
			creationTime = input.readBytes(8);
			modificationTime = input.readBytes(8);
			timeScale = input.readBytes(4);
			duration = input.readBytes(8);
			left -= 28;
		}
		else
		{
			creationTime = input.readBytes(4);
			modificationTime = input.readBytes(4);
			timeScale = input.readBytes(4);
			duration = input.readBytes(4);
			left -= 16;
		}
		
		//1 bit padding, 5*3 bits language code (ISO-639-2/T)
		var l : Int = input.readBytes(2);
		language = String.fromCharCode(((l >> 10) & 31) + 0x60) +
					String.fromCharCode(((l >> 5) & 31) + 0x60) +
					String.fromCharCode((l & 31) + 0x60);
		
		input.skipBytes(2); //pre-defined: 0
		
		left -= 4;
		
	}

	/**
	 * The creation time is an integer that declares the creation time of the
	 * presentation in seconds since midnight, Jan. 1, 1904, in UTC time.
	 * @return the creation time
	 */
	public function getCreationTime() : Int
	{
		return creationTime;
	}

	/**
	 * The modification time is an integer that declares the most recent time
	 * the presentation was modified in seconds since midnight, Jan. 1, 1904,
	 * in UTC time.
	 */
	public function getModificationTime() : Int
	{
		return modificationTime;
	}

	/**
	 * The time-scale is an integer that specifies the time-scale for this
	 * media; this is the number of time units that pass in one second. For
	 * example, a time coordinate system that measures time in sixtieths of a
	 * second has a time scale of 60.
	 * @return the time-scale
	 */
	public function getTimeScale() : Int
	{
		return timeScale;
	}

	/**
	 * The duration is an integer that declares length of the presentation (in
	 * the indicated timescale). This property is derived from the
	 * presentation's tracks: the value of this field corresponds to the
	 * duration of the longest track in the presentation.
	 * @return the duration of the longest track
	 */
	public function getDuration() : Int
	{
		return duration;
	}

	/**
	 * Language code for this media as defined in ISO 639-2/T.
	 * @return the language code
	 */
	public function getLanguage() : String
	{
		return language;
	}
	
}