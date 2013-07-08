package mp4.boxes.impl;
import flash.Vector;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class TrackSelectionBox extends FullBox
{

	private var switchGroup : Int;
	private var attributes : Vector<Int>;

	public function new()
	{
		super("Track Selection Box");
		attributes = new Vector<Int>();
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		switchGroup = input.readBytes(4);
		left -= 4;

		while (left > 3)
		{
			attributes.push(input.readBytes(4));
			left -= 4;
		}
	}

	/**
	 * The switch group is an integer that specifies a group or collection of
	 * tracks. If this field is 0 (default value) or if the Track Selection box
	 * is absent there is no information on whether the track can be used for
	 * switching during playing or streaming. If this integer is not 0 it shall
	 * be the same for tracks that can be used for switching between each other.
	 * Tracks that belong to the same switch group shall belong to the same
	 * alternate group. A switch group may have only one member.
	 */
	public function getSwitchGroup() : Int
	{
		return switchGroup;
	}

	/**
	 * <p>A list of attributes, that should be used as descriptions of tracks or
	 * differentiation criteria for tracks in the same alternate or switch
	 * group. Each differentiating attribute is associated with a pointer to the
	 * field or information that distinguishes the track.</p>
	 *
	 * <p>The following attributes are descriptive:
	 * <table>
	 * <tr><th>Name</th><th>Attribute</th><th>Description</th></tr>
	 * <tr><td>Temporal scalability</td><td>'tesc'</td><td>The track can be
	 * temporally scaled.</td></tr>
	 * <tr><td>Fine-grain SNR scalability</td><td>'fgsc'</td><td>The track can
	 * be fine-grain scaled.</td></tr>
	 * <tr><td>Coarse-grain SNR scalability</td><td>'cgsc'</td><td>The track can
	 * be coarse-grain scaled.</td></tr>
	 * <tr><td>Spatial scalability</td><td>'spsc'</td><td>The track can be
	 * spatially scaled.</td></tr>
	 * <tr><td>Region-of-interest scalability</td><td>'resc'</td><td>The track
	 * can be region-of-interest scaled.</td></tr>
	 * </table></p>
	 *
	 * <p>The following attributes are differentiating:
	 * <table><tr><th>Name</th><th>Attribute</th><th>Pointer</th></tr>
	 * <tr><td>Codec</td><td>'cdec'</td><td>Sample Entry (in Sample Description
	 * box of media track)</td></tr>
	 * <tr><td>Screen size</td><td>'scsz'</td><td>Width and height fields of
	 * Visual Sample Entries.</td></tr>
	 * <tr><td>Max packet size</td><td>'mpsz'</td><td>Maxpacketsize field in RTP
	 * Hint Sample Entry</td></tr>
	 * <tr><td>Media type</td><td>'mtyp'</td><td>Handlertype in Handler box (of
	 * media track)</td></tr>
	 * <tr><td>Media language</td><td>'mela'</td><td>Language field in Media
	 * Header box</td></tr>
	 * <tr><td>Bitrate</td><td>'bitr'</td><td>Total size of the samples in the
	 * track divided by the duration in the track header box</td></tr>
	 * <tr><td>Frame rate</td><td>'frar'</td><td>Number of samples in the track
	 * divided by duration in the track header box</td></tr>
	 * </table></p>
	 *
	 * <p>Descriptive attributes characterize the tracks they modify, whereas
	 * differentiating attributes differentiate between tracks that belong to
	 * the same alternate or switch groups. The pointer of a differentiating
	 * attribute indicates the location of the information that differentiates
	 * the track from other tracks with the same attribute.</p>
	 */
	public function getAttributes() : Vector<Int>
	{
		return attributes;
	}
	
}