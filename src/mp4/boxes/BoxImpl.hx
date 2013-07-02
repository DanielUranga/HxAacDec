package mp4.boxes;

import net.sourceforge.jaad.mp4.MP4InputStream;

public class BoxImpl implements Box
{

	var name : String;
	var size : Int;
	var type : Int;
	var offset : Int;
	var parent : Box;
	var children : Array<Box>;

	public function new(name : String)
	{
		this.name = name;
		children = [null, null, null, null];
	}

	public function setParams(parent : Box, size : Int, type : Int, offset : Int)
	{
		this.size = size;
		this.type = type;
		this.parent = parent;
		this.offset = offset;
	}

	function getLeft(in_ : MP4InputStream ) : Int
	{
		return (offset+size)-in_.getOffset();
	}

	/**
	 * Decodes the given input stream by reading this box and all of its
	 * children (if any).
	 * 
	 * @param in an input stream
	 * @throws IOException if an error occurs while reading
	 */
	public void decode(MP4InputStream in)
	{
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

	public function toString() :String
	{
		return name+" ["+BoxFactory.typeToString(type)+"]";
	}

	//container methods
	public function hasChildren() : Bool
	{
		return children.size()>0;
	}

	public function hasChild(type : Int) : Bool
	{
		var b = false;
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
		while (box == null && i < children.size())
		{
			b = children.get(i);
			if(b.getType()==type) box = b;
			i++;
		}
		return box;
	}

	public function getChildren() : List<Box>
	{
		//return Collections.unmodifiableList(children);
		return children.copy();
	}

	public function getChildren(long type) : List<Box>
	{
		var l = new Array<Box>();
		for (box in children)
		{
			if(box.getType()==type) l.add(box);
		}
		return l;
	}

	function readChildren(in_ : mp4.MP4InputStream) 
	{
		var box : Box;
		while (in_.getOffset() < (offset + size))
		{
			box = BoxFactory.parseBox(this, in_);
			children.add(box);
		}
	}

	function readChildren(in_ : mp4.MP4InputStream, len : Int)
	{
		var box : Box;
		for (i in 0...len)
		{
			box = BoxFactory.parseBox(this, in_);
			children.add(box);
		}
	}
}
