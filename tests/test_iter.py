import tempfile
from zipfile import ZipFile as PyZipFile

from fasterzip import ZipFile


def test_iterative_read():
    with tempfile.TemporaryFile() as tf:
        with PyZipFile(tf, 'w') as zf:
            with zf.open('sample.txt', 'w') as out:
                # 10MB sample file.
                out.write(b'P' * 0xA00000)
        tf.seek(0)

        zf = ZipFile(tf)
        assert len(zf) == 1

        it = zf.read_iter(b'sample.txt', max_chunk_size=0x100000)

        chunk_count = 0
        complete_size = 0

        for chunk in it:
            chunk_count += 1
            complete_size += len(chunk)

            for char in chunk:
                assert char == 0x50

        # We're reading a 10MB file in 1MB chunks, we should always have
        # 10 iterations. Note that miniz guarantees returning once the
        # max_chunk_size is hit or the file is consumed.
        assert chunk_count == 10
        assert complete_size == 0xA00000
