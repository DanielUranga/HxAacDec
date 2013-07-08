package mp4.boxes.impl;
import flash.Vector;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class TrackHeaderBox extends FullBox
{

	private var enabled : Bool;
	private var inMovie : Bool;
	private var inPreview : Bool;
	private var creationTime : Int;
	private var modificationTime : Int;
	private var duration : Int;
	private var trackID : Int;
	private var layer : Int;
	private var alternateGroup : Int;
	private var volume : Float;
	private var width : Float;
	private var height : Float;
	private var matrix : Vector<Float>;

	public function new()
	{
		super("Track Header Box");
		matrix = new Vector<Float>(9);
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		enabled = (flags&1)==1;
		inMovie = (flags&2)==2;
		inPreview = (flags&4)==4;

		if (version == 1)
		{
			creationTime = input.readBytes(8);
			modificationTime = input.readBytes(8);
			trackID = input.readBytes(4);
			input.skipBytes(4); //reserved
			duration = input.readBytes(8);
			left -= 32;
		}
		else
		{
			creationTime = input.readBytes(4);
			modificationTime = input.readBytes(4);
			trackID = input.readBytes(4);
			input.skipBytes(4); //reserved
			duration = input.readBytes(4);
			left -= 20;
		}

		input.skipBytes(4); //reserved
		input.skipBytes(4); //reserved

		layer = input.readBytes(2);
		alternateGroup = input.readBytes(2);
		volume = input.readFixedPoint(2, MP4InputStream.MASK8);

		input.skipBytes(2);

		for (i in 0...9)
		{
			matrix[i] = input.readFixedPoint(4, MP4InputStream.MASK16);
		}

		width = input.readFixedPoint(4, MP4InputStream.MASK16);
		height = input.readFixedPoint(4, MP4InputStream.MASK16);

		left -= 60;
	}

	/**
	 * A flag indicating that the track is enabled. A disabled track is treated
	 * as if it were not present.
	 * @return true if the track is enabled
	 */
	public function isTrackEnabled() : Bool
	{
		return enabled;
	}

	/**
	 * A flag indicating that the track is used in the presentation.
	 * @return true if the track is used
	 */
	public function isTrackInMovie() : Bool
	{
		return inMovie;
	}

	/**
	 * A flag indicating that the track is used when previewing the
	 * presentation.
	 * @return true if the track is used in previews
	 */
	public function isTrackInPreview() : Bool
	{
		return inPreview;
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
	 * The track ID is an integer that uniquely identifies this track over the
	 * entire life-time of this presentation. Track IDs are never re-used and
	 * cannot be zero.
	 * @return the track's ID
	 */
	public function getTrackID() : Int
	{
		return trackID;
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
	 * The layer specifies the front-to-back ordering of video tracks; tracks
	 * with lower numbers are closer to the viewer. 0 is the normal value, and
	 * -1 would be in front of track 0, and so on.
	 * @return the layer
	 */
	public function getLayer() : Int
	{
		return layer;
	}

	/**
	 * The alternate group is an integer that specifies a group or collection
	 * of tracks. If this field is 0 there is no information on possible
	 * relations to other tracks. If this field is not 0, it should be the same
	 * for tracks that contain alternate data for one another and different for
	 * tracks belonging to different such groups. Only one track within an
	 * alternate group should be played or streamed at any one time, and must be
	 * distinguishable from other tracks in the group via attributes such as
	 * bitrate, codec, language, packet size etc. A group may have only one
	 * member.
	 * @return the alternate group
	 */
	public function getAlternateGroup() : Int
	{
		return alternateGroup;
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
	 * The width specifies the track's visual presentation width as a floating
	 * point values. This needs not be the same as the pixel width of the
	 * images, which is documented in the sample description(s); all images in
	 * the sequence are scaled to this width, before any overall transformation
	 * of the track represented by the matrix. The pixel dimensions of the
	 * images are the default values. 
	 * @return the image width
	 */
	public function getWidth() : Float
	{
		return width;
	}

	/**
	 * The height specifies the track's visual presentation height as a floating
	 * point value. This needs not be the same as the pixel height of the
	 * images, which is documented in the sample description(s); all images in
	 * the sequence are scaled to this height, before any overall transformation
	 * of the track represented by the matrix. The pixel dimensions of the
	 * images are the default values.
	 * @return the image height
	 */
	public function getHeight() : Float
	{
		return height;
	}

	public function getMatrix() : Vector<Float>
	{
		return matrix;
	}
	
}