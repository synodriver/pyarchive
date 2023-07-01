# cython: language_level=3
# cython: cdivision=True
from posix.types cimport dev_t

cimport cython
from cpython.bytes cimport PyBytes_FromString, PyBytes_FromStringAndSize
from cpython.mem cimport PyMem_Malloc
from libc.stddef cimport wchar_t
from libc.stdint cimport uint8_t
from libc.time cimport time_t


cdef object os
import os

include "./consts.pxi"
include "./config.pxi"
include "./pystream.pxi"

cdef extern from "Python.h":
    wchar_t * PyUnicode_AsWideCharString(object s, Py_ssize_t *size) except NULL
    str PyUnicode_FromWideChar(wchar_t *w, Py_ssize_t size)
    str PyUnicode_FromString(const char* u)
    const char * PyUnicode_AsUTF8(str u) except NULL

class ArchiveError(Exception):

    def __init__(self, object msg, int errno=-1, int retcode=0, object archive_p=None):
        if isinstance(msg, bytes):
            msg = msg.decode()
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
    if v != NULL:
        return (<bytes>v).decode()

cpdef inline str version_details():
    cdef const char * v = la.archive_version_details()
    if v != NULL:
        return (<bytes>v).decode()

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

    cpdef int filter_count(self) except? -30:
        return la.archive_filter_count(self._archive_p)

    cpdef la.la_int64_t filter_bytes(self, int n) except? -30:
        return la.archive_filter_bytes(self._archive_p, n)

    cpdef int filter_code(self, int n) except? -30:
        return la.archive_filter_code(self._archive_p, n)

    cdef bytes filter_name(self, int n):
        cdef const char * v = la.archive_filter_name(self._archive_p, n)
        if v != NULL:
            return <bytes>v

    cpdef int get_errno(self) except? -30:
        return la.archive_errno(self._archive_p)

    cpdef bytes error_string(self):
        cdef const char* v = la.archive_error_string(self._archive_p)
        if v != NULL:
            return <bytes>v

    cpdef bytes format_name(self):
        cdef const char* v = la.archive_format_name(self._archive_p)
        if v != NULL:
            return <bytes>v

    cpdef int format(self) except? -30:
        return la.archive_format(self._archive_p)

    cpdef clear_error(self):
        la.archive_clear_error(self._archive_p)

    cpdef set_error(self, int _err, str msg):
        # cdef bytes msg_ = msg.encode()
        la.archive_set_error(self._archive_p, _err, <const char *>msg)

    cpdef copy_error(self, Archive other):
        la.archive_copy_error(self._archive_p, other._archive_p)

    cpdef int file_count(self) except? -30:
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

cdef const char* pyarchive_passphrase_callback(la.archive * a, void *_client_data) except NULL with gil:
    cdef object func = <object>_client_data
    return func()

cdef void _pyprogress_func(void* ud) with gil:
    cdef object func = <object> ud
    func()

cdef enum ArchiveReadOpenState:
    Empty
    PyFileOpened
    MemoryOpened
    FdOpened

