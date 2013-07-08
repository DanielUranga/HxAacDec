package mp4.boxes.impl;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class CleanApertureBox extends FullBox
{

	private var cleanApertureWidthN : Int;
	private var cleanApertureWidthD : Int;
	private var cleanApertureHeightN : Int;
	private var cleanApertureHeightD : Int;
	private var horizOffN : Int;
	private var horizOffD : Int;
	private var vertOffN : Int;
	private var vertOffD : Int;

	public function new()
	{
		super("Clean Aperture Box");
	}

	override public function decode(input : MP4InputStream)
	{
		cleanApertureWidthN = input.readBytes(4);
		cleanApertureWidthD = input.readBytes(4);
		cleanApertureHeightN = input.readBytes(4);
		cleanApertureHeightD = input.readBytes(4);
		horizOffN = input.readBytes(4);
		horizOffD = input.readBytes(4);
		vertOffN = input.readBytes(4);
		vertOffD = input.readBytes(4);
		left -= 32;
	}

	public function getCleanApertureWidthN() : Int
	{
		return cleanApertureWidthN;
	}

	public function getCleanApertureWidthD() : Int
	{
		return cleanApertureWidthD;
	}

	public function getCleanApertureHeightN() : Int
	{
		return cleanApertureHeightN;
	}

	public function getCleanApertureHeightD() : Int
	{
		return cleanApertureHeightD;
	}

	public function getHorizOffN() : Int
	{
		return horizOffN;
	}

	public function getHorizOffD() : Int
	{
		return horizOffD;
	}

	public function getVertOffN() : Int
	{
		return vertOffN;
	}

	public function getVertOffD() : Int
	{
		return vertOffD;
	}
	
}