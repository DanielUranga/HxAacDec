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
import impl.sbr.SBR;

class Element 
{

	private var elementInstanceTag : Int;
	private var sbr : SBR;

	private function readElementInstanceTag(input : BitStream)
	{
		elementInstanceTag = input.readBits(4);
	}

	public function getElementInstanceTag() : Int
	{
		return elementInstanceTag;
	}

	public function decodeSBR(input : BitStream, sf : SampleFrequency, count : Int, stereo : Bool, crc : Bool, downSampled : Bool)
	{
		if (sbr == null) sbr = new SBR(sf, downSampled);
		sbr.decode(input, count, stereo, crc);
	}

	public function isSBRPresent() : Bool
	{
		return sbr!=null;
	}

	public function getSBR() : SBR
	{
		return sbr;
	}
}