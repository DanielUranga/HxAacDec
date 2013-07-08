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
import mp4.api.AudioTrack;
import mp4.api.Movie;
import mp4.api.Track;
import mp4.boxes.BoxFactory;
import mp4.MP4Container;

/**
 * ...
 * @author Daniel Uranga
 */

class Mp4Sound
{

	var rawInput : URLStream;
	var decoder : Decoder;
	var bitBuffer : BitStream;	// Contenedor de la informacion por decodificar
	//private var bitBuffer : BytesData;
	var sound : Sound;
	var adts : ADTSDemultiplexer;
	var sample : SampleBuffer;	
	var track : Track;
	
	public function new(request : URLRequest)
	{
		trace("new MP4Sound " + request.url);
		BoxFactory.initialize();
		rawInput = new URLStream();
		rawInput.load(request);
		decoder = null;
		sound = new Sound();
		sample = new SampleBuffer();
		bitBuffer = new BitStream();
	}
	
	public function play()
	{
		//rawInput.addEventListener(ProgressEvent.PROGRESS, dataInputEvent);
		
		rawInput.addEventListener(IOErrorEvent.IO_ERROR, errorEvent);
		rawInput.addEventListener(IOErrorEvent.NETWORK_ERROR, errorEvent);
		
		rawInput.addEventListener(Event.COMPLETE, onComplete);
		sound.addEventListener(SampleDataEvent.SAMPLE_DATA, sampleDataEvent);
		
		sound.play();
	}
	
	public function onComplete(_)
	{
		var buffer : BytesData = new BytesData();
		
		rawInput.readBytes(buffer);
		
		bitBuffer.addData(buffer);
		var container = new MP4Container(bitBuffer);	
		var movie = container.getMovie();
		trace("Movie: " + movie);
		var tracks = movie.getTracks_(AudioCodec.AAC);
		trace("Track: " + tracks);
		if (tracks.length > 0)
		{
			track = tracks[0];
			var decoderSpecificInfo = track.getDecoderSpecificInfo();
			decoder = new Decoder(decoderSpecificInfo);
			trace("deco: " + decoder);
			//var frame = track.readNextFrame();
			//do something with the frame, e.g. pass it to the AAC decoder
		}
	}
	
	public function sampleDataEvent(event : SampleDataEvent)
	{
		//trace("event");
		try
		{
			if (decoder != null)
			{
				var b1 : UInt;
				var b2 : UInt;
				var readInt : Int;
				for ( i in 0...4 )
				{
					decoder.decodeFrame_(track.readNextFrame_BytesData(), sample);
					var i = 0;
					while(sample.getData().bytesAvailable>0)
					{					
						readInt = sample.getData().readShort();
						var pulse = readInt / 32768;
						if (i < 2)
						{
							event.data.writeFloat(pulse);
							i++;
						}
						else
						{
							i = 0;
						}
					}
				}
			}
			else
			{
				for ( i in 0...4096 )
				{
					event.data.writeFloat(0);
				}
				return;
			}
		}
		catch (e : Dynamic)
		{
			//trace("fin");
			trace(e);
		}
		/*
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
				{
					event.data.writeFloat(0);
				}
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
		*/
	}
	
	public function errorEvent(event : IOErrorEvent)
	{
		trace(event.toString());
	}
	
}