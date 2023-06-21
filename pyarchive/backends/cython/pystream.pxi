from cpython.object cimport PyObject
from cpython.bytes cimport PyBytes_GET_SIZE, PyBytes_AS_STRING, PyBytes_FromStringAndSize
from cpython.mem cimport PyMem_Realloc, PyMem_Free

from libc.string cimport memcpy

from pyarchive.backends.cython cimport archive as la


cdef struct PyStreamData:
    PyObject * file # file like
    la.la_ssize_t block_size # 一次读取多少字节
    void * buffer  # todo PyMem_Free this
    la.la_ssize_t length
    int close # 是否在close callback的时候关闭

cdef int pystream_open_callback(la.archive *a, void *_client_data) with gil:
    return la.ARCHIVE_OK

cdef la.la_ssize_t  pystream_read_callback(la.archive *a, void *_client_data, const void ** _buffer) with gil:
    cdef PyStreamData* data = <PyStreamData*> _client_data
    cdef object file = <object>data.file
    cdef size_t block_size = data.block_size
    cdef bytes block = file.read(block_size)
    cdef la.la_ssize_t outlen = <la.la_ssize_t>PyBytes_GET_SIZE(block)

    cdef void* temp = NULL
    if outlen > data.length: # 缓冲区不够了
        temp = PyMem_Realloc(data.buffer, <size_t >outlen)
        if temp == NULL:
            raise MemoryError
        data.buffer = temp
        data.length = outlen
    memcpy(data.buffer, PyBytes_AS_STRING(block), <size_t> outlen)
    _buffer[0] = data.buffer
    return outlen


cdef la.la_int64_t  pystream_skip_callback(la.archive *a, void *_client_data, la.la_int64_t request) with gil:
    cdef PyStreamData* data = <PyStreamData*> _client_data
    cdef object file = <object>data.file
    if not file.seekable():
        return 0
    cdef la.la_int64_t  oldpos = <la.la_int64_t >file.tell()
    cdef la.la_int64_t  newpos = <la.la_int64_t >file.seek(request, 1)
    return newpos - oldpos

cdef la.la_int64_t  pystream_seek_callback(la.archive *a, void *_client_data, la.la_int64_t offset, int whence) with gil:
    cdef PyStreamData* data = <PyStreamData*> _client_data
    cdef object file = <object>data.file
    if not file.seekable():
        return la.ARCHIVE_FATAL
    cdef la.la_int64_t  newpos = <la.la_int64_t>file.seek(offset, whence)
    return newpos

cdef int pystream_switch_callback(la.archive *a, void *_client_data1,  void *_client_data2) with gil:
    pystream_close_callback(a, _client_data1)
    return pystream_open_callback(a, _client_data2)


cdef int pystream_close_callback(la.archive *a, void *_client_data) with gil:
    cdef PyStreamData * data = <PyStreamData *> _client_data
    cdef object file = <object> data.file
    PyMem_Free(data.buffer)
    PyMem_Free(data)
    if data.close:
        file.close()
    return la.ARCHIVE_OK

cdef la.la_ssize_t pystream_write_callback(la.archive *a, void *_client_data, const void *_buffer, size_t _length) with gil:
    cdef PyStreamData * data = <PyStreamData *> _client_data
    cdef object file = <object> data.file
    cdef bytes writedata = PyBytes_FromStringAndSize(<char *>_buffer, <Py_ssize_t>_length)
    return file.write(writedata)