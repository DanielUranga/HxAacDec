package mp4.api;
import flash.Vector;
import mp4.boxes.Box;
import mp4.boxes.BoxTypes;
import mp4.boxes.impl.CopyrightBox;
import mp4.boxes.impl.meta.ID3TagBox;
import mp4.boxes.impl.meta.NeroMetadataTagsBox;

/**
 * ...
 * @author Daniel Uranga
 */

class Field<T>
{
	public static var ARTIST : Field<String> = new Field<String>(1);
	public static var TITLE : Field<String> = new Field<String>(2);
	public static var ALBUM_ARTIST : Field<String> = new Field<String>(3);
	public static var ALBUM : Field<String> = new Field<String>(4);
	public static var TRACK_NUMBER : Field<Int> = new Field<Int>(5);
	public static var TOTAL_TRACKS : Field<Int> = new Field<Int>(6);
	public static var DISK_NUMBER : Field<Int> = new Field<Int>(7);
	public static var TOTAL_DISKS : Field<Int> = new Field<Int>(8);
	public static var COMPOSER : Field<String> = new Field<String>(9);
	public static var COMMENTS : Field<String> = new Field<String>(10);
	public static var TEMPO : Field<Int> = new Field<Int>(11);
	public static var LENGTH_IN_MILLISECONDS : Field<Int> = new Field<Int>(12);
	public static var RELEASE_DATE : Field<Date> = new Field<Date>(13);
	public static var GENRE : Field<String> = new Field<String>(14);
	public static var ENCODER_NAME : Field<String> = new Field<String>(15);
	public static var ENCODER_TOOL : Field<String> = new Field<String>(16);
	public static var ENCODING_DATE : Field<Date> = new Field<Date>(17);
	public static var COPYRIGHT : Field<String> = new Field<String>(18);
	public static var PUBLISHER : Field<String> = new Field<String>(19);
	public static var COMPILATION : Field<Bool> = new Field<Bool>(20);
	//public static  Field<List<Artwork>> COVER_ARTWORK = new Field<List<Artwork>>();
	public static var GROUPING : Field<String> = new Field<String>(21);
	public static var LYRICS : Field<String> = new Field<String>(22);
	public static var RATING : Field<Int> = new Field<Int>(23);
	public static var PODCAST : Field<Int> = new Field<Int>(24);
	public static var PODCAST_URL : Field<String> = new Field<String>(25);
	public static var CATEGORY : Field<String> = new Field<String>(26);
	public static var KEYWORDS : Field<String> = new Field<String>(27);
	public static var EPISODE_GLOBAL_UNIQUE_ID : Field<Int> = new Field<Int>(28);
	public static var DESCRIPTION : Field<String> = new Field<String>(29);
	public static var TV_SHOW : Field<String> = new Field<String>(30);
	public static var TV_NETWORK : Field<String> = new Field<String>(31);
	public static var TV_EPISODE : Field<String> = new Field<String>(32);
	public static var TV_EPISODE_NUMBER : Field<Int> = new Field<Int>(33);
	public static var TV_SEASON : Field<Int> = new Field<Int>(34);
	public static var INTERNET_RADIO_STATION : Field<String> = new Field<String>(35);
	public static var PURCHASE_DATE : Field<String> = new Field<String>(36);
	public static var GAPLESS_PLAYBACK : Field<String> = new Field<String>(37);
	public static var HD_VIDEO : Field<Bool> = new Field<Bool>(38);
	public static var LANGUAGE : Field<String> = new Field<String>(39);
	//sorting
	public static var ARTIST_SORT_TEXT : Field<String> = new Field<String>(40);
	public static var TITLE_SORT_TEXT : Field<String> = new Field<String>(41);
	public static var ALBUM_SORT_TEXT : Field<String> = new Field<String>(42);

	private var index : Int;
	
	private function new( index : Int )
	{
		this.index = index;
	}
	
