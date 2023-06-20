# cython: language_level=3
# cython: cdivision=True
cimport cython
from libc.stdint cimport uint8_t

from cpython.mem cimport PyMem_Malloc
from cpython.bytes cimport PyBytes_FromStringAndSize

include "./consts.pxi"
include "./config.pxi"
include "./pystream.pxi"

class ArchiveError(Exception):

    def __init__(self, str msg, int errno=-1, int retcode=0, object archive_p=None):
        self.msg = msg
        self.errno = errno
        self.retcode = retcode
        self.archive_p = archive_p

    def __str__(self):
        p = '%s (errno=%s, retcode=%s, archive_p=%s)'
        return p % (self.msg, self.errno, self.retcode, self.archive_p)


cpdef inline int version_number():
    return la.archive_version_number()

cpdef inline str version_string():
    cdef const char * v = la.archive_version_string()
    return (<bytes>v).decode()

cpdef inline str version_details():
    return (<bytes>la.archive_version_details()).decode()

cpdef inline str zlib_version():
    cdef const char * v = la.archive_zlib_version()
    if v == NULL:
        raise ArchiveError("libarchive is not build with zlib")
    return (<bytes>v).decode()

cpdef inline str liblzma_version():
    cdef const char * v = la.archive_liblzma_version()
    if v == NULL:
        raise ArchiveError("libarchive is not build with liblzma")
    return (<bytes>v).decode()

cpdef inline str bzlib_version():
    cdef const char * v = la.archive_bzlib_version()
    if v == NULL:
        raise ArchiveError("libarchive is not build with bzlib")
    return (<bytes>v).decode()

cpdef inline str liblz4_version():
    cdef const char * v = la.archive_liblz4_version()
    if v == NULL:
        raise ArchiveError("libarchive is not build with liblz4")
    return (<bytes>v).decode()

cpdef inline str libzstd_version():
    cdef const char * v = la.archive_libzstd_version()
    if v == NULL:
        raise ArchiveError("libarchive is not build with libzstd")
    return (<bytes>v).decode()

# start wrapping structs
@cython.freelist(8)
cdef class Archive:
    """
    Base class around ```struct archive *```
    """
    cdef:
        la.archive * _archive_p
        # readonly bint own # 对指针的所有权 是True的那个负责析构 显然，多个PyObject可以引用一个指针，但有且仅有一个是own
        # 这种借用的引用必须在主人之前释放，其生命周期必须在主人之内

    cpdef int filter_count(self):
        return la.archive_filter_count(self._archive_p)

    cpdef la.la_int64_t filter_bytes(self, int n):
        return la.archive_filter_bytes(self._archive_p, n)

    cpdef int filter_code(self, int n):
        return la.archive_filter_code(self._archive_p, n)

    cdef str filter_name(self, int n):
        cdef const char * v = la.archive_filter_name(self._archive_p, n)
        if v != NULL:
            return (<bytes> v).decode()

    cpdef int get_errno(self):
        return la.archive_errno(self._archive_p)

    cpdef str error_string(self):
        cdef const char* v = la.archive_error_string(self._archive_p)
        if v != NULL:
            return (<bytes>v).decode()

    cpdef str format_name(self):
        cdef const char* v = la.archive_format_name(self._archive_p)
        if v != NULL:
            return (<bytes>v).decode()

    cpdef int format(self):
        return la.archive_format(self._archive_p)

    cpdef clear_error(self):
        la.archive_clear_error(self._archive_p)

    cpdef set_error(self, int _err, str msg):
        # cdef bytes msg_ = msg.encode()
        la.archive_set_error(self._archive_p, _err, <const char *>msg)

    cpdef copy_error(self, Archive other):
        la.archive_copy_error(self._archive_p, other._archive_p)

    cpdef int file_count(self):
        return la.archive_file_count(self._archive_p)

    # cpdef long long offset1(self):
    #     return <long long><void*>self
    #
    # cpdef long long offset2(self):
    #     return <long long> <void *> &self._archive_p

    # def __dealloc__(self):
    #     if self._archive_p:
    #         la.archive_free(self._archive_p)
    #     self._archive_p = NULL

# cdef struct PyCallBacks:
#     PyObject * opener
#     PyObject  * reader
#     PyObject  * seeker
#     PyObject * skipper
#     PyObject  * closer
#     PyObject  * swither

