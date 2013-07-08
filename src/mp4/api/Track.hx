package mp4.api;
import flash.Vector;
import haxe.io.BytesData;
import impl.Comparable;
import impl.VectorTools;
import mp4.boxes.Box;
import mp4.boxes.BoxTypes;
import mp4.boxes.impl.ChunkOffsetBox;
import mp4.boxes.impl.DataReferenceBox;
import mp4.boxes.impl.DecodingTimeToSampleBox;
import mp4.boxes.impl.MediaHeaderBox;
import mp4.boxes.impl.SampleSizeBox;
import mp4.boxes.impl.SampleToChunkBox;
import mp4.boxes.impl.TrackExtendsBox;
import mp4.boxes.impl.TrackHeaderBox;
import mp4.boxes.od.DecoderSpecificInfoDescriptor;
import mp4.boxes.od.ESDBox;
import mp4.boxes.od.ObjectDescriptor;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

interface Codec
{
	public function equals(codec : Codec) : Bool;
	public function getVal() : Int;
}
 
class Track 
{

	private var input : MP4InputStream;
	private var tkhd : TrackHeaderBox;
	private var mdhd : MediaHeaderBox;
	private var inFile : Bool;
	private var frames : Vector<Comparable>;
	//private URL location;
	private var currentFrame : Int;
	//info structures
	private var decoderSpecificInfo : DecoderSpecificInfoDescriptor;
	private var decoderInfo : DecoderInfo;

	public function new(trak : Box, input : MP4InputStream)
	{
		this.input = input;

		tkhd = cast(trak.getChild(BoxTypes.TRACK_HEADER_BOX), TrackHeaderBox);

		var mdia : Box = trak.getChild(BoxTypes.MEDIA_BOX);
		mdhd = cast(mdia.getChild(BoxTypes.MEDIA_HEADER_BOX), MediaHeaderBox);
		var minf : Box = mdia.getChild(BoxTypes.MEDIA_INFORMATION_BOX);

		var dinf : Box = minf.getChild(BoxTypes.DATA_INFORMATION_BOX);
		var dref : DataReferenceBox = cast(dinf.getChild(BoxTypes.DATA_REFERENCE_BOX), DataReferenceBox);
		//TODO: support URNs
		/*
		if (dref.hasChild(BoxTypes.DATA_ENTRY_URL_BOX))
		{
			DataEntryUrlBox url = (DataEntryUrlBox) dref.getChild(BoxTypes.DATA_ENTRY_URL_BOX);
			inFile = url.isInFile();
			try
			{
				location = new URL(url.getLocation());
			}
			catch(MalformedURLException e) {
				location = null;
			}
		}
		*/
		/*else if(dref.containsChild(BoxTypes.DATA_ENTRY_URN_BOX)) {
		DataEntryUrnBox urn = (DataEntryUrnBox) dref.getChild(BoxTypes.DATA_ENTRY_URN_BOX);
		inFile = urn.isInFile();
		location = urn.getLocation();
		}*/
		/*
		else {
			inFile = true;
			location = null;
		}
		*/

		//sample table
		var stbl : Box = minf.getChild(BoxTypes.SAMPLE_TABLE_BOX);
		if (stbl.hasChildren())
		{
			frames = new Vector<Comparable>();
			parseSampleTable(stbl);
		}
		else frames = new Vector<Comparable>();
		currentFrame = 0;
	}