	public inline function getIndex() : Int
	{
		return index;
	}
	
}
 
class MetaData 
{

	private static var STANDARD_GENRES : Array<String> = [
		"undefined",
		//IDv1 standard
		"blues",
		"classic rock",
		"country",
		"dance",
		"disco",
		"funk",
		"grunge",
		"hip hop",
		"jazz",
		"metal",
		"new age",
		"oldies",
		"other",
		"pop",
		"r and b",
		"rap",
		"reggae",
		"rock",
		"techno",
		"industrial",
		"alternative",
		"ska",
		"death metal",
		"pranks",
		"soundtrack",
		"euro techno",
		"ambient",
		"trip hop",
		"vocal",
		"jazz funk",
		"fusion",
		"trance",
		"classical",
		"instrumental",
		"acid",
		"house",
		"game",
		"sound clip",
		"gospel",
		"noise",
		"alternrock",
		"bass",
		"soul",
		"punk",
		"space",
		"meditative",
		"instrumental pop",
		"instrumental rock",
		"ethnic",
		"gothic",
		"darkwave",
		"techno industrial",
		"electronic",
		"pop folk",
		"eurodance",
		"dream",
		"southern rock",
		"comedy",
		"cult",
		"gangsta",
		"top ",
		"christian rap",
		"pop funk",
		"jungle",
		"native american",
		"cabaret",
		"new wave",
		"psychedelic",
		"rave",
		"showtunes",
		"trailer",
		"lo fi",
		"tribal",
		"acid punk",
		"acid jazz",
		"polka",
		"retro",
		"musical",
		"rock and roll",
		//winamp extension
		"hard rock",
		"folk",
		"folk rock",
		"national folk",
		"swing",
		"fast fusion",
		"bebob",
		"latin",
		"revival",
		"celtic",
		"bluegrass",
		"avantgarde",
		"gothic rock",
		"progressive rock",
		"psychedelic rock",
		"symphonic rock",
		"slow rock",
		"big band",
		"chorus",
		"easy listening",
		"acoustic",
		"humour",
		"speech",
		"chanson",
		"opera",
		"chamber music",
		"sonata",
		"symphony",
		"booty bass",
		"primus",
		"porn groove",
		"satire",
		"slow jam",
		"club",
		"tango",
		"samba",
		"folklore",
		"ballad",
		"power ballad",
		"rhythmic soul",
		"freestyle",
		"duet",
		"punk rock",
		"drum solo",
		"a capella",
		"euro house",
		"dance hall"
	];
	
	private static var NERO_TAGS : Array<String> = [
		"artist", "title", "album", "track", "totaltracks", "year", "genre",
		"disc", "totaldiscs", "url", "copyright", "comment", "lyrics",
		"credits", "rating", "label", "composer", "isrc", "mood", "tempo"
	];

	private var contents : Vector<Dynamic>;
	
	public function new()
	{
		contents = new Vector<Dynamic>();
	}

