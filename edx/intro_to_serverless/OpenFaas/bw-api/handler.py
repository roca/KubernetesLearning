from PIL import Image
import io

def handle(req):
    buf = io.BytesIO()
    im = Image.open(io.BytesIO(req))
    im_grayscale = im.convert("L")
    try:
        im_grayscale.save(buf, format='JPEG')
    except OSError:
        return "cannot process input file", 500, {"Content-type": "text/plain"}

    byte_im = buf.getvalue()
    # Return a binary response, so that the client knows to download
    # the data to a file
    return byte_im, 200, {"Content-type": "application/octet-stream"}
