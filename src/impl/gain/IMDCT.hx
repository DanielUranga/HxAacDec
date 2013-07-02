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

package impl.gain;
import flash.Vector;
import impl.ICSInfo;
import impl.IntDivision;
import impl.VectorTools;

class IMDCT 
{


	private static var LONG_WINDOWS : Array<Array<Float>> = [Windows.SINE_256, Windows.KBD_256];
	private static var SHORT_WINDOWS : Array<Array<Float>> = [Windows.SINE_32, Windows.KBD_32];
	private var frameLen : Int;
	private var shortFrameLen : Int;
	private var lbLong : Int;
	private var lbShort : Int;
	private var lbMid : Int;

	public function new(frameLen : Int)
	{
		this.frameLen = frameLen;
		lbLong = IntDivision.intDiv(frameLen, GCConstants.BANDS);
		shortFrameLen = IntDivision.intDiv(frameLen, 8);
		lbShort = IntDivision.intDiv(shortFrameLen, GCConstants.BANDS);
		lbMid = IntDivision.intDiv((lbLong-lbShort), 2);
	}

	public function process(input : Vector<Float>, out : Vector<Float>, winShape : Int, winShapePrev : Int, winSeq : WindowSequence)
	{
		var buf : Vector<Float> = new Vector<Float>(frameLen);

		//int b, j, i;
		if (winSeq == WindowSequence.EIGHT_SHORT_SEQUENCE)
		{
			for (b in 0...GCConstants.BANDS)
			{
				for (j in 0...8)
				{
					for (i in 0...lbShort)
					{
						if(b%2==0) buf[lbLong*b+lbShort*j+i] = input[shortFrameLen*j+lbShort*b+i];
						else buf[lbLong*b+lbShort*j+i] = input[shortFrameLen*j+lbShort*b+lbShort-1-i];
					}
				}
			}
		}
		else {
			for (b in 0...GCConstants.BANDS)
			{
				for (i in 0...lbLong)
				{
					if(b%2==0) buf[lbLong*b+i] = input[lbLong*b+i];
					else buf[lbLong*b+i] = input[lbLong*b+lbLong-1-i];
				}
			}
		}

		for (b in 0...GCConstants.BANDS)
		{
			process2(buf, out, winSeq, winShape, winShapePrev, b);
		}
	}

