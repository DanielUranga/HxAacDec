package mp4.api;
import mp4.boxes.Box;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class VideoTrack extends Track
{

	public function new(trak : Box, input : MP4InputStream)
	{
		super(trak, input);
	}
	
}