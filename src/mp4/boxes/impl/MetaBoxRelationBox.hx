package mp4.boxes.impl;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class MetaBoxRelationBox extends FullBox
{

	private var firstMetaboxHandlerType : Int;
	private var secondMetaboxHandlerType : Int;
	private var metaboxRelation : Int;

	public function new()
	{
		super("Meta Box Relation Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		firstMetaboxHandlerType = input.readBytes(4);
		secondMetaboxHandlerType = input.readBytes(4);
		metaboxRelation = input.read();
		left -= 9;
	}

	/**
	 * The first meta box to be related.
	 */
	public function getFirstMetaboxHandlerType() : Int
	{
		return firstMetaboxHandlerType;
	}

	/**
	 * The second meta box to be related.
	 */
	public function getSecondMetaboxHandlerType() : Int
	{
		return secondMetaboxHandlerType;
	}

	/**
	 * The metabox relation indicates the relation between the two meta boxes.
	 * The following values are defined:
	 * <ol start="1">
	 * <li>The relationship between the boxes is unknown (which is the default
	 * when this box is not present)</li>
	 * <li>the two boxes are semantically un-related (e.g., one is presentation,
	 * the other annotation)</li>
	 * <li>the two boxes are semantically related but complementary (e.g., two
	 * disjoint sets of meta-data expressed in two different meta-data systems)
	 * </li>
	 * <li>the two boxes are semantically related but overlap (e.g., two sets of
	 * meta-data neither of which is a subset of the other); neither is
	 * 'preferred' to the other</li>
	 * <li>the two boxes are semantically related but the second is a proper
	 * subset or weaker version of the first; the first is preferred</li>
	 * <li>the two boxes are semantically related and equivalent (e.g., two
	 * essentially identical sets of meta-data expressed in two different
	 * meta-data systems)</li>
	 * </ol>
	 */
	public function getMetaboxRelation() : Int
	{
		return metaboxRelation;
	}
	
}