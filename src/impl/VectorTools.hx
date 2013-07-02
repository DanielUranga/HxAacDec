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

package impl;

import flash.display.InteractiveObject;
import flash.Vector;

class VectorTools {
	
    public static inline function
    vectorcopy(src : Vector<Dynamic>, src_pos : Int,
               dst : Vector<Dynamic>, dst_pos : Int, length : Int) : Void
    {
        var srci : Int;
        var n : Int;
        var dsti : Int;

        if (src == dst && dst_pos > src_pos) {
            srci = src_pos + length;
            n = src_pos;
            dsti = dst_pos + length;

            while (srci > n) {
                dst[--dsti] = src[--srci];
            }
        } else {
            srci = src_pos;
            n = src_pos + length;
            dsti = dst_pos;

            while (srci < n) {
                dst[dsti++] = src[srci++];
            }
        }
    }

	public static inline function
    vectorcopyB(src : Vector<Bool>, src_pos : Int,
                dst : Vector<Bool>, dst_pos : Int, length : Int) : Void
    {
        var srci : Int;
        var n : Int;
        var dsti : Int;

        if (src == dst && dst_pos > src_pos) {
            srci = src_pos + length;
            n = src_pos;
            dsti = dst_pos + length;

            while (srci > n) {
                dst[--dsti] = src[--srci];
            }
        } else {
            srci = src_pos;
            n = src_pos + length;
            dsti = dst_pos;

            while (srci < n) {
                dst[dsti++] = src[srci++];
            }
        }
    }
	
    public static inline function
    vectorcopyI(src : Vector<Int>, src_pos : Int,
                dst : Vector<Int>, dst_pos : Int, length : Int) : Void
    {
        var srci : Int;
        var n : Int;
        var dsti : Int;

        if (src == dst && dst_pos > src_pos) {
            srci = src_pos + length;
            n = src_pos;
            dsti = dst_pos + length;

            while (srci > n) {
                dst[--dsti] = src[--srci];
            }
        } else {
            srci = src_pos;
            n = src_pos + length;
            dsti = dst_pos;

            while (srci < n) {
                dst[dsti++] = src[srci++];
            }
        }
    }

    public static inline function
    vectorcopyF(src : Vector<Float>, src_pos : Int,
                dst : Vector<Float>, dst_pos : Int, length : Int) : Void
    {
        var srci : Int;
        var n : Int;
        var dsti : Int;

        if (src == dst && dst_pos > src_pos) {
            srci = src_pos + length;
            n = src_pos;
            dsti = dst_pos + length;

            while (srci > n) {
                dst[--dsti] = src[--srci];
            }
        } else {
            srci = src_pos;
            n = src_pos + length;
            dsti = dst_pos;

            while (srci < n) {
                dst[dsti++] = src[srci++];
            }
        }
    }

	/*
    public static inline function
    copyI(src : Vector<Int>, src_pos : Int,
          dst : Vector<Int>, dst_pos : Int, length : Int) : Vector<Int>
    {
        var b : Vector<Int>;
        var src_end : Int = src_pos + length;

        if (dst_pos > 0) {
            b = dst.slice(0, dst_pos).concat(src.slice(src_pos, src_end));
        } else {
            b = src.slice(src_pos, src_end);
        }

        if (dst_pos + length < dst.length) {
            b = b.concat(dst.slice(dst_pos + length));
        }

        b.fixed = dst.fixed;
        return b;
    }

    public static inline function
    copyF(src : Vector<Float>, src_pos : Int,
          dst : Vector<Float>, dst_pos : Int, length : Int) : Vector<Float>
    {
        var b : Vector<Float>;
        var src_end : Int = src_pos + length;

        if (dst_pos > 0) {
            b = dst.slice(0, dst_pos).concat(src.slice(src_pos, src_end));
        } else {
            b = src.slice(src_pos, src_end);
        }

        if (dst_pos + length < dst.length) {
            b = b.concat(dst.slice(dst_pos + length));
        }

        b.fixed = dst.fixed;
        return b;
    }
	*/
	
	public static inline function copyOfI(v : Vector<Int>, len : Int) : Vector<Int>
	{
		var ret : Vector<Int> = new Vector<Int>(len);
		var x : Int = IntMath.min(len, v.length);
		for ( i in 0...x )
		{
			if ( i<cast(v.length, Int) )
				ret[i] = v[i];
			else
				ret[i] = 0;
		}
		return ret;
	}
	
