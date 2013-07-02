/*
 *  Copyright (C) 2011 in-somnia
 * 
 *  This file is part of JAAD.
 * 
 *  JAAD is free software; you can redistribute it and/or modify it 
 *  under the terms of the GNU Lesser General Public License as 
 *  published by the Free Software Foundation; either version 3 of the 
 *  License, or (at your option) any later version.
 *
 *  JAAD is distributed in the hope that it will be useful, but WITHOUT 
 *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
 *  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General 
 *  Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public
 *  License astatic var with this library.
 *  If not, see <http://www.gnu.org/licenses/>.
 */
package mp4.boxes;

public class BoxTypes
{

	static var EXTENDED_TYPE = 1970628964; //uuid
	//standard boxes (ISO BMFF)
	static var ADDITIONAL_METADATA_CONTAINER_BOX = 1835361135l; //meco
	static var APPLE_LOSSLESS_BOX = 1634492771l; //alac
	static var BINARY_XML_BOX = 1652059500l; //bxml
	static var BIT_RATE_BOX = 1651798644l; //btrt
	static var CHAPTER_BOX = 1667788908l; //chpl
	static var CHUNK_OFFSET_BOX = 1937007471l; //stco
	static var CHUNK_LARGE_OFFSET_BOX = 1668232756l; //co64
	static var CLEAN_APERTURE_BOX = 1668047216l; //clap
	static var COMPACT_SAMPLE_SIZE_BOX = 1937013298l; //stz2
	static var COMPOSITION_TIME_TO_SAMPLE_BOX = 1668576371l; //ctts
	static var COPYRIGHT_BOX = 1668313716l; //cprt
	static var DATA_ENTRY_URN_BOX = 1970433568l; //urn 
	static var DATA_ENTRY_URL_BOX = 1970433056l; //url 
	static var DATA_INFORMATION_BOX = 1684631142l; //dinf
	static var DATA_REFERENCE_BOX = 1685218662l; //dref
	static var DECODING_TIME_TO_SAMPLE_BOX = 1937011827l; //stts
	static var DEGRADATION_PRIORITY_BOX = 1937007728l; //stdp
	static var EDIT_BOX = 1701082227l; //edts
	static var EDIT_LIST_BOX = 1701606260l; //elst
	static var FD_ITEM_INFORMATION_BOX = 1718184302l; //fiin
	static var FD_SESSION_GROUP_BOX = 1936025458l; //segr
	static var FEC_RESERVOIR_BOX = 1717920626l; //fecr
	static var FILE_PARTITION_BOX = 1718641010l; //fpar
	static var FILE_TYPE_BOX = 1718909296l; //ftyp
	static var FREE_SPACE_BOX = 1718773093l; //free
	static var GROUP_ID_TO_NAME_BOX = 1734964334l; //gitn
	static var HANDLER_BOX = 1751411826l; //hdlr
	static var HINT_MEDIA_HEADER_BOX = 1752000612l; //hmhd
	static var IPMP_CONTROL_BOX = 1768975715l; //ipmc
	static var IPMP_INFO_BOX = 1768778086l; //imif
	static var ITEM_INFORMATION_BOX = 1768517222l; //iinf
	static var ITEM_INFORMATION_ENTRY = 1768842853l; //infe
	static var ITEM_LOCATION_BOX = 1768714083l; //iloc
	static var ITEM_PROTECTION_BOX = 1768977007l; //ipro
	static var MEDIA_BOX = 1835297121l; //mdia
	static var MEDIA_DATA_BOX = 1835295092l; //mdat
	static var MEDIA_HEADER_BOX = 1835296868l; //mdhd
	static var MEDIA_INFORMATION_BOX = 1835626086l; //minf
	static var META_BOX = 1835365473l; //meta
	static var META_BOX_RELATION_BOX = 1835364965l; //mere
	static var MOVIE_BOX = 1836019574l; //moov
	static var MOVIE_EXTENDS_BOX = 1836475768l; //mvex
	static var MOVIE_EXTENDS_HEADER_BOX = 1835362404l; //mehd
	static var MOVIE_FRAGMENT_BOX = 1836019558l; //moof
	static var MOVIE_FRAGMENT_HEADER_BOX = 1835427940l; //mfhd
	static var MOVIE_FRAGMENT_RANDOM_ACCESS_BOX = 1835430497l; //mfra
	static var MOVIE_FRAGMENT_RANDOM_ACCESS_OFFSET_BOX = 1835430511l; //mfro
	static var MOVIE_HEADER_BOX = 1836476516l; //mvhd
	static var NERO_METADATA_TAGS_BOX = 1952540531l; //tags
	static var NULL_MEDIA_HEADER_BOX = 1852663908l; //nmhd
	static var ORIGINAL_FORMAT_BOX = 1718775137l; //frma
	static var PADDING_BIT_BOX = 1885430882l; //padb
	static var PARTITION_ENTRY = 1885431150l; //paen
	static var PIXEL_ASPECT_RATIO_BOX = 1885434736l; //pasp
	static var PRIMARY_ITEM_BOX = 1885959277l; //pitm
	static var PROGRESSIVE_DOWNLOAD_INFORMATION_BOX = 1885628782l; //pdin
	static var PROTECTION_SCHEME_INFORMATION_BOX = 1936289382l; //sinf
	static var SAMPLE_DEPENDENCY_TYPE_BOX = 1935963248l; //sdtp
	static var SAMPLE_DESCRIPTION_BOX = 1937011556l; //stsd
	static var SAMPLE_GROUP_DESCRIPTION_BOX = 1936158820l; //sgpd
	static var SAMPLE_SCALE_BOX = 1937011564l; //stsl
	static var SAMPLE_SIZE_BOX = 1937011578l; //stsz
	static var SAMPLE_TABLE_BOX = 1937007212l; //stbl
	static var SAMPLE_TO_CHUNK_BOX = 1937011555l; //stsc
	static var SAMPLE_TO_GROUP_BOX = 1935828848l; //sbgp
	static var SCHEME_TYPE_BOX = 1935894637l; //schm
	static var SCHEME_INFORMATION_BOX = 1935894633l; //schi
	static var SHADOW_SYNC_SAMPLE_BOX = 1937011560l; //stsh
	static var SKIP_BOX = 1936419184l; //skip
	static var SOUND_MEDIA_HEADER_BOX = 1936549988l; //smhd
	static var SUB_SAMPLE_INFORMATION_BOX = 1937072755l; //subs
	static var SYNC_SAMPLE_BOX = 1937011571l; //stss
	static var TRACK_BOX = 1953653099l; //trak
	static var TRACK_EXTENDS_BOX = 1953654136l; //trex
	static var TRACK_FRAGMENT_BOX = 1953653094l; //traf
	static var TRACK_FRAGMENT_HEADER_BOX = 1952868452l; //tfhd
	static var TRACK_FRAGMENT_RANDOM_ACCESS_BOX = 1952871009l; //tfra
	static var TRACK_FRAGMENT_RUN_BOX = 1953658222l; //trun
	static var TRACK_HEADER_BOX = 1953196132l; //tkhd
	static var TRACK_REFERENCE_BOX = 1953654118l; //tref
	static var TRACK_SELECTION_BOX = 1953719660l; //tsel
	static var USER_DATA_BOX = 1969517665l; //udta
	static var VIDEO_MEDIA_HEADER_BOX = 1986881636l; //vmhd
	static var WIDE_BOX = 2003395685l; //wide
	static var XML_BOX = 2020437024l; //xml 
	//mp4 extension
	static var OBJECT_DESCRIPTOR_BOX = 1768907891l; //iods
	static var SAMPLE_DEPENDENCY_BOX = 1935959408l; //sdep
	//metadata: id3
	static var ID3_TAG_BOX = 1768174386l; //id32
	//metadata: itunes
	static var ITUNES_META_LIST_BOX = 1768715124l; //ilst
	static var CUSTOM_ITUNES_METADATA_BOX = 757935405l; //----
	static var ITUNES_METADATA_BOX = 1684108385l; //data
	static var ITUNES_METADATA_NAME_BOX = 1851878757l; //name
	static var ITUNES_METADATA_MEAN_BOX = 1835360622l; //mean
	static var ALBUM_ARTIST_NAME_BOX = 1631670868l; //aART
	static var ALBUM_ARTIST_SORT_BOX = 1936679265l; //soaa 
	static var ALBUM_NAME_BOX = 2841734242l; //©alb
	static var ALBUM_SORT_BOX = 1936679276l; //soal
	static var ARTIST_NAME_BOX = 2839630420l; //©ART
	static var ARTIST_SORT_BOX = 1936679282l; //soar
	static var CATEGORY_BOX = 1667331175l; //catg
	static var COMMENTS_BOX = 2841865588l; //©cmt
	static var COMPILATION_PART_BOX = 1668311404l; //cpil 
	static var COMPOSER_NAME_BOX = 2843177588l; //©wrt
	static var COMPOSER_SORT_BOX = 1936679791l; //soco
	static var COVER_BOX = 1668249202l; //covr
	static var CUSTOM_GENRE_BOX = 2842125678l; //©gen
	static var DESCRIPTION_BOX = 1684370275l; //desc
	static var DISK_NUMBER_BOX = 1684632427l; //disk
	static var ENCODER_NAME_BOX = 2841996899l; //©enc
	static var ENCODER_TOOL_BOX = 2842980207l; //©too
	static var EPISODE_GLOBAL_UNIQUE_ID_BOX = 1701276004l; //egid
	static var GAPLESS_PLAYBACK_BOX = 1885823344l; //pgap
	static var GENRE_BOX = 1735291493l; //gnre
	static var GROUPING_BOX = 2842129008l; //©grp
	static var HD_VIDEO_BOX = 1751414372l; //hdvd
	static var ITUNES_PURCHASE_ACCOUNT_BOX = 1634748740l; //apID
	static var ITUNES_ACCOUNT_TYPE_BOX = 1634421060l; //akID
	static var ITUNES_CATALOGUE_ID_BOX = 1668172100l; //cnID
	static var ITUNES_COUNTRY_CODE_BOX = 1936083268l; //sfID
	static var KEYWORD_BOX = 1801812343l; //keyw
	static var static var_DESCRIPTION_BOX = 1818518899l; //ldes
	static var LYRICS_BOX = 2842458482l; //©lyr
	static var META_TYPE_BOX = 1937009003l; //stik
	static var PODCAST_BOX = 1885565812l; //pcst
	static var PODCAST_URL_BOX = 1886745196l; //purl
	static var PURCHASE_DATE_BOX = 1886745188l; //purd
	static var RATING_BOX = 1920233063l; //rtng
	static var RELEASE_DATE_BOX = 2841928057l; //©day
	static var REQUIREMENT_BOX = 2842846577l; //©req
	static var TEMPO_BOX = 1953329263l; //tmpo
	static var TRACK_NAME_BOX = 2842583405l; //©nam
	static var TRACK_NUMBER_BOX = 1953655662l; //trkn
	static var TRACK_SORT_BOX = 1936682605l; //sonm
	static var TV_EPISODE_BOX = 1953916275l; //tves
	static var TV_EPISODE_NUMBER_BOX = 1953916270l; //tven
	static var TV_NETWORK_NAME_BOX = 1953918574l; //tvnn
	static var TV_SEASON_BOX = 1953919854l; //tvsn
	static var TV_SHOW_BOX = 1953919848l; //tvsh
	static var TV_SHOW_SORT_BOX = 1936683886l; //sosn
	//metadata: 3gpp
	static var THREE_GPP_ALBUM_BOX = 1634493037l; //albm
	static var THREE_GPP_AUTHOR_BOX = 1635087464l; //auth
	static var THREE_GPP_CLASSIFICATION_BOX = 1668051814l; //clsf
	static var THREE_GPP_DESCRIPTION_BOX = 1685283696l; //dscp
	static var THREE_GPP_KEYWORDS_BOX = 1803122532l; //kywd
	static var THREE_GPP_LOCATION_INFORMATION_BOX = 1819239273l; //loci
	static var THREE_GPP_PERFORMER_BOX = 1885696614l; //perf
	static var THREE_GPP_RECORDING_YEAR_BOX = 2037543523l; //yrrc
	static var THREE_GPP_TITLE_BOX = 1953068140l; //titl
	//metadata: google/youtube
	static var GOOGLE_HOST_HEADER_BOX = 1735616616l; //gshh
	static var GOOGLE_PING_MESSAGE_BOX = 1735618669l; //gspm
	static var GOOGLE_PING_URL_BOX = 1735618677l; //gspu
	static var GOOGLE_SOURCE_DATA_BOX = 1735619428l; //gssd
	static var GOOGLE_START_TIME_BOX = 1735619444l; //gsst
	static var GOOGLE_TRACK_DURATION_BOX = 1735619684l; //gstd
	//sample entries
	static var MP4V_SAMPLE_ENTRY = 1836070006l; //mp4v
	static var H263_SAMPLE_ENTRY = 1932670515l; //s263
	static var ENCRYPTED_VIDEO_SAMPLE_ENTRY = 1701733238l; //encv
	static var AVC_SAMPLE_ENTRY = 1635148593l; //avc1
	static var MP4A_SAMPLE_ENTRY = 1836069985l; //mp4a
	static var AC3_SAMPLE_ENTRY = 1633889587l; //ac-3
	static var EAC3_SAMPLE_ENTRY = 1700998451l; //ec-3
	static var DRMS_SAMPLE_ENTRY = 1685220723l; //drms
	static var AMR_SAMPLE_ENTRY = 1935764850l; //samr
	static var AMR_WB_SAMPLE_ENTRY = 1935767394l; //sawb
	static var EVRC_SAMPLE_ENTRY = 1936029283l; //sevc
	static var QCELP_SAMPLE_ENTRY = 1936810864l; //sqcp
	static var SMV_SAMPLE_ENTRY = 1936944502l; //ssmv
	static var ENCRYPTED_AUDIO_SAMPLE_ENTRY = 1701733217l; //enca
	static var MPEG_SAMPLE_ENTRY = 1836070003l; //mp4s
	static var TEXT_METADATA_SAMPLE_ENTRY = 1835365492l; //mett
	static var XML_METADATA_SAMPLE_ENTRY = 1835365496l; //metx
	static var RTP_HINT_SAMPLE_ENTRY = 1920233504l; //rtp 
	static var FD_HINT_SAMPLE_ENTRY = 1717858336l; //fdp 
	//codec infos
	static var ESD_BOX = 1702061171l; //esds
	//video codecs
	static var H263_SPECIFIC_BOX = 1681012275l; //d263
	static var AVC_SPECIFIC_BOX = 1635148611l; //avcC
	//audio codecs
	static var AC3_SPECIFIC_BOX = 1684103987l; //dac3
	static var EAC3_SPECIFIC_BOX = 1684366131l; //dec3
	static var AMR_SPECIFIC_BOX = 1684106610l; //damr
	static var EVRC_SPECIFIC_BOX = 1684371043l; //devc
	static var QCELP_SPECIFIC_BOX = 1685152624l; //dqcp
	static var SMV_SPECIFIC_BOX = 1685286262l; //dsmv
	//OMA DRM
	static var OMA_ACCESS_UNIT_FORMAT_BOX = 1868849510l; //odaf
	static var OMA_COMMON_HEADERS_BOX = 1869112434l; //ohdr
	static var OMA_CONTENT_ID_BOX = 1667459428l; //ccid
	static var OMA_CONTENT_OBJECT_BOX = 1868850273l; //odda
	static var OMA_COVER_URI_BOX = 1668706933l; //cvru
	static var OMA_DISCRETE_MEDIA_HEADERS_BOX = 1868851301l; //odhe
	static var OMA_DRM_CONTAINER_BOX = 1868853869l; //odrm
	static var OMA_ICON_URI_BOX = 1768124021l; //icnu
	static var OMA_INFO_URL_BOX = 1768842869l; //infu
	static var OMA_LYRICS_URI_BOX = 1819435893l; //lrcu
	static var OMA_MUTABLE_DRM_INFORMATION_BOX = 1835299433l; //mdri
	static var OMA_KEY_MANAGEMENT_BOX = 1868852077l; //odkm
	static var OMA_RIGHTS_OBJECT_BOX = 1868853858l; //odrb
	static var OMA_TRANSACTION_TRACKING_BOX = 1868854388l; //odtt
	//iTunes DRM (FairPlay)
	static var FAIRPLAY_USER_ID_BOX = 1970496882l; //user
	static var FAIRPLAY_USER_NAME_BOX = 1851878757l; //name
	static var FAIRPLAY_USER_KEY_BOX = 1801812256l; //key 
	static var FAIRPLAY_IV_BOX = 1769367926l; //iviv
	static var FAIRPLAY_PRIVATE_KEY_BOX = 1886546294l; //priv
	
}