	/*moov.udta.meta:
	-ilst
	-tags
	--meta (no container!)
	--tseg
	---tshd
	 */
	public function parse(meta : Box)
	{
		//standard boxes
		if (meta.hasChild(BoxTypes.COPYRIGHT_BOX))
		{
			var cprt : CopyrightBox = cast(meta.getChild(BoxTypes.COPYRIGHT_BOX), CopyrightBox);
			put(Field.LANGUAGE, cprt.getLanguageCode());
			put(Field.COPYRIGHT, cprt.getNotice());
		}
		//if(meta.containsChild(BoxTypes.PRIMARY_ITEM_BOX)) pitm = (PrimaryItemBox) meta.getChild(BoxTypes.PRIMARY_ITEM_BOX);
		//if(meta.containsChild(BoxTypes.DATA_INFORMATION_BOX)) dinf = (ContainerBox) meta.getChild(BoxTypes.DATA_INFORMATION_BOX);
		//if(meta.containsChild(BoxTypes.ITEM_LOCATION_BOX)) iloc = (ItemLocationBox) meta.getChild(BoxTypes.ITEM_LOCATION_BOX);
		//if(meta.containsChild(BoxTypes.ITEM_PROTECTION_BOX)) ipro = (ItemProtectionBox) meta.getChild(BoxTypes.ITEM_PROTECTION_BOX);
		//if(meta.containsChild(BoxTypes.ITEM_INFORMATION_BOX)) iinf = (ItemInformationBox) meta.getChild(BoxTypes.ITEM_INFORMATION_ENTRY);
		//if(meta.hasChild(BoxTypes.IPMP_CONTROL_BOX));
		//id3, TODO: can be present in different languages
		if(meta.hasChild(BoxTypes.ID3_TAG_BOX)) parseID3(cast(meta.getChild(BoxTypes.ID3_TAG_BOX), ID3TagBox));
		//itunes
		//if(meta.hasChild(BoxTypes.ITUNES_META_LIST_BOX)) parseITunesMetaData(meta.getChild(BoxTypes.ITUNES_META_LIST_BOX));
		//nero tags
		if(meta.hasChild(BoxTypes.NERO_METADATA_TAGS_BOX)) parseNeroTags(cast(meta.getChild(BoxTypes.NERO_METADATA_TAGS_BOX), NeroMetadataTagsBox));
	}