cdef class ArchiveRead(Archive):
    cdef ArchiveReadOpenState openstate
    # cdef:
    #     dict callbackref # 使对callback的引用变成强引用
    def __init__(self):
        self._archive_p = la.archive_read_new()
        # if is_disk:
        #     self._archive_p = la.archive_read_disk_new()
        # else:
        #     self._archive_p = la.archive_read_new()  # C结构体成员的读取，比super快多了
        if self._archive_p == NULL:
            raise MemoryError
        self.openstate = Empty

    def __dealloc__(self):
        if self._archive_p:
            la.archive_read_free(self._archive_p)
        self._archive_p = NULL

    cpdef int close(self) except? -30:
        cdef int ret = la.archive_read_close(self._archive_p)
        if ret != la.ARCHIVE_OK:
            raise ArchiveError(self.error_string(), self.get_errno(), ret, self)
        return ret

    cpdef int support_filter_all(self) except? -30:
        return la.archive_read_support_filter_all(self._archive_p)

    cpdef int support_filter_by_code(self, int code) except? -30:
        return  la.archive_read_support_filter_by_code(self._archive_p, code)

    cpdef int support_filter_bzip2(self) except? -30:
        return  la.archive_read_support_filter_bzip2(self._archive_p)

    cpdef int support_filter_gzip(self) except? -30:
        return  la.archive_read_support_filter_gzip(self._archive_p)

    cpdef int support_filter_grzip(self) except? -30:
        return  la.archive_read_support_filter_grzip(self._archive_p)

    cpdef int support_filter_lrzip(self) except? -30:
        return  la.archive_read_support_filter_lrzip(self._archive_p)

    cpdef int support_filter_lz4(self) except? -30:
        return  la.archive_read_support_filter_lz4(self._archive_p)

    cpdef int support_filter_lzip(self) except? -30:
        return  la.archive_read_support_filter_lzip(self._archive_p)

    cpdef int support_filter_lzma(self) except? -30:
        return  la.archive_read_support_filter_lzma(self._archive_p)

    cpdef int support_filter_lzop(self) except? -30:
        return  la.archive_read_support_filter_lzop(self._archive_p)

    cpdef int support_filter_none(self) except? -30:
        return  la.archive_read_support_filter_none(self._archive_p)

    cpdef int support_filter_program(self, object command) except? -30:
        # if isinstance(command, unicode):
        #     command_ = (<unicode> command).encode()
        return  la.archive_read_support_filter_program(self._archive_p, <const char *>command)

    cpdef int support_filter_program_signature(self, object command, const uint8_t[::1] signature) except? -30:
        # cdef object command_ = command
        # if isinstance(command, unicode):
        #     command_ = (<unicode> command).encode()
        return  la.archive_read_support_filter_program_signature(self._archive_p,
                                                                 <const char *>command,
                                                                 <const void*>&signature[0],
                                                                 <size_t>signature.shape[0])

    cpdef int support_filter_rpm(self) except? -30:
        return  la.archive_read_support_filter_rpm(self._archive_p)
    cpdef int support_filter_uu(self) except? -30:
        return  la.archive_read_support_filter_uu(self._archive_p)
    cpdef int support_filter_xz(self) except? -30:
        return  la.archive_read_support_filter_xz(self._archive_p)
    cpdef int support_filter_zstd(self) except? -30:
        return  la.archive_read_support_filter_zstd(self._archive_p)

    cpdef int support_format_7zip(self) except? -30:
        return la.archive_read_support_format_7zip(self._archive_p)
    cpdef int support_format_all(self) except? -30:
        return la.archive_read_support_format_all(self._archive_p)
    cpdef int support_format_ar(self) except? -30:
        return la.archive_read_support_format_ar(self._archive_p)
    cpdef int support_format_by_code(self, int code) except? -30:
        return la.archive_read_support_format_by_code(self._archive_p, code)
    cpdef int support_format_cab(self) except? -30:
        return la.archive_read_support_format_cab(self._archive_p)
    cpdef int support_format_cpio(self) except? -30:
        return la.archive_read_support_format_cpio(self._archive_p)
    cpdef int support_format_empty(self) except? -30:
        return la.archive_read_support_format_empty(self._archive_p)
    cpdef int support_format_gnutar(self) except? -30:
        return la.archive_read_support_format_gnutar(self._archive_p)
    cpdef int support_format_iso9660(self) except? -30:
        return la.archive_read_support_format_iso9660(self._archive_p)
    cpdef int support_format_lha(self) except? -30:
        return la.archive_read_support_format_lha(self._archive_p)
    cpdef int support_format_mtree(self) except? -30:
        return la.archive_read_support_format_mtree(self._archive_p)
    cpdef int support_format_rar(self) except? -30:
        return la.archive_read_support_format_rar(self._archive_p)
    cpdef int support_format_rar5(self) except? -30:
        return la.archive_read_support_format_rar5(self._archive_p)
    cpdef int support_format_raw(self) except? -30:
        return la.archive_read_support_format_raw(self._archive_p)
    cpdef int support_format_tar(self) except? -30:
        return la.archive_read_support_format_tar(self._archive_p)
    cpdef int support_format_warc(self) except? -30:
        return la.archive_read_support_format_warc(self._archive_p)
    cpdef int support_format_xar(self) except? -30:
        return la.archive_read_support_format_xar(self._archive_p)
    cpdef int support_format_zip(self) except? -30:
        return la.archive_read_support_format_zip(self._archive_p)
    cpdef int support_format_zip_streamable(self) except? -30:
        return la.archive_read_support_format_zip_streamable(self._archive_p)
    cpdef int support_format_zip_seekable(self) except? -30:
        return la.archive_read_support_format_zip_seekable(self._archive_p)
    cpdef int set_format(self, int code) except? -30:
        return la.archive_read_set_format(self._archive_p, code)
    cpdef int append_filter(self, int code) except? -30:
        return la.archive_read_append_filter(self._archive_p, code)
    cpdef int append_filter_program(self, object command) except? -30:
        # cdef object command_ = command
        # if isinstance(command, unicode):
        #     command_ = (<unicode> command).encode()
        return la.archive_read_append_filter_program(self._archive_p, <const char *>command)
    cpdef int append_filter_program_signature(self, object command, const uint8_t[::1] match) except? -30:
        # cdef object command_ = command
        # if isinstance(command, unicode):
        #     command_ = (<unicode> command).encode()
        return la.archive_read_append_filter_program_signature(self._archive_p, <const char *> command, <const void*>&match[0], <size_t>match.shape[0])

    cpdef int open(self, object file, la.la_ssize_t block_size, bint close = False) except? -30:
        if self.openstate != Empty and self.openstate != PyFileOpened:
            raise ArchiveError("other objects are already opened", -1, 0, self)
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
            ret = la.archive_read_append_callback_data(self._archive_p, data)

            if self.openstate == Empty:
                la.archive_read_set_seek_callback(self._archive_p, pystream_seek_callback)
                la.archive_read_set_switch_callback(self._archive_p, pystream_switch_callback)
                la.archive_read_set_open_callback(self._archive_p, pystream_open_callback)
                la.archive_read_set_read_callback(self._archive_p, pystream_read_callback)
                la.archive_read_set_skip_callback(self._archive_p,  pystream_skip_callback)
                la.archive_read_set_close_callback(self._archive_p, pystream_close_callback)
                ret = la.archive_read_open1(self._archive_p)
                self.openstate = PyFileOpened
            # ret = la.archive_read_open2(self._archive_p,
            #                               data,
            #                               pystream_open_callback,
            #                               pystream_read_callback,
            #                               pystream_skip_callback,
            #                               pystream_close_callback)
        if ret != la.ARCHIVE_OK:
            raise ArchiveError(self.error_string(), self.get_errno(), ret, self)
        return ret

    cpdef int open_memory(self, const uint8_t[::1] data, size_t read_size) except? -30:
        if self.openstate != Empty:
            raise ArchiveError("other objects are already opened", -1, 0, self)
        cdef int ret
        with nogil:
            ret = la.archive_read_open_memory2(self._archive_p,
                                                <const void *>&data[0],
                                                <size_t >data.shape[0],
                                               read_size)
        self.openstate = MemoryOpened
        return ret

    cpdef int open_fd(self, int fd, size_t block_size) except? -30:
        if self.openstate != Empty:
            raise ArchiveError("other objects are already opened", -1, 0, self)
        cdef int ret
        with nogil:
            ret = la.archive_read_open_fd(self._archive_p, fd,  block_size)
        self.openstate = FdOpened
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

    cpdef la.la_ssize_t readinto(self, uint8_t[::1] buf) except? -30:
        """
        read data into buffer
        :param buf: Writable buffer
        :return: 
        """
        cdef la.la_ssize_t  ret
        with nogil:
            ret = la.archive_read_data(self._archive_p, &buf[0], <size_t>buf.shape[0] )
        if ret < la.ARCHIVE_OK:
            raise ArchiveError(self.error_string(), self.get_errno(), ret, self)
        return ret

    cpdef la.la_int64_t seek(self, la.la_int64_t offset, int whence) except? -30:
        cdef la.la_int64_t ret
        with nogil:
            ret = la.archive_seek_data(self._archive_p, offset, whence)
        return ret

    cpdef tuple read_data_block(self):
        cdef:
            void* buf
            size_t size
            la.la_int64_t  offset
            int ret
        with nogil:
            ret = la.archive_read_data_block(self._archive_p, &buf,  &size, &offset)
        if ret == la.ARCHIVE_EOF:
            return None
        elif ret != la.ARCHIVE_OK:
            raise ArchiveError(self.error_string(), self.get_errno(), ret, self)
        return PyBytes_FromStringAndSize(<char*>buf, <Py_ssize_t>size), offset

    cdef int read_data_zerocopy(self, const void ** buf,  size_t *size, la.la_int64_t *offset) nogil:
        return la.archive_read_data_block(self._archive_p, buf,  size, offset)

    cpdef int skip(self) except? -30:
        """
        skips entire entry
        :return: 
        """
        cdef int ret
        with nogil:
            ret = la.archive_read_data_skip(self._archive_p)
        return ret

    cpdef int read_data_into_fd(self, int fd) except? -30:
        cdef int ret
        with nogil:
            ret = la.archive_read_data_into_fd(self._archive_p, fd)
        return ret

    cpdef int set_format_option(self, object module, object option, object value) except? -30:
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

    cpdef int set_filter_option(self, object module, object option, object value) except? -30:
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

    cpdef int set_option(self, object module, object option, object value) except? -30:
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

    cpdef int set_options(self, object opts) except? -30:
        return la.archive_read_set_options(self._archive_p,
                                          <const char *> opts)

    cpdef int add_passphrase(self, object passphrase) except? -30:
        return la.archive_read_add_passphrase(self._archive_p,  <const char *>passphrase)

    cpdef int set_passphrase_callback(self, object func) except? -30:
        """
        
        :param func: Callable[[], str|bytes]
        :return: 
        """
        cdef void* ud = <void*> func
        return la.archive_read_set_passphrase_callback(self._archive_p, ud, pyarchive_passphrase_callback)

    cpdef int extract(self, ArchiveEntry entry, int flags) except? -30:
        cdef int ret
        with nogil:
            ret = la.archive_read_extract(self._archive_p, entry._entry_p, flags)
        return ret

    cpdef int extract2(self, ArchiveEntry entry, Archive ad) except? -30:
        """
        
        :param entry: 
        :param ad: dest, should be a writable archive
        :return: 
        """
        cdef int ret
        with nogil:
            ret = la.archive_read_extract2(self._archive_p, entry._entry_p, ad._archive_p)
        return ret

    cpdef extract_set_progress_callback(self, object func):
        cdef void * ud = <void *> func
        la.archive_read_extract_set_progress_callback(self._archive_p, _pyprogress_func, ud)

    cpdef extract_set_skip_file(self, la.la_int64_t dev, la.la_int64_t ino):
        la.archive_read_extract_set_skip_file(self._archive_p, dev, ino)

    # cpdef int set_open_callback(self, object func):
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
cdef class ArchiveWrite(Archive):

    def __init__(self):
        self._archive_p = la.archive_write_new()
        # if is_disk:
        #     # print("archive_write_disk_new()")
        #     self._archive_p = la.archive_write_disk_new()
        # else:
        #     # print("aarchive_write_new()")
        #     self._archive_p = la.archive_write_new()
        if self._archive_p == NULL:
            raise MemoryError

    def __dealloc__(self):
        if self._archive_p:
            la.archive_write_free(self._archive_p)
        self._archive_p = NULL

    @property
    def bytes_per_block(self):
        return la.archive_write_get_bytes_per_block(self._archive_p)

    @bytes_per_block.setter
    def bytes_per_block(self, int value):
        la.archive_write_set_bytes_per_block(self._archive_p, value)

    cpdef int set_bytes_per_block(self, int bytes_per_block) except? -30:
        return la.archive_write_set_bytes_per_block(self._archive_p, bytes_per_block)

    cpdef int get_bytes_per_block(self) except? -30:
        return la.archive_write_get_bytes_per_block(self._archive_p)

    @property
    def bytes_in_last_block(self):
        return la.archive_write_get_bytes_in_last_block(self._archive_p)

    @bytes_in_last_block.setter
    def bytes_in_last_block(self, int value):
        la.archive_write_set_bytes_in_last_block(self._archive_p, value)

    cpdef int set_bytes_in_last_block(self, int bytes_in_last_block) except? -30:
        return la.archive_write_set_bytes_in_last_block(self._archive_p, bytes_in_last_block)

    cpdef int get_bytes_in_last_block(self) except? -30:
        return la.archive_write_get_bytes_in_last_block(self._archive_p)

    def set_skip_file(self, la.la_int64_t dev, la.la_int64_t ino):
        return la.archive_write_set_skip_file(self._archive_p, dev, ino)

    cpdef int add_filter(self, int filter_code) except? -30:
        return la.archive_write_add_filter(self._archive_p, filter_code)

    cpdef int add_filter_by_name(self, object name) except? -30:
        return la.archive_write_add_filter_by_name(self._archive_p, <const char *>name)

    cpdef int add_filter_b64encode(self) except? -30:
        return la.archive_write_add_filter_b64encode(self._archive_p)

    cpdef int add_filter_bzip2(self) except? -30:
        return la.archive_write_add_filter_bzip2(self._archive_p)

    cpdef int add_filter_compress(self) except? -30:
        return la.archive_write_add_filter_compress(self._archive_p)

    cpdef int add_filter_grzip(self) except? -30:
        return la.archive_write_add_filter_grzip(self._archive_p)

    cpdef int add_filter_gzip(self) except? -30:
        return la.archive_write_add_filter_gzip(self._archive_p)

    cpdef int add_filter_lrzip(self) except? -30:
        return la.archive_write_add_filter_lrzip(self._archive_p)

    cpdef int add_filter_lz4(self) except? -30:
        return la.archive_write_add_filter_lz4(self._archive_p)

    cpdef int add_filter_lzip(self) except? -30:
        return la.archive_write_add_filter_lzip(self._archive_p)

    cpdef int add_filter_lzma(self) except? -30:
        return la.archive_write_add_filter_lzma(self._archive_p)

    cpdef int add_filter_lzop(self) except? -30:
        return la.archive_write_add_filter_lzop(self._archive_p)

    cpdef int add_filter_none(self) except? -30:
        return la.archive_write_add_filter_none(self._archive_p)

    cpdef int add_filter_program(self, object cmd) except? -30:
        return la.archive_write_add_filter_program(self._archive_p, <const char*> cmd)

    cpdef int add_filter_uuencode(self) except? -30:
        return la.archive_write_add_filter_uuencode(self._archive_p)

    cpdef int add_filter_xz(self) except? -30:
        return la.archive_write_add_filter_xz(self._archive_p)

    cpdef int add_filter_zstd(self) except? -30:
        return la.archive_write_add_filter_zstd(self._archive_p)

    cpdef int set_format(self, int format_code) except? -30:
        return la.archive_write_set_format(self._archive_p,  format_code)

    cpdef int set_format_by_name(self, object name) except? -30:
        return la.archive_write_set_format_by_name(self._archive_p, <const char*> name)

    cpdef int set_format_7zip(self) except? -30:
        return la.archive_write_set_format_7zip(self._archive_p)

    cpdef int set_format_ar_bsd(self) except? -30:
        return la.archive_write_set_format_ar_bsd(self._archive_p)

    cpdef int set_format_ar_svr4(self) except? -30:
        return la.archive_write_set_format_ar_svr4(self._archive_p)

    cpdef int set_format_cpio(self) except? -30:
        return la.archive_write_set_format_cpio(self._archive_p)
    cpdef int set_format_cpio_bin(self) except? -30:
        return la.archive_write_set_format_cpio_bin(self._archive_p)
    cpdef int set_format_cpio_newc(self) except? -30:
        return la.archive_write_set_format_cpio_newc(self._archive_p)
    cpdef int set_format_cpio_odc(self) except? -30:
        return la.archive_write_set_format_cpio_odc(self._archive_p)
    cpdef int set_format_cpio_pwb(self) except? -30:
        return la.archive_write_set_format_cpio_pwb(self._archive_p)
    cpdef int set_format_gnutar(self) except? -30:
        return la.archive_write_set_format_gnutar(self._archive_p)
    cpdef int set_format_iso9660(self) except? -30:
        return la.archive_write_set_format_iso9660(self._archive_p)
    cpdef int set_format_mtree(self) except? -30:
        return la.archive_write_set_format_mtree(self._archive_p)
    cpdef int set_format_mtree_classic(self) except? -30:
        return la.archive_write_set_format_mtree_classic(self._archive_p)
    cpdef int set_format_pax(self) except? -30:
        return la.archive_write_set_format_pax(self._archive_p)
    cpdef int set_format_pax_restricted(self) except? -30:
        return la.archive_write_set_format_pax_restricted(self._archive_p)
    cpdef int set_format_raw(self) except? -30:
        return la.archive_write_set_format_raw(self._archive_p)
    cpdef int set_format_shar(self) except? -30:
        return la.archive_write_set_format_shar(self._archive_p)
    cpdef int set_format_shar_dump(self) except? -30:
        return la.archive_write_set_format_shar_dump(self._archive_p)
    cpdef int set_format_ustar(self) except? -30:
        return la.archive_write_set_format_ustar(self._archive_p)
    cpdef int set_format_v7tar(self) except? -30:
        return la.archive_write_set_format_v7tar(self._archive_p)
    cpdef int set_format_warc(self) except? -30:
        return la.archive_write_set_format_warc(self._archive_p)
    cpdef int set_format_xar(self) except? -30:
        return la.archive_write_set_format_xar(self._archive_p)
    cpdef int set_format_zip(self) except? -30:
        return la.archive_write_set_format_zip(self._archive_p)

    cpdef int set_format_filter_by_ext(self, object filename) except? -30:
        return la.archive_write_set_format_filter_by_ext(self._archive_p, <const char *>filename)
    cpdef int set_format_filter_by_ext_def(self, object filename, object def_ext) except? -30:
        return la.archive_write_set_format_filter_by_ext_def(self._archive_p, <const char *> filename,  <const char *> def_ext)
    cpdef int zip_set_compression_deflate(self) except? -30:
        return la.archive_write_zip_set_compression_deflate(self._archive_p)
    cpdef int zip_set_compression_store(self) except? -30:
        return la.archive_write_zip_set_compression_store(self._archive_p)

    cpdef int open(self, object file, la.la_ssize_t block_size, bint close = False) except? -30:
        cdef PyStreamData * data = <PyStreamData *> PyMem_Malloc(sizeof(PyStreamData))
        if not data:
            raise MemoryError
        data.file = <PyObject *> file
        data.block_size = block_size
        data.buffer = NULL
        data.length = 0
        data.close = close

        cdef int ret
        with nogil:
            ret = la.archive_write_open2(self._archive_p,
                                        data,
                                        pystream_open_callback,
                                        pystream_write_callback,
                                        pystream_close_callback,
                                         NULL)
        return ret

    cpdef int open_fd(self, int fd) except? -30:
        cdef int ret
        with nogil:
            ret = la.archive_write_open_fd(self._archive_p, fd)
        return ret

    cpdef int open_memory(self, uint8_t[::1] data, size_t[::1] used) except? -30:
        """
        
        :param data: the buffer that will be written into
        :param used: Keep a ref to this, it will be updated after each write into the buffer
        :return: 
        """
        cdef:
            int ret
        with nogil:
            ret = la.archive_write_open_memory(self._archive_p,
                                                <void *>&data[0],
                                                <size_t >data.shape[0],
                                               &used[0])
        return ret

    cpdef int write_header(self, ArchiveEntry entry) except? -30:
        cdef int ret
        with nogil:
            ret = la.archive_write_header(self._archive_p, entry._entry_p)
        if ret < la.ARCHIVE_OK:
            raise ArchiveError(self.error_string(), self.get_errno(), ret, self)
        return ret

    cpdef la.la_ssize_t write(self, const uint8_t[::1] data) except? -30:
        cdef la.la_ssize_t ret
        with nogil:
            ret = la.archive_write_data(self._archive_p, <const void *>&data[0], <size_t>data.shape[0])
        if ret < la.ARCHIVE_OK:
            raise ArchiveError(self.error_string(), self.get_errno(), ret, self)
        return ret

    cpdef la.la_ssize_t write_data_block(self, const uint8_t[::1] data, la.la_int64_t offset) except? -30:
        cdef la.la_ssize_t ret
        with nogil:
            ret = la.archive_write_data_block(self._archive_p,  <const void *>&data[0], <size_t>data.shape[0], offset)
        if ret != la.ARCHIVE_OK:
            raise ArchiveError(self.error_string(), self.get_errno(), ret, self)
        return ret

    cpdef int finish_entry(self) except? -30:
        cdef int ret
        with nogil:
            ret = la.archive_write_finish_entry(self._archive_p)
        if ret < la.ARCHIVE_OK:
            raise ArchiveError(self.error_string(), self.get_errno(), ret, self)
        return ret

    cpdef int close(self) except? -30:
        cdef int ret = la.archive_write_close(self._archive_p)
        if ret < la.ARCHIVE_OK:
            raise ArchiveError(self.error_string(), self.get_errno(), ret, self)
        return ret

    cpdef int fail(self) except? -30:
        cdef int ret = la.archive_write_fail(self._archive_p)
        if ret < la.ARCHIVE_OK:
            raise ArchiveError(self.error_string(), self.get_errno(), ret, self)
        return ret

    cpdef int set_format_option(self, object module, object option, object value) except? -30:
        return la.archive_write_set_format_option(self._archive_p,
                                           <const char*> module,
                                          <const char*> option,
                                          <const char*> value)

    cpdef int set_filter_option(self, object module, object option, object value) except? -30:
        return la.archive_write_set_filter_option(self._archive_p,
                                                  <const char *> module,
                                                  <const char *> option,
                                                    <const char *> value)

    cpdef int set_option(self, object module, object option, object value) except? -30:
        return la.archive_write_set_option(self._archive_p,
                                                  <const char *> module,
                                                  <const char *> option,
                                                  <const char *> value)

    def set_options(self, object opts):
        return la.archive_write_set_options(self._archive_p,
                                           <const char *> opts)

    cpdef int set_passphrase(self, object passphrase) except? -30:
        return la.archive_write_set_passphrase(self._archive_p, <const char *>passphrase)

    cpdef int set_passphrase_callback(self, object func) except? -30:
        """

        :param func: Callable[[], str|bytes]
        :return: 
        """
        cdef void * ud = <void *> func
        return la.archive_write_set_passphrase_callback(self._archive_p, ud, pyarchive_passphrase_callback)
    # ARCHIVE_WRITE_DISK API

