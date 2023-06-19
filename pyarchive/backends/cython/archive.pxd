# cython: language_level=3
# cython: cdivision=True
from libc.stdio cimport FILE
from libc.stdint cimport int64_t
from libc.stddef cimport wchar_t
from libc.time cimport time_t
from posix.types cimport dev_t

cdef extern from * nogil:
    ctypedef struct stat:
        dev_t         st_dev
        unsigned short         st_ino
        unsigned short st_mode
        short          st_nlink
        short          st_uid
        short          st_gid
        dev_t         st_rdev
        long         st_size
        time_t         st_atime
        time_t         st_mtime
        time_t         st_ctime
    ctypedef struct BY_HANDLE_FILE_INFORMATION

cdef extern from "stdlib.h" nogil:
    int errno

cdef extern from "archive.h" nogil:
    ctypedef ssize_t la_ssize_t
    ctypedef int64_t la_int64_t
    int archive_version_number()
    const char *    archive_version_string()
    const char *    archive_version_details()
    const char *  archive_zlib_version()
    const char *  archive_liblzma_version()
    const char *  archive_bzlib_version()
    const char *  archive_liblz4_version()
    const char *  archive_libzstd_version()

    struct archive:
        pass

    struct archive_entry:
        pass
    int ARCHIVE_EOF  # Found end of archive. */
    int ARCHIVE_OK  # Operation was successful. */
    int ARCHIVE_RETRY  # Retry might succeed. */
    int ARCHIVE_WARN  # Partial success. */
    # For example, if write_header "fails", then you can't push data. */
    int ARCHIVE_FAILED  # Current operation cannot complete. */
    # But if write_header is "fatal," then this archive is dead and useless. */
    int ARCHIVE_FATAL  # No more operations are possible. */

    ctypedef la_ssize_t    archive_read_callback(archive *, void *_client_data, const void ** _buffer)

    ctypedef la_int64_t    archive_skip_callback(archive *, void *_client_data, la_int64_t request)

    ctypedef la_int64_t    archive_seek_callback(archive *, void *_client_data, la_int64_t offset, int whence)

    ctypedef la_ssize_t    archive_write_callback(archive *, void *_client_data, const void *_buffer, size_t _length)
    ctypedef int    archive_open_callback(archive *, void *_client_data)

    ctypedef int    archive_close_callback(archive *, void *_client_data)

    ctypedef int    archive_free_callback(archive *, void *_client_data)
    ctypedef int archive_switch_callback(archive *, void *_client_data1,
                                         void *_client_data2)
    ctypedef const char *archive_passphrase_callback(archive *,
                                                     void *_client_data)
    int ARCHIVE_FILTER_NONE
    int ARCHIVE_FILTER_GZIP
    int ARCHIVE_FILTER_BZIP2
    int ARCHIVE_FILTER_COMPRESS
    int ARCHIVE_FILTER_PROGRAM
    int ARCHIVE_FILTER_LZMA
    int ARCHIVE_FILTER_XZ
    int ARCHIVE_FILTER_UU
    int ARCHIVE_FILTER_RPM
    int ARCHIVE_FILTER_LZIP
    int ARCHIVE_FILTER_LRZIP
    int ARCHIVE_FILTER_LZOP
    int ARCHIVE_FILTER_GRZIP
    int ARCHIVE_FILTER_LZ4
    int ARCHIVE_FILTER_ZSTD

    int ARCHIVE_COMPRESSION_NONE
    int ARCHIVE_COMPRESSION_GZIP
    int ARCHIVE_COMPRESSION_BZIP2
    int ARCHIVE_COMPRESSION_COMPRESS
    int ARCHIVE_COMPRESSION_PROGRAM
    int ARCHIVE_COMPRESSION_LZMA
    int ARCHIVE_COMPRESSION_XZ
    int ARCHIVE_COMPRESSION_UU
    int ARCHIVE_COMPRESSION_RPM
    int ARCHIVE_COMPRESSION_LZIP
    int ARCHIVE_COMPRESSION_LRZIP

    int ARCHIVE_FORMAT_BASE_MASK
    int ARCHIVE_FORMAT_CPIO
    int ARCHIVE_FORMAT_CPIO_POSIX
    int ARCHIVE_FORMAT_CPIO_BIN_LE
    int ARCHIVE_FORMAT_CPIO_BIN_BE
    int ARCHIVE_FORMAT_CPIO_SVR4_NOCRC
    int ARCHIVE_FORMAT_CPIO_SVR4_CRC
    int ARCHIVE_FORMAT_CPIO_AFIO_LARGE
    int ARCHIVE_FORMAT_CPIO_PWB
    int ARCHIVE_FORMAT_SHAR
    int ARCHIVE_FORMAT_SHAR_BASE
    int ARCHIVE_FORMAT_SHAR_DUMP
    int ARCHIVE_FORMAT_TAR
    int ARCHIVE_FORMAT_TAR_USTAR
    int ARCHIVE_FORMAT_TAR_PAX_INTERCHANGE
    int ARCHIVE_FORMAT_TAR_PAX_RESTRICTED
    int ARCHIVE_FORMAT_TAR_GNUTAR
    int ARCHIVE_FORMAT_ISO9660
    int ARCHIVE_FORMAT_ISO9660_ROCKRIDGE
    int ARCHIVE_FORMAT_ZIP
    int ARCHIVE_FORMAT_EMPTY
    int ARCHIVE_FORMAT_AR
    int ARCHIVE_FORMAT_AR_GNU
    int ARCHIVE_FORMAT_AR_BSD
    int ARCHIVE_FORMAT_MTREE
    int ARCHIVE_FORMAT_RAW
    int ARCHIVE_FORMAT_XAR
    int ARCHIVE_FORMAT_LHA
    int ARCHIVE_FORMAT_CAB
    int ARCHIVE_FORMAT_RAR
    int ARCHIVE_FORMAT_7ZIP
    int ARCHIVE_FORMAT_WARC
    int ARCHIVE_FORMAT_RAR_V5

    int ARCHIVE_READ_FORMAT_CAPS_NONE  # no special capabilities */
    int ARCHIVE_READ_FORMAT_CAPS_ENCRYPT_DATA  # reader can detect encrypted data */
    int ARCHIVE_READ_FORMAT_CAPS_ENCRYPT_METADATA  # reader can detect encryptable metadata (pathname, mtime, etc.) */
    int ARCHIVE_READ_FORMAT_ENCRYPTION_UNSUPPORTED
    int ARCHIVE_READ_FORMAT_ENCRYPTION_DONT_KNOW

    archive * archive_read_new()

    # DEPRECATED
    # int archive_read_support_compression_all(archive *)
    # int archive_read_support_compression_bzip2(archive *)
    # int archive_read_support_compression_compress(archive *)
    # int archive_read_support_compression_gzip(archive *)
    # int archive_read_support_compression_lzip(archive *)
    # int archive_read_support_compression_lzma(archive *)
    # int archive_read_support_compression_none(archive *)
    # int archive_read_support_compression_program(archive *, const char *command)
    # int archive_read_support_compression_program_signature(archive *, const char *, const void *, size_t)
    # int archive_read_support_compression_rpm(archive *)
    # int archive_read_support_compression_uu(archive *)
    # int archive_read_support_compression_xz(archive *)

    int archive_read_support_filter_all(archive *)
    int archive_read_support_filter_by_code(archive *, int)
    int archive_read_support_filter_bzip2(archive *)
    int archive_read_support_filter_compress(archive *)
    int archive_read_support_filter_gzip(archive *)
    int archive_read_support_filter_grzip(archive *)
    int archive_read_support_filter_lrzip(archive *)
    int archive_read_support_filter_lz4(archive *)
    int archive_read_support_filter_lzip(archive *)
    int archive_read_support_filter_lzma(archive *)
    int archive_read_support_filter_lzop(archive *)
    int archive_read_support_filter_none(archive *)
    int archive_read_support_filter_program(archive *, const char *command)
    int archive_read_support_filter_program_signature(archive *, const char *, const void *, size_t)
    int archive_read_support_filter_rpm(archive *)
    int archive_read_support_filter_uu(archive *)
    int archive_read_support_filter_xz(archive *)
    int archive_read_support_filter_zstd(archive *)

    int archive_read_support_format_7zip(archive *)
    int archive_read_support_format_all(archive *)
    int archive_read_support_format_ar(archive *)
    int archive_read_support_format_by_code(archive *, int)
    int archive_read_support_format_cab(archive *)
    int archive_read_support_format_cpio(archive *)
    int archive_read_support_format_empty(archive *)
    int archive_read_support_format_gnutar(archive *)
    int archive_read_support_format_iso9660(archive *)
    int archive_read_support_format_lha(archive *)
    int archive_read_support_format_mtree(archive *)
    int archive_read_support_format_rar(archive *)
    int archive_read_support_format_rar5(archive *)
    int archive_read_support_format_raw(archive *)
    int archive_read_support_format_tar(archive *)
    int archive_read_support_format_warc(archive *)
    int archive_read_support_format_xar(archive *)

    int archive_read_support_format_zip(archive *)
    int archive_read_support_format_zip_streamable(archive *)
    int archive_read_support_format_zip_seekable(archive *)

    int archive_read_set_format(archive *, int)
    int archive_read_append_filter(archive *, int)
    int archive_read_append_filter_program(archive *, const char *)
    int archive_read_append_filter_program_signature(archive *, const char *, const void * match, size_t)

    int archive_read_set_open_callback(archive *, archive_open_callback *)
    int archive_read_set_read_callback(archive *, archive_read_callback *)
    int archive_read_set_seek_callback(archive *, archive_seek_callback *)
    int archive_read_set_skip_callback(archive *, archive_skip_callback *)
    int archive_read_set_close_callback(archive *, archive_close_callback *)
    # Callback used to switch between one data object to the next */
    int archive_read_set_switch_callback(archive *, archive_switch_callback *)

    # This sets the first data object. */
    int archive_read_set_callback_data(archive *, void *)
    # This sets data object at specified index */
    int archive_read_set_callback_data2(archive *, void *, unsigned int)
    # This adds a data object at the specified index. */
    int archive_read_add_callback_data(archive *, void *, unsigned int)
    # This appends a data object to the end of list */
    int archive_read_append_callback_data(archive *, void *)
    # This prepends a data object to the beginning of list */
    int archive_read_prepend_callback_data(archive *, void *)

    int archive_read_open1(archive *)
    int archive_read_open(archive *, void *_client_data,
                          archive_open_callback *, archive_read_callback *,
                          archive_close_callback *)
    int archive_read_open2(archive *, void *_client_data,
                           archive_open_callback *, archive_read_callback *,
                           archive_skip_callback *, archive_close_callback *)
    int archive_read_open_filename(archive *,
                                   const char *_filename, size_t _block_size)
    int archive_read_open_filenames(archive *,
                                    const char ** _filenames, size_t _block_size)
    int archive_read_open_filename_w(archive *,
                                     const wchar_t *_filename, size_t _block_size)
    int archive_read_open_file(archive *,
                               const char *_filename, size_t _block_size)
    int archive_read_open_memory(archive *,
                                 const void * buff, size_t size)
    int archive_read_open_memory2(archive *a, const void *buff,
                                  size_t size, size_t read_size)
    int archive_read_open_fd(archive *, int _fd,
                             size_t _block_size)
    int archive_read_open_FILE(archive *, FILE *_file)
    int archive_read_next_header(archive *, archive_entry **)
    int archive_read_next_header2(archive *, archive_entry *)
    la_int64_t         archive_read_header_position(archive *)
    int    archive_read_has_encrypted_entries(archive *)
    int         archive_read_format_capabilities(archive *)
    la_ssize_t         archive_read_data(archive *, void *, size_t)
    la_int64_t  archive_seek_data(archive *, la_int64_t, int)
    int archive_read_data_block(archive *a, const void ** buff, size_t *size, la_int64_t *offset)
    int archive_read_data_skip(archive *)
    int archive_read_data_into_fd(archive *, int fd)

    # Apply option to the format only. */
    int archive_read_set_format_option(archive *_a,
                                       const char *m, const char *o,
                                       const char *v)
    # Apply option to the filter only. */
    int archive_read_set_filter_option(archive *_a,
                                       const char *m, const char *o,
                                       const char *v)
    # Apply option to both the format and the filter. */
    int archive_read_set_option(archive *_a,
                                const char *m, const char *o,
                                const char *v)
    # Apply option string to both the format and the filter. */
    int archive_read_set_options(archive *_a,
                                 const char *opts)

    int archive_read_add_passphrase(archive *, const char *)
    int archive_read_set_passphrase_callback(archive *, void *client_data, archive_passphrase_callback *)

    # flags
    # Default: Do not try to set owner/group. */
    int ARCHIVE_EXTRACT_OWNER
    # Default: Do obey umask, do not restore SUID/SGID/SVTX bits. */
    int ARCHIVE_EXTRACT_PERM
    # Default: Do not restore mtime/atime. */
    int ARCHIVE_EXTRACT_TIME
    # Default: Replace existing files. */
    int ARCHIVE_EXTRACT_NO_OVERWRITE
    # Default: Try create first, unlink only if create fails with EEXIST. */
    int ARCHIVE_EXTRACT_UNLINK
    # Default: Do not restore ACLs. */
    int ARCHIVE_EXTRACT_ACL
    # Default: Do not restore fflags. */
    int ARCHIVE_EXTRACT_FFLAGS
    # Default: Do not restore xattrs. */
    int ARCHIVE_EXTRACT_XATTR
    # Default: Do not try to guard against extracts redirected by symlinks. */
    # Note: With ARCHIVE_EXTRACT_UNLINK, will remove any intermediate symlink. */
    int ARCHIVE_EXTRACT_SECURE_SYMLINKS
    # Default: Do not reject entries with '..' as path elements. */
    int ARCHIVE_EXTRACT_SECURE_NODOTDOT
    # Default: Create parent directories as needed. */
    int ARCHIVE_EXTRACT_NO_AUTODIR
    # Default: Overwrite files, even if one on disk is newer. */
    int ARCHIVE_EXTRACT_NO_OVERWRITE_NEWER
    # Detect blocks of 0 and write holes instead. */
    int ARCHIVE_EXTRACT_SPARSE
    # Default: Do not restore Mac extended metadata. */
    # This has no effect except on Mac OS. */
    int ARCHIVE_EXTRACT_MAC_METADATA
    # Default: Use HFS+ compression if it was compressed. */
    # This has no effect except on Mac OS v10.6 or later. */
    int ARCHIVE_EXTRACT_NO_HFS_COMPRESSION
    # Default: Do not use HFS+ compression if it was not compressed. */
    # This has no effect except on Mac OS v10.6 or later. */
    int ARCHIVE_EXTRACT_HFS_COMPRESSION_FORCED
    # Default: Do not reject entries with absolute paths */
    int ARCHIVE_EXTRACT_SECURE_NOABSOLUTEPATHS
    # Default: Do not clear no-change flags when unlinking object */
    int ARCHIVE_EXTRACT_CLEAR_NOCHANGE_FFLAGS
    # Default: Do not extract atomically (using rename) */
    int ARCHIVE_EXTRACT_SAFE_WRITES

    int archive_read_extract(archive *, archive_entry *, int flags)
    int archive_read_extract2(archive *, archive_entry *, archive *)
    void archive_read_extract_set_progress_callback(archive *, void (*_progress_func)(void *), void *_user_data)

    void        archive_read_extract_set_skip_file(archive *, la_int64_t, la_int64_t)
    int         archive_read_close(archive *)
    int         archive_read_free(archive *)
    int         archive_read_finish(archive *)  # for backwards compatibility.

    archive *archive_write_new()
    int archive_write_set_bytes_per_block(archive *, int bytes_per_block)
    int archive_write_get_bytes_per_block(archive *)
    # XXX This is badly misnamed suggestions appreciated. XXX */
    int archive_write_set_bytes_in_last_block(archive *, int bytes_in_last_block)
    int archive_write_get_bytes_in_last_block(archive *)
    int archive_write_set_skip_file(archive *, la_int64_t, la_int64_t)

    int archive_write_set_compression_bzip2(archive *)

    int archive_write_set_compression_compress(archive *)

    int archive_write_set_compression_gzip(archive *)

    int archive_write_set_compression_lzip(archive *)

    int archive_write_set_compression_lzma(archive *)

    int archive_write_set_compression_none(archive *)
    int archive_write_set_compression_program(archive *, const char *cmd)
    int archive_write_set_compression_xz(archive *)

    # A convenience function to set the filter based on the code. */
    int archive_write_add_filter(archive *, int filter_code)
    int archive_write_add_filter_by_name(archive *, const char *name)
    int archive_write_add_filter_b64encode(archive *)
    int archive_write_add_filter_bzip2(archive *)
    int archive_write_add_filter_compress(archive *)
    int archive_write_add_filter_grzip(archive *)
    int archive_write_add_filter_gzip(archive *)
    int archive_write_add_filter_lrzip(archive *)
    int archive_write_add_filter_lz4(archive *)
    int archive_write_add_filter_lzip(archive *)
    int archive_write_add_filter_lzma(archive *)
    int archive_write_add_filter_lzop(archive *)
    int archive_write_add_filter_none(archive *)
    int archive_write_add_filter_program(archive *, const char *cmd)
    int archive_write_add_filter_uuencode(archive *)
    int archive_write_add_filter_xz(archive *)
    int archive_write_add_filter_zstd(archive *)

    # A convenience function to set the format based on the code or name. */
    int archive_write_set_format(archive *, int format_code)
    int archive_write_set_format_by_name(archive *,
                                         const char *name)
    # To minimize link pollution, use one or more of the following. */
    int archive_write_set_format_7zip(archive *)
    int archive_write_set_format_ar_bsd(archive *)
    int archive_write_set_format_ar_svr4(archive *)
    int archive_write_set_format_cpio(archive *)
    int archive_write_set_format_cpio_bin(archive *)
    int archive_write_set_format_cpio_newc(archive *)
    int archive_write_set_format_cpio_odc(archive *)
    int archive_write_set_format_cpio_pwb(archive *)
    int archive_write_set_format_gnutar(archive *)
    int archive_write_set_format_iso9660(archive *)
    int archive_write_set_format_mtree(archive *)
    int archive_write_set_format_mtree_classic(archive *)
    # TODO: int archive_write_set_format_old_tar(archive *) */
    int archive_write_set_format_pax(archive *)
    int archive_write_set_format_pax_restricted(archive *)
    int archive_write_set_format_raw(archive *)
    int archive_write_set_format_shar(archive *)
    int archive_write_set_format_shar_dump(archive *)
    int archive_write_set_format_ustar(archive *)
    int archive_write_set_format_v7tar(archive *)
    int archive_write_set_format_warc(archive *)
    int archive_write_set_format_xar(archive *)
    int archive_write_set_format_zip(archive *)
    int archive_write_set_format_filter_by_ext(archive *a, const char *filename)
    int archive_write_set_format_filter_by_ext_def(archive *a, const char *filename, const char * def_ext)
    int archive_write_zip_set_compression_deflate(archive *)
    int archive_write_zip_set_compression_store(archive *)

    # Deprecated use archive_write_open2 instead */
    int archive_write_open(archive *, void *,
                           archive_open_callback *, archive_write_callback *,
                           archive_close_callback *)

    int archive_write_open2(archive *, void *,
                            archive_open_callback *, archive_write_callback *,
                            archive_close_callback *, archive_free_callback *)
    int archive_write_open_fd(archive *, int _fd)
    int archive_write_open_filename(archive *, const char *_file)
    int archive_write_open_filename_w(archive *,
                                      const wchar_t *_file)
    # A deprecated synonym for archive_write_open_filename() */
    int archive_write_open_file(archive *, const char *_file)
    int archive_write_open_FILE(archive *, FILE *)
    # _buffSize is the size of the buffer, _used refers to a variable that
    # will be updated after each write into the buffer. */
    int archive_write_open_memory(archive *,
                                  void *_buffer, size_t _buffSize, size_t *_used)

    int archive_write_header(archive *, archive_entry *)
    la_ssize_t archive_write_data(archive *, const void *, size_t)
    la_ssize_t archive_write_data_block(archive *, const void *, size_t, la_int64_t)
    int archive_write_finish_entry(archive *)
    int archive_write_close(archive *)
    int archive_write_fail(archive *)
    int archive_write_free(archive *)
    int	archive_write_finish(archive *) # for backwards compatibility

    int archive_write_set_format_option(archive *_a,
			    const char *m, const char *o,
			    const char *v)
