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
	
package impl.filterbank;
import flash.Vector;
import impl.Constants;
import impl.ICSInfo;
import impl.IntDivision;
import impl.VectorTools;

class FilterBank 
{

	private var LONG_WINDOWS : Array<Array<Float>>;// = {SINE_LONG, KBD_LONG};
	private var SHORT_WINDOWS : Array<Array<Float>>;// = {SINE_SHORT, KBD_SHORT};
	private var length : Int;
	private var shortLen : Int;
	private var mid : Int;
	private var trans : Int;
	private var mdctShort : MDCT;
	private var mdctLong : MDCT;
	private var buf : Vector<Float>;
	private var overlaps : Vector<Vector<Float>>;
	
	public function new(smallFrames : Bool, channels : Int)
	{
		if (smallFrames)
		{
			length = Constants.WINDOW_SMALL_LEN_LONG;
			shortLen = Constants.WINDOW_SMALL_LEN_SHORT;
			LONG_WINDOWS = [SineWindows.SINE_960, KBDWindows.KBD_960];
			SHORT_WINDOWS = [SineWindows.SINE_120, KBDWindows.KBD_120];
		}
		else
		{
			length = Constants.WINDOW_LEN_LONG;
			shortLen = Constants.WINDOW_LEN_SHORT;
			LONG_WINDOWS = [SineWindows.SINE_1024, KBDWindows.KBD_1024];
			SHORT_WINDOWS = [SineWindows.SINE_128, KBDWindows.KBD_128];
		}
		mid = IntDivision.intDiv(length-shortLen,2);
		trans = IntDivision.intDiv(shortLen,2);
		mdctShort = new MDCT(shortLen*2);
		mdctLong = new MDCT(length*2);
		overlaps = VectorTools.newMatrixVectorF(channels,length);
		buf = new Vector<Float>(2*length);
	}
	
	public function process(windowSequence : ICSInfo.WindowSequence, windowShape : Int, windowShapePrev : Int, input : Vector<Float>, out : Vector<Float>, channel : Int)
	{
		var i : Int;
		var overlap : Vector<Float> = overlaps[channel];
		switch(windowSequence) {
			case ONLY_LONG_SEQUENCE:
			{
				mdctLong.process(input, 0, buf, 0);
				//add second half output of previous frame to windowed output of current frame
				for (i in 0...length)
				{
					out[i] = overlap[i]+(buf[i]*LONG_WINDOWS[windowShapePrev][i]);
				}

				//window the second half and save as overlap for next frame
				for (i in 0...length)
				{
					overlap[i] = buf[length+i]*LONG_WINDOWS[windowShape][length-1-i];
				}
			}
			case LONG_START_SEQUENCE:
			{
				mdctLong.process(input, 0, buf, 0);
				//add second half output of previous frame to windowed output of current frame
				for (i in 0...length)
				{
					out[i] = overlap[i]+(buf[i]*LONG_WINDOWS[windowShapePrev][i]);
				}

				//window the second half and save as overlap for next frame
				for (i in 0...mid)
				{
					overlap[i] = buf[length+i];
				}
				for (i in 0...shortLen)
				{
					overlap[mid+i] = buf[length+mid+i]*SHORT_WINDOWS[windowShape][shortLen-i-1];
				}
				for (i in 0...mid)
				{
					overlap[mid+shortLen+i] = 0;
				}
			}
			case EIGHT_SHORT_SEQUENCE:
			{
				for (i in 0...8)
				{
					mdctShort.process(input, i*shortLen, buf, 2*i*shortLen);
				}

				//add second half output of previous frame to windowed output of current frame
				for (i in 0...mid)
				{
					out[i] = overlap[i];
				}
				for (i in 0...shortLen)
				{
					out[mid+i] = overlap[mid+i]+(buf[i]*SHORT_WINDOWS[windowShapePrev][i]);
					out[mid+1*shortLen+i] = overlap[mid+shortLen*1+i]+(buf[shortLen*1+i]*SHORT_WINDOWS[windowShape][shortLen-1-i])+(buf[shortLen*2+i]*SHORT_WINDOWS[windowShape][i]);
					out[mid+2*shortLen+i] = overlap[mid+shortLen*2+i]+(buf[shortLen*3+i]*SHORT_WINDOWS[windowShape][shortLen-1-i])+(buf[shortLen*4+i]*SHORT_WINDOWS[windowShape][i]);
					out[mid+3*shortLen+i] = overlap[mid+shortLen*3+i]+(buf[shortLen*5+i]*SHORT_WINDOWS[windowShape][shortLen-1-i])+(buf[shortLen*6+i]*SHORT_WINDOWS[windowShape][i]);
					if(i<trans) out[mid+4*shortLen+i] = overlap[mid+shortLen*4+i]+(buf[shortLen*7+i]*SHORT_WINDOWS[windowShape][shortLen-1-i])+(buf[shortLen*8+i]*SHORT_WINDOWS[windowShape][i]);
				}

				//window the second half and save as overlap for next frame
				for (i in 0...shortLen)
				{
					if(i>=trans) overlap[mid+4*shortLen+i-length] = (buf[shortLen*7+i]*SHORT_WINDOWS[windowShape][shortLen-1-i])+(buf[shortLen*8+i]*SHORT_WINDOWS[windowShape][i]);
					overlap[mid+5*shortLen+i-length] = (buf[shortLen*9+i]*SHORT_WINDOWS[windowShape][shortLen-1-i])+(buf[shortLen*10+i]*SHORT_WINDOWS[windowShape][i]);
					overlap[mid+6*shortLen+i-length] = (buf[shortLen*11+i]*SHORT_WINDOWS[windowShape][shortLen-1-i])+(buf[shortLen*12+i]*SHORT_WINDOWS[windowShape][i]);
					overlap[mid+7*shortLen+i-length] = (buf[shortLen*13+i]*SHORT_WINDOWS[windowShape][shortLen-1-i])+(buf[shortLen*14+i]*SHORT_WINDOWS[windowShape][i]);
					overlap[mid+8*shortLen+i-length] = (buf[shortLen*15+i]*SHORT_WINDOWS[windowShape][shortLen-1-i]);
				}
				for (i in 0...mid)
				{
					overlap[mid+shortLen+i] = 0;
				}
			}
			case LONG_STOP_SEQUENCE:
			{
				mdctLong.process(input, 0, buf, 0);
				//add second half output of previous frame to windowed output of current frame
				//construct first half window using padding with 1's and 0's
				for (i in 0...mid)
				{
					out[i] = overlap[i];
				}
				for (i in 0...shortLen)
				{
					out[mid+i] = overlap[mid+i]+(buf[mid+i]*SHORT_WINDOWS[windowShapePrev][i]);
				}
				for (i in 0...mid)
				{
					out[mid+shortLen+i] = overlap[mid+shortLen+i]+buf[mid+shortLen+i];
				}
				//window the second half and save as overlap for next frame
				for (i in 0...length)
				{
					overlap[i] = buf[length+i]*LONG_WINDOWS[windowShape][length-1-i];
				}
			}
		}
	}
	
