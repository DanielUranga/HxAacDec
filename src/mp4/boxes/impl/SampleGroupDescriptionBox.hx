package mp4.boxes.impl;
import flash.Vector;
import mp4.boxes.FullBox;
import mp4.boxes.impl.samplegroupentries.AudioSampleGroupEntry;
import mp4.boxes.impl.samplegroupentries.HintSampleGroupEntry;
import mp4.boxes.impl.samplegroupentries.SampleGroupDescriptionEntry;
import mp4.boxes.impl.samplegroupentries.VisualSampleGroupEntry;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class SampleGroupDescriptionBox extends FullBox
{
	
	private var groupingType : Int;
	private var defaultLength : Int;
	private var descriptionLength : Int;
	private var entries : Vector<SampleGroupDescriptionEntry>;

	public function new()
	{
		super("Sample Group Description Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		groupingType = input.readBytes(4);
		if (version == 1)
		{
			defaultLength = input.readBytes(4);
			left -= 4;
		}
		var entryCount : Int = input.readBytes(4);
		left -= 8;

		var hdlr : HandlerBox = cast(parent.getParent().getParent().getChild(BoxTypes.HANDLER_BOX), HandlerBox);
		var handlerType : Int = hdlr.getHandlerType();

		var boxClass : Dynamic;
		switch(handlerType)
		{
			case HandlerBox.TYPE_VIDEO:
				boxClass = VisualSampleGroupEntry;
			case HandlerBox.TYPE_SOUND:
				boxClass = AudioSampleGroupEntry;
			case HandlerBox.TYPE_HINT:
				boxClass = HintSampleGroupEntry;
			default:
				boxClass = null;
		}

		for (i in 1...entryCount)
		{
			if (version == 1 && defaultLength == 0)
			{
				descriptionLength = input.readBytes(4);
				left -= 4;
			}
			if (boxClass != null)
			{
				entries[i] = cast(BoxFactory.parseBox_(input, boxClass), SampleGroupDescriptionEntry);
				if(entries[i]!=null) left -= entries[i].getSize();
			}
		}
	}

	/**
	 * The grouping type is an integer that identifies the SampleToGroup box
	 * that is associated with this sample group description.
	 */
	public function getGroupingType() : Int
	{
		return groupingType;
	}

	/**
	 * The default length indicates the length of every group entry (if the
	 * length is constant), or zero (0) if it is variable.
	 */
	public function getDefaultLength() : Int
	{
		return defaultLength;
	}

	/**
	 * The description length indicates the length of an individual group entry,
	 * in the case it varies from entry to entry and default length is therefore 0.
	 */
	public function getDescriptionLength() : Int
	{
		return descriptionLength;
	}
}