# Apply option to the filter only. */
    int archive_write_set_filter_option(archive *_a,
			    const char *m, const char *o,
			    const char *v)
# Apply option to both the format and the filter. */
    int archive_write_set_option(archive *_a,
			    const char *m, const char *o,
			    const char *v)
# Apply option string to both the format and the filter. */
    int archive_write_set_options(archive *_a,
			    const char *opts)

    int archive_write_set_passphrase(archive *_a, const char *p)
    int archive_write_set_passphrase_callback(archive *,
			    void *client_data, archive_passphrase_callback *)

    archive *archive_write_disk_new()
    int archive_write_disk_set_skip_file( archive *, la_int64_t, la_int64_t)
    int		 archive_write_disk_set_options(archive *, int flags)

    int	 archive_write_disk_set_standard_lookup(archive *)
    int archive_write_disk_set_group_lookup(archive *, void *private_data , la_int64_t (*)(void *, const char *, la_int64_t), void (* cleanup )(void *))
    int archive_write_disk_set_user_lookup(archive *, void *private_data , la_int64_t (*)(void *, const char *, la_int64_t), void (* cleanup )(void *))
    la_int64_t archive_write_disk_gid(archive *, const char *, la_int64_t)
    la_int64_t archive_write_disk_uid(archive *, const char *, la_int64_t)

    archive *archive_read_disk_new()
    int archive_read_disk_set_symlink_logical(archive * )
    int archive_read_disk_set_symlink_physical(archive *)
    int archive_read_disk_set_symlink_hybrid(archive *)
    int archive_read_disk_entry_from_file( archive *, archive_entry *, int fd, const  stat *)
    const char *archive_read_disk_gname( archive *, la_int64_t)
    const char *archive_read_disk_uname( archive *, la_int64_t)
    int	archive_read_disk_set_standard_lookup(archive *)
    int	archive_read_disk_set_gname_lookup( archive *, void *  private_data, const char *(* lookup_fn )(void *, la_int64_t), void (*  cleanup_fn )(void *))
    int	archive_read_disk_set_uname_lookup(archive *, void *  private_data , const char *(*  lookup_fn )(void *, la_int64_t), void (*  cleanup_fn )(void *))
    int	archive_read_disk_open(archive *, const char *)
    int	archive_read_disk_open_w(archive *, const wchar_t *)

    int	archive_read_disk_descend(archive *)
    int	archive_read_disk_can_descend(archive *)
    int	archive_read_disk_current_filesystem(archive *)
    int	archive_read_disk_current_filesystem_is_synthetic(archive *)
    int	archive_read_disk_current_filesystem_is_remote(archive *)
    int archive_read_disk_set_atime_restored(archive *)

    # behaviors
    int ARCHIVE_READDISK_RESTORE_ATIME
    # Default: Do not skip an entry which has nodump flags. */
    int ARCHIVE_READDISK_HONOR_NODUMP
    # Default: Skip a mac resource fork file whose prefix is "._" because of
    # using copyfile. */
    int ARCHIVE_READDISK_MAC_COPYFILE
    # Default: Traverse mount points. */
    int ARCHIVE_READDISK_NO_TRAVERSE_MOUNTS
    # Default: Xattrs are read from disk. */
    int ARCHIVE_READDISK_NO_XATTR
    # Default: ACLs are read from disk. */
    int ARCHIVE_READDISK_NO_ACL
    # Default: File flags are read from disk. */
    int ARCHIVE_READDISK_NO_FFLAGS
    # Default: Sparse file information is read from disk. */
    int ARCHIVE_READDISK_NO_SPARSE
    int archive_read_disk_set_behavior(archive *, int flags)
    int	archive_read_disk_set_matching(archive *, archive *_matching, void (*_excluded_func) (archive *, void *, archive_entry *),
		    void *_client_data)
    int	archive_read_disk_set_metadata_filter_callback(archive *, int (*_metadata_filter_func)(archive *, void *, archive_entry *), void *_client_data)
    int	archive_free(archive *)

    int		 archive_filter_count(archive *)
    la_int64_t	 archive_filter_bytes(archive *, int)
    int		 archive_filter_code(archive *, int)
    const char *	 archive_filter_name(archive *, int)

    int		 archive_errno(archive *)
    const char	*archive_error_string(archive *)
    const char	*archive_format_name(archive *)
    int		 archive_format(archive *)
    void		 archive_clear_error(archive *)
    void		 archive_set_error(archive *, int _err, const char *fmt, ...)
    void		 archive_copy_error(archive *dest, archive *src)
    int		 archive_file_count(archive *)

    archive *archive_match_new()
    int	archive_match_free(archive *)
    int	archive_match_excluded(archive *, archive_entry *)
    int	archive_match_path_excluded(archive *, archive_entry *)
