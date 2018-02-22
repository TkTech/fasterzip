import io
import tempfile
from zipfile import ZipFile as PyZipFile

import pytest

from fasterzip import ZipFile


def test_open_fd():
    """Ensure we can open file-like objects implementing fileno()."""
    with tempfile.TemporaryFile() as tf:
        # Generate an empty ZipFile.
        with PyZipFile(tf, 'w'):
            pass
        tf.seek(0)

        ZipFile(tf)


def test_open_no_fd():
    """Ensure we error as expected when trying to open a file-like object
    that has no fileno() implementation."""
    with pytest.raises(NotImplementedError):
        ZipFile(io.BytesIO())


def test_open_by_path():
    """Ensure we can open a file given a filesystem path."""
    with tempfile.NamedTemporaryFile() as tf:
        # Generate an empty ZipFile.
        with PyZipFile(tf, 'w'):
            pass
        tf.seek(0)

        # `tf.name` being the full filesystem path.
        ZipFile(tf.name.encode('UTF-8'))