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

import flash.net.URLRequest;
 
class Main 
{	
	
	static function main()
	{
		
		var clip : flash.display.MovieClip = flash.Lib.current;
		var pars : Dynamic<String> = clip.loaderInfo.parameters;
        if (pars.url != null)
		{
			trace("url: " + pars.url);
			var aacSound : AACSound = new AACSound(new URLRequest(pars.url));
			aacSound.play();
		}
		else
		{
			trace("Hay que definir \"url\" en las flashvars");
			var aacSound : AACSound = new AACSound(new URLRequest("http://4083.live.streamtheworld.com:80/DUBAI_92AAC_SC"));
			try
			{
				aacSound.play();
			}
			catch (e : Dynamic)
			{
				trace("excepcion: " + e);
			}
		}
	}

}
