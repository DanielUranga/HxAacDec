package mp4.boxes;

/**
 * ...
 * @author Daniel Uranga
 */

class BoxTypes 
{

	public static inline var EXTENDED_TYPE : UInt = 1970628964;
	//standard boxes (ISO BMFF)
	public static inline var ADDITIONAL_METADATA_CONTAINER_BOX : UInt = 1835361135; //meco
	public static inline var BINARY_XML_BOX : UInt = 1652059500; //bxml
	public static inline var BIT_RATE_BOX : UInt = 1651798644; //btrt
	public static inline var CHUNK_OFFSET_BOX : UInt = 1937007471; //stco
	public static inline var CHUNK_LARGE_OFFSET_BOX : UInt = 1668232756; //co64
	public static inline var CLEAN_APERTURE_BOX : UInt = 1668047216; //clap
	public static inline var COMPACT_SAMPLE_SIZE_BOX : UInt = 1937013298; //stz2
	public static inline var COMPOSITION_TIME_TO_SAMPLE_BOX : UInt = 1668576371; //ctts
	public static inline var COPYRIGHT_BOX : UInt = 1668313716; //cprt
	public static inline var DATA_ENTRY_URN_BOX : UInt = 1970433568; //urn
	public static inline var DATA_ENTRY_URL_BOX : UInt = 1970433056; //url
	public static inline var DATA_INFORMATION_BOX : UInt = 1684631142; //dinf
	public static inline var DATA_REFERENCE_BOX : UInt = 1685218662; //dref
	public static inline var DECODING_TIME_TO_SAMPLE_BOX : UInt = 1937011827; //stts
	public static inline var DEGRADATION_PRIORITY_BOX : UInt = 1937007728; //stdp
	public static inline var EDIT_BOX : UInt = 1701082227; //edts
	public static inline var EDIT_LIST_BOX : UInt = 1701606260; //elst
	public static inline var FILE_TYPE_BOX : UInt = 1718909296; //ftyp
	public static inline var FREE_SPACE_BOX : UInt = 1718773093; //free
	public static inline var HANDLER_BOX : UInt = 1751411826; //hdlr
	public static inline var HINT_MEDIA_HEADER_BOX : UInt = 1752000612; //hmhd
	public static inline var IPMP_CONTROL_BOX : UInt = 1768975715; //ipmc
	public static inline var ITEM_INFORMATION_BOX : UInt = 1768517222; //iinf
	public static inline var ITEM_INFORMATION_ENTRY : UInt = 1768842853; //infe
	public static inline var ITEM_LOCATION_BOX : UInt = 1768714083; //iloc
	public static inline var ITEM_PROTECTION_BOX : UInt = 1768977007; //ipro
	public static inline var MEDIA_BOX : UInt = 1835297121; //mdia
	public static inline var MEDIA_DATA_BOX : UInt = 1835295092; //mdat
	public static inline var MEDIA_HEADER_BOX : UInt = 1835296868; //mdhd
	public static inline var MEDIA_INFORMATION_BOX : UInt = 1835626086; //minf
	public static inline var META_BOX : UInt = 1835365473; //meta
	public static inline var META_BOX_RELATION_BOX : UInt = 1835364965; //mere
	public static inline var MOVIE_BOX : UInt = 1836019574; //moov
	public static inline var MOVIE_EXTENDS_BOX : UInt = 1836475768; //mvex
	public static inline var MOVIE_EXTENDS_HEADER_BOX : UInt = 1835362404; //mehd
	public static inline var MOVIE_FRAGMENT_BOX : UInt = 1836019558; //moof
	public static inline var MOVIE_FRAGMENT_HEADER_BOX : UInt = 1835427940; //mfhd
	public static inline var MOVIE_HEADER_BOX : UInt = 1836476516; //mvhd
	public static inline var NERO_METADATA_TAGS_BOX : UInt = 1952540531; //tags
	public static inline var NULL_MEDIA_HEADER_BOX : UInt = 1852663908; //nmhd
	public static inline var PADDING_BIT_BOX : UInt = 1885430882; //padb
	public static inline var PIXEL_ASPECT_RATIO_BOX : UInt = 1885434736; //pasp
	public static inline var PRIMARY_ITEM_BOX : UInt = 1885959277; //pitm
	public static inline var PROGRESSIVE_DOWNLOAD_INFORMATION_BOX : UInt = 1885628782; //pdin
	public static inline var SAMPLE_DEPENDENCY_TYPE_BOX : UInt = 1935963248; //sdtp
	public static inline var SAMPLE_DESCRIPTION_BOX : UInt = 1937011556; //stsd
	public static inline var SAMPLE_GROUP_DESCRIPTION_BOX : UInt = 1936158820; //sgpd
	public static inline var SAMPLE_SCALE_BOX : UInt = 1937011564; //stsl
	public static inline var SAMPLE_SIZE_BOX : UInt = 1937011578; //stsz
	public static inline var SAMPLE_TABLE_BOX : UInt = 1937007212; //stbl
	public static inline var SAMPLE_TO_CHUNK_BOX : UInt = 1937011555; //stsc
	public static inline var SAMPLE_TO_GROUP_BOX : UInt = 1935828848; //sbgp
	public static inline var SCHEME_TYPE_BOX : UInt = 1935894637; //schm
	public static inline var SCHEME_INFORMATION_BOX : UInt = 1935894633; //schi
	public static inline var SHADOW_SYNC_SAMPLE_BOX : UInt = 1937011560; //stsh
	public static inline var SKIP_BOX : UInt = 1936419184; //skip
	public static inline var SOUND_MEDIA_HEADER_BOX : UInt = 1936549988; //smhd
	public static inline var SUB_SAMPLE_INFORMATION_BOX : UInt = 1937072755; //subs
	public static inline var SYNC_SAMPLE_BOX : UInt = 1937011571; //stss
	public static inline var TRACK_BOX : UInt = 1953653099; //trak
	public static inline var TRACK_EXTENDS_BOX : UInt = 1953654136; //trex
	public static inline var TRACK_FRAGMENT_BOX : UInt = 1953653094; //traf
	public static inline var TRACK_FRAGMENT_HEADER_BOX : UInt = 1952868452; //tfhd
	public static inline var TRACK_FRAGMENT_RUN_BOX : UInt = 1953658222; //trun
	public static inline var TRACK_HEADER_BOX : UInt = 1953196132; //tkhd
	public static inline var TRACK_REFERENCE_BOX : UInt = 1953654118; //tref
	public static inline var TRACK_SELECTION_BOX : UInt = 1953719660; //tsel
	public static inline var USER_DATA_BOX : UInt = 1969517665; //udta
	public static inline var VIDEO_MEDIA_HEADER_BOX : UInt = 1986881636; //vmhd
	public static inline var XML_BOX : UInt = 2020437024; //xml
	//mp4 extension
	public static inline var OBJECT_DESCRIPTOR_BOX : UInt = 1768907891; //iods
	public static inline var SAMPLE_DEPENDENCY_BOX : UInt = 1935959408; //sdep
	//metadata extensions
	//id3
	public static inline var ID3_TAG_BOX : UInt = 1768174386; //id32
	//itunes
	public static inline var ITUNES_META_LIST_BOX : UInt = 1768715124; //ilst
	public static inline var CUSTOM_ITUNES_METADATA_BOX : UInt = 757935405; //----
	public static inline var ITUNES_METADATA_BOX : UInt = 1684108385; //data
	public static inline var ITUNES_METADATA_NAME_BOX : UInt = 1851878757; //name
	public static inline var ALBUM_ARTIST_NAME_BOX : UInt = 1631670868; //aART
	public static inline var ALBUM_ARTIST_SORT_BOX : UInt = 1936679265; //soaa
	public static inline var ALBUM_NAME_BOX : UInt = 0xA9616C62; //2841734242; //©alb
	public static inline var ALBUM_SORT_BOX : UInt = 1936679276; //soal
	public static inline var ARTIST_NAME_BOX : UInt = 0xA9415254; //2839630420; //©ART
	public static inline var ARTIST_SORT_BOX : UInt = 1936679282; //soar
	public static inline var CATEGORY_BOX : UInt = 1667331175; //catg
	public static inline var COMMENTS_BOX : UInt = 0xA9636D74; //2841865588; //©cmt
	public static inline var COMPILATION_PART_BOX : UInt = 1668311404; //cpil
	public static inline var COMPOSER_NAME_BOX : UInt = 0xA9777274; //2843177588; //©wrt
	public static inline var COMPOSER_SORT_BOX : UInt = 1936679791; //soco
	public static inline var COVER_BOX : UInt = 1668249202; //covr
	public static inline var CUSTOM_GENRE_BOX : UInt = 0xA967656E; //2842125678; //©gen
	public static inline var DESCRIPTION_BOX : UInt = 1684370275; //desc
	public static inline var DISK_NUMBER_BOX : UInt = 1684632427; //disk
	public static inline var ENCODER_NAME_BOX : UInt = 0xA9656E63; //2841996899; //©enc
	public static inline var ENCODER_TOOL_BOX : UInt = 0xA9746F6F; //2842980207; //©too
	public static inline var EPISODE_GLOBAL_UNIQUE_ID_BOX : UInt = 1701276004; //egid
	public static inline var GAPLESS_PLAYBACK_BOX : UInt = 1885823344; //pgap
	public static inline var GENRE_BOX : UInt = 1735291493; //gnre
	public static inline var GROUPING_BOX : UInt = 0xA9677270; //2842129008; //©grp
	public static inline var HD_VIDEO_BOX : UInt = 1751414372; //hdvd
	public static inline var ITUNES_PURCHASE_ACCOUNT_BOX : UInt = 1634748740; //apID
	public static inline var ITUNES_ACCOUNT_TYPE_BOX : UInt = 1634421060; //akID
	public static inline var ITUNES_CATALOGUE_ID_BOX : UInt = 1668172100; //cnID
	public static inline var ITUNES_COUNTRY_CODE_BOX : UInt = 1936083268; //sfID
	public static inline var KEYWORD_BOX : UInt = 1801812343; //keyw
	public static inline var LONG_DESCRIPTION_BOX : UInt = 1818518899; //ldes
	public static inline var LYRICS_BOX : UInt = 0xA96C7972; //2842458482; //©lyr
	public static inline var META_TYPE_BOX : UInt = 1937009003; //stik
	public static inline var PODCAST_BOX : UInt = 1885565812; //pcst
	public static inline var PODCAST_URL_BOX : UInt = 1886745196; //purl
	public static inline var PURCHASE_DATE_BOX : UInt = 1886745188; //purd
	public static inline var RATING_BOX : UInt = 1920233063; //rtng
	public static inline var RELEASE_DATE_BOX : UInt = 0xA9646179; //2841928057; //©day
	public static inline var TEMPO_BOX : UInt = 1953329263; //tmpo
	public static inline var TRACK_NAME_BOX : UInt = 0xA96E616D; //2842583405; //©nam
	public static inline var TRACK_NUMBER_BOX : UInt = 1953655662; //trkn
	public static inline var TRACK_SORT_BOX : UInt = 1936682605; //sonm
	public static inline var TV_EPISODE_BOX : UInt = 1953916275; //tves
	public static inline var TV_EPISODE_NUMBER_BOX : UInt = 1953916270; //tven
	public static inline var TV_NETWORK_NAME_BOX : UInt = 1953918574; //tvnn
	public static inline var TV_SEASON_BOX : UInt = 1953919854; //tvsn
	public static inline var TV_SHOW_BOX : UInt = 1953919848; //tvsh
	public static inline var TV_SHOW_SORT_BOX : UInt = 1936683886; //sosn
	//sample entries
	public static inline var MP4V_SAMPLE_ENTRY : UInt = 1836070006; //mp4v
	public static inline var H263_SAMPLE_ENTRY : UInt = 1932670515; //s263
	public static inline var AVC_SAMPLE_ENTRY : UInt = 1635148593; //avc1
	public static inline var MP4A_SAMPLE_ENTRY : UInt = 1836069985; //mp4a
	public static inline var AMR_SAMPLE_ENTRY : UInt = 1935764850; //samr
	public static inline var AMR_WB_SAMPLE_ENTRY : UInt = 1935767394; //sawb
	public static inline var EVRC_SAMPLE_ENTRY : UInt = 1936029283; //sevc
	public static inline var QCELP_SAMPLE_ENTRY : UInt = 1936810864; //sqcp
	public static inline var SMV_SAMPLE_ENTRY : UInt = 1936944502; //ssmv
	public static inline var MPEG_SAMPLE_ENTRY : UInt = 1836070003; //mp4s
	public static inline var TEXT_METADATA_SAMPLE_ENTRY : UInt = 1835365492; //mett
	public static inline var XML_METADATA_SAMPLE_ENTRY : UInt = 1835365496; //metx
	//codec infos
	public static inline var ESD_BOX : UInt = 1702061171; //esds
	//video codecs
	public static inline var H263_SPECIFIC_BOX : UInt = 1681012275; //d263
	public static inline var AVC_SPECIFIC_BOX : UInt = 1635148611; //avcC
	//audio codecs
	public static inline var AMR_SPECIFIC_BOX : UInt = 1684106610; //damr
	public static inline var EVRC_SPECIFIC_BOX : UInt = 1684371043; //devc
	public static inline var QCELP_SPECIFIC_BOX : UInt = 1685152624; //dqcp
	public static inline var SMV_SPECIFIC_BOX : UInt = 1685286262; //dsmv
	
}