	private function process2(input : Vector<Float>, out : Vector<Float>, winSeq : WindowSequence, winShape : Int , winShapePrev : Int, band : Int)
	{
		var bufIn : Vector<Float> = new Vector<Float>(lbLong);
		var bufOut : Vector<Float> = new Vector<Float>(lbLong*2);
		var window : Vector<Float> = new Vector<Float>(lbLong*2);
		var window1 : Vector<Float> = new Vector<Float>(lbLong*2);
		var window2 : Vector<Float> = new Vector<Float>(lbLong*2);

		//init windows
		switch(winSeq)
		{
			case WindowSequence.ONLY_LONG_SEQUENCE:
			{
				for (i in 0...lbLong)
				{
					window[i] = IMDCT.LONG_WINDOWS[winShapePrev][i];
					window[lbLong*2-1-i] = IMDCT.LONG_WINDOWS[winShape][i];
				}
			}
			case WindowSequence.EIGHT_SHORT_SEQUENCE:
			{
				for (i in 0...lbShort)
				{
					window1[i] = IMDCT.SHORT_WINDOWS[winShapePrev][i];
					window1[lbShort*2-1-i] = IMDCT.SHORT_WINDOWS[winShape][i];
					window2[i] = IMDCT.SHORT_WINDOWS[winShape][i];
					window2[lbShort*2-1-i] = IMDCT.SHORT_WINDOWS[winShape][i];
				}
			}
			case WindowSequence.LONG_START_SEQUENCE:
			{
				for (i in 0...lbLong)
				{
					window[i] = IMDCT.LONG_WINDOWS[winShapePrev][i];
				}
				for (i in 0...lbMid)
				{
					window[i+lbLong] = 1.0;
				}

				for (i in 0...lbShort)
				{
					window[i+lbMid+lbLong] = IMDCT.SHORT_WINDOWS[winShape][lbShort-1-i];
				}
				for (i in 0...lbMid)
				{
					window[i+lbMid+lbLong+lbShort] = 0.0;
				}
			}
			case LONG_STOP_SEQUENCE:
			{
				for (i in 0...lbMid)
				{
					window[i] = 0.0;
				}
				for (i in 0...lbShort)
				{
					window[i+lbMid] = IMDCT.SHORT_WINDOWS[winShapePrev][i];
				}
				for (i in 0...lbMid)
				{
					window[i+lbMid+lbShort] = 1.0;
				}
				for (i in 0...lbLong)
				{
					window[i+lbMid+lbShort+lbMid] = IMDCT.LONG_WINDOWS[winShape][lbLong-1-i];
				}
			}
		}

		if (winSeq == WindowSequence.EIGHT_SHORT_SEQUENCE)
		{
			for (j in 0...8)
			{
				for (k in 0...lbShort)
				{
					bufIn[k] = input[band*lbLong+j*lbShort+k];
				}
				//if(j==0) System.arraycopy(window1, 0, window, 0, lbShort*2);
				if (j == 0) VectorTools.vectorcopyF(window1, 0, window, 0, lbShort*2);
				//else System.arraycopy(window2, 0, window, 0, lbShort*2);
				else VectorTools.vectorcopyF(window2, 0, window, 0, lbShort * 2);
				imdct(bufIn, bufOut, window, lbShort);
				for (k in 0...(lbShort * 2))
				{
					out[band*lbLong*2+j*lbShort*2+k] = bufOut[k]/32.0;
				}
			}
		}
		else
		{
			for (j in 0...lbLong)
			{
				bufIn[j] = input[band*lbLong+j];
			}
			imdct(bufIn, bufOut, window, lbLong);
			for (j in 0...(lbLong * 2))
			{
				out[band*lbLong*2+j] = bufOut[j]/256.0;
			}
		}
	}

	
	private function imdct(input : Vector<Float>, out : Vector<Float>, window : Vector<Float>, n : Int)
	{
		var n2 : Int = IntDivision.intDiv(n, 2);
		var table : Array<Array<Float>>;
		var table2 : Array<Array<Float>>;
		if (n == 256)
		{
			table = IMDCTTables.IMDCT_TABLE_256;
			table2 = IMDCTTables.IMDCT_POST_TABLE_256;
		}
		else if (n == 32)
		{
			table = IMDCTTables.IMDCT_TABLE_32;
			table2 = IMDCTTables.IMDCT_POST_TABLE_32;
		}
		else throw("gain control: unexpected IMDCT length");

		var tmp : Vector<Float> = new Vector<Float>(n);
		for (i in 0...n2)
		{
			tmp[i] = input[2*i];
		}
		for (i in n2...n)
		{
			tmp[i] = -input[2*n-1-2*i];
		}

		//pre-twiddle
		//final float[][] buf = new float[n2][2];
		var buf : Vector<Vector<Float>> = VectorTools.newMatrixVectorF(n2, 2);
		for (i in 0...n2)
		{
			buf[i][0] = (table[i][0]*tmp[2*i])-(table[i][1]*tmp[2*i+1]);
			buf[i][1] = (table[i][0]*tmp[2*i+1])+(table[i][1]*tmp[2*i]);
		}

		//fft
		FFT.process(buf, n2);

		//post-twiddle and reordering
		for (i in 0...n2)
		{
			tmp[i] = table2[i][0]*buf[i][0]+table2[i][1]*buf[n2-1-i][0]
					+table2[i][2]*buf[i][1]+table2[i][3]*buf[n2-1-i][1];
			tmp[n-1-i] = table2[i][2]*buf[i][0]-table2[i][3]*buf[n2-1-i][0]
					-table2[i][0]*buf[i][1]+table2[i][1]*buf[n2-1-i][1];
		}

		//copy to output and apply window
		//System.arraycopy(tmp, n2, out, 0, n2);
		VectorTools.vectorcopyF(tmp, n2, out, 0, n2);
		for (i in n2...IntDivision.intDiv(n * 3, 2))
		{
			out[i] = -tmp[IntDivision.intDiv(n*3, 2)-1-i];
		}
		for (i in IntDivision.intDiv(n * 3, 2)...(n * 2))
		{
			out[i] = -tmp[i-IntDivision.intDiv(n*3, 2)];
		}

		for (i in 0...n)
		{
			out[i] *= window[i];
		}
	}
	
}