from libc.time cimport time_t
from libc.stdint cimport uint64_t

cdef extern from "miniz.h":
    ctypedef unsigned char mz_uint8
    ctypedef signed short mz_int16
    ctypedef unsigned short mz_uint16
    ctypedef unsigned int mz_uint32
    ctypedef unsigned int mz_uint
    ctypedef int mz_bool
    ctypedef enum mz_zip_error:
        MZ_ZIP_NO_ERROR = 0,
        MZ_ZIP_UNDEFINED_ERROR,
        MZ_ZIP_TOO_MANY_FILES,
        MZ_ZIP_FILE_TOO_LARGE,
        MZ_ZIP_UNSUPPORTED_METHOD,
        MZ_ZIP_UNSUPPORTED_ENCRYPTION,
        MZ_ZIP_UNSUPPORTED_FEATURE,
        MZ_ZIP_FAILED_FINDING_CENTRAL_DIR,
        MZ_ZIP_NOT_AN_ARCHIVE,
        MZ_ZIP_INVALID_HEADER_OR_CORRUPTED,
        MZ_ZIP_UNSUPPORTED_MULTIDISK,
        MZ_ZIP_DECOMPRESSION_FAILED,
        MZ_ZIP_COMPRESSION_FAILED,
        MZ_ZIP_UNEXPECTED_DECOMPRESSED_SIZE,
        MZ_ZIP_CRC_CHECK_FAILED,
        MZ_ZIP_UNSUPPORTED_CDIR_SIZE,
        MZ_ZIP_ALLOC_FAILED,
        MZ_ZIP_FILE_OPEN_FAILED,
        MZ_ZIP_FILE_CREATE_FAILED,
        MZ_ZIP_FILE_WRITE_FAILED,
        MZ_ZIP_FILE_READ_FAILED,
        MZ_ZIP_FILE_CLOSE_FAILED,
        MZ_ZIP_FILE_SEEK_FAILED,
        MZ_ZIP_FILE_STAT_FAILED,
        MZ_ZIP_INVALID_PARAMETER,
        MZ_ZIP_INVALID_FILENAME,
        MZ_ZIP_BUF_TOO_SMALL,
        MZ_ZIP_INTERNAL_ERROR,
        MZ_ZIP_FILE_NOT_FOUND,
        MZ_ZIP_ARCHIVE_TOO_LARGE,
        MZ_ZIP_VALIDATION_FAILED,
        MZ_ZIP_WRITE_CALLBACK_FAILED,
        MZ_ZIP_TOTAL_ERRORS

    ctypedef struct mz_zip_archive:
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


    cdef void mz_free(void *)
    cdef void mz_zip_zero_struct(mz_zip_archive *)


    cdef mz_bool mz_zip_reader_init_file(mz_zip_archive *, const char *, mz_uint32)
    cdef mz_bool mz_zip_end(mz_zip_archive *)

    cdef mz_uint mz_zip_reader_get_num_files(mz_zip_archive *)
    cdef mz_bool mz_zip_reader_file_stat(mz_zip_archive *, mz_uint, mz_zip_archive_file_stat *)

    cdef void *mz_zip_reader_extract_file_to_heap(mz_zip_archive *, const char *, size_t *, mz_uint)

    cdef mz_zip_error mz_zip_get_last_error(mz_zip_archive *);
    cdef const char *mz_zip_get_error_string(mz_zip_error);