	public static inline function copyOfB(v : Vector<Bool>, len : Int) : Vector<Bool>
	{
		var ret : Vector<Bool> = new Vector<Bool>(len);
		var x : Int = IntMath.min(len, v.length);
		for ( i in 0...x )
		{
			if ( i<cast(v.length, Int) )
				ret[i] = v[i];
			else
				ret[i] = false;
		}
		return ret;
	}
	
	public static inline function newMatrixVectorB(a : Int, b : Int) : Vector<Vector<Bool>>
	{
		var v : Vector<Vector<Bool>> = new Vector<Vector<Bool>>(a);
		for ( i in 0...v.length )
		{
			v[i] = new Vector<Bool>(b);
		}
		return v;
	}
	
	public static inline function newMatrixVectorI(a : Int, b : Int) : Vector<Vector<Int>>
	{
		var v : Vector<Vector<Int>> = new Vector<Vector<Int>>(a);
		for ( i in 0...v.length )
		{
			v[i] = new Vector<Int>(b);
		}
		return v;
	}
	
	public static inline function new3DMatrixVectorI( a : Int, b : Int, c : Int ) : Vector<Vector<Vector<Int>>>
	{
		var v : Vector<Vector<Vector<Int>>> = new Vector<Vector<Vector<Int>>>(a);
		for ( x in 0...v.length )
		{
			v[x]  = newMatrixVectorI(b, c);
		}
		return v;
	}
	
	public static inline function new4DMatrixVectorI(a : Int, b : Int, c : Int, d : Int) : Vector<Vector<Vector<Vector<Int>>>>
	{
		var v : Vector<Vector<Vector<Vector<Int>>>> = new Vector<Vector<Vector<Vector<Int>>>>(a);
		for ( x in 0...v.length )
		{
			v[x] = new3DMatrixVectorI(b, c, d);
		}
		return v;
	}
	
	public static inline function newMatrixVectorF(a : Int, b : Int) : Vector<Vector<Float>>
	{
		var v : Vector<Vector<Float>> = new Vector<Vector<Float>>(a);
		for ( i in 0...v.length )
		{
			v[i] = new Vector<Float>(b);
		}
		return v;
	}
	
	public static inline function new3DMatrixVectorF( a : Int, b : Int, c : Int ) : Vector<Vector<Vector<Float>>>
	{
		var v : Vector<Vector<Vector<Float>>> = new Vector<Vector<Vector<Float>>>(a);
		for ( x in 0...v.length )
		{
			v[x]  = newMatrixVectorF(b, c);
		}
		return v;
	}
	
	public static inline function new4DMatrixVectorF(a : Int, b : Int, c : Int, d : Int) : Vector<Vector<Vector<Vector<Float>>>>
	{
		var v : Vector<Vector<Vector<Vector<Float>>>> = new Vector<Vector<Vector<Vector<Float>>>>(a);
		for ( x in 0...v.length )
		{
			v[x] = new3DMatrixVectorF(b, c, d);
		}
		return v;
	}
	
	private static function sortI_(arr : Vector<Int>, lo : Int, hi : Int)
	{
		var i : Int = lo;
        var j : Int = hi;
		var buf : Vector<Int> = arr;
        var p : Int = buf[(lo + hi) >> 1];
        while ( i <= j )
		{			
            while( arr[i] < p ) i++;
            while( arr[j] > p ) j--;
            if ( i <= j )
			{
                var t : Int = buf[i];
                buf[i++] = buf[j];
                buf[j--] = t;
            }
        }
        if( lo < j ) sortI_( arr, lo, j );
        if( i < hi ) sortI_( arr, i, hi );
	}
	
	public static inline function sortI(arr : Vector<Int>, lo : Int, hi : Int)
	{
		sortI_(arr,lo,hi-1);
	}
	
	// Selection sort...
	public static function sort(arr : Vector<Comparable>)
	{
		for ( startIndex in 0...arr.length )
		{
			var minElementIndex : Int = startIndex;
			for ( i in startIndex...arr.length )
			{
				if ( arr[minElementIndex].compareTo(arr[i]) == 1 )
					minElementIndex = i;
			}
			var tmp : Comparable = arr[startIndex];
			arr[startIndex] = arr[minElementIndex];
			arr[minElementIndex] = tmp;
		}
	}
	
}
