package mp4.boxes;
import flash.Vector;
import mp4.boxes.impl.BinaryXMLBox;
import mp4.boxes.impl.BitRateBox;
import mp4.boxes.impl.ChunkOffsetBox;
import mp4.boxes.impl.CleanApertureBox;
import mp4.boxes.impl.CompositionTimeToSampleBox;
import mp4.boxes.impl.CopyrightBox;
import mp4.boxes.impl.DataEntryUrlBox;
import mp4.boxes.impl.DataEntryUrnBox;
import mp4.boxes.impl.DataReferenceBox;
import mp4.boxes.impl.DecodingTimeToSampleBox;
import mp4.boxes.impl.DegradationPriorityBox;
import mp4.boxes.impl.EditListBox;
import mp4.boxes.impl.FileTypeBox;
import mp4.boxes.impl.FreeSpaceBox;
import mp4.boxes.impl.HandlerBox;
import mp4.boxes.impl.HintMediaHeaderBox;
import mp4.boxes.impl.IPMPControlBox;
import mp4.boxes.impl.ItemInformationBox;
import mp4.boxes.impl.ItemInformationEntry;
import mp4.boxes.impl.ItemLocationBox;
import mp4.boxes.impl.ItemProtectionBox;
import mp4.boxes.impl.MediaDataBox;
import mp4.boxes.impl.MediaHeaderBox;
import mp4.boxes.impl.meta.ID3TagBox;
import mp4.boxes.impl.meta.NeroMetadataTagsBox;
import mp4.boxes.impl.MetaBox;
import mp4.boxes.impl.MetaBoxRelationBox;
import mp4.boxes.impl.MovieExtendsHeaderBox;
import mp4.boxes.impl.MovieFragmentHeaderBox;
import mp4.boxes.impl.MovieHeaderBox;
import mp4.boxes.impl.ObjectDescriptorBox;
import mp4.boxes.impl.PaddingBitBox;
import mp4.boxes.impl.PixelAspectRatioBox;
import mp4.boxes.impl.PrimaryItemBox;
import mp4.boxes.impl.ProgressiveDownloadInformationBox;
import mp4.boxes.impl.SampleDependencyBox;
import mp4.boxes.impl.SampleDependencyTypeBox;
import mp4.boxes.impl.SampleDescriptionBox;
import mp4.boxes.impl.sampleentries.AudioSampleEntry;
import mp4.boxes.impl.sampleentries.codec.CodecSpecificBox;
import mp4.boxes.impl.sampleentries.MPEGSampleEntry;
import mp4.boxes.impl.sampleentries.VideoSampleEntry;
import mp4.boxes.impl.sampleentries.TextMetadataSampleEntry;
import mp4.boxes.impl.sampleentries.XMLMetadataSampleEntry;
import mp4.boxes.impl.SampleGroupDescriptionBox;
import mp4.boxes.impl.SampleScaleBox;
import mp4.boxes.impl.SampleSizeBox;
import mp4.boxes.impl.SampleToChunkBox;
import mp4.boxes.impl.SampleToGroupBox;
import mp4.boxes.impl.SchemeTypeBox;
import mp4.boxes.impl.ShadowSyncSampleBox;
import mp4.boxes.impl.SkipBox;
import mp4.boxes.impl.SoundMediaHeaderBox;
import mp4.boxes.impl.SubSampleInformationBox;
import mp4.boxes.impl.SyncSampleBox;
import mp4.boxes.impl.TrackExtendsBox;
import mp4.boxes.impl.TrackFragmentHeaderBox;
import mp4.boxes.impl.TrackFragmentRunBox;
import mp4.boxes.impl.TrackHeaderBox;
import mp4.boxes.impl.TrackReferenceBox;
import mp4.boxes.impl.TrackSelectionBox;
import mp4.boxes.impl.VideoMediaHeaderBox;
import mp4.boxes.impl.XMLBox;
import mp4.boxes.od.ESDBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class BoxFactory 
{

	private static var BOX_CLASSES : Map<Int, Dynamic>;
	private static var PARAMETER : Map<Int, String>;
	
	public static function initialize()
	{
		BOX_CLASSES = new Map<Int, Dynamic>();
		PARAMETER = new Map<Int, String>();
		//classes
		BOX_CLASSES.set(BoxTypes.ADDITIONAL_METADATA_CONTAINER_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.BINARY_XML_BOX, BinaryXMLBox);
		BOX_CLASSES.set(BoxTypes.BIT_RATE_BOX, BitRateBox);
		BOX_CLASSES.set(BoxTypes.CHUNK_OFFSET_BOX, ChunkOffsetBox);
		BOX_CLASSES.set(BoxTypes.CHUNK_LARGE_OFFSET_BOX, ChunkOffsetBox);
		BOX_CLASSES.set(BoxTypes.CLEAN_APERTURE_BOX, CleanApertureBox);
		BOX_CLASSES.set(BoxTypes.COMPACT_SAMPLE_SIZE_BOX, SampleSizeBox);
		BOX_CLASSES.set(BoxTypes.COMPOSITION_TIME_TO_SAMPLE_BOX, CompositionTimeToSampleBox);
		BOX_CLASSES.set(BoxTypes.COPYRIGHT_BOX, CopyrightBox);
		BOX_CLASSES.set(BoxTypes.DATA_ENTRY_URN_BOX, DataEntryUrnBox);
		BOX_CLASSES.set(BoxTypes.DATA_ENTRY_URL_BOX, DataEntryUrlBox);
		BOX_CLASSES.set(BoxTypes.DATA_INFORMATION_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.DATA_REFERENCE_BOX, DataReferenceBox);
		BOX_CLASSES.set(BoxTypes.DECODING_TIME_TO_SAMPLE_BOX, DecodingTimeToSampleBox);
		BOX_CLASSES.set(BoxTypes.DEGRADATION_PRIORITY_BOX, DegradationPriorityBox);
		BOX_CLASSES.set(BoxTypes.EDIT_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.EDIT_LIST_BOX, EditListBox);
		BOX_CLASSES.set(BoxTypes.FILE_TYPE_BOX, FileTypeBox);
		BOX_CLASSES.set(BoxTypes.FREE_SPACE_BOX, FreeSpaceBox);
		BOX_CLASSES.set(BoxTypes.HANDLER_BOX, HandlerBox);
		BOX_CLASSES.set(BoxTypes.HINT_MEDIA_HEADER_BOX, HintMediaHeaderBox);
		BOX_CLASSES.set(BoxTypes.IPMP_CONTROL_BOX, IPMPControlBox);
		BOX_CLASSES.set(BoxTypes.ITEM_INFORMATION_BOX, ItemInformationBox);
		BOX_CLASSES.set(BoxTypes.ITEM_INFORMATION_ENTRY, ItemInformationEntry);
		BOX_CLASSES.set(BoxTypes.ITEM_LOCATION_BOX, ItemLocationBox);
		BOX_CLASSES.set(BoxTypes.ITEM_PROTECTION_BOX, ItemProtectionBox);
		BOX_CLASSES.set(BoxTypes.MEDIA_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.MEDIA_DATA_BOX, MediaDataBox);
		BOX_CLASSES.set(BoxTypes.MEDIA_HEADER_BOX, MediaHeaderBox);
		BOX_CLASSES.set(BoxTypes.MEDIA_INFORMATION_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.META_BOX, MetaBox);
		BOX_CLASSES.set(BoxTypes.META_BOX_RELATION_BOX, MetaBoxRelationBox);
		BOX_CLASSES.set(BoxTypes.MOVIE_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.MOVIE_EXTENDS_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.MOVIE_EXTENDS_HEADER_BOX, MovieExtendsHeaderBox);
		BOX_CLASSES.set(BoxTypes.MOVIE_FRAGMENT_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.MOVIE_FRAGMENT_HEADER_BOX, MovieFragmentHeaderBox);
		BOX_CLASSES.set(BoxTypes.MOVIE_HEADER_BOX, MovieHeaderBox);
		BOX_CLASSES.set(BoxTypes.NERO_METADATA_TAGS_BOX, NeroMetadataTagsBox);
		BOX_CLASSES.set(BoxTypes.NULL_MEDIA_HEADER_BOX, FullBox);
		BOX_CLASSES.set(BoxTypes.PADDING_BIT_BOX, PaddingBitBox);
		BOX_CLASSES.set(BoxTypes.PIXEL_ASPECT_RATIO_BOX, PixelAspectRatioBox);
		BOX_CLASSES.set(BoxTypes.PRIMARY_ITEM_BOX, PrimaryItemBox);
		BOX_CLASSES.set(BoxTypes.PROGRESSIVE_DOWNLOAD_INFORMATION_BOX, ProgressiveDownloadInformationBox);
		BOX_CLASSES.set(BoxTypes.SAMPLE_DEPENDENCY_TYPE_BOX, SampleDependencyTypeBox);
		BOX_CLASSES.set(BoxTypes.SAMPLE_DESCRIPTION_BOX, SampleDescriptionBox);
		BOX_CLASSES.set(BoxTypes.SAMPLE_GROUP_DESCRIPTION_BOX, SampleGroupDescriptionBox);
		BOX_CLASSES.set(BoxTypes.SAMPLE_SCALE_BOX, SampleScaleBox);
		BOX_CLASSES.set(BoxTypes.SAMPLE_SIZE_BOX, SampleSizeBox);
		BOX_CLASSES.set(BoxTypes.SAMPLE_TABLE_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.SAMPLE_TO_CHUNK_BOX, SampleToChunkBox);
		BOX_CLASSES.set(BoxTypes.SAMPLE_TO_GROUP_BOX, SampleToGroupBox);
		BOX_CLASSES.set(BoxTypes.SCHEME_TYPE_BOX, SchemeTypeBox);
		BOX_CLASSES.set(BoxTypes.SCHEME_INFORMATION_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.SHADOW_SYNC_SAMPLE_BOX, ShadowSyncSampleBox);
		BOX_CLASSES.set(BoxTypes.SKIP_BOX, SkipBox);
		BOX_CLASSES.set(BoxTypes.SOUND_MEDIA_HEADER_BOX, SoundMediaHeaderBox);
		BOX_CLASSES.set(BoxTypes.SUB_SAMPLE_INFORMATION_BOX, SubSampleInformationBox);
		BOX_CLASSES.set(BoxTypes.SYNC_SAMPLE_BOX, SyncSampleBox);
		BOX_CLASSES.set(BoxTypes.TRACK_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.TRACK_EXTENDS_BOX, TrackExtendsBox);
		BOX_CLASSES.set(BoxTypes.TRACK_FRAGMENT_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.TRACK_FRAGMENT_HEADER_BOX, TrackFragmentHeaderBox);
		BOX_CLASSES.set(BoxTypes.TRACK_FRAGMENT_RUN_BOX, TrackFragmentRunBox);
		BOX_CLASSES.set(BoxTypes.TRACK_HEADER_BOX, TrackHeaderBox);
		BOX_CLASSES.set(BoxTypes.TRACK_REFERENCE_BOX, TrackReferenceBox);
		BOX_CLASSES.set(BoxTypes.TRACK_SELECTION_BOX, TrackSelectionBox);
		BOX_CLASSES.set(BoxTypes.USER_DATA_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.VIDEO_MEDIA_HEADER_BOX, VideoMediaHeaderBox);
		BOX_CLASSES.set(BoxTypes.XML_BOX, XMLBox);
		BOX_CLASSES.set(BoxTypes.OBJECT_DESCRIPTOR_BOX, ObjectDescriptorBox);
		BOX_CLASSES.set(BoxTypes.SAMPLE_DEPENDENCY_BOX, SampleDependencyBox);
		BOX_CLASSES.set(BoxTypes.ID3_TAG_BOX, ID3TagBox);
		BOX_CLASSES.set(BoxTypes.ITUNES_META_LIST_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.CUSTOM_ITUNES_METADATA_BOX, BoxImpl);
		//BOX_CLASSES.set(BoxTypes.ITUNES_METADATA_BOX, ITunesMetadataBox);
		//BOX_CLASSES.set(BoxTypes.ITUNES_METADATA_NAME_BOX, ITunesMetadataNameBox);
		BOX_CLASSES.set(BoxTypes.ALBUM_ARTIST_NAME_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.ALBUM_ARTIST_SORT_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.ALBUM_NAME_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.ALBUM_SORT_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.ARTIST_NAME_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.ARTIST_SORT_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.CATEGORY_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.COMMENTS_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.COMPILATION_PART_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.COMPOSER_NAME_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.COMPOSER_SORT_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.COVER_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.CUSTOM_GENRE_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.DESCRIPTION_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.DISK_NUMBER_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.ENCODER_NAME_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.ENCODER_TOOL_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.EPISODE_GLOBAL_UNIQUE_ID_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.GAPLESS_PLAYBACK_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.GENRE_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.GROUPING_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.HD_VIDEO_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.ITUNES_PURCHASE_ACCOUNT_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.ITUNES_ACCOUNT_TYPE_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.ITUNES_CATALOGUE_ID_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.ITUNES_COUNTRY_CODE_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.KEYWORD_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.LONG_DESCRIPTION_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.LYRICS_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.META_TYPE_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.PODCAST_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.PODCAST_URL_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.PURCHASE_DATE_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.RATING_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.RELEASE_DATE_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.TEMPO_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.TRACK_NAME_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.TRACK_NUMBER_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.TRACK_SORT_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.TV_EPISODE_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.TV_EPISODE_NUMBER_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.TV_NETWORK_NAME_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.TV_SEASON_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.TV_SHOW_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.TV_SHOW_SORT_BOX, BoxImpl);
		BOX_CLASSES.set(BoxTypes.MP4V_SAMPLE_ENTRY, VideoSampleEntry);
		BOX_CLASSES.set(BoxTypes.H263_SAMPLE_ENTRY, VideoSampleEntry);
		BOX_CLASSES.set(BoxTypes.AVC_SAMPLE_ENTRY, VideoSampleEntry);
		BOX_CLASSES.set(BoxTypes.MP4A_SAMPLE_ENTRY, AudioSampleEntry);
		BOX_CLASSES.set(BoxTypes.AMR_SAMPLE_ENTRY, AudioSampleEntry);
		BOX_CLASSES.set(BoxTypes.AMR_WB_SAMPLE_ENTRY, AudioSampleEntry);
		BOX_CLASSES.set(BoxTypes.EVRC_SAMPLE_ENTRY, AudioSampleEntry);
		BOX_CLASSES.set(BoxTypes.QCELP_SAMPLE_ENTRY, AudioSampleEntry);
		BOX_CLASSES.set(BoxTypes.SMV_SAMPLE_ENTRY, AudioSampleEntry);
		BOX_CLASSES.set(BoxTypes.MPEG_SAMPLE_ENTRY, MPEGSampleEntry);
		BOX_CLASSES.set(BoxTypes.TEXT_METADATA_SAMPLE_ENTRY, TextMetadataSampleEntry);
		BOX_CLASSES.set(BoxTypes.XML_METADATA_SAMPLE_ENTRY, XMLMetadataSampleEntry);
		BOX_CLASSES.set(BoxTypes.ESD_BOX, ESDBox);
		BOX_CLASSES.set(BoxTypes.H263_SPECIFIC_BOX, CodecSpecificBox);
		BOX_CLASSES.set(BoxTypes.AVC_SPECIFIC_BOX, CodecSpecificBox);
		BOX_CLASSES.set(BoxTypes.AMR_SPECIFIC_BOX, CodecSpecificBox);
		BOX_CLASSES.set(BoxTypes.EVRC_SPECIFIC_BOX, CodecSpecificBox);
		BOX_CLASSES.set(BoxTypes.QCELP_SPECIFIC_BOX, CodecSpecificBox);
		BOX_CLASSES.set(BoxTypes.SMV_SPECIFIC_BOX, CodecSpecificBox);
		//parameter		
		PARAMETER.set(BoxTypes.ADDITIONAL_METADATA_CONTAINER_BOX, "Additional Metadata Container Box");
		PARAMETER.set(BoxTypes.DATA_INFORMATION_BOX, "Data Information Box");
		PARAMETER.set(BoxTypes.EDIT_BOX, "Edit Box");
		PARAMETER.set(BoxTypes.MEDIA_BOX, "Media Box");
		PARAMETER.set(BoxTypes.MEDIA_INFORMATION_BOX, "Media Information Box");
		PARAMETER.set(BoxTypes.MOVIE_BOX, "Movie Box");
		PARAMETER.set(BoxTypes.MOVIE_EXTENDS_BOX, "Movie Extends Box");
		PARAMETER.set(BoxTypes.MOVIE_FRAGMENT_BOX, "Movie Fragment Box");
		PARAMETER.set(BoxTypes.NULL_MEDIA_HEADER_BOX, "Null Media Header Box");
		PARAMETER.set(BoxTypes.SAMPLE_TABLE_BOX, "Sample Table Box");
		PARAMETER.set(BoxTypes.SCHEME_INFORMATION_BOX, "Scheme Information Box");
		PARAMETER.set(BoxTypes.TRACK_BOX, "Track Box");
		PARAMETER.set(BoxTypes.TRACK_FRAGMENT_BOX, "Track Fragment Box");
		PARAMETER.set(BoxTypes.USER_DATA_BOX, "User Data Box");
		PARAMETER.set(BoxTypes.ITUNES_META_LIST_BOX, "iTunes Meta List Box");
		PARAMETER.set(BoxTypes.CUSTOM_ITUNES_METADATA_BOX, "Custom iTunes Metadata Box");
		PARAMETER.set(BoxTypes.ALBUM_ARTIST_NAME_BOX, "Album Artist Name Box");
		PARAMETER.set(BoxTypes.ALBUM_ARTIST_SORT_BOX, "Album Artist Sort Box");
		PARAMETER.set(BoxTypes.ALBUM_NAME_BOX, "Album Name Box");
		PARAMETER.set(BoxTypes.ALBUM_SORT_BOX, "Album Sort Box");
		PARAMETER.set(BoxTypes.ARTIST_NAME_BOX, "Artist Name Box");
		PARAMETER.set(BoxTypes.ARTIST_SORT_BOX, "Artist Sort Box");
		PARAMETER.set(BoxTypes.CATEGORY_BOX, "Category Box");
		PARAMETER.set(BoxTypes.COMMENTS_BOX, "Comments Box");
		PARAMETER.set(BoxTypes.COMPILATION_PART_BOX, "Compilation Part Box");
		PARAMETER.set(BoxTypes.COMPOSER_NAME_BOX, "Composer Name Box");
		PARAMETER.set(BoxTypes.COMPOSER_SORT_BOX, "Composer Sort Box");
		PARAMETER.set(BoxTypes.COVER_BOX, "Cover Box");
		PARAMETER.set(BoxTypes.CUSTOM_GENRE_BOX, "Custom Genre Box");
		PARAMETER.set(BoxTypes.DESCRIPTION_BOX, "Description Cover Box");
		PARAMETER.set(BoxTypes.DISK_NUMBER_BOX, "Disk Number Box");
		PARAMETER.set(BoxTypes.ENCODER_NAME_BOX, "Encoder Name Box");
		PARAMETER.set(BoxTypes.ENCODER_TOOL_BOX, "Encoder Tool Box");
		PARAMETER.set(BoxTypes.EPISODE_GLOBAL_UNIQUE_ID_BOX, "Episode Global Unique ID Box");
		PARAMETER.set(BoxTypes.GAPLESS_PLAYBACK_BOX, "Gapless Playback Box");
		PARAMETER.set(BoxTypes.GENRE_BOX, "Genre Box");
		PARAMETER.set(BoxTypes.GROUPING_BOX, "Grouping Box");
		PARAMETER.set(BoxTypes.HD_VIDEO_BOX, "HD Video Box");
		PARAMETER.set(BoxTypes.ITUNES_PURCHASE_ACCOUNT_BOX, "iTunes Purchase Account Box");
		PARAMETER.set(BoxTypes.ITUNES_ACCOUNT_TYPE_BOX, "iTunes Account Type Box");
		PARAMETER.set(BoxTypes.ITUNES_CATALOGUE_ID_BOX, "iTunes Catalogue ID Box");
		PARAMETER.set(BoxTypes.ITUNES_COUNTRY_CODE_BOX, "iTunes Country Code Box");
		PARAMETER.set(BoxTypes.KEYWORD_BOX, "Keyword Box");
		PARAMETER.set(BoxTypes.LONG_DESCRIPTION_BOX, "Long Description Box");
		PARAMETER.set(BoxTypes.LYRICS_BOX, "Lyrics Box");
		PARAMETER.set(BoxTypes.META_TYPE_BOX, "Meta Type Box");
		PARAMETER.set(BoxTypes.PODCAST_BOX, "Podcast Box");
		PARAMETER.set(BoxTypes.PODCAST_URL_BOX, "Podcast URL Box");
		PARAMETER.set(BoxTypes.PURCHASE_DATE_BOX, "Purchase Date Box");
		PARAMETER.set(BoxTypes.RATING_BOX, "Rating Box");
		PARAMETER.set(BoxTypes.RELEASE_DATE_BOX, "Release Date Box");
		PARAMETER.set(BoxTypes.TEMPO_BOX, "Tempo Box");
		PARAMETER.set(BoxTypes.TRACK_NAME_BOX, "Track Name Box");
		PARAMETER.set(BoxTypes.TRACK_NUMBER_BOX, "Track Number Box");
		PARAMETER.set(BoxTypes.TRACK_SORT_BOX, "Track Sort Box");
		PARAMETER.set(BoxTypes.TV_EPISODE_BOX, "TV Episode Box");
		PARAMETER.set(BoxTypes.TV_EPISODE_NUMBER_BOX, "TV Episode Number Box");
		PARAMETER.set(BoxTypes.TV_NETWORK_NAME_BOX, "TV Network Name Box");
		PARAMETER.set(BoxTypes.TV_SEASON_BOX, "TV Season Box");
		PARAMETER.set(BoxTypes.TV_SHOW_BOX, "TV Show Box");
		PARAMETER.set(BoxTypes.TV_SHOW_SORT_BOX, "TV Show Sort Box");
	}

	static var depth : Int = -1;
	
	public static function parseBox(parent : Box, input : MP4InputStream) : Box
	{
		depth++;
		var offset : Int = input.getOffset();
		
		var size : Int = input.readBytes(4);
		var left : Int = size-4;
		
		//trace("Left: " + left);
		
		if (size == 1)
		{
			size = input.readBytes(8);
			left -= 8;
		}
		var type : Int = input.readBytes(4);
		
		left -= 4;
		
		if (type == BoxTypes.EXTENDED_TYPE)
		{
			type = input.readBytes(16);
			left -= 16;
		}
		
		var box : BoxImpl = forType(type);
		box.setParams(parent, size, type, offset, left);
		box.decode(input);
		
		//if mdat found and no random access, don't skip
		left = box.getLeft();
		//if(left<0) LOGGER.log(Level.WARNING, "box: {0}, left: {1}, offset: {2}", {typeToString(type), Long.toString(left), Long.toString(in.getOffset())});
		var str = "";
		for (i in 0...depth)	str += i;
		trace(str+" SKIP " + left + " : " + box.getName() + " : size="+size + " : type="+box.getType() + " : childs="+box.getAllChildren().length + " : offset=" + input.getOffset());
		if (box.getType() != BoxTypes.MEDIA_DATA_BOX || input.hasRandomAccess()) input.skipBytes(left);
		
		depth--;
		return box;
		
		/*
		var offset : Int = in_.getOffset();
		
		var size = in_.readBytes(4);
		var type = in_.readBytes(4);
		if(size==1) size = in_.readBytes(8);
		if(type==BoxTypes.EXTENDED_TYPE) in_.skipBytes(16);
        
        trace("Size: " + size);
        
		//error protection
		if (parent != null)
		{
			var parentLeft = (parent.getOffset()+parent.getSize())-offset;
			if(size>parentLeft) throw ("error while decoding box '"+type+"' at offset "+offset+": box too large for parent");
		}
		
		//Logger.getLogger("MP4 Boxes").finest(typeToString(type));
		
		trace("for type");
		var box : BoxImpl = forType(type
		//, in_.getOffset()
		);
		box.setParams_(parent, size, type, offset);
		trace("pre decode");
		
		box.decode(in_);
		trace("post decode");
		
		//check bytes left
		var left = (box.getOffset() + box.getSize()) - in_.getOffset();
		
		if(left>0
			&&!(Std.is(box, MediaDataBox))
			&&!(Std.is(box, UnknownBox))
			&&!(Std.is(box, FreeSpaceBox)))
		{
			//LOGGER.log(Level.INFO, "bytes left after reading box {0}: left: {1}, offset: {2}", new Object[] { typeToString(type), left, in.getOffset() } );
		}
		else if (left < 0)
		{
			//LOGGER.log(Level.SEVERE, "box {0} overread: {1} bytes, offset: {2}", new Object[] { typeToString(type), -left, in.getOffset() } );
		}

		//if mdat found and no random access, don't skip
		if(box.getType()!=BoxTypes.MEDIA_DATA_BOX||in_.hasRandomAccess()) in_.skipBytes(left);
		return box;
		*/
	}

	//TODO: remove usages
	public static function parseBox_(input : MP4InputStream, boxClass : Dynamic) : Box
	{
		var offset : Int = input.getOffset();

		var size : Int = input.readBytes(4);
		var left : Int = size-4;
		if (size == 1)
		{
			size = input.readBytes(8);
			left -= 8;
		}
		var type : Int = input.readBytes(4);
		left -= 4;
		if (type == BoxTypes.EXTENDED_TYPE)
		{
			type = input.readBytes(16);
			left -= 16;
		}

		var box : BoxImpl = cast(Type.createInstance(boxClass,[]), BoxImpl);
		/*
		try {
			box = boxClass.newInstance();
		}
		catch(InstantiationException e) {
		}
		catch(IllegalAccessException e) {
		}
		*/

		if (box != null)
		{
			box.setParams(null, size, type, offset, left);
			box.decode(input);
			input.skipBytes(box.getLeft());
			//DEBUG:
			//System.out.println(box.getShortName());
		}
		return box;
	}

	private static function forType(type : Int) : BoxImpl
	{
		var box : Dynamic = null;

		if (BOX_CLASSES.exists(type))
		{
			var cl : Dynamic = BOX_CLASSES.get(type);
			if (PARAMETER.exists(type))
			{
				var s : String = PARAMETER.get(type);
				try
				{
					/*
					Constructor<? extends BoxImpl> con = cl.getConstructor(String);
					box = con.newInstance(s[0]);
					*/
					box = Type.createInstance(cl, [s]);					
				}
				catch (e : Dynamic)
				{
					//LOGGER.log(Level.WARNING, "could not call constructor for "+typeToString(type), e);
					trace("could not call constructor for "+type);
					box = new UnknownBox();
				}
			}
			else
			{
				try
				{
					box = Type.createInstance(cl, []);
				}
				catch (e : Dynamic)
				{
					//LOGGER.log(Level.WARNING, "could not instantiate box "+typeToString(type), e);
					trace("could not instantiate box "+type);
				}
			}
		}

		if (box == null) box = new UnknownBox();
		//trace(cast(box, BoxImpl).getName());
		return box;
	}

	/*
	public static String typeToString(long l) {
		byte[] b = new byte[4];
		b[0] = (byte) ((l>>24)&0xFF);
		b[1] = (byte) ((l>>16)&0xFF);
		b[2] = (byte) ((l>>8)&0xFF);
		b[3] = (byte) (l&0xFF);
		return new String(b);
	}
	*/
	
}