	private function parseSampleTable(stbl : Box)
	{
		var timeScale : Float = mdhd.getTimeScale();

		//get tables from boxes
		var sampleToChunks : Vector<SampleToChunkEntry> = cast(stbl.getChild(BoxTypes.SAMPLE_TO_CHUNK_BOX), SampleToChunkBox).getEntries();
		var sampleSizes : Vector<Int> = cast(stbl.getChild(BoxTypes.SAMPLE_SIZE_BOX), SampleSizeBox).getSampleSizes();
		var stco : ChunkOffsetBox;
		if(stbl.hasChild(BoxTypes.CHUNK_OFFSET_BOX)) stco = cast(stbl.getChild(BoxTypes.CHUNK_OFFSET_BOX), ChunkOffsetBox);
		else stco = cast(stbl.getChild(BoxTypes.CHUNK_LARGE_OFFSET_BOX), ChunkOffsetBox);
		var chunkOffsets : Vector<Int> = stco.getChunks();

		//DecodingTimeToSampleBox
		var stts : DecodingTimeToSampleBox = cast(stbl.getChild(BoxTypes.DECODING_TIME_TO_SAMPLE_BOX), DecodingTimeToSampleBox);
		var sampleCounts : Vector<Int> = stts.getSampleCounts();
		if(getType()==Frame.VIDEO) trace("samples: "+sampleSizes.length);
		var sampleDeltas : Vector<Int> = stts.getSampleDeltas();

		//decode sampleDurations
		var sampleDurations : Vector<Int> = new Vector<Int>(sampleSizes.length);
		var off : Int = 0;
		for (i in 0...sampleCounts.length)
		{
			for (j in 0...sampleCounts[i])
			{
				sampleDurations[off+j] = sampleDeltas[i];
			}
			off += sampleCounts[i];
		}

		//create frames
		var entry : SampleToChunkEntry;
		var firstChunk : Int;
		var lastChunk : Int;
		var pos : Int;
		var size : Int;
		//int j, s;
		var timeStamp : Float;
		var current : Int = 0;

		//TODO: is this valid for video samples?
		for (i in 0...sampleToChunks.length)
		{
			//an entry (run) contains several chunks with the same 'samples-per-chunk' value
			entry = sampleToChunks[i];
			firstChunk = entry.getFirstChunk();
			//since the last chunk of a run is not specified: get it from the next run
			if(i<sampleToChunks.length-1) lastChunk = sampleToChunks[i+1].getFirstChunk()-1;
			else lastChunk = chunkOffsets.length;

			//iterate over all chunks in this run
			for (j in firstChunk...lastChunk+1)
			{
				pos = chunkOffsets[j-1];
				//iterate over all samples in this chunk
				for (s in 0...entry.getSamplesPerChunk())
				{
					//create frame for sample
					timeStamp = (sampleDurations[j-1]*current)/timeScale;
					size = sampleSizes[current];
					frames.push(new Frame(getType(), pos, size, timeStamp));

					//calculate sampe offset from chunk offset and sample sizes
					pos += size;
					current++;
				}
			}
		}

		//frames need not to be time-ordered: sort by timestamp
		//TODO: is it possible to add them to the specific position?
		//Collections.sort(frames);
		VectorTools.sort(frames);
	}

	//TODO: implement other entry descriptors
	private function findDecoderSpecificInfo(esds : ESDBox)
	{
		var ed : ObjectDescriptor = esds.getEntryDescriptor();
		var children : Vector<ObjectDescriptor> = ed.getChildren();
		var children2 : Vector<ObjectDescriptor>;

		for (e in children)
		{
			children2 = e.getChildren();
			for (e2 in children2)
			{
				switch(e2.getType())
				{
					case ObjectDescriptor.TYPE_DECODER_SPECIFIC_INFO_DESCRIPTOR:
						decoderSpecificInfo = cast(e2, DecoderSpecificInfoDescriptor);
				}
			}
		}
	}

	public function getType() : Int
	{
		return -1;
	}

	public function getCodec() : Codec
	{
		return null;
	}

	//tkhd
	/**
	 * Returns true if the track is enabled. A disabled track is treated as if
	 * it were not present.
	 * @return true if the track is enabled
	 */
	public function isEnabled() : Bool
	{
		return tkhd.isTrackEnabled();
	}

	/**
	 * Returns true if the track is used in the presentation.
	 * @return true if the track is used
	 */
	public function isUsed() : Bool
	{
		return tkhd.isTrackInMovie();
	}

	/**
	 * Returns true if the track is used in previews.
	 * @return true if the track is used in previews
	 */
	public function isUsedForPreview() : Bool
	{
		return tkhd.isTrackInPreview();
	}

	/**
	 * Returns the time this track was created.
	 * @return the creation time
	 */
	/*
	public Date getCreationTime() {
		return Utils.getDate(tkhd.getCreationTime());
	}
	*/

