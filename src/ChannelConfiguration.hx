package ;

/**
 * ...
 * @author Daniel Uranga
 */

class ChannelConfiguration 
{

	public static var CHANNEL_CONFIG_UNSUPPORTED : ChannelConfiguration = new ChannelConfiguration( -1, "invalid");
	public static var CHANNEL_CONFIG_NONE : ChannelConfiguration = new ChannelConfiguration(0, "No channel");
	public static var CHANNEL_CONFIG_MONO : ChannelConfiguration = new ChannelConfiguration(1, "Mono");
	public static var CHANNEL_CONFIG_STEREO : ChannelConfiguration = new ChannelConfiguration(2, "Stereo");
	public static var CHANNEL_CONFIG_STEREO_PLUS_CENTER : ChannelConfiguration = new ChannelConfiguration(3, "Stereo+Center");
	public static var CHANNEL_CONFIG_STEREO_PLUS_CENTER_PLUS_REAR_MONO : ChannelConfiguration = new ChannelConfiguration(4, "Stereo+Center+Rear");
	public static var CHANNEL_CONFIG_FIVE : ChannelConfiguration = new ChannelConfiguration(5, "Five channels");
	public static var CHANNEL_CONFIG_FIVE_PLUS_ONE : ChannelConfiguration = new ChannelConfiguration(6, "Five channels+LF");
	public static var CHANNEL_CONFIG_SEVEN_PLUS_ONE : ChannelConfiguration = new ChannelConfiguration(8, "Seven channels+LF");

	public static inline function forInt(i : Int) : ChannelConfiguration
	{
		var c : ChannelConfiguration = CHANNEL_CONFIG_UNSUPPORTED;
		switch(i)
		{
			case 0:
				c = CHANNEL_CONFIG_NONE;
			case 1:
				c = CHANNEL_CONFIG_MONO;
			case 2:
				c = CHANNEL_CONFIG_STEREO;
			case 3:
				c = CHANNEL_CONFIG_STEREO_PLUS_CENTER;
			case 4:
				c = CHANNEL_CONFIG_STEREO_PLUS_CENTER_PLUS_REAR_MONO;
			case 5:
				c = CHANNEL_CONFIG_FIVE;
			case 6:
				c = CHANNEL_CONFIG_FIVE_PLUS_ONE;
			case 7,8:
				c = CHANNEL_CONFIG_SEVEN_PLUS_ONE;
			default:
				c = CHANNEL_CONFIG_UNSUPPORTED;
		}
		return c;
	}
	private var chCount : Int;
	private var descr : String;

	private function new(chCount : Int, descr : String)
	{
		this.chCount = chCount;
		this.descr = descr;
	}

	/**
	 * Returns the number of channels in this configuration.
	 */
	public function getChannelCount() : Int
	{
		return chCount;
	}

	/**
	 * Returns a short description of this configuration.
	 * @return the channel configuration's description
	 */
	public function getDescription() : String
	{
		return descr;
	}

	/**
	 * Returns a string representation of this channel configuration.
	 * The method is identical to <code>getDescription()</code>.
	 * @return the channel configuration's description
	 */
	public function toString() : String
	{
		return descr;
	}
	
}