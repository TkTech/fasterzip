cimport cfasterzip
import zipfile
import contextlib


cdef class ZipFile:
    cdef cfasterzip.mz_zip_archive _zip_archive;

    def __init__(self, file: bytes):
        cfasterzip.mz_zip_zero_struct(&self._zip_archive)

        status = cfasterzip.mz_zip_reader_init_file(
            &self._zip_archive,
            file,
            0
        )
        if not status:
            raise zipfile.BadZipFile(
                cfasterzip.mz_zip_get_error_string(
                    cfasterzip.mz_zip_get_last_error(&self._zip_archive)
                )
            )

    def __dealloc__(self):
        cfasterzip.mz_zip_end(&self._zip_archive)

    def _file_count(self):
        return cfasterzip.mz_zip_reader_get_num_files(&self._zip_archive)

    def infolist(self):
        cdef cfasterzip.mz_zip_archive_file_stat stat

        for i in range(self._file_count()):
            status = cfasterzip.mz_zip_reader_file_stat(
                &self._zip_archive,
                i,
                &stat
            )
            if not status:
                raise zipfile.BadZipFile(
                cfasterzip.mz_zip_get_error_string(
                    cfasterzip.mz_zip_get_last_error(&self._zip_archive)
                )
            )

            yield stat

    def namelist(self):
        """
        Return archive members by name.
        """
        yield from (s['m_filename'] for s in self.infolist())

    @contextlib.contextmanager
    def read(self, name):
        """
        Reads the contents of `name`, returning a memory view over
        it.

        .. note::

            You should always use this as a context manager, as
            the buffer will be freed from the heap immediately after.

        :param name:
        :return: memory view of uncompressed contents.
        """
        cdef void *p
        cdef size_t uncompressed_size

        p = cfasterzip.mz_zip_reader_extract_file_to_heap(
            &self._zip_archive,
            name,
            &uncompressed_size,
            0
        )
        if not p:
            raise zipfile.BadZipFile(
                cfasterzip.mz_zip_get_error_string(
                    cfasterzip.mz_zip_get_last_error(&self._zip_archive)
                )
            )

        yield <char[:uncompressed_size]>p
        cfasterzip.mz_free(p)

    def __len__(self):
        return self._file_count()