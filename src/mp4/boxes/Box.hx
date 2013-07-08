package mp4.boxes;
import flash.Vector;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

interface Box
{
	
	public function getParent() : Box;

	public function decode(input : MP4InputStream) : Void;

	/**
	 * Returns the size of this box including its header.
	 *
	 * @return this box's size
	 */
	public function getSize() : Int;

	/**
	 * Returns the type of this box as a 4CC converted to a long.
	 * 
	 * @return this box's type
	 */
	public function getType() : Int;

	/**
	 * Returns the offset of this box in the stream/file. This is needed as a
	 * seek point for random access.
	 *
	 * @return this box's offset
	 */
	public function getOffset() : Int;

	/**
	 * Returns the name of this box as a human-readable string 
	 * (e.g. "Track Header Box").
	 *
	 * @return this box's name
	 */
	public function getName() : String;

	/**
	 * Indicates if this box has children.
	 *
	 * @return true if this box contains at least one child
	 */
	public function hasChildren() : Bool;

	/**
	 * Indicated if the box has a child with the given type.
	 *
	 * @param type the type of child box to look for
	 * @return true if this box contains at least one child with the given type
	 */
	public function hasChild(type : Int) : Bool;

	/**
	 * Returns an ordered and unmodifiable list of all direct children of this
	 * box. The list does not contain the children's children.
	 *
	 * @return this box's children
	 */
	public function getAllChildren() : Vector<Box>;

	/**
	 * Returns an ordered and unmodifiable list of all direct children of this
	 * box with the specified type. The list does not contain the children's
	 * children. If there is no child with the given type, the list will be
	 * empty.
	 *
	 * @param type the type of child boxes to look for
	 * @return this box's children with the given type
	 */
	public function getChildren(type : Int) : Vector<Box>;

	/**
	 * Returns the child box with the specified type. If this box has no child
	 * with the given type, null is returned. To check if there is such a child
	 * <code>hasChild(type)</code> can be used.
	 * If more than one child exists with the same type, the first one will
	 * always be returned. A list of all children with that type can be received
	 * via <code>getChildren(type)</code>.
	 *
	 * @param type the type of child box to look for
	 * @return the first child box with the given type, or null if none is found
	 */
	public function getChild(type : Int) : Box;
	
}