	/*
	private void parseITunesMetaData(Box ilst)
	{
		final List<Box> boxes = ilst.getChildren();
		long l;
		ITunesMetadataBox data;
		for(Box box : boxes) {
			l = box.getType();
			data = (ITunesMetadataBox) box.getChild(BoxTypes.ITUNES_METADATA_BOX);
			if(l==BoxTypes.ARTIST_NAME_BOX) put(Field.ARTIST, data.getText());
			else if(l==BoxTypes.TRACK_NAME_BOX) put(Field.TITLE, data.getText());
			else if(l==BoxTypes.ALBUM_ARTIST_NAME_BOX) put(Field.ALBUM_ARTIST, data.getText());
			else if(l==BoxTypes.ALBUM_NAME_BOX) put(Field.ALBUM, data.getText());
			else if(l==BoxTypes.TRACK_NUMBER_BOX) {
				byte[] b = data.getData();
				put(Field.TRACK_NUMBER, new Integer(b[7]));
				put(Field.TOTAL_TRACKS, new Integer(b[9]));
			}
			else if(l==BoxTypes.DISK_NUMBER_BOX) put(Field.DISK_NUMBER, data.getInteger());
			else if(l==BoxTypes.COMPOSER_NAME_BOX) put(Field.COMPOSER, data.getText());
			else if(l==BoxTypes.COMMENTS_BOX) put(Field.COMMENTS, data.getText());
			else if(l==BoxTypes.TEMPO_BOX) put(Field.TEMPO, data.getInteger());
			else if(l==BoxTypes.RELEASE_DATE_BOX) put(Field.RELEASE_DATE, data.getDate());
			else if(l==BoxTypes.GENRE_BOX||l==BoxTypes.CUSTOM_GENRE_BOX) {
				final String s;
				if(data.getDataType()==ITunesMetadataBox.DataType.UTF8) s = data.getText();
				else s = STANDARD_GENRES[data.getInteger()];
				put(Field.GENRE, s);
			}
			else if(l==BoxTypes.ENCODER_NAME_BOX) put(Field.ENCODER_NAME, data.getText());
			else if(l==BoxTypes.ENCODER_TOOL_BOX) put(Field.ENCODER_TOOL, data.getText());
			else if(l==BoxTypes.COPYRIGHT_BOX) put(Field.COPYRIGHT, data.getText());
			else if(l==BoxTypes.COMPILATION_PART_BOX) put(Field.COMPILATION, data.getBoolean());
			else if(l==BoxTypes.COVER_BOX) {
				if(contents.containsKey(Field.COVER_ARTWORK)) get(Field.COVER_ARTWORK).add(new Artwork(Artwork.Type.forDataType(data.getDataType()), data.getData()));
				else put(Field.COVER_ARTWORK, new ArrayList<Artwork>());
			}
			else if(l==BoxTypes.GROUPING_BOX) put(Field.GROUPING, data.getText());
			else if(l==BoxTypes.LYRICS_BOX) put(Field.LYRICS, data.getText());
			else if(l==BoxTypes.RATING_BOX) put(Field.RATING, data.getInteger());
			else if(l==BoxTypes.PODCAST_BOX) put(Field.PODCAST, data.getInteger());
			else if(l==BoxTypes.PODCAST_URL_BOX) put(Field.PODCAST_URL, data.getText());
			else if(l==BoxTypes.CATEGORY_BOX) put(Field.CATEGORY, data.getText());
			else if(l==BoxTypes.KEYWORD_BOX) put(Field.KEYWORDS, data.getText());
			else if(l==BoxTypes.DESCRIPTION_BOX) put(Field.DESCRIPTION, data.getText());
			else if(l==BoxTypes.LONG_DESCRIPTION_BOX) put(Field.DESCRIPTION, data.getText());
			else if(l==BoxTypes.TV_SHOW_BOX) put(Field.TV_SHOW, data.getText());
			else if(l==BoxTypes.TV_NETWORK_NAME_BOX) put(Field.TV_NETWORK, data.getText());
			else if(l==BoxTypes.TV_EPISODE_BOX) put(Field.TV_EPISODE, data.getText());
			else if(l==BoxTypes.TV_EPISODE_NUMBER_BOX) put(Field.TV_EPISODE_NUMBER, data.getInteger());
			else if(l==BoxTypes.TV_SEASON_BOX) put(Field.TV_SEASON, data.getInteger());
			else if(l==BoxTypes.PURCHASE_DATE_BOX) put(Field.PURCHASE_DATE, data.getText());
			else if(l==BoxTypes.GAPLESS_PLAYBACK_BOX) put(Field.GAPLESS_PLAYBACK, data.getText());
			else if(l==BoxTypes.HD_VIDEO_BOX) put(Field.HD_VIDEO, data.getBoolean());
			else if(l==BoxTypes.ARTIST_SORT_BOX) put(Field.ARTIST_SORT_TEXT, data.getText());
			else if(l==BoxTypes.TRACK_SORT_BOX) put(Field.TITLE_SORT_TEXT, data.getText());
			else if(l==BoxTypes.ALBUM_SORT_BOX) put(Field.ALBUM_SORT_TEXT, data.getText());
		}
	}
	*/

