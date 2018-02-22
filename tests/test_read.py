import tempfile
from zipfile import ZipFile as PyZipFile

from fasterzip import ZipFile


def test_read():
    # Include at least one null byte in our small sample to make sure we
    # aren't accidentally using any APIs that truncate on NULLs (for example
    # auto casting to bytes in Cython.)
    sample_bytes = b'\x00' + (b'P' * 0x100000)

    with tempfile.TemporaryFile() as tf:
        with PyZipFile(tf, 'w') as zf:
            with zf.open('sample.txt', 'w') as out:
                out.write(sample_bytes)
        tf.seek(0)

        zf = ZipFile(tf)
        with zf.read(b'sample.txt') as file_contents:
            assert file_contents.tobytes() == sample_bytes