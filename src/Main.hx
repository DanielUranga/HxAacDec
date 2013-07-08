import flash.net.URLRequest;
/**
 * ...
 * @author Daniel Uranga
 */
 
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
			//trace("Hay que definir \"url\" en las flashvars");			
			var aacSound = new Mp4Sound(new URLRequest("trimmed.caf"));
			aacSound.play();			
		}
	}

}