# Control recursive inclusion of directory content when directory is included. Default on. */
    int	archive_match_set_inclusion_recursion(archive *, int)
# Add exclusion pathname pattern. */
    int	archive_match_exclude_pattern(archive *, const char *)
    int	archive_match_exclude_pattern_w(archive *,
		    const wchar_t *)
# Add exclusion pathname pattern from file. */
    int	archive_match_exclude_pattern_from_file(archive *, const char *, int _nullSeparator)
    int	archive_match_exclude_pattern_from_file_w(archive *, const wchar_t *, int _nullSeparator)
# Add inclusion pathname pattern. */
    int	archive_match_include_pattern(archive *, const char *)
    int	archive_match_include_pattern_w(archive *,
		    const wchar_t *)
# Add inclusion pathname pattern from file. */
    int	archive_match_include_pattern_from_file(archive *, const char *, int _nullSeparator)
    int	archive_match_include_pattern_from_file_w(archive *, const wchar_t *, int _nullSeparator)
#
 # How to get statistic information for inclusion patterns.
 #
# Return the amount number of unmatched inclusion patterns. */
    int	archive_match_path_unmatched_inclusions(archive *)
# Return the pattern of unmatched inclusion with ARCHIVE_OK.
 # Return ARCHIVE_EOF if there is no inclusion pattern. */
    int	archive_match_path_unmatched_inclusions_next( archive *, const char **)
    int	archive_match_path_unmatched_inclusions_next_w(archive *, const wchar_t **)

