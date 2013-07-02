/*
	Copyright 2011 Nestor Daniel Uranga
	
	This file is part of HxAacDec.

    HxAacDec is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    HxAacDec is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with HxAacDec.  If not, see <http://www.gnu.org/licenses/>.
*/

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
		trace("new AACSound " + request.url);
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
			do {
				x = "";
				var c : UInt;
				do {
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