cdef struct LookupData:
    PyObject *lookup
    PyObject *cleanup

cdef la.la_int64_t pywrite_disk_lookup_cb(void *ud, const char *gname, la.la_int64_t gid) with gil:
    cdef LookupData* data = <LookupData*>ud
    cdef object func = <object>data.lookup
    return func(gname, gid)

cdef void pywrite_disk_lookup_cleanup(void *ud) with gil:
    cdef LookupData * data = <LookupData *> ud
    cdef object func = <object>data.cleanup
    func()
    PyMem_Free(data)

@cython.final
cdef class ArchiveWriteDisk(ArchiveWrite):
    def __init__(self):
        self._archive_p = la.archive_write_disk_new()
        if self._archive_p == NULL:
            raise MemoryError
        # print(f"in ArchiveWriteDisk.__cinit__ {is_disk}")


    def set_skip_file(self, la.la_int64_t dev, la.la_int64_t ino):
        return la.archive_write_disk_set_skip_file(self._archive_p, dev, ino)

    def set_options(self, int flags):
        """
        Set flags to control how the next item gets created.
        This accepts a bitmask of ARCHIVE_EXTRACT_XXX flags defined above.
        :param flags: 
        :return: 
        """
        return la.archive_write_disk_set_options(self._archive_p,  flags)

    cpdef inline int set_standard_lookup(self) except? -30:
        return la.archive_write_disk_set_standard_lookup(self._archive_p )

    cpdef inline int set_group_lookup(self, object lookup, object cleanup) except? -30:
        """
        
        :param lookup: Callable[[bytes, int], int] lookup_gid callback
        :param cleanup: Callable[[], None] cleanup callback
        :return: 
        """
        cdef LookupData * data = <LookupData *>PyMem_Malloc(sizeof(LookupData))
        if not data:
            raise MemoryError
        data.lookup = <PyObject*>lookup
        data.cleanup = <PyObject *> cleanup
        return la.archive_write_disk_set_group_lookup(self._archive_p,
                                                      data,
                                                      pywrite_disk_lookup_cb,
                                                      pywrite_disk_lookup_cleanup)

    cpdef inline int set_user_lookup(self, object lookup, object cleanup) except? -30:
        """
        
        :param lookup: Callable[[bytes, int], int] lookup_gid callback
        :param cleanup: Callable[[], None] cleanup callback
        :return: 
        """
        cdef LookupData * data = <LookupData *>PyMem_Malloc(sizeof(LookupData))
        if not data:
            raise MemoryError
        data.lookup = <PyObject*>lookup
        data.cleanup = <PyObject *> cleanup
        return la.archive_write_disk_set_user_lookup(self._archive_p,
                                                      data,
                                                      pywrite_disk_lookup_cb,
                                                      pywrite_disk_lookup_cleanup)

    cpdef la.la_int64_t gid(self, object name, la.la_int64_t gid) except? -30:
        return  la.archive_write_disk_gid(self._archive_p, <const char *>name, gid)

    cpdef la.la_int64_t uid(self, object name, la.la_int64_t uid) except? -30:
        return la.archive_write_disk_uid(self._archive_p, <const char *> name, uid)