#
 # Test if a file is excluded by its time stamp.
 # The conditions are set by following functions.
#
    int	archive_match_time_excluded(archive *, archive_entry *)

    # Time flag: mtime to be tested. */
    int ARCHIVE_MATCH_MTIME
    # Time flag: ctime to be tested. */
    int ARCHIVE_MATCH_CTIME
    # Comparison flag: Match the time if it is newer than. */
    int ARCHIVE_MATCH_NEWER
    # Comparison flag: Match the time if it is older than. */
    int ARCHIVE_MATCH_OLDER
    # Comparison flag: Match the time if it is equal to. */
    int ARCHIVE_MATCH_EQUAL
# Set inclusion time. */
    int	archive_match_include_time(archive *, int _flag, time_t _sec, long _nsec)
# Set inclusion time by a date string. */
    int	archive_match_include_date(archive *, int _flag, const char *_datestr)
    int	archive_match_include_date_w(archive *, int _flag, const wchar_t *_datestr)
# Set inclusion time by a particular file. */
    int	archive_match_include_file_time(archive *,
		    int _flag, const char *_pathname)
    int	archive_match_include_file_time_w(archive *, int _flag, const wchar_t *_pathname)
# Add exclusion entry. */
    int	archive_match_exclude_entry(archive *, int _flag,  archive_entry *)

    int	archive_match_owner_excluded(archive *, archive_entry *)
