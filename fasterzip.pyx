import zipfile
import contextlib
from cpython.mem cimport PyMem_Malloc, PyMem_Free
from cfasterzip cimport (
    mz_zip_archive,
    mz_zip_zero_struct,
    mz_zip_reader_init_file,
    mz_zip_get_error_string,
    mz_zip_get_last_error,
    mz_zip_end,
    mz_zip_reader_get_num_files,
    mz_zip_archive_file_stat,
    mz_zip_reader_file_stat,
    mz_zip_reader_extract_file_to_heap,
    mz_zip_reader_extract_iter_state,
    mz_zip_reader_extract_file_iter_new,
    mz_zip_reader_extract_iter_read,
    mz_zip_reader_extract_iter_free,
    mz_zip_reader_locate_file,
    mz_free
)


cdef class ZipFile:
    cdef mz_zip_archive* _zip_archive;

    def __init__(self, file):
        status = mz_zip_reader_init_file(
            self._zip_archive,
            file,
            0
        )
        if not status:
            raise zipfile.BadZipFile(
                mz_zip_get_error_string(
                    mz_zip_get_last_error(self._zip_archive)
                )
            )

    def __cinit__(self):
        """Called on object allocation before all other methods."""
        # Must, must, must make sure either this allocation was a success
        # or we abort otherwise CPython will die with vague unfriendly
        # segfaults.
        self._zip_archive = <mz_zip_archive*> PyMem_Malloc(
            sizeof(mz_zip_archive)
        )
        # Allocation failed (can only occur due to out-of-memory)
        if not self._zip_archive:
            raise MemoryError()

        mz_zip_zero_struct(self._zip_archive)

    def __dealloc__(self):
        """Called on object deallocation."""
        mz_zip_end(self._zip_archive)
        PyMem_Free(self._zip_archive)

    def _locate_file(self, path):
        """Given a an archive entry path return its index."""
        idx = mz_zip_reader_locate_file(
            self._zip_archive,
            path,
            NULL,
            0
        )
        if idx == -1:
            # We raise KeyError here to mimic the behaviour of the stdlib
            # zipfile.
            raise KeyError(
                'There is not item named {0!r} in the archive'.format(
                    path
                )
            )

        return idx

    def getinfo(self, path):
        """
        Return a dict with information about the archive member name.

        :param path: The archive entry path
        :return: dict
        """
        cdef mz_zip_archive_file_stat stat

        idx = self._locate_file(path)

        status = mz_zip_reader_file_stat(
            self._zip_archive,
            idx,
            &stat
        )

        if not status:
            raise zipfile.BadZipFile(
                mz_zip_get_error_string(
                    mz_zip_get_last_error(self._zip_archive)
                )
            )

        return stat

    def infolist(self):
        """
        Yield detailed archive member information as dicts.

        :rtype: Iterator[dict]
        """
        cdef mz_zip_archive_file_stat stat

        for i in range(len(self)):
            status = mz_zip_reader_file_stat(
                self._zip_archive,
                i,
                &stat
            )
            if not status:
                raise zipfile.BadZipFile(
                    mz_zip_get_error_string(
                        mz_zip_get_last_error(self._zip_archive)
                    )
                )

            yield stat

    def namelist(self):
        """
        Yield archive members by name.
        """
        for s in self.infolist():
            yield s['m_filename']

    @contextlib.contextmanager
    def read(self, path):
        """
        Reads the contents of `path`, returning a memory view over
        it.

        .. note::

            This is the simplest way of extracting a file from an archive,
            however it will extract the entire file at once into memory. If
            not enough heap remains out-of-memory errors may occur.

        .. note::

            You should always use this as a context manager, as
            the buffer will be freed from the heap immediately after.

        :param path: The archive entry path.
        :return: memory view of decompressed contents.
        """
        cdef void *p
        cdef size_t uncompressed_size

        p = mz_zip_reader_extract_file_to_heap(
            self._zip_archive,
            path,
            &uncompressed_size,
            0
        )
        if not p:
            raise zipfile.BadZipFile(
                mz_zip_get_error_string(
                    mz_zip_get_last_error(self._zip_archive)
                )
            )

        yield <char[:uncompressed_size]>p
        mz_free(p)

    def read_iter(self, path, max_chunk_size=0x100000):
        """Read the contents of `path`, yielding chunks of at most
        `max_chunk_size`.

        This method may be used to efficiently decompress files that would
        not fit in memory by decompressing only `max_chunk_size` at a time.

        .. note::
            The "real" memory overhead of this method at any given iteration
            is `MAX_CHUNK_SIZE + size_of(current_chunk)`, since a Python
            byte string is created for the chunk being returned.

        :param path: The archive entry path.
        :param max_chunk_size: The maximum size of the buffer (in bytes)
        """
        cdef unsigned long copied_bytes = 0
        cdef mz_zip_reader_extract_iter_state* state
        cdef char* buff = <char*>PyMem_Malloc(max_chunk_size)

        if not buff:
            raise MemoryError()

        try:
            # We need to know the uncompressed size to know when to stop
            # iterating.
            stat = self.getinfo(path)

            state = mz_zip_reader_extract_file_iter_new(
                self._zip_archive,
                path,
                0
            )
            if not state:
                raise zipfile.BadZipFile(
                    mz_zip_get_error_string(
                        mz_zip_get_last_error(self._zip_archive)
                    )
                )

            try:
                while copied_bytes < stat['m_uncomp_size']:
                    size_read = mz_zip_reader_extract_iter_read(
                        state,
                        buff,
                        max_chunk_size
                    )

                    yield <bytes>buff[:size_read]

                    copied_bytes += size_read
            finally:
                mz_zip_reader_extract_iter_free(state)
        finally:
            PyMem_Free(buff)

    def __len__(self):
        """Returns the number of archive entries in the zipfile."""
        return mz_zip_reader_get_num_files(self._zip_archive)