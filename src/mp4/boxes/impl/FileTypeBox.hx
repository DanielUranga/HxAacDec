/*
 *  Copyright (C) 2011 in-somnia
 * 
 *  This file is part of JAAD.
 * 
 *  JAAD is free software; you can redistribute it and/or modify it 
 *  under the terms of the GNU Lesser General Public License as 
 *  published by the Free Software Foundation; either version 3 of the 
 *  License, or (at your option) any later version.
 *
 *  JAAD is distributed in the hope that it will be useful, but WITHOUT 
 *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
 *  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General 
 *  Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with this library.
 *  If not, see <http://www.gnu.org/licenses/>.
 */
package mp4.boxes.impl;

import mp4.boxes.BoxImpl;
import mp4.MP4InputStream;

//TODO: 3gpp brands
class FileTypeBox extends BoxImpl
{
	
	public static var BRAND_ISO_BASE_MEDIA = "isom";
	public static var BRAND_ISO_BASE_MEDIA_2 = "iso2";
	public static var BRAND_ISO_BASE_MEDIA_3 = "iso3";
	public static var BRAND_MP4_1 = "mp41";
	public static var BRAND_MP4_2 = "mp42";
	public static var BRAND_MOBILE_MP4 = "mmp4";
	public static var BRAND_QUICKTIME = "qm  ";
	public static var BRAND_AVC = "avc1";
	public static var BRAND_AUDIO = "M4A ";
	public static var BRAND_AUDIO_2 = "M4B ";
	public static var BRAND_AUDIO_ENCRYPTED = "M4P ";
	public static var BRAND_MP7 = "mp71";
	var majorBrand : String;
	var minorVersion : String;
	var compatibleBrands : Array<String>;

	public function new()
	{
		super("File Type Box");
	}

	override function decode(in_ : MP4InputStream)
	{
		majorBrand = in_.readString(4);
		minorVersion = in_.readString(4);
		//compatibleBrands = new String[(int) getLeft(in)/4];
		compatibleBrands = new Array<Strin>;
		compatibleBrands.length = getLeft(in_) / 4;
		for (i in 0...compatibleBrands.length)
		{
			compatibleBrands[i] = in_.readString(4);
		}
	}

	public function getMajorBrand()
	{
		return majorBrand;
	}

	public function getMinorVersion()
	{
		return minorVersion;
	}

	public function getCompatibleBrands()
	{
		return compatibleBrands;
	}
}
