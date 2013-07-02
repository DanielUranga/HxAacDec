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
	
package impl.prediction;
import flash.Lib;
import flash.Memory;
import flash.Vector;
import impl.BitStream;
import impl.ICStream;
import impl.IntMath;
import impl.ICSInfo;

class PredictorState
{
	public var cor0 : Float;
	public var cor1 : Float;
	public var var0 : Float;
	public var var1 : Float;
	public var r0 : Float;
	public var r1 : Float;
	public function new()
	{
		cor0 = 0.0;
		cor1 = 0.0;
		var0 = 0.0;
		var1 = 0.0;
		r0 = 1.0;
		r1 = 1.0;
	}
}
 
class ICPrediction
{

	private static inline var memOffset : Int = 0;
	private static inline var SF_SCALE : Float = 1.0/-1024.0;
	private static inline var INV_SF_SCALE : Float = 1.0/SF_SCALE;
	private static inline var MAX_PREDICTORS : Int = 672;
	private static inline var A : Float = 0.953125; //61.0 / 64
	private static inline var ALPHA : Float = 0.90625;  //29.0 / 32
	private var predictorReset : Bool;
	private var predictorCount : Int;
	private var predictorResetGroup : Int;
	private var predictionUsed : Vector<Bool>;
	private var states : Vector<PredictorState>;

	public function new()
	{
		states = new Vector<PredictorState>(MAX_PREDICTORS);
		for (i in 0...states.length)
		{
			states[i] = new PredictorState();
		}
		resetAllPredictors();
	}

	public function decode(input : BitStream, maxSFB : Int, sf : SampleFrequency)
	{
		predictorCount = sf.getPredictorCount();
		if (predictorReset = input.readBool())
			predictorResetGroup = input.readBits(5);
		var maxPredSFB : Int = sf.getMaximalPredictionSFB();
		var length : Int = IntMath.min(maxSFB, maxPredSFB);
		var predictionUsed = new Vector<Bool>(length);
		for (sfb in 0...length)
		{
			predictionUsed[sfb] = input.readBool();
		}
		//Constants.LOGGER.log(Level.WARNING, "ICPrediction: maxSFB={0}, maxPredSFB={1}", new int[]{maxSFB, maxPredSFB});
		/*//if maxSFB<maxPredSFB set remaining to false
		for(int sfb = length; sfb<maxPredSFB; sfb++) {
		predictionUsed[sfb] = false;
		}*/
	}

	public inline function setPredictionUnused(sfb : Int)
	{
		predictionUsed[sfb] = false;
	}

	public function process(ics : ICStream, data : Vector<Float>, sf : SampleFrequency)
	{
		var info : ICSInfo = ics.getInfo();
		if (info.isEightShortFrame())
		{
			resetAllPredictors();
		}
		else
		{
			var len : Int = IntMath.min(sf.getMaximalPredictionSFB(), info.getMaxSFB());
			var swbOffsets : Vector<Int> = info.getSWBOffsets();
			var k : Int;
			for (sfb in 0...len)
			{
				for(k in swbOffsets[sfb]...swbOffsets[sfb + 1])
				{
					predict(data, k, predictionUsed[sfb]);
				}
			}
			if(predictorReset) resetPredictorGroup(predictorResetGroup);
		}
	}

	private inline function resetPredictState(index : Int)
	{
		if(states[index]==null) states[index] = new PredictorState();
		states[index].r0 = 0;
		states[index].r1 = 0;
		states[index].cor0 = 0;
		states[index].cor1 = 0;
		states[index].var0 = 0x3F80;
		states[index].var1 = 0x3F80;
	}

	private inline function resetAllPredictors()
	{
		for (i in 0...states.length)
		{
			resetPredictState(i);
		}
	}

	private inline function resetPredictorGroup(group : Int)
	{		
		var i : Int = group - 1;
		while(i<states.length)
		{
			resetPredictState(i);
			i += 30;
		}
	}

	private function predict(data : Vector<Float>, off : Int, output : Bool)
	{
		if(states[off]==null) states[off] = new PredictorState();
		var state : PredictorState = states[off];
		var r0 : Float = state.r0;
		var r1 : Float = state.r1;
		var cor0 : Float = state.cor0;
		var cor1 : Float = state.cor1;
		var var0 : Float = state.var0;
		var var1 : Float = state.var1;
		var k1 : Float = var0>1 ? cor0*even(A/var0) : 0;
		var k2 : Float = var1>1 ? cor1*even(A/var1) : 0;
		var pv : Float = Math.round(k1*r0+k2*r1);
		if(output) data[off] += pv*SF_SCALE;
		var e0 : Float = (data[off]*INV_SF_SCALE);
		var e1 : Float = e0-k1*r0;
		state.cor1 = trunc(ALPHA*cor1+r1*e1);
		state.var1 = trunc(ALPHA*var1+0.5*(r1*r1+e1*e1));
		state.cor0 = trunc(ALPHA*cor0+r0*e0);
		state.var0 = trunc(ALPHA*var0+0.5*(r0*r0+e0*e0));

		state.r1 = trunc(A*(r0-k1*e0));
		state.r0 = trunc(A*e0);
	}

	public inline function round(pf : Float) : Float
	{
		/*
		return Float.intBitsToFloat((Float.floatToIntBits(pf)+0x00008000)&0xFFFF0000);
		*/
		Memory.setFloat(memOffset, pf);
		var ipf : Int = Memory.getI32(memOffset);
		ipf = (ipf + 0x00008000) & 0xFFFF0000;
		Memory.setI32(memOffset, ipf);
		return Memory.getFloat(memOffset);
	}

	public function even(pf : Float) : Float
	{
		/*
		int i = Float.floatToIntBits(pf);
		i = (i+0x00007FFF+(i&0x00010000>>16))&0xFFFF0000;
		return Float.intBitsToFloat(i);
		*/
		Memory.setFloat(memOffset, pf);
		var ipf : Int = Memory.getI32(memOffset);
		ipf = (ipf + 0x00007FFF + (ipf & 0x00010000 >> 16)) & 0xFFFF0000;
		Memory.setI32(memOffset, ipf);
		return Memory.getFloat(memOffset);
	}

	public inline function trunc(pf : Float) : Float
	{
		/*
		return Float.intBitsToFloat(Float.floatToIntBits(pf)&0xFFFF0000);
		*/
		Memory.setFloat(memOffset, pf);
		var ipf : Int = Memory.getI32(memOffset);
		ipf = ipf & 0xFFFF0000;
		Memory.setI32(memOffset, ipf);
		return Memory.getFloat(memOffset);
	}
}