	/**
	 * Returns the last time this track was modified.
	 * @return the modification time
	 */
	/*
	public Date getModificationTime() {
		return Utils.getDate(tkhd.getModificationTime());
	}
	*/

	//mdhd
	/**
	 * Returns the language for this media.
	 * @return the language
	 */
	public function getLanguage() : String
	{
		//return new Locale(mdhd.getLanguage());
		return mdhd.getLanguage();
	}

	/**
	 * Returns true if the data for this track is present in this file (stream).
	 * If not, <code>getLocation()</code> returns the URL where the data can be
	 * found.
	 * @return true if the data is in this file (stream), false otherwise
	 */
	public function isInFile() : Bool
	{
		return inFile;
	}

	/**
	 * If the data for this track is not present in this file (if
	 * <code>isInFile</code> returns false), this method returns the data's
	 * location. Else null is returned.
	 * @return the data's location or null if the data is in this file
	 */
	/*
	public URL getLocation() {
		return location;
	}
	*/

	//info structures
	/**
	 * Returns the decoder specific info, if present. It contains configuration
	 * data for the decoder. If the decoder specific info is not present, the
	 * track contains a <code>DecoderInfo</code>.
	 *
	 * @see #getDecoderInfo() 
	 * @return the decoder specific info
	 */
	public function getDecoderSpecificInfo() : BytesData
	{
		return decoderSpecificInfo.getData();
	}

	/**
	 * Returns the <code>DecoderInfo</code>, if present. It contains 
	 * configuration information for the decoder. If the structure is not
	 * present, the track contains a decoder specific info.
	 *
	 * @see #getDecoderSpecificInfo()
	 * @return the codec specific structure
	 */
	public function getDecoderInfo() : DecoderInfo
	{
		return decoderInfo;
	}

	//reading
	/**
	 * Indicates if there are more frames to be read in this track.
	 * 
	 * @return true if there is at least one more frame to read.
	 */
	public function hasMoreFrames() : Bool
	{
		return currentFrame<frames.length;
	}

	/**
	 * Reads the next frame from this track. If it contains no more frames to
	 * read, null is returned.
	 * 
	 * @return the next frame or null if there are no more frames to read
	 * @throws IOException if reading fails
	 */
	public function readNextFrame() : Frame
	{
		var frame : Frame = null;
		if (hasMoreFrames())
		{
			frame = cast(frames[currentFrame], Frame);

			var diff : Int = frame.getOffset()-input.getOffset();
			if(diff>0) input.skipBytes(diff);
			else if (diff < 0)
			{
				if(input.hasRandomAccess()) input.seek(frame.getOffset());
				else trace("frame already skipped and no random access");
			}

			// new byte[(int) frame.getSize()];
			var b : BytesData = new BytesData();
			b.length = frame.getSize();			
			if (!input.readBytes_(b)) trace("unexpected end of stream");//throw new IOException("unexpected end of stream");
			frame.setData(b);
			currentFrame++;
		}
		return frame;
	}
	
	public function readNextFrame_BytesData() : BytesData
	{
		var f = readNextFrame();
		return f.getData();
	}

	/**
	 * This method tries to seek to the frame that is nearest to the given
	 * timestamp. It returns the timestamp of the frame it seeked to or -1 if
	 * none was found.
	 * 
	 * @param timestamp a timestamp to seek to
	 * @return the frame's timestamp that the method seeked to
	 */
	public function seek(timestamp : Float) : Float
	{
		//find first frame > timestamp
		var frame : Frame = null;
		for (i in 0...frames.length)
		{
			// Aca avanzaba la variable i nose porq, mejor soy conservador y no avanzo nada
			frame = cast(frames[i], Frame);
			if (frame.getTime() > timestamp)
			{
				currentFrame = i;
				break;
			}
		}
		return (frame==null) ? -1 : frame.getTime();
	}

	/**
	 * Returns the timestamp of the next frame to be read. This is needed to
	 * read frames from a movie that contains multiple tracks.
	 *
	 * @return the next frame's timestamp
	 */
	public function getNextTimeStamp() : Float
	{
		return cast(frames[currentFrame], Frame).getTime();
	}
	
}