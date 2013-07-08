package mp4.boxes.impl;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class HandlerBox extends FullBox
{

	//ISO BMFF types
	public static inline var TYPE_VIDEO : Int = 1986618469; //vide
	public static inline var TYPE_SOUND : Int = 1936684398; //soun
	public static inline var TYPE_HINT : Int = 1751740020; //hint
	public static inline var TYPE_META : Int = 1835365473; //meta
	public static inline var TYPE_NULL : Int = 1853189228; //null
	//MP4 types
	public static inline var TYPE_ODSM : Int = 1868854125; //odsm
	public static inline var TYPE_CRSM : Int = 1668445037; //crsm
	public static inline var TYPE_SDSM : Int = 1935962989; //sdsm
	public static inline var TYPE_M7SM : Int = 1832350573; //m7sm
	public static inline var TYPE_OCSM : Int = 1868788589; //ocsm
	public static inline var TYPE_IPSM : Int = 1768977261; //ipsm
	public static inline var TYPE_MJSM : Int = 1835692909; //mjsm
	private var handlerType : Int;
	private var handlerName : String;

	public function new()
	{
		super("Handler Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		input.skipBytes(4); //pre-defined: 0

		handlerType = input.readBytes(4);

		input.readBytes(4); //reserved
		input.readBytes(4); //reserved
		input.readBytes(4); //reserved
		left -= 20;
		
		var of = input.getOffset();
		handlerName = input.readUTFString(left, MP4InputStream.UTF8);
		left -= /*handlerName.length + 1*/ ((input.getOffset()-of));
		
		//trace("asdasd: " + (input.getOffset()-of) + " " + handlerName.length);
		
	}

	/**
	 * When present in a media box, the handler type is an integer containing
	 * one of the following values:
	 * <ul>
	 * <li>'vide': Video track</li>
	 * <li>'soun': Audio track</li>
	 * <li>'hint': Hint track</li>
	 * <li>'meta': Timed Metadata track</li>
	 * </ul>
	 *
	 * When present in a meta box, it contains an appropriate value to indicate
	 * the format of the meta box contents. The value 'null' can be used in the
	 * primary meta box to indicate that it is merely being used to hold
	 * resources.
	 *
	 * @return the handler type
	 */
	public function getHandlerType() : Int
	{
		return handlerType;
	}

	/**
	 * The name gives a human-readable name for the track type (for debugging
	 * and inspection purposes).
	 * 
	 * @return the handler type's name
	 */
	public function getHandlerName() : String
	{
		return handlerName;
	}
	
}