package mp4.boxes.impl.drm;

import mp4.MP4InputStream;
import mp4.boxes.BoxImpl;

public class FairPlayDataBox extends BoxImpl {

	private byte[] data;

	public FairPlayDataBox() {
		super("iTunes FairPlay Data Box");
	}

	@Override
	public void decode(MP4InputStream in) throws IOException {
		super.decode(in);

		data = new byte[(int) getLeft(in)];
		in.readBytes(data);
	}

	public byte[] getData() {
		return data;
	}
}
