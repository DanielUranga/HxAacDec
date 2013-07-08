package mp4.boxes.impl;
import flash.Vector;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class MovieHeaderBox extends FullBox
{
	
	private var creationTime : Int;
	private var modificationTime : Int;
	private var timeScale : Int;
	private var duration : Int;
	private var rate : Float;
	private var volume : Float;
	private var matrix : Vector<Float>;
	private var nextTrackID : Int;

	public function new()
	{
		super("Movie Header Box");
		matrix = new Vector<Float>(9);
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

		//rate: 16.16 fixed point
		rate = input.readFixedPoint(4, MP4InputStream.MASK16);
		//volume: 8.8 fixed point
		volume = input.readFixedPoint(2, MP4InputStream.MASK8);

		input.skipBytes(2); //reserved
		input.skipBytes(4); //reserved
		input.skipBytes(4); //reserved

		for (i in 0...9)
		{
			matrix[i] = input.readFixedPoint(4, MP4InputStream.MASK16);
		}

		input.skipBytes(24); //reserved

		nextTrackID = input.readBytes(4);

		left -= 80;
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
	 * The time-scale is an integer that specifies the time-scale for the entire
	 * presentation; this is the number of time units that pass in one second.
	 * For example, a time coordinate system that measures time in sixtieths of
	 * a second has a time scale of 60.
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
	 * The rate is a floting point number that indicates the preferred rate
	 * to play the presentation; 1.0 is normal forward playback
	 * @return the playback rate
	 */
	public function getRate() : Float
	{
		return rate;
	}

	/**
	 * The volume is a floating point number that indicates the preferred
	 * playback volume: 0.0 is mute, 1.0 is normal volume.
	 * @return the volume
	 */
	public function getVolume() : Float
	{
		return volume;
	}

	/**
	 * Provides a transformation matrix for the video:
	 * [A,B,U,C,D,V,X,Y,W]
	 * A: width scale
	 * B: width rotate
	 * U: width angle
	 * C: height rotate
	 * D: height scale
	 * V: height angle
	 * X: position from left
	 * Y: position from top
	 * W: divider scale (restricted to 1.0)
	 *
	 * The normal values for scale are 1.0 and for rotate 0.0.
	 * The angles are restricted to 0.0.
	 *
	 * @return the transformation matrix for the video
	 */
	public function getTransformationMatrix() : Vector<Float>
	{
		return matrix;
	}

	/**
	 * The next-track-ID is a non-zero integer that indicates a value to use
	 * for the track ID of the next track to be added to this presentation. Zero
	 * is not a valid track ID value. The value shall be larger than the largest
	 * track-ID in use. If this value is equal to all 1s (32-bit), and a new
	 * media track is to be added, then a search must be made in the file for an
	 * unused track identifier.
	 * @return the ID for the next track
	 */
	public function getNextTrackID() : Int
	{
		return nextTrackID;
	}
	
}