	private function parseID3(box : ID3TagBox)
	{
		//final DataInputStream in = new DataInputStream(new ByteArrayInputStream(box.getID3Data()));
		var tag : ID3Tag = new ID3Tag(box.getID3Data());
		var num : Vector<Int>;
		for (frame in tag.getFrames())
		{
			switch(frame.getID())
			{
				case ID3Frame.TITLE:
					put(Field.TITLE, frame.getEncodedText());
				case ID3Frame.ALBUM_TITLE:
					put(Field.ALBUM, frame.getEncodedText());
				case ID3Frame.TRACK_NUMBER:
				{
					num = frame.getNumbers();
					put(Field.TRACK_NUMBER, num[0]);
					if (num.length > 1) put(Field.TOTAL_TRACKS, num[1]);
				}
				case ID3Frame.ARTIST:
					put(Field.ARTIST, frame.getEncodedText());
				case ID3Frame.COMPOSER:
					put(Field.COMPOSER, frame.getEncodedText());
				case ID3Frame.BEATS_PER_MINUTE:
					put(Field.TEMPO, frame.getNumber());
				case ID3Frame.LENGTH:
					put(Field.LENGTH_IN_MILLISECONDS, frame.getNumber());
				case ID3Frame.LANGUAGES:
					put(Field.LANGUAGE, frame.getLocale());
				case ID3Frame.COPYRIGHT_MESSAGE:
					put(Field.COPYRIGHT, frame.getEncodedText());
				case ID3Frame.PUBLISHER:
					put(Field.PUBLISHER, frame.getEncodedText());					
				case ID3Frame.INTERNET_RADIO_STATION_NAME:
					put(Field.INTERNET_RADIO_STATION, frame.getEncodedText());
				case ID3Frame.ENCODING_TIME:
					put(Field.ENCODING_DATE, frame.getDate());
				case ID3Frame.RELEASE_TIME:
					put(Field.RELEASE_DATE, frame.getDate());
				case ID3Frame.ENCODING_TOOLS_AND_SETTINGS:
					put(Field.ENCODER_TOOL, frame.getEncodedText());
				case ID3Frame.PERFORMER_SORT_ORDER:
					put(Field.ARTIST_SORT_TEXT, frame.getEncodedText());
				case ID3Frame.TITLE_SORT_ORDER:
					put(Field.TITLE_SORT_TEXT, frame.getEncodedText());
				case ID3Frame.ALBUM_SORT_ORDER:
					put(Field.ALBUM_SORT_TEXT, frame.getEncodedText());
			}
		}
	}

	private function parseNeroTags(tags : NeroMetadataTagsBox)
	{
		//final Map<String, String> pairs = tags.getPairs();
		var pairs : Map<String, String> = tags.getPairs();
		var val : String;
		for (key in pairs)
		{
			val = pairs.get(key);			
			if(key==(NERO_TAGS[0])) put(Field.ARTIST, val);
			if(key==(NERO_TAGS[1])) put(Field.TITLE, val);
			if(key==(NERO_TAGS[2])) put(Field.ALBUM, val);
			if(key==(NERO_TAGS[3])) put(Field.TRACK_NUMBER, Std.parseInt(val));
			if(key==(NERO_TAGS[4])) put(Field.TOTAL_TRACKS, Std.parseInt(val));
			if(key==(NERO_TAGS[5])) {
				//Calendar c = Calendar.getInstance();
				//c.set(Calendar.YEAR, Integer.parseInt(val));
				//put(Field.RELEASE_DATE, c.getTime());
				put(Field.RELEASE_DATE, "");
			}
			if(key==(NERO_TAGS[6])) put(Field.GENRE, val);
			if(key==(NERO_TAGS[7])) put(Field.DISK_NUMBER, Std.parseInt(val));
			if(key==(NERO_TAGS[8])) put(Field.TOTAL_DISKS, Std.parseInt(val));
			//if(key==(NERO_TAGS[9])); //url
			if(key==(NERO_TAGS[10])) put(Field.COPYRIGHT, val);
			if(key==(NERO_TAGS[11])) put(Field.COMMENTS, val);
			if(key==(NERO_TAGS[12])) put(Field.LYRICS, val);
			//if(key==(NERO_TAGS[13])); //credits
			if(key==(NERO_TAGS[14])) put(Field.RATING, Std.parseInt(val));
			if(key==(NERO_TAGS[15])) put(Field.PUBLISHER, val);
			if(key==(NERO_TAGS[16])) put(Field.COMPOSER, val);
			//if(key==(NERO_TAGS[17])); //isrc
			//if(key==(NERO_TAGS[18])); //mood
			if(key==(NERO_TAGS[19])) put(Field.TEMPO, Std.parseInt(val));
		}
	}

	private function put(field : Field<Dynamic>, value : Dynamic)
	{
		contents[field.getIndex()] = value;
	}

	public function get(field : Field<Dynamic>) : Dynamic
	{
		return contents[field.getIndex()];
	}
	
}