cdef const char * pyread_disk_lookup_cb(void *ud, la.la_int64_t gid) with gil:
    cdef LookupData * data = <LookupData *> ud
    cdef object func = <object> data.lookup
    return func(gid)

cdef void pyread_disk_lookup_cleanup(void *ud) with gil:
    cdef LookupData * data = <LookupData *> ud
    cdef object func = <object> data.cleanup
    func()
    PyMem_Free(data)

cdef void pyexcluded_func(la.archive *a, void *ud, la.archive_entry *entry_) with gil:
    cdef object func = <object> ud
    cdef ArchiveEntry entry = ArchiveEntry.from_ptr(entry_, 0)
    func(entry)
    # entry._entry_p = NULL deref
cdef int pymetadata_filter_func(la.archive *a, void* ud, la.archive_entry *entry_) with gil:
    cdef object func = <object> ud
    cdef ArchiveEntry entry = ArchiveEntry.from_ptr(entry_, 0)
    return func(entry)


@cython.final
cdef class ArchiveReadDisk(ArchiveRead):
    def __init__(self):
        self._archive_p = la.archive_read_disk_new()
        if self._archive_p == NULL:
            raise MemoryError

    cpdef inline int set_symlink_logical(self) except? -30:
        return la.archive_read_disk_set_symlink_logical(self._archive_p)

    cpdef inline int set_symlink_physical(self) except? -30:
        return la.archive_read_disk_set_symlink_physical(self._archive_p)

    cpdef inline int set_symlink_hybrid(self) except? -30:
        return la.archive_read_disk_set_symlink_hybrid(self._archive_p)

    cpdef inline int entry_from_file(self, ArchiveEntry entry, int fd, object stat) except? -30:
        cdef la.stat st
        if stat is not None:
            st.st_dev = stat.st_dev
            st.st_ino = stat.st_ino
            st.st_mode = stat.st_mode
            st.st_nlink = stat.st_nlink
            st.st_uid = stat.st_uid
            st.st_gid = stat.st_gid
            # st.st_rdev = stat.st_rdev todo In python, os.stat_result has no st_rdev
            st.st_size = stat.st_size
            st.st_atime = stat.st_atime
            st.st_mtime = stat.st_mtime
            st.st_ctime = stat.st_ctime

            return la.archive_read_disk_entry_from_file(self._archive_p, entry._entry_p, fd, &st)
        else:
            return la.archive_read_disk_entry_from_file(self._archive_p, entry._entry_p, fd, NULL)

    cpdef inline bytes gname(self, la.la_int64_t gid):
        cdef const char* v
        v = la.archive_read_disk_gname(self._archive_p, gid)
        if v != NULL:
            return <bytes>v

    cpdef inline bytes uname(self, la.la_int64_t uid):
        cdef const char * v
        v = la.archive_read_disk_uname(self._archive_p, uid)
        if v != NULL:
            return <bytes>v

    cpdef inline int set_standard_lookup(self) except? -30:
        return la.archive_read_disk_set_standard_lookup(self._archive_p)

    cpdef inline int set_gname_lookup(self, object lookup, object cleanup) except? -30:
        """

        :param lookup: Callable[[bytes, int], int] lookup_gid callback
        :param cleanup: Callable[[], None] cleanup callback
        :return: 
        """
        cdef LookupData * data = <LookupData *> PyMem_Malloc(sizeof(LookupData))
        if not data:
            raise MemoryError
        data.lookup = <PyObject *> lookup
        data.cleanup = <PyObject *> cleanup
        return la.archive_read_disk_set_gname_lookup(self._archive_p,
                                                     data,
                                                     pyread_disk_lookup_cb,
                                                     pyread_disk_lookup_cleanup)

    cpdef inline int set_uname_lookup(self, object lookup, object cleanup) except? -30:
        """

        :param lookup: Callable[[bytes, int], int] lookup_gid callback
        :param cleanup: Callable[[], None] cleanup callback
        :return: 
        """
        cdef LookupData * data = <LookupData *> PyMem_Malloc(sizeof(LookupData))
        if not data:
            raise MemoryError
        data.lookup = <PyObject *> lookup
        data.cleanup = <PyObject *> cleanup
        return la.archive_read_disk_set_uname_lookup(self._archive_p,
                                                     data,
                                                     pyread_disk_lookup_cb,
                                                     pyread_disk_lookup_cleanup)

    cpdef inline int open_a(self, const uint8_t[::1] name) except? -30:
        return la.archive_read_disk_open(self._archive_p, <const char *>&name[0])

    cpdef inline int open_w(self, str name) except? -30:
        cdef wchar_t * name_ = PyUnicode_AsWideCharString(name, NULL)
        try:
            return la.archive_read_disk_open_w(self._archive_p, <const wchar_t *>name_)
        finally:
            PyMem_Free(name_)

    cpdef inline int descend(self) except? -30:
        return la.archive_read_disk_descend(self._archive_p)

    cpdef inline int can_descend(self) except? -30:
        return la.archive_read_disk_can_descend(self._archive_p)

    cpdef inline int current_filesystem(self) except? -30:
        return la.archive_read_disk_current_filesystem(self._archive_p)

    cpdef inline int current_filesystem_is_synthetic(self) except? -30:
        return la.archive_read_disk_current_filesystem_is_synthetic(self._archive_p)

    cpdef inline int current_filesystem_is_remote(self) except? -30:
        return la.archive_read_disk_current_filesystem_is_remote(self._archive_p)

    cpdef inline int set_atime_restored(self) except? -30:
        return la.archive_read_disk_set_atime_restored(self._archive_p)

    cpdef inline int set_behavior(self, int flags) except? -30:
        return la.archive_read_disk_set_behavior(self._archive_p, flags)

    cpdef inline int set_matching(self, ArchiveMatch ma, object excluded_func) except? -30:
        cdef void* ud = <void*> excluded_func
        return la.archive_read_disk_set_matching(self._archive_p, ma._archive_p, pyexcluded_func, ud)

    cpdef inline int set_metadata_filter_callback(self, object filter_func) except? -30:
        cdef void * ud = <void *> filter_func
        return la.archive_read_disk_set_metadata_filter_callback(self._archive_p, pymetadata_filter_func, ud)

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

    cpdef inline int excluded(self, ArchiveEntry entry) except? -30:
        cdef int ret
        with nogil:
            ret = la.archive_match_excluded(self._archive_p, entry._entry_p)
        return ret

    cpdef inline int set_inclusion_recursion(self, bint enabled) except? -30:
        return la.archive_match_set_inclusion_recursion(self._archive_p, enabled)

    cpdef inline int exclude_pattern(self, object pattern) except? -30:
        return la.archive_match_exclude_pattern(self._archive_p, <const char*>pattern)

    cpdef inline int exclude_pattern_w(self, object pattern) except? -30:
        cdef wchar_t * pattern_ = PyUnicode_AsWideCharString(pattern, NULL)
        try:
            return la.archive_match_exclude_pattern_w(self._archive_p, <const wchar_t *> pattern_)
        finally:
            PyMem_Free(pattern_)

    cpdef inline int exclude_pattern_from_file(self, object pathname, const uint8_t[::1] null_separator) except? -30:
        cdef int nullSeparator_ = <int>null_separator[0]
        return la.archive_match_exclude_pattern_from_file(self._archive_p, <const char*>pathname, nullSeparator_)

    cpdef inline int exclude_pattern_from_file_w(self, str pathname, const uint8_t[::1] null_separator) except? -30:
        cdef int nullSeparator_ = <int>null_separator[0]
        cdef wchar_t * pathname_ = PyUnicode_AsWideCharString(pathname, NULL)
        try:
            return la.archive_match_exclude_pattern_from_file_w(self._archive_p, <const wchar_t *>pathname_, nullSeparator_)
        finally:
            PyMem_Free(pathname_)

    cpdef inline int include_pattern(self, object pattern) except? -30:
        return la.archive_match_include_pattern(self._archive_p,  <const char*>pattern)

    cpdef inline int include_pattern_w(self, str pattern) except? -30:
        cdef wchar_t * pattern_ = PyUnicode_AsWideCharString(pattern, NULL)
        try:
            return la.archive_match_include_pattern_w(self._archive_p, <const wchar_t *> pattern_)
        finally:
            PyMem_Free(pattern_)

    cpdef inline int include_pattern_from_file(self, object pathname, const uint8_t[::1] null_separator) except? -30:
        cdef int nullSeparator_ = <int> null_separator[0]
        return la.archive_match_include_pattern_from_file(self._archive_p, <const char *> pathname, nullSeparator_)

    cpdef inline int include_pattern_from_file_w(self, str pathname, const uint8_t[::1] null_separator) except? -30:
        cdef int nullSeparator_ = <int>null_separator[0]
        cdef wchar_t * pathname_ = PyUnicode_AsWideCharString(pathname, NULL)
        try:
            return la.archive_match_include_pattern_from_file_w(self._archive_p, <const wchar_t *>pathname_, nullSeparator_)
        finally:
            PyMem_Free(pathname_)

    cpdef inline int path_unmatched_inclusions(self) except? -30:
        cdef int ret
        with nogil:
            ret = la.archive_match_path_unmatched_inclusions(self._archive_p)
        return ret

    cpdef inline tuple path_unmatched_inclusions_next(self):
        cdef const char *p
        cdef int ret = la.archive_match_path_unmatched_inclusions_next(self._archive_p, &p)
        if ret == la.ARCHIVE_OK:
            return ret, PyBytes_FromString(p)
        else:  # EOF
            return ret, None

    cpdef inline tuple path_unmatched_inclusions_next_w(self):
        cdef const wchar_t *p
        cdef int ret = la.archive_match_path_unmatched_inclusions_next_w(self._archive_p, &p)
        if ret == la.ARCHIVE_OK:
            return ret, PyUnicode_FromWideChar(p, -1)
        else:  # EOF
            return ret, None

    cpdef inline int time_excluded(self, ArchiveEntry entry) except? -30:
        return la.archive_match_time_excluded(self._archive_p, entry._entry_p)

    cpdef inline int include_time(self, int flag, time_t sec, long nsec) except? -30:
        return la.archive_match_include_time(self._archive_p, flag, sec, nsec)

    cpdef inline int include_date(self, int flag, object datestr) except? -30:
        return la.archive_match_include_date(self._archive_p, flag, <const char*>datestr)

    cpdef inline int include_date_w(self, int flag, str datestr) except? -30:
        cdef wchar_t * datestr_ = PyUnicode_AsWideCharString(datestr, NULL)
        try:
            return la.archive_match_include_date_w(self._archive_p, flag, <const wchar_t *> datestr_)
        finally:
            PyMem_Free(datestr_)


    cpdef inline int include_file_time(self, int flag, object pathname) except? -30:
        return la.archive_match_include_file_time(self._archive_p, flag, <const char*>pathname)

    cpdef inline int include_file_time_w(self, int flag, str pathname) except? -30:
        cdef wchar_t * pathname_ = PyUnicode_AsWideCharString(pathname, NULL)
        try:
            return la.archive_match_include_file_time_w(self._archive_p, flag, <const wchar_t *> pathname_)
        finally:
            PyMem_Free(pathname_)

    cpdef inline int exclude_entry(self, int flag, ArchiveEntry entry) except? -30:
        return la.archive_match_exclude_entry(self._archive_p, flag, entry._entry_p)
    # ---
    cpdef inline int owner_excluded(self, ArchiveEntry entry) except? -30:
        return la.archive_match_owner_excluded(self._archive_p, entry._entry_p)

    cpdef inline int include_uid(self, la.la_int64_t uid) except? -30:
        return la.archive_match_include_uid(self._archive_p, uid)

    cpdef inline int include_gid(self, la.la_int64_t gid) except? -30:
        return la.archive_match_include_gid(self._archive_p, gid)

    cpdef inline int include_uname(self, object uname) except? -30:
        return la.archive_match_include_uname(self._archive_p, <const char*>uname)

    cpdef inline int include_uname_w(self, str uname) except? -30:
        cdef wchar_t * uname_ = PyUnicode_AsWideCharString(uname, NULL)
        try:
            return la.archive_match_include_uname_w(self._archive_p, <const wchar_t *> uname_)
        finally:
            PyMem_Free(uname_)

    cpdef inline int include_gname(self, object gname) except? -30:
        return la.archive_match_include_gname(self._archive_p, <const char *> gname)

    cpdef inline int include_gname_w(self, str gname) except? -30:
        cdef wchar_t * gname_ = PyUnicode_AsWideCharString(gname, NULL)
        try:
            return la.archive_match_include_gname_w(self._archive_p, <const wchar_t *> gname_)
        finally:
            PyMem_Free(gname_)

