package mp4.boxes;
import flash.Vector;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class BoxImpl implements Box
{

	private var name : String;
	private var size : Int;
	private var type : Int;
	private var left : Int;
	private var offset : Int;
	private var parent : Box;
	private var children : Vector<Box>;

	public function new(name : String)
	{
		this.name = name;
		children = new Vector<Box>();
	}
	
	public function setParams_(parent : Box, size : Int, type : Int, offset : Int)
	{
		this.size = size;
		this.type = type;
		this.parent = parent;
	}

	public function setParams(parent : Box, size : Int, type : Int, offset : Int, left : Int)
	{
		this.size = size;
		this.type = type;
		this.parent = parent;
		this.left = left;
	}

	public function getLeft()
	{
		return left;
	}

	/**
	 * Decodes the specified input stream by reading this box and all of its
	 * children (if any) and returns the number of bytes left in the box (which
	 * should be normally 0).
	 * @param in an input stream
	 * @throws IOException if an reading error occurs
	 */
	public function decode(input : MP4InputStream)
	{
		readChildren(input);
	}

	public function getType() : Int
	{
		return type;
	}

	public function getSize() : Int
	{
		return size;
	}

	public function getOffset() : Int
	{
		return offset;
	}

	public function getParent() : Box
	{
		return parent;
	}

	public function getName() : String
	{
		return name;
	}

	public function toString() : String
	{
		//return name+" ["+BoxFactory.typeToString(type)+"]";
		return "";
	}

	//container methods
	public function hasChildren() : Bool
	{
		return children.length>0;
	}

	public function hasChild(type : Int) : Bool
	{
		var b : Bool = false;
		for (box in children)
		{
			if (box.getType() == type)
			{
				b = true;
				break;
			}
		}
		return b;
	}

	public function getChild(type : Int) : Box
	{
		var box : Box = null;
		var b : Box = null;
		var i : Int = 0;
		while (box == null && i < cast(children.length, Int))
		{
			b = children[i];
			if(b.getType()==type) box = b;
			i++;
		}
		return box;
	}

	public function getAllChildren() : Vector<Box>
	{
		return children;
	}

	public function getChildren(type : Int) : Vector<Box>
	{
		var l : Vector<Box> = new Vector<Box>();
		for (box in children)
		{
			if(box.getType()==type) l.push(box);
		}
		return l;
	}

	private function readChildren(input : MP4InputStream)
	{
		var box : Box = null;
		while (left > 0)
		{
			box = BoxFactory.parseBox(this, input);
			left -= box.getSize();
			children.push(box);
		}
	}

	private function readChildren_(input : MP4InputStream, len : Int)
	{
		var box : Box = null;
		for (i in 0...len)
		{
			box = BoxFactory.parseBox(this, input);
			left -= box.getSize();
			children.push(box);
		}
	}
	
}