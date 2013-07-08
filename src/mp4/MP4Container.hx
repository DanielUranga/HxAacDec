package mp4;
import flash.Vector;
import haxe.io.BytesData;
import impl.BitStream;
import mp4.api.Movie;
import mp4.boxes.Box;
import mp4.boxes.BoxFactory;
import mp4.boxes.BoxTypes;
import mp4.boxes.impl.FileTypeBox;
import mp4.boxes.impl.ProgressiveDownloadInformationBox;

/**
 * ...
 * @author Daniel Uranga
 */

class MP4Container 
{

	private var input : MP4InputStream;
	private var boxes : Vector<Box>;
	private var ftyp : FileTypeBox;
	private var pdin : ProgressiveDownloadInformationBox;
	private var moov(default, set) : Box;
	function set_moov(i : Box) : Box
	{
		if (i == null)
		{
			throw("Set moov null");
		}
		return moov = i;
	}
	
	private var movie : Movie;

	public function new(input : BitStream)
	{
		this.input = new MP4InputStream(input);
		boxes = new Vector<Box>();
		readContent();
		//moov = null;
		//movie = null;
	}

	private function readContent()
	{
		//read all boxes
		var box : Box = null;
		var type : Int;
		var moovFound : Bool = false;
		//TODO: while(true)???
		//while (true)
		while (input.bytesAvailable()>1)
		{
			/*
			try
			{
			*/
				box = BoxFactory.parseBox(null, input);
				boxes.push(box);
				type = box.getType();
				//trace("Tipo: " + type);
				
				if (type == BoxTypes.MOVIE_BOX)
				{
					if (movie == null) this.moov = box;
					moovFound = true;
				}
				else if (type == BoxTypes.FILE_TYPE_BOX)
				{
					if(ftyp==null) ftyp = cast(box, FileTypeBox);
				}
				else if (type == BoxTypes.PROGRESSIVE_DOWNLOAD_INFORMATION_BOX)
				{
					if(pdin==null) pdin = cast(box, ProgressiveDownloadInformationBox);
				}
				else if (type == BoxTypes.MEDIA_DATA_BOX)
				{
					if(moovFound) break;
					else if(!input.hasRandomAccess()) trace("movie box at end of file, need random access");
				}
				/*
			}
			
			catch (d:Dynamic)
			{
				trace("Exception: " + d);
				break;
			}
			*/
		}
	}

	public function getMajorBrand() : String
	{
		return ftyp.getMajorBrand();
	}

	public function getMinorBrand() : String
	{
		return ftyp.getMajorBrand();
	}

	public function getCompatibleBrands() : Vector<String>
	{
		return ftyp.getCompatibleBrands();
	}

	//TODO: pdin, movie fragments??
	public function getMovie() : Movie
	{		
		if(moov==null) return null;
		else if(movie==null) movie = new Movie(moov, input);
		return movie;
	}

	public function getBoxes() : Vector<Box>
	{
		//return Collections.unmodifiableList(boxes);
		var copy = new Vector<Box>();
		for (b in boxes)	copy.push(b);
		return copy;
	}
	
}