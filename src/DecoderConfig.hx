package ;
import flash.utils.ByteArray;
import flash.Vector;
import impl.BitStream;
import impl.Constants;
import impl.PCE;
import impl.transport.ADIFHeader;
import impl.transport.ADTSFrame;

/**
 * ...
 * @author Daniel Uranga
 */

class DecoderConfig 
{

	private var input : BitStream;
	private var profile : Profile;
	private var sampleFrequency : SampleFrequency;
	private var channelConfiguration : ChannelConfiguration;
	private var frameLengthFlag : Bool;
	private var dependsOnCoreCoder : Bool;
	private var coreCoderDelay : Int;
	private var extensionFlag : Bool;
	private var extProfile : Profile;
	//extension: SBR
	private var sbrPresent : Bool;
	private var downSampledSBR : Bool;
	//extension: error resilience
	private var sectionDataResilience : Bool;
	private var scalefactorResilience : Bool;
	private var spectralDataResilience : Bool;

	public function new(?input : BitStream)
	{
		if ( input == null )
		{
			input = null;
			profile = Profile.AAC_MAIN;
			sampleFrequency = SampleFrequency.SAMPLE_FREQUENCY_NONE;
			channelConfiguration = ChannelConfiguration.CHANNEL_CONFIG_UNSUPPORTED;
			frameLengthFlag = false;
			sbrPresent = false;
			downSampledSBR = false;
			extProfile = Profile.UNKNOWN;
		}
		else
		{
			this.input = input;
		}
	}

	/* ========== gets/sets ========== */
	public function getChannelConfiguration() : ChannelConfiguration
	{
		return channelConfiguration;
	}

	public function setChannelConfiguration(channelConfiguration : ChannelConfiguration)
	{
		this.channelConfiguration = channelConfiguration;
	}

	public function getCoreCoderDelay() : Int
	{
		return coreCoderDelay;
	}

	public function setCoreCoderDelay(coreCoderDelay : Int)
	{
		this.coreCoderDelay = coreCoderDelay;
	}

	public function isDependsOnCoreCoder() : Bool
	{
		return dependsOnCoreCoder;
	}

	public function setDependsOnCoreCoder(dependsOnCoreCoder : Bool)
	{
		this.dependsOnCoreCoder = dependsOnCoreCoder;
	}

	public function getExtObjectType() : Profile
	{
		return extProfile;
	}

	public function setExtObjectType(extObjectType : Profile)
	{
		this.extProfile = extObjectType;
	}

	public function getFrameLength() : Int
	{
		return frameLengthFlag ? Constants.WINDOW_SMALL_LEN_LONG : Constants.WINDOW_LEN_LONG;
	}

	public function isSmallFrameUsed() : Bool
	{
		return frameLengthFlag;
	}

	public function setSmallFrameUsed(shortFrame : Bool)
	{
		this.frameLengthFlag = shortFrame;
	}

	public function getProfile() : Profile
	{
		return profile;
	}

	public function setProfile(profile : Profile)
	{
		this.profile = profile;
	}

	public function getSampleFrequency() : SampleFrequency
	{
		return sampleFrequency;
	}

	public function setSampleFrequency(sampleFrequency : SampleFrequency)
	{
		this.sampleFrequency = sampleFrequency;
	}

	//=========== SBR =============
	public function isSBRPresent() : Bool
	{
		return sbrPresent;
	}

	public function setSBRPresent(sbrPresent : Bool)
	{
		this.sbrPresent = sbrPresent;
	}

	public function isSBRDownSampled() : Bool
	{
		return downSampledSBR;
	}

	//=========== ER =============
	public function isScalefactorResilienceUsed() : Bool
	{
		return scalefactorResilience;
	}

	public function isSectionDataResilienceUsed() : Bool
	{
		return sectionDataResilience;
	}

	public function isSpectralDataResilienceUsed() : Bool
	{
		return spectralDataResilience;
	}

	//=========== ADIF/ADTS header =============
	public function isBitStreamStored() : Bool
	{
		return input!=null;
	}

	public function getBitStream() : BitStream
	{
		return input;
	}

