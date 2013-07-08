package mp4.boxes.impl;
import flash.Vector;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class ItemLocationBox extends FullBox
{

	private var itemID : Vector<Int>;
	private var dataReferenceIndex : Vector<Int>;
	private var baseOffset : Vector<Int>;
	private var extentOffset : Vector<Vector<Int>>;
	private var extentLength : Vector<Vector<Int>>;

	public function new()
	{
		super("Item Location Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		/*4 bits offsetSize
		4 bits lengthSize
		4 bits baseOffsetSize
		4 bits reserved
		 */
		var l : Int = input.readBytes(2);
		var offsetSize : Int = (l>>12)&0xF;
		var lengthSize : Int = (l>>8)&0xF;
		var baseOffsetSize : Int = (l>>4)&0xF;

		var itemCount : Int = input.readBytes(2);
		left -= 4;
		dataReferenceIndex = new Vector<Int>(itemCount);
		baseOffset = new Vector<Int>(itemCount);
		extentOffset = new Vector<Vector<Int>>(itemCount);
		extentLength = new Vector<Vector<Int>>(itemCount);
		
		var extentCount : Int;
		for (i in 0...itemCount)
		{
			itemID[i] = input.readBytes(2);
			dataReferenceIndex[i] = input.readBytes(2);
			baseOffset[i] = input.readBytes(baseOffsetSize);

			extentCount = input.readBytes(2);
			left -= 6+baseOffsetSize;
			extentOffset[i] = new Vector<Int>(extentCount);
			extentLength[i] = new Vector<Int>(extentCount);

			for (j in 0...extentCount)
			{
				extentOffset[i][j] = input.readBytes(offsetSize);
				extentLength[i][j] = input.readBytes(lengthSize);
				left -= offsetSize+lengthSize;
			}
		}
	}

	/**
	 * The item ID is an arbitrary integer 'name' for this resource which can be
	 * used to refer to it (e.g. in a URL).
	 *
	 * @return the item ID
	 */
	public function getItemID() : Vector<Int>
	{
		return itemID;
	}

	/**
	 * The data reference index is either zero ('this file') or a 1-based index
	 * into the data references in the data information box.
	 *
	 * @return the data reference index
	 */
	public function getDataReferenceIndex() : Vector<Int>
	{
		return dataReferenceIndex;
	}

	/**
	 * The base offset provides a base value for offset calculations within the 
	 * referenced data.
	 * 
	 * @return the base offsets for all items
	 */
	public function getBaseOffset() : Vector<Int>
	{
		return baseOffset;
	}

	/**
	 * The extent offset provides the absolute offset in bytes from the
	 * beginning of the containing file, of this item.
	 *
	 * @return the offsets for all extents in all items
	 */
	public function getExtentOffset() : Vector<Vector<Int>>
	{
		return extentOffset;
	}

	/**
	 * The extends length provides the absolute length in bytes of this metadata
	 * item. If the value is 0, then length of the item is the length of the
	 * entire referenced file.
	 *
	 * @return the lengths for all extends in all items
	 */
	public function getExtentLength() : Vector<Vector<Int>>
	{
		return extentLength;
	}
	
}