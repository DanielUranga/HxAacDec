package mp4.boxes.impl.sampleentries.codec;
import mp4.boxes.BoxTypes;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class CodecSpecificBox extends BoxImpl
{

	private var struc : CodecSpecificStructure;

	public function new()
	{
		super("CodecSpecificBox");
	}

	override public function decode(input : MP4InputStream)
	{
		if(type==BoxTypes.H263_SPECIFIC_BOX) struc = new H263SpecificStructure();
		else if(type==BoxTypes.AMR_SPECIFIC_BOX) struc = new AMRSpecificStructure();
		else if(type==BoxTypes.EVRC_SPECIFIC_BOX) struc = new EVCRSpecificStructure();
		else if(type==BoxTypes.QCELP_SPECIFIC_BOX) struc = new QCELPSpecificStructure();
		else if(type==BoxTypes.SMV_SPECIFIC_BOX) struc = new SMVSpecificStructure();
		else if(type==BoxTypes.AVC_SPECIFIC_BOX) struc = new AVCSpecificStructure();
		else struc = new UnknownCodecSpecificStructure();

		struc.decode(input);
		left -= struc.getSize();
	}

	public function getCodecSpecificStructure() : CodecSpecificStructure
	{
		return struc;
	}
	
}