	/* ======== static builder ========= */
	/**
	 * Parses the input arrays as a DecoderSpecificInfo, as used in MP4
	 * containers.
	 * @return a DecoderConfig
	 */
	public static function parseMP4DecoderSpecificInfo(data : ByteArray) : DecoderConfig
	{
		var input : BitStream = new BitStream(data);
		var config : DecoderConfig = new DecoderConfig();

		try
		{
			config.profile = readProfile(input);

			var sf : Int = input.readBits(4);
			if (sf == 0xF)
			{
				throw("sample rate specified explicitly, not supported yet!");
				//bits.readBits(24);
			}
			else config.sampleFrequency = SampleFrequency.forInt(sf);
			config.channelConfiguration = ChannelConfiguration.forInt(input.readBits(4));

			/*
			switch(config.profile)
			{
			*/
			if (config.profile==Profile.AAC_SBR)
			{
				config.extProfile = config.profile;
				config.sbrPresent = true;
				sf = input.readBits(4);
				if (sf == 0xF)
				{
					throw("extended sample rate specified explicitly, not supported yet!");
					//bits.readBits(24);
				}
				//if sample frequencies are the same: downsample SBR
				config.downSampledSBR = config.sampleFrequency.getIndex()==sf;
				config.sampleFrequency = SampleFrequency.forInt(sf);
				config.profile = readProfile(input);
			}
			else if (
				config.profile == Profile.AAC_MAIN ||
				config.profile == Profile.AAC_LC ||
				config.profile == Profile.AAC_SSR ||
				config.profile == Profile.AAC_LTP ||
				config.profile == Profile.ER_AAC_LC ||
				config.profile == Profile.ER_AAC_LTP ||
				config.profile==Profile.ER_AAC_LD)
			{
				//ga-specific info:
				config.frameLengthFlag = input.readBool();
				if(config.frameLengthFlag) throw("config uses 960-sample frames, not yet supported");
				config.dependsOnCoreCoder = input.readBool();
				if(config.dependsOnCoreCoder) config.coreCoderDelay = input.readBits(14);
				else config.coreCoderDelay = 0;
				config.extensionFlag = input.readBool();

				if (config.channelConfiguration == ChannelConfiguration.CHANNEL_CONFIG_NONE)
				{
					//PCE()
				}

				if (config.extensionFlag)
				{
					if (config.profile.isErrorResilientProfile())
					{
						config.sectionDataResilience = input.readBool();
						config.scalefactorResilience = input.readBool();
						config.spectralDataResilience = input.readBool();
					}
					//extensionFlag3
					input.skipBit();
				}
			}
			else
			{
				
				throw("profile not supported: " + config.profile.getIndex());
			}
			/*
			}
			*/
		}
		input.destroy();
		return config;
	}

	private static function readProfile(input : BitStream) : Profile
	{
		var i : Int = input.readBits(5);
		if (i == 31)
		{
			i = 32+input.readBits(6);
		}
		return Profile.forInt(i);
	}

	/**
	 * Reads and parses a transport header from the InputStream. The method can
	 * detect and parse ADTS and ADIF headers.
	 * @return a DecoderConfig
	 */
	public static function parseTransportHeader(input : BitStream) : DecoderConfig
	{
		//InputBitStream in = new InputBitStream(input);
		var config : DecoderConfig = new DecoderConfig(input);
		if (ADIFHeader.isPresent(input))
		{
			var adif : ADIFHeader = ADIFHeader.readHeader(input);
			var pce : PCE = adif.getFirstPCE();
			config.profile = pce.getProfile();
			config.sampleFrequency = pce.getSampleFrequency();
			config.channelConfiguration = ChannelConfiguration.forInt(pce.getChannelCount());
			return config;
		}
		else if (ADTSFrame.isPresent(input))
		{
			var adts : ADTSFrame = ADTSFrame.readFrame(input);
			config.profile = adts.getProfile();
			config.sampleFrequency = adts.getSampleFrequency();
			config.channelConfiguration = adts.getChannelConfiguration();
			return config;
		}
		else throw("no transport header found");
	}
	
}