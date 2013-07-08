package mp4.boxes.impl;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class SampleScaleBox extends FullBox
{

	private var constrained : Bool;
	private var scaleMethod : Int;
	private var displayCenterX : Int;
	private var displayCenterY : Int;

	public function new()
	{
		super("Sample Scale Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		//7 bits reserved, 1 bit flag
		constrained = (input.read()&1)==1;

		scaleMethod = input.read();
		displayCenterX = input.readBytes(2);
		displayCenterY = input.readBytes(2);
		left -= 6;
	}

	/**
	 * If this flag is set, all samples described by this sample entry shall be 
	 * scaled according to the method specified by the field 'scale_method'.
	 * Otherwise, it is recommended that all the samples be scaled according to
	 * the method specified by the field 'scale_method', but can be displayed in
	 * an implementation dependent way, which may include not scaling the image
	 * (i.e. neither to the width and height specified in the track header box,
	 * nor by the method indicated here).
	 *
	 * @return true if the samples should be scaled by the scale method
	 */
	public function isConstrained() : Bool
	{
		return constrained;
	}

	/**
	 * The horizontal offset in pixels of the centre of the region that should
	 * be displayed by priority relative to the centre of the image. Default
	 * value is zero. Positive values indicate a display centre to the right of
	 * the image centre.
	 *
	 * @return the horizontal offset
	 */
	public function getDisplayCenterX() : Int
	{
		return displayCenterX;
	}

	/**
	 * The vertical offset in pixels of the centre of the region that should be 
	 * displayed by priority relative to the centre of the image. Default value
	 * is zero. Positive values indicate a display centre below the image
	 * centre.
	 * @return the vertical offset
	 */
	public function getDisplayCenterY() : Int
	{
		return displayCenterY;
	}

	/**
	 * The scale method is an integer that defines the scaling mode to be used.
	 * Of the 256 possible values the values 0 through 127 are reserved for use
	 * by ISO and values 128 through 255 are user-defined and are not specified
	 * in this International Standard; they may be used as determined by the
	 * application. Of the reserved values the following modes are currently
	 * defined:
	 * 1: scaling is done by 'fill' mode.
	 * 2: scaling is done by 'hidden' mode.
	 * 3: scaling is done by 'meet' mode.
	 * 4: scaling is done by 'slice' mode in the x-coordinate.
	 * 5: scaling is done by 'slice' mode in the y-coordinate.
	 *
	 * @return the scale method
	 */
	public function getScaleMethod() : Int
	{
		return scaleMethod;
	}
	
}