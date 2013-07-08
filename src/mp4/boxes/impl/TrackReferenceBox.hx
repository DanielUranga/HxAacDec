package mp4.boxes.impl;
import flash.Vector;
import mp4.boxes.BoxImpl;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class TrackReferenceBox extends BoxImpl
{

	private var referenceType : String;
	private var trackIDs : Vector<Int>;

	public function new()
	{
		super("Track Reference Box");
		trackIDs = new Vector<Int>();
	}

	override public function decode(input : MP4InputStream)
	{
		referenceType = input.readString(4);
		left-=4;

		while (left > 3)
		{
			trackIDs.push(input.readBytes(4));
			left -= 4;
		}
	}

	/**
	 * The reference type shall be set to one of the following values: 
	 * <ul>
	 * <li>'hint': the referenced track(s) contain the original media for this 
	 * hint track.</li>
	 * <li>'cdsc': this track describes the referenced track.</li>
	 * <li>'hind': this track depends on the referenced hint track, i.e., it 
	 * should only be used if the referenced hint track is used.</li>
	 * @return the reference type
	 */
	public function getReferenceType() : String
	{
		return referenceType;
	}

	/**
	 * The track IDs are integers that provide a reference from the containing
	 * track to other tracks in the presentation. Track IDs are never re-used
	 * and cannot be equal to zero.
	 * @return the track IDs this box refers to
	 */
	public function getTrackIDs() : Vector<Int>
	{
		return trackIDs;
	}
	
}