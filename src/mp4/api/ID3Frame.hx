package mp4.api;
import flash.Vector;
import haxe.io.BytesData;

/**
 * ...
 * @author Daniel Uranga
 */

class ID3Frame 
{

	public static inline var ALBUM_TITLE = 1413565506; //TALB
	public static inline var ALBUM_SORT_ORDER = 1414745921; //TSOA
	public static inline var ARTIST = 1414546737; //TPE1
	public static inline var ATTACHED_PICTURE = 1095780675; //APIC
	public static inline var AUDIO_ENCRYPTION = 1095061059; //AENC
	public static inline var AUDIO_SEEK_POINT_INDEX = 1095979081; //ASPI
	public static inline var BAND = 1414546738; //TPE2
	public static inline var BEATS_PER_MINUTE = 1413632077; //TBPM
	public static inline var COMMENTS = 1129270605; //COMM
	public static inline var COMMERCIAL_FRAME = 1129270610; //COMR
	public static inline var COMMERCIAL_INFORMATION = 1464029005; //WCOM
	public static inline var COMPOSER = 1413697357; //TCOM
	public static inline var CONDUCTOR = 1414546739; //TPE3
	public static inline var CONTENT_GROUP_DESCRIPTION = 1414091825; //TIT1
	public static inline var CONTENT_TYPE = 1413697358; //TCON
	public static inline var COPYRIGHT = 1464029008; //WCOP
	public static inline var COPYRIGHT_MESSAGE = 1413697360; //TCOP
	public static inline var ENCODED_BY = 1413828163; //TENC
	public static inline var ENCODING_TIME = 1413760334; //TDEN
	public static inline var ENCRYPTION_METHOD_REGISTRATION = 1162756946; //ENCR
	public static inline var EQUALISATION = 1162958130; //EQU2
	public static inline var EVENT_TIMING_CODES = 1163150159; //ETCO
	public static inline var FILE_OWNER = 1414485838; //TOWN
	public static inline var FILE_TYPE = 1413893204; //TFLT
	public static inline var GENERAL_ENCAPSULATED_OBJECT = 1195724610; //GEOB
	public static inline var GROUP_IDENTIFICATION_REGISTRATION = 1196575044; //GRID
	public static inline var INITIAL_KEY = 1414219097; //TKEY
	public static inline var INTERNET_RADIO_STATION_NAME = 1414681422; //TRSN
	public static inline var INTERNET_RADIO_STATION_OWNER = 1414681423; //TRSO
	public static inline var MODIFIED_BY = 1414546740; //TPE4
	public static inline var INVOLVED_PEOPLE_LIST = 1414090828; //TIPL
	public static inline var INTERNATIONAL_STANDARD_RECORDING_CODE = 1414746691; //TSRC
	public static inline var LANGUAGES = 1414283598; //TLAN
	public static inline var LENGTH = 1414284622; //TLEN
	public static inline var LINKED_INFORMATION = 1279872587; //LINK
	public static inline var LYRICIST = 1413830740; //TEXT
	public static inline var MEDIA_TYPE = 1414350148; //TMED
	public static inline var MOOD = 1414352719; //TMOO
	public static inline var MPEG_LOCATION_LOOKUP_TABLE = 1296845908; //MLLT
	public static inline var MUSICIAN_CREDITS_LIST = 1414349644; //TMCL
	public static inline var MUSIC_CD_IDENTIFIER = 1296254025; //MCDI
	public static inline var OFFICIAL_ARTIST_WEBPAGE = 1464811858; //WOAR
	public static inline var OFFICIAL_AUDIO_FILE_WEBPAGE = 1464811846; //WOAF
	public static inline var OFFICIAL_AUDIO_SOURCE_WEBPAGE = 1464811859; //WOAS
	public static inline var OFFICIAL_INTERNET_RADIO_STATION_HOMEPAGE = 1464816211; //WORS
	public static inline var ORIGINAL_ALBUM_TITLE = 1414480204; //TOAL
	public static inline var ORIGINAL_ARTIST = 1414484037; //TOPE
	public static inline var ORIGINAL_FILENAME = 1414481486; //TOFN
	public static inline var ORIGINAL_LYRICIST = 1414483033; //TOLY
	public static inline var ORIGINAL_RELEASE_TIME = 1413762898; //TDOR
	public static inline var OWNERSHIP_FRAME = 1331121733; //OWNE
	public static inline var PART_OF_A_SET = 1414549331; //TPOS
	public static inline var PAYMENT = 1464877401; //WPAY
	public static inline var PERFORMER_SORT_ORDER = 1414745936; //TSOP
	public static inline var PLAYLIST_DELAY = 1413762137; //TDLY
	public static inline var PLAY_COUNTER = 1346588244; //PCNT
	public static inline var POPULARIMETER = 1347375181; //POPM
	public static inline var POSITION_SYNCHRONISATION_FRAME = 1347375955; //POSS
	public static inline var PRIVATE_FRAME = 1347570006; //PRIV
	public static inline var PRODUCED_NOTICE = 1414550095; //TPRO
	public static inline var PUBLISHER = 1414550850; //TPUB
	public static inline var PUBLISHERS_OFFICIAL_WEBPAGE = 1464882498; //WPUB
	public static inline var RECOMMENDED_BUFFER_SIZE = 1380078918; //RBUF
	public static inline var RECORDING_TIME = 1413763651; //TDRC
	public static inline var RELATIVE_VOLUME_ADJUSTMENT = 1381384498; //RVA2
	public static inline var RELEASE_TIME = 1413763660; //TDRL
	public static inline var REVERB = 1381388866; //RVRB
	public static inline var SEEK_FRAME = 1397048651; //SEEK
	public static inline var SET_SUBTITLE = 1414746964; //TSST
	public static inline var SIGNATURE_FRAME = 1397311310; //SIGN
	public static inline var ENCODING_TOOLS_AND_SETTINGS = 1414746949; //TSSE
	public static inline var SUBTITLE = 1414091827; //TIT3
	public static inline var SYNCHRONISED_LYRIC = 1398361172; //SYLT
	public static inline var SYNCHRONISED_TEMPO_CODES = 1398363203; //SYTC
	public static inline var TAGGING_TIME = 1413764167; //TDTG
	public static inline var TERMS_OF_USE = 1431520594; //USER
	public static inline var TITLE = 1414091826; //TIT2
	public static inline var TITLE_SORT_ORDER = 1414745940; //TSOT
	public static inline var TRACK_NUMBER = 1414677323; //TRCK
	public static inline var UNIQUE_FILE_IDENTIFIER = 1430669636; //UFID
	public static inline var UNSYNCHRONISED_LYRIC = 1431522388; //USLT
	public static inline var USER_DEFINED_TEXT_INFORMATION_FRAME = 1415075928; //TXXX
	public static inline var USER_DEFINED_URL_LINK_FRAME = 1465407576; //WXXX
	
