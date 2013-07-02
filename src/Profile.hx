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
import haxe.macro.Expr;
import flash.Vector;

class Profile 
{

	public static var UNKNOWN : Profile = new Profile( -1, "unknown", false);
	public static var AAC_MAIN : Profile = new Profile(1, "AAC Main Profile", true);
	public static var AAC_LC : Profile =  new Profile(2, "AAC Low Complexity", true);
	public static var AAC_SSR : Profile =  new Profile(3, "AAC Scalable Sample Rate", false);
	public static var AAC_LTP : Profile =  new Profile(4, "AAC Long Term Prediction", false);
	public static var AAC_SBR : Profile =  new Profile(5, "AAC SBR", true);
	public static var AAC_SCALABLE : Profile =  new Profile(6, "Scalable AAC", false);
	public static var TWIN_VQ : Profile =  new Profile(7, "TwinVQ", false);
	public static var AAC_LD : Profile =  new Profile(11, "AAC Low Delay", false);
	public static var ER_AAC_LC : Profile =  new Profile(17, "Error Resilient AAC Low Complexity", true);
	public static var ER_AAC_SSR : Profile =  new Profile(18, "Error Resilient AAC SSR", false);
	public static var ER_AAC_LTP : Profile =  new Profile(19, "Error Resilient AAC Long Term Prediction", false);
	public static var ER_AAC_SCALABLE : Profile =  new Profile(20, "Error Resilient Scalable AAC", false);
	public static var ER_TWIN_VQ : Profile =  new Profile(21, "Error Resilient TwinVQ", false);
	public static var ER_BSAC : Profile =  new Profile(22, "Error Resilient BSAC", false);
	public static var ER_AAC_LD : Profile =  new Profile(23, "Error Resilient AAC Low Delay", false);
	public static var ALL : Array<Profile> = [
		AAC_MAIN, AAC_LC, AAC_SSR, AAC_LTP, AAC_SBR, AAC_SCALABLE, TWIN_VQ,
		null, null, null, AAC_LD, null, null, null, null, null, ER_AAC_LC, ER_AAC_SSR,
		ER_AAC_LTP, ER_AAC_SCALABLE, ER_TWIN_VQ, ER_BSAC, ER_AAC_LD
	];
	
	private var num : Int;
	private var descr : String;
	private var supported : Bool;
	
	public static function forInt(i : Int) : Profile
	{
		var p : Profile;
		if(i<=0||i>ALL.length) p = UNKNOWN;
		else p = ALL[i-1];
		return p;
	}
	
	private function new(num : Int, descr : String, supported : Bool)
	{
		this.num = num;
		this.descr = descr;
		this.supported = supported;
	}
	
	public function getIndex() : Int
	{
		return num;
	}
	
	public function getDescription() : String
	{
		return descr;
	}
	
	public function isDecodingSupported() : Bool
	{
		return supported;
	}
	
	public function isErrorResilientProfile() : Bool
	{
		return (num>16);
	}
	
}
