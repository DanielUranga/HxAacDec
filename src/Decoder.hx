package ;
import haxe.io.BytesData;
import impl.BitStream;
import impl.filterbank.FilterBank;
import impl.PCE;
import impl.SyntacticElements;
import impl.transport.ADIFHeader;
import impl.transport.ADTSFrame;

/**
 * ...
 * @author Daniel Uranga
 */

class Decoder 
{

	private var config : DecoderConfig;
	private var syntacticElements : SyntacticElements;
	private var filterBank : FilterBank;
	private var input : BitStream;
	private var adifHeader : ADIFHeader;
	private var adtsFrame : ADTSFrame;

	/**
	 * The methods indicates, which profiles are current supported by the
	 * decoder.
	 * @param p an AAC profile
	 * @return true if the specified profile can be decoded
	 * @see Profile#isDecodingSupported()
	 */
	public static function canDecode(p : Profile) : Bool
	{
		return p.isDecodingSupported();
	}

	/**
	 * Initializes the decoder with a specific configuration.
	 * @param config A previously created decoder configuration.
	 * @throws AACException if the profile, specified by the DecoderConfig, is not supported
	 */
	/*
	public function new(config : DecoderConfig)
	{
		if(config==null) throw("decoder config must not be null");
		if(!canDecode(config.getProfile())) throw("unsupported profile: "+config.getProfile().getDescription());

		if(config.isBitStreamStored()) input = config.getBitStream();
		else input = new BitStream();

		this.config = config;

		syntacticElements = new SyntacticElements(config);
		filterBank = new FilterBank(config.isSmallFrameUsed(), config.getChannelConfiguration().getChannelCount());
	}
	*/
	
	/**
	 * Initializes the decoder with a MP4 decoder specific info.
	 *
	 * After this the MP4 frames can be passed to the
	 * <code>decodeFrame(byte[], SampleBuffer)</code> method to decode them.
	 * 
	 * @param decoderSpecificInfo a byte array containing the decoder specific info from an MP4 container
	 * @throws AACException if the specified profile is not supported
	 */
	public function new(decoderSpecificInfo : BytesData)
	{
		config = DecoderConfig.parseMP4DecoderSpecificInfo(decoderSpecificInfo);
		if(config==null) throw("illegal MP4 decoder specific info");

		if(!canDecode(config.getProfile())) throw("unsupported profile: "+config.getProfile().getDescription());

		syntacticElements = new SyntacticElements(config);
		filterBank = new FilterBank(config.isSmallFrameUsed(), config.getChannelConfiguration().getChannelCount());

		input = new BitStream();

		//printLog();
	}

	/**
	 * Decodes one frame of AAC data in frame mode and returns the raw PCM
	 * data.
	 * @param frame the AAC frame
	 * @param buffer a buffer to hold the decoded PCM data
	 * @throws AACException if decoding fails
	 */
	public function decodeFrame_(frame : BytesData, buffer : SampleBuffer)
	{
		if(frame!=null) input.setData(frame);
		decodeFrame(buffer);
	}

	/**
	 * Decodes one frame of AAC data in stream mode and returns the raw PCM
	 * data.
	 * @param buffer a buffer to hold the decoded PCM data
	 * @throws AACException if decoding fails
	 * @return true if a frame could be decoded, false if the stream ended
	 */
	public function decodeFrame(buffer : SampleBuffer) : Bool
	{
		decode(buffer);
		return true;
		/*
		try
		{
			decode(buffer);
			return true;
		}
		catch (e : Dynamic)
		{
			
			//if(e.isEndOfStream()) return false;
			//else throw e;
			
			trace(e);
			return false;
		}
		*/
	}

	private function decode(buffer : SampleBuffer)
	{
		if (ADIFHeader.isPresent(input))
		{
			adifHeader = ADIFHeader.readHeader(input);
			var pce : PCE = adifHeader.getFirstPCE();
			config.setProfile(pce.getProfile());
			config.setSampleFrequency(pce.getSampleFrequency());
			config.setChannelConfiguration(ChannelConfiguration.forInt(pce.getChannelCount()));
		}
		if (ADTSFrame.isPresent(input))
		{
			adtsFrame = ADTSFrame.readFrame(input);
			config.setProfile(adtsFrame.getProfile());
			config.setSampleFrequency(adtsFrame.getSampleFrequency());
			config.setChannelConfiguration(adtsFrame.getChannelConfiguration());
		}

		if(!canDecode(config.getProfile())) throw("unsupported profile: "+config.getProfile().getDescription());

		syntacticElements.startNewFrame();

		//1: bitstream parsing and noiseless coding
		//trace("1:");
		syntacticElements.decode(input);
		//2: spectral processing
		//trace("2:");
		syntacticElements.process(filterBank);
		//3: send to output buffer			
		//trace("3:");
		syntacticElements.sendToOutput(buffer);			
		
		/*
		try
		{
			//1: bitstream parsing and noiseless coding
			trace("1:");
			syntacticElements.decode(input);
			//2: spectral processing
			trace("2:");
			syntacticElements.process(filterBank);
			//3: send to output buffer			
			trace("3:");
			syntacticElements.sendToOutput(buffer);			
		}
		catch (e : Dynamic)
		{
			trace(e);
			buffer.setData(new BytesData());
			throw e;
		}
		*/
		/*
		catch(Exception e) {
			buffer.setData(new byte[0]);
			throw new AACException(e);
		}
		*/
	}
	
}