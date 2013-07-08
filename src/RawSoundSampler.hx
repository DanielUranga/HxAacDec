package ;
import flash.events.SampleDataEvent;
import flash.Memory;
import flash.net.URLStream;
import haxe.io.BytesData;

/**
 * ...
 * @author Daniel Uranga
 */

class RawSoundSampler 
{

	private var rawInput : URLStream;
	
	public function new(b : URLStream)
	{
		this.rawInput = b;
	}
	
	public function sampleDataEvent(event : SampleDataEvent)
	{
		var b1 : UInt;
		var b2 : UInt;
		var readInt : Int;
		var pulse : Float;
		for ( i in 0...8192 )
		{
			if ( rawInput.bytesAvailable < 8 )
				break;
			b1 = rawInput.readUnsignedByte();
			b2 = rawInput.readUnsignedByte();
			readInt = (b1 << 8) | b2;
			readInt = Memory.signExtend16(readInt);
			pulse = readInt / 32768;
			event.data.writeFloat(pulse);
		}
	}
	
}