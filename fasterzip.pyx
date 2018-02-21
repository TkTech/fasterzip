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
        self._zip_archive = <mz_zip_archive*> PyMem_Malloc(
            sizeof(mz_zip_archive)
        )
        if not self._zip_archive:
            raise MemoryError()

        mz_zip_zero_struct(self._zip_archive)

    def __dealloc__(self):
        mz_zip_end(self._zip_archive)
        PyMem_Free(self._zip_archive)

    def _file_count(self):
        return mz_zip_reader_get_num_files(self._zip_archive)

    def infolist(self):
        cdef mz_zip_archive_file_stat stat

        for i in range(self._file_count()):
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
        Return archive members by name.
        """
        yield from (s['m_filename'] for s in self.infolist())

    @contextlib.contextmanager
    def read(self, path):
        """
        Reads the contents of `path`, returning a memory view over
        it.

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

    def __len__(self):
        return self._file_count()