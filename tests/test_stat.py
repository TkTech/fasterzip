import tempfile
from zipfile import ZipFile as PyZipFile

import pytest

from fasterzip import ZipFile


def test_getinfo():
    with tempfile.TemporaryFile() as tf:
        with PyZipFile(tf, 'w') as zf:
            with zf.open('sample.txt', 'w') as out:
                out.write(b'P' * 0x10)
        tf.seek(0)

        zf = ZipFile(tf)
        stat = zf.getinfo(b'sample.txt')

        # We don't bother checking every field, we're just ensuring we can
        # get the results we don't want to test miniz itself!
        assert stat['m_uncomp_size'] == 0x10
        assert stat['m_filename'] == b'sample.txt'

        # Ensure we get a KeyError if the file does not exist, which mimics
        # the behaviour of PyZipFile.
        with pytest.raises(KeyError) as exception:
            zf.getinfo(b'does_not_exist')

        # Ensure it's actually our error being raised.
        assert 'There is no item named' in str(exception.value)