# todo should we wrap archive_utility_string_sort?



@cython.freelist(8)
@cython.final
cdef class ArchiveEntry:
    cdef:
        la.archive_entry* _entry_p
        readonly bint own  # 谁是主人

    def __cinit__(self, Archive archive = None, bint _init = True, bint _own = True): # todo should we keep a ref to Archive?
        if _init:
            if archive is None:
                self._entry_p = la.archive_entry_new2(NULL)
            else:
                self._entry_p = la.archive_entry_new2(archive._archive_p)
            if self._entry_p == NULL:
                raise MemoryError
        else:
            self._entry_p = NULL
        self.own = _own

    def __dealloc__(self):
        if self.own:
            if self._entry_p:
                la.archive_entry_free(self._entry_p)
            self._entry_p = NULL

    cpdef clear(self):
        la.archive_entry_clear(self._entry_p)

    cpdef inline ArchiveEntry clone(self):
        cdef la.archive_entry *ret = la.archive_entry_clone(self._entry_p)
        if ret == NULL:
            raise MemoryError
        return ArchiveEntry.from_ptr(ret, 1)

    @staticmethod
    cdef inline ArchiveEntry from_ptr(la.archive_entry* ptr, bint _own):
        cdef ArchiveEntry self = ArchiveEntry(_init=False, _own=_own)
        self._entry_p = ptr
        return self

    @property
    def atime(self):
        if la.archive_entry_atime_is_set(self._entry_p):
            return la.archive_entry_atime(self._entry_p)

    @property
    def atime_nsec(self):
        if la.archive_entry_atime_is_set(self._entry_p):
            return la.archive_entry_atime_nsec(self._entry_p)

    @property
    def atime_is_set(self):
        return <bint>la.archive_entry_atime_is_set(self._entry_p)

    @property
    def birthtime(self):
        if la.archive_entry_birthtime_is_set(self._entry_p):
            return la.archive_entry_birthtime(self._entry_p)

    @property
    def birthtime_nsec(self):
        if la.archive_entry_birthtime_is_set(self._entry_p):
            return la.archive_entry_birthtime_nsec(self._entry_p)

    @property
    def birthtime_is_set(self):
        return <bint> la.archive_entry_birthtime_is_set(self._entry_p)

    @property
    def ctime(self):
        if la.archive_entry_ctime_is_set(self._entry_p):
            return la.archive_entry_ctime(self._entry_p)

    @property
    def ctime_nsec(self):
        if la.archive_entry_ctime_is_set(self._entry_p):
            return la.archive_entry_ctime_nsec(self._entry_p)

    @property
    def ctime_is_set(self):
        return <bint> la.archive_entry_ctime_is_set(self._entry_p)


    @property
    def dev(self):
        if la.archive_entry_dev_is_set(self._entry_p):
            return la.archive_entry_dev(self._entry_p)

    @property
    def dev_is_set(self):
        return <bint> la.archive_entry_dev_is_set(self._entry_p)

    @property
    def devmajor(self):
        return la.archive_entry_devmajor(self._entry_p)

    @property
    def devminor(self):
        return la.archive_entry_devminor(self._entry_p)

    @property
    def filetype(self):
        return la.archive_entry_filetype(self._entry_p)

    @property
    def fflags(self):
        cdef unsigned long set_, clear_
        la.archive_entry_fflags(self._entry_p, &set_, &clear_)
        return set_, clear_

    @property
    def fflags_text(self):
        cdef const char* ret = la.archive_entry_fflags_text(self._entry_p)
        if ret != NULL:
            return ret

    @property
    def gid(self):
        return la.archive_entry_gid(self._entry_p)

    @property
    def gname(self):
        cdef const char* ret = la.archive_entry_gname(self._entry_p)
        if ret != NULL:
            return ret

    @property
    def gname_utf8(self):
        cdef const char* ret = la.archive_entry_gname_utf8(self._entry_p)
        if ret != NULL:
            return PyUnicode_FromString(ret)

    @property
    def gname_w(self):
        cdef const wchar_t *ret = la.archive_entry_gname_w(self._entry_p)
        if ret != NULL:
            return PyUnicode_FromWideChar(ret, -1)

    @property
    def hardlink(self):
        cdef const char * ret = la.archive_entry_hardlink(self._entry_p)
        if ret != NULL:
            return ret

    @property
    def hardlink_utf8(self):
        cdef const char * ret = la.archive_entry_hardlink_utf8(self._entry_p)
        if ret != NULL:
            return PyUnicode_FromString(ret)

    @property
    def hardlink_w(self):
        cdef const wchar_t *ret = la.archive_entry_hardlink_w(self._entry_p)
        if ret != NULL:
            return PyUnicode_FromWideChar(ret, -1)

    @property
    def ino(self):
        if la.archive_entry_ino_is_set(self._entry_p):
            return la.archive_entry_ino(self._entry_p)

    @property
    def ino64(self):
        if la.archive_entry_ino_is_set(self._entry_p):
            return la.archive_entry_ino64(self._entry_p)

    @property
    def ino_is_set(self):
        return <bint>la.archive_entry_ino_is_set(self._entry_p)

    @property
    def mode(self):
        return la.archive_entry_mode(self._entry_p)

    @property
    def mtime(self):
        if la.archive_entry_mtime_is_set(self._entry_p):
            return la.archive_entry_mtime(self._entry_p)

    @property
    def mtime_nsec(self):
        if la.archive_entry_mtime_is_set(self._entry_p):
            return la.archive_entry_mtime_nsec(self._entry_p)

    @property
    def mtime_is_set(self):
        return <bint> la.archive_entry_mtime_is_set(self._entry_p)

    @property
    def nlink(self):
        return la.archive_entry_nlink(self._entry_p)

    @property
    def pathname(self):
        cdef const char * ret = la.archive_entry_pathname(self._entry_p)
        if ret != NULL:
            return ret

    @property
    def pathname_utf8(self):
        cdef const char * ret = la.archive_entry_pathname_utf8(self._entry_p)
        if ret != NULL:
            return PyUnicode_FromString(ret)

    @property
    def pathname_w(self):
        cdef const wchar_t *ret = la.archive_entry_pathname_w(self._entry_p)
        if ret != NULL:
            return PyUnicode_FromWideChar(ret, -1)

    @property
    def perm(self):
        return la.archive_entry_perm(self._entry_p)

    @property
    def rdev(self):
        return la.archive_entry_rdev(self._entry_p)

    @property
    def rdevmajor(self):
        return la.archive_entry_rdevmajor(self._entry_p)

    @property
    def rdevminor(self):
        return la.archive_entry_rdevminor(self._entry_p)

    @property
    def sourcepath(self):
        cdef const char * ret = la.archive_entry_sourcepath(self._entry_p)
        if ret != NULL:
            return ret

    @property
    def sourcepath_w(self):
        cdef const wchar_t * ret = la.archive_entry_sourcepath_w(self._entry_p)
        if ret != NULL:
            return PyUnicode_FromWideChar(ret, -1)

    @property
    def size(self):
        if la.archive_entry_size_is_set(self._entry_p):
            return la.archive_entry_size(self._entry_p)

    @property
    def size_is_set(self):
        return <bint>la.archive_entry_size_is_set(self._entry_p)

    @property
    def strmode(self):
        cdef const char * ret = la.archive_entry_strmode(self._entry_p)
        if ret != NULL:
            return ret

    @property
    def symlink(self):
        cdef const char * ret = la.archive_entry_symlink(self._entry_p)
        if ret != NULL:
            return ret

    @property
    def symlink_utf8(self):
        cdef const char * ret = la.archive_entry_symlink_utf8(self._entry_p)
        if ret != NULL:
            return PyUnicode_FromString(ret)

    @property
    def symlink_type(self):
        return la.archive_entry_symlink_type(self._entry_p)

    @property
    def symlink_w(self):
        cdef const wchar_t* ret = la.archive_entry_symlink_w(self._entry_p)
        if ret != NULL:
            return PyUnicode_FromWideChar(ret, -1)

    @property
    def uid(self):
        return la.archive_entry_uid(self._entry_p)

    @property
    def uname(self):
        cdef const char * ret = la.archive_entry_uname(self._entry_p)
        if ret != NULL:
            return ret

    @property
    def uname_utf8(self):
        cdef const char * ret = la.archive_entry_uname_utf8(self._entry_p)
        if ret != NULL:
            return PyUnicode_FromString(ret)

    @property
    def uname_w(self):
        cdef const wchar_t *ret = la.archive_entry_uname_w(self._entry_p)
        if ret != NULL:
            return PyUnicode_FromWideChar(ret, -1)

    @property
    def is_data_encrypted(self):
        return <bint>la.archive_entry_is_data_encrypted(self._entry_p)

    @property
    def is_metadata_encrypted(self):
        return <bint>la.archive_entry_is_metadata_encrypted(self._entry_p)

    @property
    def is_encrypted(self):
        return <bint>la.archive_entry_is_encrypted(self._entry_p)

    # Set fields in an archive_entry.
    cpdef set_atime(self, time_t t, long ns):
        la.archive_entry_set_atime(self._entry_p, t, ns)

    cpdef unset_atime(self, time_t t, long ns):
        la.archive_entry_unset_atime(self._entry_p)

    cpdef set_birthtime(self, time_t t, long ns):
        la.archive_entry_set_birthtime(self._entry_p, t, ns)

    cpdef unset_birthtime(self, time_t t, long ns):
        la.archive_entry_unset_birthtime(self._entry_p)

    cpdef set_ctime(self, time_t t, long ns):
        la.archive_entry_set_ctime(self._entry_p, t, ns)

    cpdef unset_ctime(self, time_t t, long ns):
        la.archive_entry_unset_ctime(self._entry_p)

    @dev.setter
    def dev(self, dev_t d):
        la.archive_entry_set_dev(self._entry_p, d)

    @devmajor.setter
    def devmajor(self, dev_t d):
        la.archive_entry_set_devmajor(self._entry_p, d)

    @devminor.setter
    def devminor(self, dev_t d):
        la.archive_entry_set_devminor(self._entry_p, d)

    @filetype.setter
    def filetype(self, unsigned int type_):
        la.archive_entry_set_filetype(self._entry_p, type_)

    @fflags.setter
    def fflags(self, tuple v):
        cdef unsigned long set_, clear_
        set_ = v[0]
        clear_ = v[1]
        la.archive_entry_set_fflags(self._entry_p, set_, clear_)

    cpdef inline bytes copy_fflags_text(self, object flags):
        cdef const char * ret = la.archive_entry_copy_fflags_text(self._entry_p, <const char *>flags)
        if ret != NULL:
            return ret

    cpdef inline str copy_fflags_text_w(self, str flags):
        cdef wchar_t * flags_ = PyUnicode_AsWideCharString(flags, NULL)
        cdef const wchar_t * ret
        try:
            ret = la.archive_entry_copy_fflags_text_w(self._entry_p, <const wchar_t *> flags_)
            if ret != NULL:
                return PyUnicode_FromWideChar(ret, -1)
        finally:
            PyMem_Free(flags_)

    @gid.setter
    def gid(self, la.la_int64_t gid):
        la.archive_entry_set_gid(self._entry_p, gid)

    @gname.setter
    def gname(self, object gname):
        la.archive_entry_set_gname(self._entry_p, <const char *>gname)

    @gname_utf8.setter
    def gname_utf8(self, str gname):
        la.archive_entry_set_gname_utf8(self._entry_p, PyUnicode_AsUTF8(gname))

    @gname_w.setter
    def gname_w(self, str gname):
        cdef wchar_t *gname_ = PyUnicode_AsWideCharString(gname, NULL)
        try:
            la.archive_entry_copy_gname_w(self._entry_p, gname_)
        finally:
            PyMem_Free(gname_)

    cpdef inline int update_gname_utf8(self, str gname) except? -30:
        return la.archive_entry_update_gname_utf8(self._entry_p, PyUnicode_AsUTF8(gname))

    @hardlink.setter
    def hardlink(self, object target):
        la.archive_entry_set_hardlink(self._entry_p, <const char*>target)

    @hardlink_utf8.setter
    def hardlink_utf8(self, str target):
        la.archive_entry_set_hardlink_utf8(self._entry_p, PyUnicode_AsUTF8(target))

    @hardlink_w.setter
    def hardlink_w(self, str target):
        cdef wchar_t *target_ = PyUnicode_AsWideCharString(target, NULL)
        try:
            la.archive_entry_copy_hardlink_w(self._entry_p, <const wchar_t *>target_)
        finally:
            PyMem_Free(target_)

    cpdef inline int update_hardlink_utf8(self, str target) except? -30:
        return la.archive_entry_update_hardlink_utf8(self._entry_p, PyUnicode_AsUTF8(target))

    @ino.setter
    def ino(self, la.la_int64_t ino):
        la.archive_entry_set_ino(self._entry_p, ino)

    @ino64.setter
    def ino64(self, la.la_int64_t ino):
        la.archive_entry_set_ino64(self._entry_p, ino)

    cpdef set_link(self, object target):
        la.archive_entry_set_link(self._entry_p, <const char *>target)

    cpdef set_link_utf8(self, object target):
        la.archive_entry_set_link_utf8(self._entry_p, PyUnicode_AsUTF8(target))

    cpdef set_link_w(self, str target):
        cdef wchar_t *target_ = PyUnicode_AsWideCharString(target, NULL)
        try:
            la.archive_entry_copy_link_w(self._entry_p, <const wchar_t *>target_)
        finally:
            PyMem_Free(target_)

    cpdef inline int update_link_utf8(self, str target) except? -30:
        return la.archive_entry_update_link_utf8(self._entry_p, PyUnicode_AsUTF8(target))

    @mode.setter
    def mode(self, la.__LA_MODE_T m):
        la.archive_entry_set_mode(self._entry_p, m)


    @mtime.setter
    def mtime(self, tuple v):
        cdef:
            time_t t = v[0]
            long ns = v[1]
        la.archive_entry_set_mtime(self._entry_p, t, ns)

    @mtime.deleter
    def mtime(self):
        la.archive_entry_unset_mtime(self._entry_p)

    @nlink.setter
    def nlink(self, unsigned int nlink):
        la.archive_entry_set_nlink(self._entry_p, nlink)

    @pathname.setter
    def pathname(self, object name):
        la.archive_entry_set_pathname(self._entry_p, <const char *>name)


    @pathname_utf8.setter
    def pathname_utf8(self, str name):
        la.archive_entry_set_pathname_utf8(self._entry_p,  PyUnicode_AsUTF8(name))

    @pathname_w.setter
    def pathname_w(self, str name):
        cdef wchar_t *name_ = PyUnicode_AsWideCharString(name, NULL)
        try:
            la.archive_entry_copy_pathname_w(self._entry_p, <const wchar_t *>name_)
        finally:
            PyMem_Free(name_)

    cpdef inline int update_pathname_utf8(self, str name) except? -30:
        return la.archive_entry_update_pathname_utf8(self._entry_p, PyUnicode_AsUTF8(name))

    @perm.setter
    def perm(self, la.__LA_MODE_T p):
        la.archive_entry_set_perm(self._entry_p, p)

    @rdev.setter
    def rdev(self, dev_t m):
        la.archive_entry_set_rdev(self._entry_p, m)


    @rdevmajor.setter
    def rdevmajor(self, dev_t m):
        la.archive_entry_set_rdevmajor(self._entry_p, m)

    @rdevminor.setter
    def rdevminor(self, dev_t m):
        la.archive_entry_set_rdevminor(self._entry_p, m)

    @size.setter
    def size(self, la.la_int64_t size):
        la.archive_entry_set_size(self._entry_p, size)

    @size.deleter
    def size(self):
        la.archive_entry_unset_size(self._entry_p)

    @sourcepath.setter
    def sourcepath(self, object path):
        la.archive_entry_copy_sourcepath(self._entry_p, <const char *>path)

    @sourcepath_w.setter
    def sourcepath_w(self, str path):
        cdef wchar_t *path_ = PyUnicode_AsWideCharString(path, NULL)
        try:
            la.archive_entry_copy_sourcepath_w(self._entry_p, <const wchar_t *>path_)
        finally:
            PyMem_Free(path_)

    @symlink.setter
    def symlink(self, object linkname):
        la.archive_entry_set_symlink(self._entry_p, <const char *>linkname)

    @symlink_type.setter
    def symlink_type(self, int type_):
        la.archive_entry_set_symlink_type(self._entry_p, type_)

    @symlink_utf8.setter
    def symlink_utf8(self, str linkname):
        la.archive_entry_set_symlink_utf8(self._entry_p, PyUnicode_AsUTF8(linkname))

    @symlink_w.setter
    def symlink_w(self, str linkname):
        cdef wchar_t *linkname_ = PyUnicode_AsWideCharString(linkname, NULL)
        try:
            la.archive_entry_copy_symlink_w(self._entry_p, <const wchar_t*>linkname_)
        finally:
            PyMem_Free(linkname_)

    cpdef inline int update_symlink_utf8(self, object linkname) except? -30:
        la.archive_entry_update_symlink_utf8(self._entry_p, <const char *>linkname)

    @uid.setter
    def uid(self, la.la_int64_t uid):
        la.archive_entry_set_uid(self._entry_p, uid)

    @uname.setter
    def uname(self, object name):
        la.archive_entry_set_uname(self._entry_p, <const char *>name)

    @uname_utf8.setter
    def uname_utf8(self, str name):
        la.archive_entry_set_uname_utf8(self._entry_p, PyUnicode_AsUTF8(name))

    @uname_w.setter
    def uname_w(self, str name):
        cdef wchar_t *name_ = PyUnicode_AsWideCharString(name, NULL)
        try:
            la.archive_entry_copy_uname_w(self._entry_p, <const wchar_t *>name_)
        finally:
            PyMem_Free(name_)

    cpdef inline int update_uname_utf8(self, str name) except? -30:
        return la.archive_entry_update_uname_utf8(self._entry_p, PyUnicode_AsUTF8(name))


    @is_data_encrypted.setter
    def is_data_encrypted(self, bint is_encrypted):
        la.archive_entry_set_is_data_encrypted(self._entry_p, <char>is_encrypted)

    @is_metadata_encrypted.setter
    def is_metadata_encrypted(self, bint is_encrypted):
        la.archive_entry_set_is_metadata_encrypted(self._entry_p, <char>is_encrypted)

    @property
    def stat(self):
        cdef const la.stat * ret = la.archive_entry_stat(self._entry_p)
        return os.stat_result((ret.st_mode,
                                ret.st_ino,
                                ret.st_dev,
                                ret.st_nlink,
                                ret.st_uid,
                                ret.st_gid,
                                ret.st_size,
                                ret.st_atime,
                                ret.st_mtime,
                                ret.st_ctime))

    @stat.setter
    def stat(self, object stat):
        cdef la.stat st
        st.st_dev = stat.st_dev
        st.st_ino = stat.st_ino
        st.st_mode = stat.st_mode
        st.st_nlink = stat.st_nlink
        st.st_uid = stat.st_uid
        st.st_gid = stat.st_gid
        # st.st_rdev = stat.st_rdev
        st.st_size = stat.st_size
        st.st_atime = stat.st_atime
        st.st_mtime = stat.st_mtime
        st.st_ctime = stat.st_ctime
        la.archive_entry_copy_stat(self._entry_p, &st)
    # cpdef long long offset1(self):
    #     return <long long><void*>self
    #
    # cpdef long long offset2(self):
    #     return <long long> <void *> &self._entry_p
    @property
    def mac_metadata(self):
        cdef size_t s
        cdef const char * ret = <const char *>la.archive_entry_mac_metadata(self._entry_p, &s)
        return PyBytes_FromStringAndSize(ret, <Py_ssize_t>s)

    @mac_metadata.setter
    def mac_metadata(self, bytes metadata not None):
        la.archive_entry_copy_mac_metadata(self._entry_p, <const void *>PyBytes_AS_STRING(metadata), <size_t>PyBytes_GET_SIZE(metadata))

    @mac_metadata.deleter
    def mac_metadata(self):
        la.archive_entry_copy_mac_metadata(self._entry_p, NULL, 0)

    cpdef bytes digest(self, int type_):
        cdef const unsigned char * ret = la.archive_entry_digest(self._entry_p, type_)
        if ret != NULL:
            return <bytes>ret

    # todo: check if there exist more deleter
    cpdef acl_clear(self):
        la.archive_entry_acl_clear(self._entry_p)

    cpdef inline int acl_add_entry(self, int type_, int permset, int tag, int id_, object name) except? -30:
        return la.archive_entry_acl_add_entry(self._entry_p, type_, permset,  tag, id_, <const char*>name)

    cpdef inline int acl_add_entry_w(self, int type_, int permset, int tag, int id_, str name) except? -30:
        cdef wchar_t *name_ = PyUnicode_AsWideCharString(name, NULL)
        try:
            return la.archive_entry_acl_add_entry_w(self._entry_p, type_, permset, tag, id_, <const wchar_t *> name_)
        finally:
            PyMem_Free(name_)

    cpdef inline int acl_reset(self, int want_type) except? -30:
        return la.archive_entry_acl_reset(self._entry_p, want_type)

    cpdef inline tuple acl_next(self, int want_type):
        cdef:
            int type_
            int permset
            int tag
            int qual
            const char *name
            int ret
        ret = la.archive_entry_acl_next(self._entry_p, want_type, &type_, &permset, &tag, &qual, &name)
        if ret != la.ARCHIVE_OK:
            raise ArchiveError(self.error_string(), self.get_errno(), ret, self)
        return ret, type_, permset, tag, qual, PyBytes_FromString(name)

    cpdef inline str acl_to_text_w(self, int flags):
        cdef la.la_ssize_t length
        cdef wchar_t * ret = la.archive_entry_acl_to_text_w(self._entry_p, &length, flags)
        if ret != NULL:
            return PyUnicode_FromWideChar(ret, <Py_ssize_t>length)

    cpdef inline bytes acl_to_text(self, int flags):
        cdef la.la_ssize_t length
        cdef char* ret = la.archive_entry_acl_to_text(self._entry_p, &length, flags)
        if ret != NULL:
            return PyBytes_FromStringAndSize(ret, <Py_ssize_t>length)

    cpdef inline int acl_from_text_w(self, str text, int type_) except? -30:
        cdef wchar_t *text_ = PyUnicode_AsWideCharString(text, NULL)
        try:
            return la.archive_entry_acl_from_text_w(self._entry_p, text_, type_)
        finally:
            PyMem_Free(text_)

    cpdef inline int acl_from_text(self, object text, int type_) except? -30:
        return la.archive_entry_acl_from_text(self._entry_p, <const char*>text, type_)


    cpdef inline int acl_types(self) except? -30:
        return la.archive_entry_acl_types(self._entry_p)

    cpdef inline int acl_count(self, int want_type) except? -30:
        return la.archive_entry_acl_count(self._entry_p, want_type)

    cpdef xattr_clear(self):
        la.archive_entry_xattr_clear(self._entry_p)

    cpdef xattr_add_entry(self, object name, const uint8_t[::1] value):
        la.archive_entry_xattr_add_entry(self._entry_p, <const char*>name, <const void*>&value[0], <size_t>value.shape[0])

    cpdef inline int xattr_count(self) except? -30:
        return la.archive_entry_xattr_count(self._entry_p)

    cpdef inline int xattr_reset(self) except? -30:
        return la.archive_entry_xattr_reset(self._entry_p)

    cpdef inline tuple xattr_next(self):
        cdef:
            const char* name
            const void *value
            size_t size
            int ret
        ret = la.archive_entry_xattr_next(self._entry_p, &name, &value, &size)
        if ret != la.ARCHIVE_OK:
            raise ArchiveError(self.error_string(), self.get_errno(), ret, self)
        return ret, PyBytes_FromString(name), PyBytes_FromStringAndSize(<char*>value, <Py_ssize_t>size)

    cpdef sparse_clear(self):
        la.archive_entry_sparse_clear(self._entry_p)

    cpdef sparse_add_entry(self, la.la_int64_t offset, la.la_int64_t length):
        la.archive_entry_sparse_add_entry(self._entry_p, offset, length)

    cpdef inline int sparse_count(self) except? -30:
        return la.archive_entry_sparse_count(self._entry_p)

    cpdef inline int sparse_reset(self) except? -30:
        return la.archive_entry_sparse_reset(self._entry_p)

    cpdef inline tuple sparse_next(self):
        cdef la.la_int64_t offset, length
        cdef int ret = la.archive_entry_sparse_next(self._entry_p, &offset, &length)
        if ret != la.ARCHIVE_OK:
            raise ArchiveError(self.error_string(), self.get_errno(), ret, self)
        return ret, offset, length



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
        with nogil:
            la.archive_entry_linkify(self._resolver, &a._entry_p, &b._entry_p)

    cpdef inline tuple partial_links(self):
        cdef:
            unsigned int links
            la.archive_entry * ret
        with nogil:
            ret = la.archive_entry_partial_links(self._resolver, &links)
        return  ArchiveEntry.from_ptr(ret, 0), links

cpdef inline int copy_data_to_disk(ArchiveRead ar, ArchiveWriteDisk aw) except? -30:
    cdef:
        const void* buff
        size_t size
        la.la_int64_t offset
        int ret
    with nogil:
        ret = la.archive_read_data_block(ar._archive_p, &buff, &size, &offset)
        if ret == la.ARCHIVE_EOF:
            return la.ARCHIVE_OK
        if ret < la.ARCHIVE_OK:
            with gil:
                raise ArchiveError(ar.error_string(), ar.get_errno(), ret, ar)
        ret = <int>la.archive_write_data_block(aw._archive_p, buff, size, offset)
        if ret < la.ARCHIVE_OK:
            with gil:
                raise ArchiveError(aw.error_string(), aw.get_errno(), ret, aw)

