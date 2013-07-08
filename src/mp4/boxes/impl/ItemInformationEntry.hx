package mp4.boxes.impl;
import flash.Vector;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class Extension
{

	private static inline var TYPE_FDEL : Int = 1717855596; //fdel

	public static function forType(type : Int) : Extension
	{
		var ext : Extension;
		switch(type)
		{
			case Extension.TYPE_FDEL:
				ext = new FDExtension();
			default:
				ext = null;
		}
		return ext;
	}

	//returns the number of bytes read
	public function decode_(input : MP4InputStream) : Int
	{
		return 0;
	}
}

class FDExtension extends Extension
{

	private var contentLocation : String;
	private var contentMD5: String;
	private var contentLength : Int;
	private var transferLength : Int;
	private var groupID : Vector<Int>;

	public function new()
	{
		
	}
	
	override public function decode_(input : MP4InputStream) : Int
	{
		contentLocation = input.readUTFString(100, MP4InputStream.UTF8);
		contentMD5 = input.readUTFString(100, MP4InputStream.UTF8);

		contentLength = input.readBytes(8);
		transferLength = input.readBytes(8);

		var entryCount : Int = input.read();
		groupID = new Vector<Int>(entryCount);
		for (i in 0...entryCount)
		{
			groupID[i] = input.readBytes(4);
		}

		return contentLocation.length+contentMD5.length+19+(entryCount*4);
	}

	/**
	 * The content location is a String in containing the URI of the file as
	 * defined in HTTP/1.1 (RFC 2616).
	 *
	 * @return the content location
	 */
	public function getContentLocation() : String
	{
		return contentLocation;
	}

	/**
	 * The content MD5 is a string containing an MD5 digest of the file. See
	 * HTTP/1.1 (RFC 2616) and RFC 1864.
	 *
	 * @return the content MD5
	 */
	public function getContentMD5() : String
	{
		return contentMD5;
	}

	/**
	 * The total length (in bytes) of the (un-encoded) file.
	 *
	 * @return the content length
	 */
	public function getContentLength() : Int
	{
		return contentLength;
	}

	/**
	 * The transfer length is the total length (in bytes) of the (encoded)
	 * file. Note that transfer length is equal to content length if no
	 * content encoding is applied (see above).
	 *
	 * @return the transfer length
	 */
	public function getTransferLength() : Int
	{
		return transferLength;
	}

	/**
	 * The group ID indicates a file group to which the file item (source
	 * file) belongs. See 3GPP TS 26.346 for more details on file groups.
	 *
	 * @return the group IDs
	 */
	public function getGroupID() : Vector<Int>
	{
		return groupID;
	}
	
}
 
class ItemInformationEntry extends FullBox
{

	private var itemID : Int;
	private var itemProtectionIndex : Int;
	private var itemName : String;
	private var contentType : String;
	private var contentEncoding : String;
	private var extensionType : Int;
	private var extension : Extension;

	public function new()
	{
		super("Item Information Entry");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		if ((version == 0) || (version == 1))
		{
			itemID = input.readBytes(2);
			itemProtectionIndex = input.readBytes(2);
			left -= 4;
			itemName = input.readUTFString(left, MP4InputStream.UTF8);
			left -= itemName.length+1;
			contentType = input.readUTFString(left, MP4InputStream.UTF8);
			left -= contentType.length+1;
			contentEncoding = input.readUTFString(left, MP4InputStream.UTF8); //optional
			left -= contentEncoding.length+1;
		}
		if (version == 1 && left > 0)
		{
			//optional
			extensionType = input.readBytes(4);
			left -= 4;
			if (left > 0)
			{
				extension = Extension.forType(extensionType);
				if(extension!=null) left -= extension.decode_(input);
			}
		}
	}

	/**
	 * The item ID contains either 0 for the primary resource (e.g., the XML
	 * contained in an 'xml ' box) or the ID of the item for which the following
	 * information is defined.
	 *
	 * @return the item ID
	 */
	public function getItemID() : Int
	{
		return itemID;
	}

	/**
	 * The item protection index contains either 0 for an unprotected item, or
	 * the one-based index into the item protection box defining the protection
	 * applied to this item (the first box in the item protection box has the
	 * index 1).
	 *
	 * @return the item protection index
	 */
	public function getItemProtectionIndex() : Int
	{
		return itemProtectionIndex;
	}

	/**
	 * The item name is a String containing a symbolic name of the item (source
	 * file for file delivery transmissions).
	 *
	 * @return the item name
	 */
	public function getItemName() : String
	{
		return itemName;
	}

	/**
	 * The content type is a String with the MIME type of the item. If the item 
	 * is content encoded (see below), then the content type refers to the item 
	 * after content decoding.
	 * 
	 * @return the content type
	 */
	public function getContentType() : String
	{
		return contentType;
	}

	/**
	 * The content encoding is an optional String used to indicate that the
	 * binary file is encoded and needs to be decoded before interpreted. The
	 * values are as defined for Content-Encoding for HTTP/1.1. Some possible
	 * values are "gzip", "compress" and "deflate". An empty string indicates no
	 * content encoding. Note that the item is stored after the content encoding
	 * has been applied.
	 *
	 * @return the content encoding
	 */
	public function getContentEncoding() : String
	{
		return contentEncoding;
	}

	/**
	 * The extension type is a printable four-character code that identifies the
	 * extension fields of version 1 with respect to version 0 of the item 
	 * information entry.
	 * 
	 * @return the extension type
	 */
	public function getExtensionType() : Int
	{
		return extensionType;
	}

	/**
	 * Returns the extension.
	 */
	public function getExtension() : Extension
	{
		return extension;
	}
	
}