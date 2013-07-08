package ;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SampleDataEvent;
import flash.media.Sound;
import flash.Memory;
import flash.net.URLRequest;
import flash.net.URLStream;
import flash.Vector;
import haxe.io.BytesData;
import impl.adts.ADTSDemultiplexer;
import impl.BitStream;
import impl.error.BitsBuffer;
import mp4.api.AudioTrack;
import mp4.api.Frame;
import mp4.api.Movie;
import mp4.api.Track;
import mp4.MP4Container;

/**
 * ...
 * @author Daniel Uranga
 */

class AACSound
{

	private var rawInput : URLStream;
	private var decoder : Decoder;
	//private var bitBuffer : BitStream;	// Contenedor de la informacion por decodificar
	private var bitBuffer : BytesData;
	private var sound : Sound;
	private var playing : Bool;
	
	private var adts : ADTSDemultiplexer;
	private var sample : SampleBuffer;
	private var writePos : Int;
	
	public function new(request : URLRequest)
	{
		rawInput = new URLStream();
		rawInput.load(request);
		decoder = null;
		sound = new Sound();
		playing = false;
		sample = new SampleBuffer();
		bitBuffer = new BytesData();
		writePos = 0;
	}
	
	public function play()
	{
		rawInput.addEventListener(ProgressEvent.PROGRESS, dataInputEvent);
		rawInput.addEventListener(IOErrorEvent.IO_ERROR, errorEvent);
		rawInput.addEventListener(IOErrorEvent.NETWORK_ERROR, errorEvent);
		sound.addEventListener(SampleDataEvent.SAMPLE_DATA, sampleDataEvent);
		sound.play();
	}
	
	public function dataInputEvent(event : Event)
	{
		if (rawInput.bytesAvailable < 50000)
		{
			return;
		}
		
		var buffer : BytesData = new BytesData();
		
		if ( !playing )
		{
			playing = true;

			trace(rawInput.bytesAvailable);
			var x : String;
			do
			{
				x = "";
				var c : UInt;
				do
				{
					c = rawInput.readUnsignedByte();
					if ( c == 10 || c == 13 )
						break;
					x = x + String.fromCharCode(c);
				} while (true);
				//trace(x);
			} while (x!=null && StringTools.trim(x)!="");
			
			rawInput.readBytes(buffer);
			var pos = bitBuffer.position;
			bitBuffer.writeBytes(buffer);
			writePos = bitBuffer.position;
			bitBuffer.position = pos;
			adts = new ADTSDemultiplexer(bitBuffer);
			decoder = new Decoder(adts.getDecoderSpecificInfo());			
		}
		else
		{
			bitBuffer.length = bitBuffer.length + rawInput.bytesAvailable + 1;
			rawInput.readBytes(buffer);
			trace("(" + writePos + ", " + (writePos + buffer.length) + ") -> " + "(0, " + bitBuffer.length + ")");
			var pos : Int = bitBuffer.position;
			bitBuffer.position = writePos;
			bitBuffer.writeBytes(buffer);
			bitBuffer.position = pos;			
			writePos += buffer.length;
		}
	}
	
	public function sampleDataEvent(event : SampleDataEvent)
	{
		var b1 : UInt;
		var b2 : UInt;
		var readInt : Int;
		var pulse : Float;
		
		for ( i in 0...4 )
		{
			if ( !playing || bitBuffer.bytesAvailable<8192 )
			{
				//if ( i==0 )	trace("esperando I/O");
				for ( i in 0...4096 )
					event.data.writeFloat(0);
				return;
			}
			
			decoder.decodeFrame_(adts.readNextFrame(), sample);
			
			while(sample.getData().bytesAvailable>0)
			{
				b1 = sample.getData().readUnsignedByte();
				b2 = sample.getData().readUnsignedByte();
				readInt = (b1 << 8) | b2;
				readInt = Memory.signExtend16(readInt);
				pulse = readInt / 32768;
				event.data.writeFloat(pulse);
			}
		}
		
	}
	
	public function errorEvent(event : IOErrorEvent)
	{
		trace(event.toString());
	}
	
}