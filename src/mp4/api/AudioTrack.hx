package mp4.api;
import mp4.boxes.Box;
import mp4.boxes.BoxTypes;
import mp4.boxes.impl.SampleDescriptionBox;
import mp4.boxes.impl.sampleentries.AudioSampleEntry;
import mp4.boxes.impl.sampleentries.codec.CodecSpecificBox;
import mp4.boxes.impl.SoundMediaHeaderBox;
import mp4.boxes.od.ESDBox;
import mp4.MP4InputStream;
import mp4.api.Track;

/**
 * ...
 * @author Daniel Uranga
 */

class AudioCodec implements Codec
{

	public static var AAC : AudioCodec = new AudioCodec(1);
	public static var AMR : AudioCodec = new AudioCodec(2);
	public static var AMR_WIDE_BAND : AudioCodec = new AudioCodec(3);
	public static var EVRC : AudioCodec = new AudioCodec(4);
	public static var QCELP : AudioCodec = new AudioCodec(5);
	public static var SMV : AudioCodec = new AudioCodec(6);
	public static var UNKNOWN_AUDIO_CODEC : AudioCodec = new AudioCodec(7);

	public static function forType(type : UInt) : Codec
	{
		var ac : Codec;
		if(type==BoxTypes.MP4A_SAMPLE_ENTRY) ac = AAC;
		else if(type==BoxTypes.AMR_SAMPLE_ENTRY) ac = AMR;
		else if(type==BoxTypes.AMR_WB_SAMPLE_ENTRY) ac = AMR_WIDE_BAND;
		else if(type==BoxTypes.EVRC_SAMPLE_ENTRY) ac = EVRC;
		else if(type==BoxTypes.QCELP_SAMPLE_ENTRY) ac = QCELP;
		else if(type==BoxTypes.SMV_SAMPLE_ENTRY) ac = SMV;
		else ac = UNKNOWN_AUDIO_CODEC;
		return ac;
	}
	
	private var val : Int;
	
	private function new(val : Int)
	{
		this.val = val;
	}
	
	public function getVal() : Int
	{
		return val;
	}
	
	public function equals(codec : Codec) : Bool
	{
		return this.val == codec.getVal(); 
	}
	
}
 
class AudioTrack extends Track
{

	private var smhd : SoundMediaHeaderBox;
	private var sampleEntry : AudioSampleEntry;
	private var codec : Codec;

	public function new(trak : Box, input : MP4InputStream)
	{
		super(trak, input);

		var mdia : Box = trak.getChild(BoxTypes.MEDIA_BOX);
		var minf : Box = mdia.getChild(BoxTypes.MEDIA_INFORMATION_BOX);
		smhd = cast(minf.getChild(BoxTypes.SOUND_MEDIA_HEADER_BOX), SoundMediaHeaderBox);

		var stbl : Box = minf.getChild(BoxTypes.SAMPLE_TABLE_BOX);

		//sample descriptions: 'mp4a' has an ESDBox, all others have a CodecSpecificBox
		var stsd : SampleDescriptionBox = cast(stbl.getChild(BoxTypes.SAMPLE_DESCRIPTION_BOX), SampleDescriptionBox);
		sampleEntry = cast(stsd.getAllChildren()[0], AudioSampleEntry);
		if(sampleEntry.getType()==BoxTypes.MP4A_SAMPLE_ENTRY) findDecoderSpecificInfo(cast(sampleEntry.getChild(BoxTypes.ESD_BOX), ESDBox));
		else decoderInfo = new DecoderInfo(cast(sampleEntry.getAllChildren()[0], CodecSpecificBox));

		codec = AudioCodec.forType(sampleEntry.getType());
	}

	override public function getType() : Int
	{
		return Frame.AUDIO;
	}

	override public function getCodec() : Codec
	{
		return codec;
	}

	/**
	 * The balance is a floating-point number that places mono audio tracks in a
	 * stereo space: 0 is centre (the normal value), full left is -1.0 and full
	 * right is 1.0.
	 *
	 * @return the stereo balance for a this track
	 */
	public function getBalance() : Float
	{
		return smhd.getBalance();
	}

	/**
	 * Returns the number of channels in this audio track.
	 * @return the number of channels
	 */
	public function getChannelCount() : Int
	{
		return sampleEntry.getChannelCount();
	}

	/**
	 * Returns the sample rate of this audio track.
	 * @return the sample rate
	 */
	public function getSampleRate() : Int
	{
		return sampleEntry.getSampleRate();
	}

	/**
	 * Returns the sample size in bits for this track.
	 * @return the sample size
	 */
	public function getSampleSize() : Int
	{
		return sampleEntry.getSampleSize();
	}

	public function getVolume() : Float
	{
		return tkhd.getVolume();
	}
	
}