package mp4.api;
import flash.Vector;
import mp4.boxes.Box;
import mp4.boxes.BoxTypes;
import mp4.boxes.impl.HandlerBox;
import mp4.boxes.impl.MovieHeaderBox;
import mp4.MP4InputStream;
import mp4.api.Track;

/**
 * ...
 * @author Daniel Uranga
 */

class Movie 
{

	private var input : MP4InputStream;
	private var mvhd : MovieHeaderBox;
	private var tracks : Vector<Track>;
	private var metaData : MetaData;

	public function new(box : Box, input : MP4InputStream)
	{
		this.input = input;

		//create tracks
		mvhd = cast(box.getChild(BoxTypes.MOVIE_HEADER_BOX), MovieHeaderBox);
		var trackBoxes : Vector<Box> = box.getChildren(BoxTypes.TRACK_BOX);
		tracks = new Vector<Track>(/*trackBoxes.length*/);
		var track : Track;
		for (i in 0...trackBoxes.length)
		{
			track = createTrack(trackBoxes[i]);
			if(track!=null) tracks.push(track);
		}
		
		//read metadata: moov.meta/moov.udta.meta
		metaData = new MetaData();
		if(box.hasChild(BoxTypes.META_BOX)) metaData.parse(box.getChild(BoxTypes.META_BOX));
		else if (box.hasChild(BoxTypes.USER_DATA_BOX))
		{
			var udta : Box = box.getChild(BoxTypes.USER_DATA_BOX);
			if(udta.hasChild(BoxTypes.META_BOX)) metaData.parse(udta.getChild(BoxTypes.META_BOX));
		}
	}

	//TODO: support hint and meta
	private function createTrack(trak : Box) : Track
	{		
		var hdlr : HandlerBox = cast(trak.getChild(BoxTypes.MEDIA_BOX).getChild(BoxTypes.HANDLER_BOX), HandlerBox);
		var track : Track;
		switch(hdlr.getHandlerType())
		{
			case HandlerBox.TYPE_VIDEO:
				track = new VideoTrack(trak, input);
			case HandlerBox.TYPE_SOUND:
				track = new AudioTrack(trak, input);
			default:
				track = null;
		}
		return track;
	}

	/**
	 * Returns an unmodifiable list of all tracks in this movie. The tracks are
	 * ordered as they appeare in the file/stream.
	 *
	 * @return the tracks contained by this movie
	 */
	public function getAllTracks() : Vector<Track>
	{
		//return Collections.unmodifiableList(tracks);
		return tracks;
	}

	/**
	 * Returns an unmodifiable list of all tracks in this movie with the
	 * specified type. The tracks are ordered as they appeare in the
	 * file/stream.
	 *
	 * @return the tracks contained by this movie with the passed type
	 */
	public function getTracks_(/*type : Int*/ type : AudioTrack.AudioCodec) : Vector<Track>
	{
		var l : Vector<Track> = new Vector<Track>();
		for (t in tracks)
		{			
			if(/*t.getType()==type*/type.equals(t.getCodec())) l.push(t);
		}
		//return Collections.unmodifiableList(l);
		return l;
	}

	/**
	 * Returns an unmodifiable list of all tracks in this movie whose samples
	 * are encoded with the specified codec. The tracks are ordered as they 
	 * appeare in the file/stream.
	 *
	 * @return the tracks contained by this movie with the passed type
	 */
	public function getTracks(codec : Codec) : Vector<Track>
	{
		var l : Vector<Track> = new Vector<Track>();
		for (t in tracks)
		{
			if(t.getCodec().equals(codec)) l.push(t);
		}
		//return Collections.unmodifiableList(l);
		return l;
	}

	/**
	 * Returns the MetaData object for this movie.
	 *
	 * @return the MetaData for this movie
	 */
	public function getMetaData() : MetaData
	{
		return metaData;
	}

	//mvhd
	/**
	 * Returns the time this movie was created.
	 * @return the creation time
	 */
	public function getCreationTime() : Int
	{
		//return Utils.getDate(mvhd.getCreationTime());
		return mvhd.getCreationTime();
	}

	/**
	 * Returns the last time this movie was modified.
	 * @return the modification time
	 */
	public function getModificationTime() : Int
	{
		//return Utils.getDate(mvhd.getModificationTime());
		return mvhd.getCreationTime();
	}

	/**
	 * Returns the duration in seconds.
	 * @return the duration
	 */
	public function getDuration() : Float
	{
		return mvhd.getDuration()/mvhd.getTimeScale();
	}

	/**
	 * Indicates if there are more frames to be read in this movie.
	 *
	 * @return true if there is at least one track in this movie that has at least one more frame to read.
	 */
	public function hasMoreFrames() : Bool
	{
		for (track in tracks)
		{
			if(track.hasMoreFrames()) return true;
		}
		return false;
	}

	/**
	 * Reads the next frame from this movie (from one of the contained tracks).
	 * The frame is the next in time-order, thus the next for playback. If none
	 * of the tracks contains any more frames, null is returned.
	 *
	 * @return the next frame or null if there are no more frames to read from this movie.
	 * @throws IOException if reading fails
	 */
	public function readNextFrame()
	{
		var track : Track = null;
		for (t in tracks)
		{
			if(t.hasMoreFrames()&&(track==null||t.getNextTimeStamp()<track.getNextTimeStamp())) track = t;
		}

		return (track==null) ? null : track.readNextFrame();
	}
	
}