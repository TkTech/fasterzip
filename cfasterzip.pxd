from libc.time cimport time_t
from libc.stdint cimport uint64_t
from libc.stdio cimport FILE


cdef extern from "stdio.h":
    FILE *fdopen(int, const char *)


cdef extern from "Python.h":
    object PyMemoryView_FromMemory(char *mem, ssize_t size, int flags)


cdef extern from "miniz.h":
    ctypedef unsigned char mz_uint8
    ctypedef signed short mz_int16
    ctypedef unsigned short mz_uint16
    ctypedef unsigned int mz_uint32
    ctypedef unsigned int mz_uint
    ctypedef int mz_bool

    ctypedef enum mz_zip_error:
        pass

    ctypedef struct mz_zip_archive:
        pass

    ctypedef struct mz_zip_reader_extract_iter_state:
        pass

    ctypedef struct mz_zip_archive_file_stat:
        mz_uint32 m_file_index;
        uint64_t m_central_dir_ofs;
        mz_uint16 m_version_made_by;
        mz_uint16 m_version_needed;
        mz_uint16 m_bit_flag;
        mz_uint16 m_method;
        time_t m_time;
        mz_uint32 m_crc32;
        uint64_t m_comp_size;
        uint64_t m_uncomp_size;
        mz_uint16 m_internal_attr;
        mz_uint32 m_external_attr;
        uint64_t m_local_header_ofs;
        mz_uint32 m_comment_size;
        mz_bool m_is_directory;
        mz_bool m_is_encrypted;
        mz_bool m_is_supported;
        char m_filename[512];
        char m_comment[512];

    cdef:
        void mz_free(void *)
        void mz_zip_zero_struct(mz_zip_archive *)

        mz_bool mz_zip_reader_init_file(mz_zip_archive *, const char *, mz_uint32)
        mz_bool mz_zip_reader_init_cfile(mz_zip_archive *, FILE *, uint64_t, mz_uint);

        mz_bool mz_zip_end(mz_zip_archive *)

        mz_uint mz_zip_reader_get_num_files(mz_zip_archive *)
        int mz_zip_reader_locate_file(mz_zip_archive *, const char *, const char *, mz_uint flags)
        mz_bool mz_zip_reader_file_stat(mz_zip_archive *, mz_uint, mz_zip_archive_file_stat *)

        void *mz_zip_reader_extract_file_to_heap(mz_zip_archive *, const char *, size_t *, mz_uint)
        mz_zip_reader_extract_iter_state* mz_zip_reader_extract_file_iter_new(mz_zip_archive *, const char *, mz_uint)
        size_t mz_zip_reader_extract_iter_read(mz_zip_reader_extract_iter_state*, void*, size_t)
        mz_bool mz_zip_reader_extract_iter_free(mz_zip_reader_extract_iter_state*)

        mz_zip_error mz_zip_get_last_error(mz_zip_archive *)
        const char *mz_zip_get_error_string(mz_zip_error)