# Add inclusion uid, gid, uname and gname. */
    int	archive_match_include_uid(archive *, la_int64_t)
    int	archive_match_include_gid(archive *, la_int64_t)
    int	archive_match_include_uname(archive *, const char *)
    int	archive_match_include_uname_w(archive *, const wchar_t *)
    int	archive_match_include_gname(archive *, const char *)
    int	archive_match_include_gname_w(archive *, const wchar_t *)
    int archive_utility_string_sort(char **)

cdef extern from "archive_entry.h" nogil:
    int AE_IFMT	
    int AE_IFREG
    int AE_IFLNK
    int AE_IFSOCK
    int AE_IFCHR
    int AE_IFBLK
    int AE_IFDIR
    int AE_IFIFO

    int AE_SYMLINK_TYPE_UNDEFINED
    int AE_SYMLINK_TYPE_FILE
    int AE_SYMLINK_TYPE_DIRECTORY

    archive_entry	*archive_entry_clear(archive_entry *)
# The 'clone' function does a deep copy all of the strings are copied too. */
    archive_entry	*archive_entry_clone(archive_entry *)
    void			 archive_entry_free(archive_entry *)
    archive_entry	*archive_entry_new()
    archive_entry * archive_entry_new2(archive * )

    time_t	 archive_entry_atime(archive_entry *)
    long		 archive_entry_atime_nsec(archive_entry *)
    int		 archive_entry_atime_is_set(archive_entry *)
    time_t	 archive_entry_birthtime(archive_entry *)
    long		 archive_entry_birthtime_nsec(archive_entry *)
    int		 archive_entry_birthtime_is_set(archive_entry *)
    time_t	 archive_entry_ctime(archive_entry *)
    long		 archive_entry_ctime_nsec(archive_entry *)
    int		 archive_entry_ctime_is_set(archive_entry *)
    dev_t		 archive_entry_dev(archive_entry *)
    int		 archive_entry_dev_is_set(archive_entry *)
    dev_t		 archive_entry_devmajor(archive_entry *)
    dev_t		 archive_entry_devminor(archive_entry *)
    unsigned short	 archive_entry_filetype(archive_entry *)
    void		 archive_entry_fflags(archive_entry *,
			    unsigned long * set,
			    unsigned long * clear)
    const char	*archive_entry_fflags_text(archive_entry *)
    la_int64_t	 archive_entry_gid(archive_entry *)
    const char	*archive_entry_gname(archive_entry *)
    const char	*archive_entry_gname_utf8(archive_entry *)
    const wchar_t	*archive_entry_gname_w(archive_entry *)
    const char	*archive_entry_hardlink(archive_entry *)
    const char	*archive_entry_hardlink_utf8(archive_entry *)
    const wchar_t	*archive_entry_hardlink_w(archive_entry *)
    la_int64_t	 archive_entry_ino(archive_entry *)
    la_int64_t	 archive_entry_ino64(archive_entry *)
    int		 archive_entry_ino_is_set(archive_entry *)
    unsigned short	 archive_entry_mode(archive_entry *)
    time_t	 archive_entry_mtime(archive_entry *)
    long		 archive_entry_mtime_nsec(archive_entry *)
    int		 archive_entry_mtime_is_set(archive_entry *)
    unsigned int	 archive_entry_nlink(archive_entry *)
    const char	*archive_entry_pathname(archive_entry *)
    const char	*archive_entry_pathname_utf8(archive_entry *)
    const wchar_t	*archive_entry_pathname_w(archive_entry *)
    unsigned short	 archive_entry_perm(archive_entry *)
    dev_t		 archive_entry_rdev(archive_entry *)
    dev_t		 archive_entry_rdevmajor(archive_entry *)
    dev_t		 archive_entry_rdevminor(archive_entry *)
    const char	*archive_entry_sourcepath(archive_entry *)
    const wchar_t	*archive_entry_sourcepath_w(archive_entry *)
    la_int64_t	 archive_entry_size(archive_entry *)
    int		 archive_entry_size_is_set(archive_entry *)
    const char	*archive_entry_strmode(archive_entry *)
    const char	*archive_entry_symlink(archive_entry *)
    const char	*archive_entry_symlink_utf8(archive_entry *)
    int		 archive_entry_symlink_type(archive_entry *)
    const wchar_t	*archive_entry_symlink_w(archive_entry *)
    la_int64_t	 archive_entry_uid(archive_entry *)
    const char	*archive_entry_uname(archive_entry *)
    const char	*archive_entry_uname_utf8(archive_entry *)
    const wchar_t	*archive_entry_uname_w(archive_entry *)
    int archive_entry_is_data_encrypted(archive_entry *)
    int archive_entry_is_metadata_encrypted(archive_entry *)
    int archive_entry_is_encrypted(archive_entry *)

    void	archive_entry_set_atime(archive_entry *, time_t, long)
    void  archive_entry_unset_atime(archive_entry *)
