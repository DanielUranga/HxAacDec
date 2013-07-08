package mp4.api;
import haxe.io.BytesData;
import impl.Comparable;

/**
 * ...
 * @author Daniel Uranga
 */

class Frame implements Comparable
{

	public static inline var VIDEO = 0;
	public static inline var AUDIO = 1;
	
	private var type : Int;
	private var offset : Int;
	private var size : Int;
	private var time : Float;
	private var data : BytesData;

	public function new(type : Int, offset : Int, size : Int, time : Float)
	{
		this.type = type;
		this.offset = offset;
		this.size = size;
		this.time = time;
	}

	public function getType() : Int
	{
		return type;
	}

	public function getOffset() : Int
	{
		return offset;
	}

	public function getSize() : Int
	{
		return size;
	}

	public function getTime() : Float
	{
		return time;
	}

	public function compareTo(f : Comparable) : Int
	{
		return Std.int(time-(cast(f, Frame).time));
	}

	public function setData(data : BytesData)
	{
		this.data = data;
	}

	public function getData() : BytesData
	{
		return data;
	}
	
}