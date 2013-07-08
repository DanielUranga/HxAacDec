package mp4;
import flash.Memory;
import flash.Vector;
import haxe.io.BytesData;
import impl.BitStream;

/**
 * ...
 * @author Daniel Uranga
 */

class MP4InputStream 
{
	
	public static inline var MASK8 : Int = 0xFF;
	public static inline var MASK16 : Int = 0xFFFF;
	public static inline var UTF8 : String = "UTF-8";
	public static inline var UTF16 : String = "UTF-16";
	public static inline var BYTE_ORDER_MASK : Int = 0xFEFF;
	private var input : BitStream;
	private var offset : Int;

	public function new(input : BitStream)
	{
		this.input = input;
		offset = 0;
		//this.count = 0;
	}

	/**
	 * Indicates, if the input has some data left.
	 * 
	 * @return true if there is at least one byte left	 
	 */
	public function hasLeft() : Bool
	{
		return input.getBitsLeft() > 8;
	}
	
	public function read() : Int
	{
		var i : Int = 0;
		if (input != null) i = input.read();
		//log(i);
		
		if(i==-1) throw "EOF";
		else if(input!=null) offset++;
		return i;
	}
	
	public function read_(b : BytesData, off : Int, len : Int) : Int
	{
		var i : Int = 0;
		if (input != null)
		{
			var index : Int = off;
			while ( index<off+len && input.getBitsLeft()>8 )
			{
				b[index] = input.read();
				//log(b[index]);
				index++;
				i++;
			}
			offset += i;
		}

		return i;
	}

	public function readBytes(n : Int) : Int
	{
		var i : Int = -1;
		var result : Int = 0;
		while (n > 0)
		{
			i = read();
			result = (result<<8)|(i&0xFF);
			n--;
		}
		return result;
	}

	public function readBytes_(b : BytesData) : Bool
	{
		var read : Int = 0;
		var i : Int;
		while (read < cast(b.length, Int))
		{
			i = read_(b, read, b.length-read);
			if(i==-1) break;
			else read += i;
		}
		return read==cast(b.length, Int);
	}

	public function readString(n : Int) : String
	{
		var i : Int = -1;
		var pos : Int = 0;
		//char[] c = new char[n];
		var s : String = "";
		while (pos < n)
		{
			i = read();
			s += String.fromCharCode(i);
			pos++;
		}
		return s;
	}

	public function readUTFString(max : Int, encoding : String) : String
	{
		return readUTFString2(max, encoding, null);
	}

	public function readUTFString1(max : Int) : String
	{
		//final byte[] bom = new byte[2];
		var bom : BytesData = new BytesData();
		bom.length = 2;
		read_(bom, 0, 2);
		var i : Int = (bom[0] << 8) | bom[1];
		return readUTFString2(max, (i == BYTE_ORDER_MASK) ? UTF16 : UTF8, bom);
	}

	private function readUTFString2(max : Int, encoding : String, bom : BytesData) : String
	{
		
		var b : Vector<Int> = new Vector<Int>();
		b.length = max;
		var pos : Int = 0;
		
		if (bom != null)
		{
			//System.arraycopy(bom, 0, b, 0, bom.length);
			b[0] = (bom[0] << 8) | bom[1];
			pos++;
		}

		if ( encoding == UTF8 )
		{
			var i : Int;
			var j : Int;
			while (true)
			{	
				i = read();
				if (i == -1 || i == 0) break;
				j = read();
				if (j == -1 || j == 0) break;
				b[pos] = (i << 8) | j;
			}
		}
		else if ( encoding == UTF16 )
		{
			var v : Vector<Int> = new Vector<Int>();
			v.length = 4;
			while (true)
			{	
				for ( vi in v )
				{
					vi = read();
					if (vi == -1 || vi == 0) break;
				}
			}
			b[pos] = (v[0] << 24) | (v[1] << 16) | (v[2] << 8) | (v[3]);
		}
		pos++;

		//return Unicode.string(b);
		return "";
	}

	//TODO: test this!
	public function readFixedPoint(len : Int, mask : Int) : Float
	{
		var l : Int = readBytes(len);
		var mantissa : Int = (l&mask)<<23;	// No puede ser "52", no es de 64 bits, es de 32. ACTUALIZADO: Lo reemplaze por "23".
		var exponent : Int = l & mask;
		Memory.setI32(0, mantissa | exponent);
		return Memory.getFloat(0);		
	}
	/*public static double readFixedPoint(int m, int n) throws IOException {
	//final long l = readBytes((m + n) / 8);
	final long l = 0x00010000;
	final double d = (double) (l >> n); //integer part
	return d * Math.pow(2,-n);
	}*/

	public function skipBytes(n : Int) : Bool
	{
		//first: skip, second: read, if remaining
		var l : Int = 0;
		if (input != null)
		{
			/*
			l = input.skip(n);
			while (l < n)
			{
				read();
				l++;
			}
			offset += l;
			*/
			l = input.skip(n);
			offset += l;
		}

		return l==n;
	}

	public function getOffset() : Int
	{
		var l : Int = -1;
		if(input!=null) l = offset;
		return l;
	}

	public function seek(l : Int)
	{
		//throw("could not seek: no random access");
		trace("seek: " + l);
		offset = l;
		input.setPosition(l*8);
	}

	public function hasRandomAccess() : Bool
	{
		return true;
	}

	function close()
	{		
	}
	
	public function bytesAvailable() : Int
	{
		return Std.int(input.getBitsLeft() / 8);
	}
	
}