	//only for LTP: no overlapping, no short blocks
	public function processLTP(windowSequence : ICSInfo.WindowSequence, windowShape : Int, windowShapePrev : Int, input : Vector<Float>, out : Vector<Float>)
	{
		var i : Int;

		switch(windowSequence) {
			case ONLY_LONG_SEQUENCE:
			{
				//for(i = length-1; i>=0; i--) {
				var i : Int = length - 1;
				while(i>=0)
				{
					buf[i] = input[i]*LONG_WINDOWS[windowShapePrev][i];
					buf[i + length] = input[i + length] * LONG_WINDOWS[windowShape][length - 1 - i];
					i--;
				}
			}

			case LONG_START_SEQUENCE:
			{
				for (i in 0...length)
				{
					buf[i] = input[i]*LONG_WINDOWS[windowShapePrev][i];
				}
				for (i in 0...mid)
				{
					buf[i+length] = input[i+length];
				}
				for (i in 0...shortLen)
				{
					buf[i+length+mid] = input[i+length+mid]*SHORT_WINDOWS[windowShape][shortLen-1-i];
				}
				for (i in 0...mid)
				{
					buf[i+length+mid+shortLen] = 0;
				}
			}

			case LONG_STOP_SEQUENCE:
			{
				for (i in 0...mid)
				{
					buf[i] = 0;
				}
				for (i in 0...shortLen)
				{
					buf[i+mid] = input[i+mid]*SHORT_WINDOWS[windowShapePrev][i];
				}
				for (i in 0...mid)
				{
					buf[i+mid+shortLen] = input[i+mid+shortLen];
				}
				for (i in 0...length)
				{
					buf[i+length] = input[i+length]*LONG_WINDOWS[windowShape][length-1-i];
				}
			}
			case EIGHT_SHORT_SEQUENCE:
			{
				// Nada
			}
		}
		mdctLong.processForward(buf, out);
	}
	
	public function getOverlap(channel : Int) : Vector<Float>
	{
		return overlaps[channel];
	}
	
}