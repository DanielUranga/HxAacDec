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
import haxe.io.BytesData;

/**
 * ...
 * @author Daniel Uranga
 */

/**
 * This class represents the format of the raw PCM data stored in the
 * sample buffer.
 */
class Format
{

	public var sampleRate : Int;
	public var channels : Int;
	public var bitsPerSample : Int;

	public function new(sampleRate : Int, channels : Int, bitsPerSample : Int)
	{
		this.sampleRate = sampleRate;
		this.channels = channels;
		this.bitsPerSample = bitsPerSample;
	}

	public function getSampleRate() : Int
	{
		return sampleRate;
	}

	public function getChannels() : Int
	{
		return channels;
	}

	public function getBitsPerSample() : Int
	{
		return bitsPerSample;
	}
}
 
class SampleBuffer 
{

	private var format : Format;
	private var data : BytesData;

	public function new()
	{
		data = new BytesData();
		format = new Format(0, 0, 0);
	}

	/**
	 * Returns the format of this sample buffer's data.
	 * @return the audio format
	 */
	public function getFormat() : Format
	{
		return format;
	}

	public function setFormat(sampleRate : Int, channels : Int, bitsPerSample : Int)
	{
		format.sampleRate = sampleRate;
		format.channels = channels;
		format.bitsPerSample = bitsPerSample;
	}

	/**
	 * Returns the buffer's PCM data.
	 * @return the audio data
	 */
	public function getData() : BytesData
	{
		return data;
	}

	public function setData(data : BytesData)
	{
		this.data = data;
	}
	
}