#if defined(_WIN32) && !defined(__CYGWIN__)
    void archive_entry_copy_bhfi(archive_entry *, BY_HANDLE_FILE_INFORMATION *) # todo windows only
#endif
    void	archive_entry_set_birthtime(archive_entry *, time_t, long)
    void  archive_entry_unset_birthtime(archive_entry *)
    void	archive_entry_set_ctime(archive_entry *, time_t, long)
    void  archive_entry_unset_ctime(archive_entry *)
    void	archive_entry_set_dev(archive_entry *, dev_t)
    void	archive_entry_set_devmajor(archive_entry *, dev_t)
    void	archive_entry_set_devminor(archive_entry *, dev_t)
    void	archive_entry_set_filetype(archive_entry *, unsigned int)
    void	archive_entry_set_fflags(archive_entry *,  unsigned long  set , unsigned long  clear )

    const char *archive_entry_copy_fflags_text(archive_entry *, const char *)
    const wchar_t *archive_entry_copy_fflags_text_w(archive_entry *, const wchar_t *)
    void	archive_entry_set_gid(archive_entry *, la_int64_t)
    void	archive_entry_set_gname(archive_entry *, const char *)
    void	archive_entry_set_gname_utf8(archive_entry *, const char *)
    void	archive_entry_copy_gname(archive_entry *, const char *)
    void	archive_entry_copy_gname_w(archive_entry *, const wchar_t *)
    int	archive_entry_update_gname_utf8(archive_entry *, const char *)
    void	archive_entry_set_hardlink(archive_entry *, const char *)
    void	archive_entry_set_hardlink_utf8(archive_entry *, const char *)
    void	archive_entry_copy_hardlink(archive_entry *, const char *)
    void	archive_entry_copy_hardlink_w(archive_entry *, const wchar_t *)
    int	archive_entry_update_hardlink_utf8(archive_entry *, const char *)
    void	archive_entry_set_ino(archive_entry *, la_int64_t)
    void	archive_entry_set_ino64(archive_entry *, la_int64_t)
    void	archive_entry_set_link(archive_entry *, const char *)
    void	archive_entry_set_link_utf8(archive_entry *, const char *)
    void	archive_entry_copy_link(archive_entry *, const char *)
    void	archive_entry_copy_link_w(archive_entry *, const wchar_t *)
    int	archive_entry_update_link_utf8(archive_entry *, const char *)
    void	archive_entry_set_mode(archive_entry *, __LA_MODE_T)
    void	archive_entry_set_mtime(archive_entry *, time_t, long)
    void  archive_entry_unset_mtime(archive_entry *)
    void	archive_entry_set_nlink(archive_entry *, unsigned int)
    void	archive_entry_set_pathname(archive_entry *, const char *)
    void	archive_entry_set_pathname_utf8(archive_entry *, const char *)
    void	archive_entry_copy_pathname(archive_entry *, const char *)
    void	archive_entry_copy_pathname_w(archive_entry *, const wchar_t *)
    int	archive_entry_update_pathname_utf8(archive_entry *, const char *)
    void	archive_entry_set_perm(archive_entry *, __LA_MODE_T)
    void	archive_entry_set_rdev(archive_entry *, dev_t)
    void	archive_entry_set_rdevmajor(archive_entry *, dev_t)
    void	archive_entry_set_rdevminor(archive_entry *, dev_t)
    void	archive_entry_set_size(archive_entry *, la_int64_t)
    void	archive_entry_unset_size(archive_entry *)
    void	archive_entry_copy_sourcepath(archive_entry *, const char *)
    void	archive_entry_copy_sourcepath_w(archive_entry *, const wchar_t *)
    void	archive_entry_set_symlink(archive_entry *, const char *)
    void	archive_entry_set_symlink_type(archive_entry *, int)
    void	archive_entry_set_symlink_utf8(archive_entry *, const char *)
    void	archive_entry_copy_symlink(archive_entry *, const char *)
    void	archive_entry_copy_symlink_w(archive_entry *, const wchar_t *)
    int	archive_entry_update_symlink_utf8(archive_entry *, const char *)
    void	archive_entry_set_uid(archive_entry *, la_int64_t)
    void	archive_entry_set_uname(archive_entry *, const char *)
    void	archive_entry_set_uname_utf8(archive_entry *, const char *)
    void	archive_entry_copy_uname(archive_entry *, const char *)
    void	archive_entry_copy_uname_w(archive_entry *, const wchar_t *)
    int	archive_entry_update_uname_utf8(archive_entry *, const char *)
    void	archive_entry_set_is_data_encrypted(archive_entry *, char is_encrypted)
    void	archive_entry_set_is_metadata_encrypted(archive_entry *, char is_encrypted)

    const stat	*archive_entry_stat(archive_entry *)
    void	archive_entry_copy_stat(archive_entry *, const  stat *) # use sth like os.stat

    const void * archive_entry_mac_metadata(archive_entry *, size_t *)
    void archive_entry_copy_mac_metadata(archive_entry *, const void *, size_t)

    int ARCHIVE_ENTRY_DIGEST_MD5
    int ARCHIVE_ENTRY_DIGEST_RMD160
    int ARCHIVE_ENTRY_DIGEST_SHA1
    int ARCHIVE_ENTRY_DIGEST_SHA256
    int ARCHIVE_ENTRY_DIGEST_SHA384
    int ARCHIVE_ENTRY_DIGEST_SHA512

    const unsigned char * archive_entry_digest(archive_entry *, int  type_)

    # Permission bits.
    int ARCHIVE_ENTRY_ACL_EXECUTE
    int ARCHIVE_ENTRY_ACL_WRITE
    int ARCHIVE_ENTRY_ACL_READ
    int ARCHIVE_ENTRY_ACL_READ_DATA
    int ARCHIVE_ENTRY_ACL_LIST_DIRECTORY
    int ARCHIVE_ENTRY_ACL_WRITE_DATA
    int ARCHIVE_ENTRY_ACL_ADD_FILE
    int ARCHIVE_ENTRY_ACL_APPEND_DATA
    int ARCHIVE_ENTRY_ACL_ADD_SUBDIRECTORY
    int ARCHIVE_ENTRY_ACL_READ_NAMED_ATTRS
    int ARCHIVE_ENTRY_ACL_WRITE_NAMED_ATTRS
    int ARCHIVE_ENTRY_ACL_DELETE_CHILD
    int ARCHIVE_ENTRY_ACL_READ_ATTRIBUTES
    int ARCHIVE_ENTRY_ACL_WRITE_ATTRIBUTES
    int ARCHIVE_ENTRY_ACL_DELETE
    int ARCHIVE_ENTRY_ACL_READ_ACL
    int ARCHIVE_ENTRY_ACL_WRITE_ACL
    int ARCHIVE_ENTRY_ACL_WRITE_OWNER
    int ARCHIVE_ENTRY_ACL_SYNCHRONIZE

    int ARCHIVE_ENTRY_ACL_PERMS_POSIX1E
    int ARCHIVE_ENTRY_ACL_PERMS_NFS4

    int ARCHIVE_ENTRY_ACL_ENTRY_INHERITED
    int ARCHIVE_ENTRY_ACL_ENTRY_FILE_INHERIT
    int ARCHIVE_ENTRY_ACL_ENTRY_DIRECTORY_INHERIT
    int ARCHIVE_ENTRY_ACL_ENTRY_NO_PROPAGATE_INHERIT
    int ARCHIVE_ENTRY_ACL_ENTRY_INHERIT_ONLY
    int ARCHIVE_ENTRY_ACL_ENTRY_SUCCESSFUL_ACCESS
    int ARCHIVE_ENTRY_ACL_ENTRY_FAILED_ACCESS
    int ARCHIVE_ENTRY_ACL_INHERITANCE_NFS4

    int ARCHIVE_ENTRY_ACL_TYPE_ACCESS	  # POSIX.1e only */
    int ARCHIVE_ENTRY_ACL_TYPE_DEFAULT	  # POSIX.1e only */
    int ARCHIVE_ENTRY_ACL_TYPE_ALLOW	 # NFS4 only */
    int ARCHIVE_ENTRY_ACL_TYPE_DENY	     # NFS4 only */
    int ARCHIVE_ENTRY_ACL_TYPE_AUDIT	 # NFS4 only */
    int ARCHIVE_ENTRY_ACL_TYPE_ALARM	 # NFS4 only */
    int ARCHIVE_ENTRY_ACL_TYPE_POSIX1E
    int ARCHIVE_ENTRY_ACL_TYPE_NFS4

    # Tag values mimic POSIX.1e */
    int ARCHIVE_ENTRY_ACL_USER			# Specified user. */
    int ARCHIVE_ENTRY_ACL_USER_OBJ 		# User who owns the file. */
    int ARCHIVE_ENTRY_ACL_GROUP			# Specified group. */
    int ARCHIVE_ENTRY_ACL_GROUP_OBJ		# Group who owns the file. */
    int ARCHIVE_ENTRY_ACL_MASK			# Modify group access (POSIX.1e only) */
    int ARCHIVE_ENTRY_ACL_OTHER			# Public (POSIX.1e only) */
    int ARCHIVE_ENTRY_ACL_EVERYONE	  # Everyone (NFS4 only) */

    void	 archive_entry_acl_clear(archive_entry *)
    int	 archive_entry_acl_add_entry(archive_entry *, int type_, int permset, int tag, int qual, const char * name)
    int	 archive_entry_acl_add_entry_w(archive_entry *,int type_, int permset, int tag, int qual, const wchar_t * name)

    int	 archive_entry_acl_reset(archive_entry *, int want_type )
    int	 archive_entry_acl_next(archive_entry *, int want_type , int *  type_ , int *  permset , int *  tag , int *  qual , const char **  name )

    int ARCHIVE_ENTRY_ACL_STYLE_EXTRA_ID
    int ARCHIVE_ENTRY_ACL_STYLE_MARK_DEFAULT
    int ARCHIVE_ENTRY_ACL_STYLE_SOLARIS
    int ARCHIVE_ENTRY_ACL_STYLE_SEPARATOR_COMMA
    int ARCHIVE_ENTRY_ACL_STYLE_COMPACT

    wchar_t *archive_entry_acl_to_text_w(archive_entry *,
	    la_ssize_t *  len, int  flags)
    char *archive_entry_acl_to_text(archive_entry *,
	    la_ssize_t *  len, int  flags)
    int archive_entry_acl_from_text_w(archive_entry *,
	    const wchar_t *  wtext, int  type)
    int archive_entry_acl_from_text(archive_entry *,
	    const char *  text, int  type)

    # Deprecated constants */
    int OLD_ARCHIVE_ENTRY_ACL_STYLE_EXTRA_ID
    int OLD_ARCHIVE_ENTRY_ACL_STYLE_MARK_DEFAULT

    # const wchar_t	*archive_entry_acl_text_w(archive_entry *,
	# 	    int  flags)
    # const char *archive_entry_acl_text(archive_entry *,
	# 	    int  flags)
    int	 archive_entry_acl_types( archive_entry *)
    int	 archive_entry_acl_count( archive_entry *, int   want_type )

    struct archive_acl:
        pass

    archive_acl *archive_entry_acl(archive_entry *)

    void	 archive_entry_xattr_clear(archive_entry *)
    void	 archive_entry_xattr_add_entry(archive_entry *, const char * name, const void * value, size_t size)

    int	archive_entry_xattr_count(archive_entry *)
    int	archive_entry_xattr_reset(archive_entry *)
    int	archive_entry_xattr_next(archive_entry *, const char ** name, const void ** value, size_t *)

    void	 archive_entry_sparse_clear(archive_entry *)
    void	 archive_entry_sparse_add_entry(archive_entry *, la_int64_t offset, la_int64_t length)


    int	archive_entry_sparse_count(archive_entry *)
    int	archive_entry_sparse_reset(archive_entry *)
    int	archive_entry_sparse_next(archive_entry *, la_int64_t *offset, la_int64_t *length)

    struct archive_entry_linkresolver:
        pass

    archive_entry_linkresolver *archive_entry_linkresolver_new()
    void archive_entry_linkresolver_set_strategy(archive_entry_linkresolver *, int format_code)
    void archive_entry_linkresolver_free(archive_entry_linkresolver *)
    void archive_entry_linkify(archive_entry_linkresolver *, archive_entry **, archive_entry **)
    archive_entry *archive_entry_partial_links(archive_entry_linkresolver *res, unsigned int *links)
