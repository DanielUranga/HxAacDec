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

import mp4.MP4InputStream;
import mp4.boxes.FullBox;
import mp4.od.Descriptor;

/**
 * The IPMP Control Box may contain IPMP descriptors which may be referenced by
 * any stream in the file.
 *
 * The IPMP ToolListDescriptor is defined in ISO/IEC 14496-1, which conveys the
 * list of IPMP tools required to access the media streams in an ISO Base Media
 * File or meta-box, and may include a list of alternate IPMP tools or
 * parametric descriptions of tools required to access the content.
 * 
 * The presence of IPMP Descriptor in this IPMPControlBox indicates that media
 * streams within the file or meta-box are protected by the IPMP Tool described
 * in the IPMP Descriptor. More than one IPMP Descriptors can be carried here,
 * if there are more than one IPMP Tools providing the global governance.
 *
 * @author in-somnia
 */
class IPMPControlBox extends FullBox
{

	var toolList : /*IPMPToolList*/Descriptor;
	var ipmpDescriptors : Array<Descriptor>;

	public function new()
	{
		super("IPMP Control Box");
	}

	override function decode(in_ : MP4InputStream)
	{
		super.decode(in_);

		toolList = /*(IPMPToolListDescriptor)*/ Descriptor.createDescriptor(in_);

		var count = in_.read();

		//ipmpDescriptors = new Descriptor[count];
		ipmpDescriptors = [];
		ipmpDescriptors.length = count;
		for (i in 0...count)
		{
			ipmpDescriptors[i] = /*(IPMPDescriptor)*/ Descriptor.createDescriptor(in_);
		}
	}

	/**
	 * The toollist is an IPMP ToolListDescriptor as defined in ISO/IEC 14496-1.
	 *
	 * @return the toollist
	 */
	public function getToolList()
	{
		return toolList;
	}

	/**
	 * The list of contained IPMP Descriptors.
	 *
	 * @return the IPMP descriptors
	 */
	public function getIPMPDescriptors()
	{
		return ipmpDescriptors;
	}
}