#
# cdef int pyarchive_open_callback(la.archive *a, void *_client_data) with gil:
#     cdef PyCallBacks* funcs = <PyCallBacks*>_client_data
#     cdef object func = <object>funcs.opener
#     cdef object archive = <object><void*>(<Py_ssize_t>a - ptroffset)
#     return func(archive)
#
# cdef  la.la_ssize_t  pyarchive_read_callback(la.archive *a, void *_client_data,  const void ** _buffer) with gil:
#     cdef PyCallBacks* funcs = <PyCallBacks*>_client_data
#     cdef object func = <object>funcs.reader
#     cdef object archive = <object><void*>(<Py_ssize_t>a - ptroffset)
#     return func(archive)

cdef const char* pyarchive_passphrase_callback(la.archive * a, void *_client_data) with gil:
    cdef object func = <object>_client_data
    return func()

cdef void _pyprogress_func(void* ud) with gil:
    cdef object func = <object> ud
    func()

@cython.final
cdef class ArchiveRead(Archive):
    # cdef:
    #     dict callbackref # 使对callback的引用变成强引用
    def __cinit__(self):
        self._archive_p = la.archive_read_new()  # C结构体成员的读取，比super快多了
        if self._archive_p == NULL:
            raise MemoryError

    def __dealloc__(self):
        if self._archive_p:
            la.archive_read_free(self._archive_p)
        self._archive_p = NULL

    cpdef inline int close(self):
        cdef int ret = la.archive_read_close(self._archive_p)
        if ret != la.ARCHIVE_OK:
            raise ArchiveError(self.error_string(), self.get_errno(), ret, self)
        return ret

    cpdef inline int support_filter_all(self):
        return la.archive_read_support_filter_all(self._archive_p)

    cpdef inline int support_filter_by_code(self, int code):
        return  la.archive_read_support_filter_by_code(self._archive_p, code)

    cpdef inline int support_filter_bzip2(self):
        return  la.archive_read_support_filter_bzip2(self._archive_p)

    cpdef inline int support_filter_gzip(self):
        return  la.archive_read_support_filter_gzip(self._archive_p)

    cpdef inline int support_filter_grzip(self):
        return  la.archive_read_support_filter_grzip(self._archive_p)

    cpdef inline int support_filter_lrzip(self):
        return  la.archive_read_support_filter_lrzip(self._archive_p)

    cpdef inline int support_filter_lz4(self):
        return  la.archive_read_support_filter_lz4(self._archive_p)

    cpdef inline int support_filter_lzip(self):
        return  la.archive_read_support_filter_lzip(self._archive_p)

    cpdef inline int support_filter_lzma(self):
        return  la.archive_read_support_filter_lzma(self._archive_p)

    cpdef inline int support_filter_lzop(self):
        return  la.archive_read_support_filter_lzop(self._archive_p)

    cpdef inline int support_filter_none(self):
        return  la.archive_read_support_filter_none(self._archive_p)

    cpdef inline int support_filter_program(self, object command):
        # if isinstance(command, unicode):
        #     command_ = (<unicode> command).encode()
        return  la.archive_read_support_filter_program(self._archive_p, <const char *>command)

    cpdef inline int support_filter_program_signature(self, object command, uint8_t[::1] signature):
        # cdef object command_ = command
        # if isinstance(command, unicode):
        #     command_ = (<unicode> command).encode()
        return  la.archive_read_support_filter_program_signature(self._archive_p,
                                                                 <const char *>command,
                                                                 <const void*>&signature[0],
                                                                 <size_t>signature.shape[0])

    cpdef inline int support_filter_rpm(self):
        return  la.archive_read_support_filter_rpm(self._archive_p)
    cpdef inline int support_filter_uu(self):
        return  la.archive_read_support_filter_uu(self._archive_p)
    cpdef inline int support_filter_xz(self):
        return  la.archive_read_support_filter_xz(self._archive_p)
    cpdef inline int support_filter_zstd(self):
        return  la.archive_read_support_filter_zstd(self._archive_p)

    cpdef inline int support_format_7zip(self):
        return la.archive_read_support_format_7zip(self._archive_p)
    cpdef inline int support_format_all(self):
        return la.archive_read_support_format_all(self._archive_p)
    cpdef inline int support_format_ar(self):
        return la.archive_read_support_format_ar(self._archive_p)
    cpdef inline int support_format_by_code(self, int code):
        return la.archive_read_support_format_by_code(self._archive_p, code)
    cpdef inline int support_format_cab(self):
        return la.archive_read_support_format_cab(self._archive_p)
    cpdef inline int support_format_cpio(self):
        return la.archive_read_support_format_cpio(self._archive_p)
    cpdef inline int support_format_empty(self):
        return la.archive_read_support_format_empty(self._archive_p)
    cpdef inline int support_format_gnutar(self):
        return la.archive_read_support_format_gnutar(self._archive_p)
    cpdef inline int support_format_iso9660(self):
        return la.archive_read_support_format_iso9660(self._archive_p)
    cpdef inline int support_format_lha(self):
        return la.archive_read_support_format_lha(self._archive_p)
    cpdef inline int support_format_mtree(self):
        return la.archive_read_support_format_mtree(self._archive_p)
    cpdef inline int support_format_rar(self):
        return la.archive_read_support_format_rar(self._archive_p)
    cpdef inline int support_format_rar5(self):
        return la.archive_read_support_format_rar5(self._archive_p)
    cpdef inline int support_format_raw(self):
        return la.archive_read_support_format_raw(self._archive_p)
    cpdef inline int support_format_tar(self):
        return la.archive_read_support_format_tar(self._archive_p)
    cpdef inline int support_format_warc(self):
        return la.archive_read_support_format_warc(self._archive_p)
    cpdef inline int support_format_xar(self):
        return la.archive_read_support_format_xar(self._archive_p)
    cpdef inline int support_format_zip(self):
        return la.archive_read_support_format_zip(self._archive_p)
    cpdef inline int support_format_zip_streamable(self):
        return la.archive_read_support_format_zip_streamable(self._archive_p)
    cpdef inline int support_format_zip_seekable(self):
        return la.archive_read_support_format_zip_seekable(self._archive_p)
    cpdef inline int set_format(self, int code):
        return la.archive_read_set_format(self._archive_p, code)
    cpdef inline int append_filter(self, int code):
        return la.archive_read_append_filter(self._archive_p, code)
    cpdef inline int append_filter_program(self, object command):
        # cdef object command_ = command
        # if isinstance(command, unicode):
        #     command_ = (<unicode> command).encode()
        return la.archive_read_append_filter_program(self._archive_p, <const char *>command)
    cpdef inline int append_filter_program_signature(self, object command, uint8_t[::1] match):
        # cdef object command_ = command
        # if isinstance(command, unicode):
        #     command_ = (<unicode> command).encode()
        return la.archive_read_append_filter_program_signature(self._archive_p, <const char *> command, <const void*>&match[0], <size_t>match.shape[0])

    cpdef inline int open(self, object file, la.la_ssize_t block_size, bint close = False) except? -30:
        cdef PyStreamData * data = <PyStreamData *>PyMem_Malloc(sizeof(PyStreamData))
        if not data:
            raise MemoryError
        data.file = <PyObject*>file
        data.block_size = block_size
        data.buffer = NULL
        data.length = 0
        data.close = close

        cdef int ret
        with nogil:
            ret = la.archive_read_open2(self._archive_p,
                                          data,
                                          pystream_open_callback,
                                          pystream_read_callback,
                                          pystream_skip_callback,
                                          pystream_close_callback)
        return ret

    cpdef inline int open_memory(self, uint8_t[::1] data, size_t read_size) except? -30:
        cdef int ret
        with nogil:
            ret = la.archive_read_open_memory2(self._archive_p,
                                                <const void *>&data[0],
                                                <size_t >data.shape[0],
                                               read_size)
        return ret

    cpdef inline int open_fd(self, int fd, size_t block_size) except? -30:
        cdef int ret
        with nogil:
            ret = la.archive_read_open_fd(self._archive_p, fd,  block_size)
        return ret

    def iter_entries(self):
        cdef:
            ArchiveEntry entry
            int ret
        while True:
            entry = ArchiveEntry(self)
            with nogil:
                ret = la.archive_read_next_header2(self._archive_p, entry._entry_p)
            if ret == la.ARCHIVE_EOF:
                break
            if ret != la.ARCHIVE_OK:
                raise ArchiveError(self.error_string(), self.get_errno(), ret, self)
            yield entry

    @property
    def header_position(self):
        return la.archive_read_header_position(self._archive_p)

    @property
    def has_encrypted_entries(self):
        return la.archive_read_has_encrypted_entries(self._archive_p)

    @property
    def format_capabilities(self):
        return la.archive_read_format_capabilities(self._archive_p)

    cpdef inline la.la_ssize_t readinto(self, uint8_t[::1] buf):
        """
        read data into buffer
        :param buf: Writable buffer
        :return: 
        """
        cdef la.la_ssize_t  ret
        with nogil:
            ret = la.archive_read_data(self._archive_p, &buf[0], <size_t>buf.shape[0] )
        return ret

    cpdef inline la.la_int64_t seek(self, la.la_int64_t offset, int whence):
        cdef la.la_int64_t ret
        with nogil:
            ret = la.archive_seek_data(self._archive_p, offset, whence)
        return ret

    cpdef inline tuple read_data_block(self):
        cdef:
            void* buf
            size_t size
            la.la_int64_t  offset
        with nogil:
            la.archive_read_data_block(self._archive_p, &buf,  &size, &offset)
        return PyBytes_FromStringAndSize(<char*>buf, <Py_ssize_t>size), offset

    cdef inline int read_data_zerocopy(self, const void ** buf,  size_t *size, la.la_int64_t *offset):
        cdef int ret
        with nogil:
            ret = la.archive_read_data_block(self._archive_p, buf,  size, offset)
        return ret

    cpdef inline int skip(self):
        """
        skips entire entry
        :return: 
        """
        cdef int ret
        with nogil:
            ret = la.archive_read_data_skip(self._archive_p)
        return ret

    cpdef inline int read_data_into_fd(self, int fd):
        cdef int ret
        with nogil:
            ret = la.archive_read_data_into_fd(self._archive_p, fd)
        return ret

    cpdef inline int set_format_option(self, object module, object option, object value):
        # cdef:
        #     object module_ = module
        #     object option_ = option
        #     object value_ = value
        # if isinstance( module, unicode):
        #     module_ = (<unicode>  module).encode()
        # if isinstance( option, unicode):
        #     option_ = (<unicode>  option).encode()
        # if isinstance( value, unicode):
        #     value_ = (<unicode>  value).encode()

        return la.archive_read_set_format_option(self._archive_p,
                                          <const char*> module,
                                          <const char*> option,
                                          <const char*> value)

    cpdef inline int set_filter_option(self, object module, object option, object value):
        # cdef:
        #     object module_ = module
        #     object option_ = option
        #     object value_ = value
        # if isinstance(module, unicode):
        #     module_ = (<unicode> module).encode()
        # if isinstance(option, unicode):
        #     option_ = (<unicode> option).encode()
        # if isinstance(value, unicode):
        #     value_ = (<unicode> value).encode()

        return la.archive_read_set_filter_option(self._archive_p,
                                                 <const char *> module,
                                                 <const char *> option,
                                                 <const char *> value)

    cpdef inline int set_option(self, object module, object option, object value):
        # cdef:
        #     object module_ = module
        #     object option_ = option
        #     object value_ = value
        # if isinstance(module, unicode):
        #     module_ = (<unicode> module).encode()
        # if isinstance(option, unicode):
        #     option_ = (<unicode> option).encode()
        # if isinstance(value, unicode):
        #     value_ = (<unicode> value).encode()

        return la.archive_read_set_option(self._archive_p,
                                                 <const char *> module,
                                                 <const char *> option,
                                                 <const char *> value)

    cpdef inline int set_options(self, object opts):
        return la.archive_read_set_options(self._archive_p,
                                          <const char *> opts)

    cpdef inline int add_passphrase(self, object passphrase):
        return la.archive_read_add_passphrase(self._archive_p,  <const char *>passphrase)

    cpdef inline int set_passphrase_callback(self, object func):
        """
        
        :param func: Callable[[], str|bytes]
        :return: 
        """
        cdef void* ud = <void*> func
        return la.archive_read_set_passphrase_callback(self._archive_p, ud, pyarchive_passphrase_callback)

    cpdef inline int extract(self, ArchiveEntry entry, int flags):
        cdef int ret
        with nogil:
            ret = la.archive_read_extract(self._archive_p, entry._entry_p, flags)
        return ret

    cpdef inline int extract2(self, ArchiveEntry entry, Archive ad):
        """
        
        :param entry: 
        :param ad: dest, should be a writable archive
        :return: 
        """
        cdef int ret
        with nogil:
            ret = la.archive_read_extract2(self._archive_p, entry._entry_p, ad._archive_p)
        return ret

    cpdef inline  extract_set_progress_callback(self, object func):
        cdef void * ud = <void *> func
        la.archive_read_extract_set_progress_callback(self._archive_p, _pyprogress_func, ud)

    cpdef inline extract_set_skip_file(self, la.la_int64_t dev, la.la_int64_t ino):
        la.archive_read_extract_set_skip_file(self._archive_p, dev, ino)

    # cpdef inline int set_open_callback(self, object func):
    #     self.callbacks.opener = <PyObject*>func
    #     self.callbackref["opener"] = func # 增加强引用
    #     if la.archive_read_set_callback_data(self._archive_p, &self.callbacks) == la.ARCHIVE_FATAL:
    #         raise ArchiveError(self.error_string(), self.get_errno(), -1, self)
    #     return la.archive_read_set_open_callback(self._archive_p, pyarchive_open_callback)
    #
    # cpdef inline set_read_callback(self, object func):
    #     self.callbacks.opener = <PyObject *> func
    #     self.callbackref["reader"] = func  # 增加强引用
    #     if la.archive_read_set_callback_data(self._archive_p, &self.callbacks) == la.ARCHIVE_FATAL:
    #         raise ArchiveError(self.error_string(), self.get_errno(), -1, self)
    #     return la.archive_read_set_read_callback(self._archive_p, pyarchive_read_callback)