	//private static final String[] TEXT_ENCODINGS = {"ISO-8859-1", "UTF-16"/*BOM*/, "UTF-16", "UTF-8"};
	//private static final String[] VALID_TIMESTAMPS = {"yyyy, yyyy-MM", "yyyy-MM-dd", "yyyy-MM-ddTHH", "yyyy-MM-ddTHH:mm", "yyyy-MM-ddTHH:mm:ss"};
	//private static final String UNKNOWN_LANGUAGE = "xxx";
	private var size : Int;
	private var id : Int;
	private var flags : Int;
	private var groupID : Int;
	private var encryptionMethod : Int;
	private var data : BytesData;

	public function new(input : BytesData)
	{
		id = input.readInt();
		size = ID3Tag.readSynch(input);
		flags = input.readShort();

		if(isInGroup()) groupID = input.readByte();
		if(isEncrypted()) encryptionMethod = input.readByte();
		//TODO: data length indicator, unsync

		//data = new byte[(int) size];
		data = new BytesData();
		data.length = size;
		//input.readFully(data);
		input.readBytes(data);
	}

	//header data
	public function getID() : Int
	{
		return id;
	}

	public function getSize() : Int
	{
		return size;
	}

	public function isInGroup() : Bool
	{
		return (flags&0x40)==0x40;
	}

	public function getGroupID() : Int
	{
		return groupID;
	}

	public function isCompressed() : Bool
	{
		return (flags&8)==8;
	}

	public function isEncrypted() : Bool
	{
		return (flags&4)==4;
	}

	public function getEncryptionMethod() : Int
	{
		return encryptionMethod;
	}

	//content data
	public function getData() : BytesData
	{
		return data;
	}

	public function getText() : String
	{
		//return new String(data, Charset.forName(TEXT_ENCODINGS[0]));
		return "";
	}

	public function getEncodedText() : String
	{
		//first byte indicates encoding
		var enc : Int = data[0];

		//charsets 0,3 end with '0'; 1,2 end with '00'
		var t : Int = -1;
		var i : Int = 1;
		while ( cast(i, UInt) < data.length && t < 0)
		{
			if (data[i] == 0 && (enc == 0 || enc == 3 || data[i + 1] == 0)) t = i;
			i++;
		}
		//return new String(data, 1, t-1, Charset.forName(TEXT_ENCODINGS[enc]));
		var s : String = "";
		for ( i in 1...t - 1 )
			s += String.fromCharCode(data[i]);
		return s;
	}

	public function isNumber(x) : Bool
	{
		//use quotes because these are strings not numbers..
		if (x >= "0" && x <= "9")
		{
			return (true);
		} else
		{
			return (false);
		}
	} 
	
	public function getNumber() : Int
	{
		var s : String = "";
		for ( i in 0...data.length )
		{
			var c : String = String.fromCharCode(data[i]);
			if ( !isNumber(c) )
				break;
			s += c;
		}
		return Std.parseInt(s);
	}

	public function getNumbers() : Vector<Int>
	{
		/*
		//multiple numbers separated by '/'
		final String x = new String(data, Charset.forName(TEXT_ENCODINGS[0]));
		final int i = x.indexOf('/');
		final int[] y;
		if(i>0) y = new int[]{Integer.parseInt(x.substring(0, i)), Integer.parseInt(x.substring(i+1))};
		else y = new int[]{Integer.parseInt(x)};
		return y;
		*/
		return new Vector<Int>();
	}

	public function getDate() : Date
	{
		/*
		//timestamp lengths: 4,7,10,13,16,19
		final int i = (int) Math.floor(data.length/3)-1;
		final Date date;
		if(i>=0&&i<VALID_TIMESTAMPS.length) {
			final SimpleDateFormat sdf = new SimpleDateFormat(VALID_TIMESTAMPS[i]);
			date = sdf.parse(new String(data), new ParsePosition(0));
		}
		else date = null;
		return date;
		*/
		return new Date(2011, 1, 1, 1, 1, 1);
	}

	public function getLocale() : String
	{
		/*
		final String s = new String(data).toLowerCase();
		final Locale l;
		if(s.equals(UNKNOWN_LANGUAGE)) l = null; //TODO: return something else than null
		else l = new Locale(s);
		return l;
		*/
		return "";
	}
	
}