@cython.no_gc
@cython.final
cdef class ArchiveMatch(Archive):

    def __cinit__(self):
        self._archive_p = la.archive_match_new()
        if self._archive_p == NULL:
            raise MemoryError

    def __dealloc__(self):
        if self._archive_p:
            la.archive_match_free(self._archive_p)
        self._archive_p = NULL

    cpdef inline int match_path_unmatched_inclusions(self):
        cdef int ret
        with nogil:
            ret = la.archive_match_path_unmatched_inclusions(self._archive_p)
        return ret


@cython.freelist(8)
cdef class ArchiveEntry:
    cdef:
        la.archive_entry* _entry_p

    def __cinit__(self, Archive archive = None):
        if archive is None:
            self._entry_p = la.archive_entry_new2(NULL)
        else:
            self._entry_p = la.archive_entry_new2(archive._archive_p)
        if self._entry_p == NULL:
            raise MemoryError

    def __dealloc__(self):
        if self._entry_p:
            la.archive_entry_free(self._entry_p)
        self._entry_p = NULL

    @staticmethod
    cdef inline ArchiveEntry from_ptr(la.archive_entry* ptr):
        cdef ArchiveEntry self = ArchiveEntry.__new__(ArchiveEntry)
        self._entry_p = ptr
        return self



@cython.freelist(8)
@cython.no_gc
@cython.final
cdef class ArchiveEntryLinkresolver:
    cdef la.archive_entry_linkresolver *_resolver

    def __cinit__(self):
        self._resolver = la.archive_entry_linkresolver_new()
        if self._resolver == NULL:
            raise MemoryError

    def __dealloc__(self):
        if self._resolver:
            la.archive_entry_linkresolver_free(self._resolver)
        self._resolver = NULL

    cpdef inline set_strategy(self, int format_code):
        la.archive_entry_linkresolver_set_strategy(self._resolver, format_code)

    cpdef inline linkify(self, ArchiveEntry a, ArchiveEntry b):
        la.archive_entry_linkify(self._resolver, &a._entry_p, &b._entry_p)

    cpdef inline tuple partial_links(self):
        cdef unsigned int links
        cdef la.archive_entry * ret = la.archive_entry_partial_links(self._resolver, &links)
        return  ArchiveEntry.from_ptr(ret) ,links