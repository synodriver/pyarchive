## Public apis
```python
from typing import Iterable

AE_IFBLK: int
AE_IFCHR: int
AE_IFDIR: int
AE_IFIFO: int
AE_IFLNK: int
AE_IFMT: int
AE_IFREG: int
AE_IFSOCK: int
AE_SYMLINK_TYPE_DIRECTORY: int
AE_SYMLINK_TYPE_FILE: int
AE_SYMLINK_TYPE_UNDEFINED: int
ARCHIVE_COMPRESSION_BZIP2: int
ARCHIVE_COMPRESSION_COMPRESS: int
ARCHIVE_COMPRESSION_GZIP: int
ARCHIVE_COMPRESSION_LRZIP: int
ARCHIVE_COMPRESSION_LZIP: int
ARCHIVE_COMPRESSION_LZMA: int
ARCHIVE_COMPRESSION_NONE: int
ARCHIVE_COMPRESSION_PROGRAM: int
ARCHIVE_COMPRESSION_RPM: int
ARCHIVE_COMPRESSION_UU: int
ARCHIVE_COMPRESSION_XZ: int
ARCHIVE_ENTRY_ACL_ADD_FILE: int
ARCHIVE_ENTRY_ACL_ADD_SUBDIRECTORY: int
ARCHIVE_ENTRY_ACL_APPEND_DATA: int
ARCHIVE_ENTRY_ACL_DELETE: int
ARCHIVE_ENTRY_ACL_DELETE_CHILD: int
ARCHIVE_ENTRY_ACL_ENTRY_DIRECTORY_INHERIT: int
ARCHIVE_ENTRY_ACL_ENTRY_FAILED_ACCESS: int
ARCHIVE_ENTRY_ACL_ENTRY_FILE_INHERIT: int
ARCHIVE_ENTRY_ACL_ENTRY_INHERITED: int
ARCHIVE_ENTRY_ACL_ENTRY_INHERIT_ONLY: int
ARCHIVE_ENTRY_ACL_ENTRY_NO_PROPAGATE_INHERIT: int
ARCHIVE_ENTRY_ACL_ENTRY_SUCCESSFUL_ACCESS: int
ARCHIVE_ENTRY_ACL_EVERYONE: int
ARCHIVE_ENTRY_ACL_EXECUTE: int
ARCHIVE_ENTRY_ACL_GROUP: int
ARCHIVE_ENTRY_ACL_GROUP_OBJ: int
ARCHIVE_ENTRY_ACL_INHERITANCE_NFS4: int
ARCHIVE_ENTRY_ACL_LIST_DIRECTORY: int
ARCHIVE_ENTRY_ACL_MASK: int
ARCHIVE_ENTRY_ACL_OTHER: int
ARCHIVE_ENTRY_ACL_PERMS_NFS4: int
ARCHIVE_ENTRY_ACL_PERMS_POSIX1E: int
ARCHIVE_ENTRY_ACL_READ: int
ARCHIVE_ENTRY_ACL_READ_ACL: int
ARCHIVE_ENTRY_ACL_READ_ATTRIBUTES: int
ARCHIVE_ENTRY_ACL_READ_DATA: int
ARCHIVE_ENTRY_ACL_READ_NAMED_ATTRS: int
ARCHIVE_ENTRY_ACL_STYLE_COMPACT: int
ARCHIVE_ENTRY_ACL_STYLE_EXTRA_ID: int
ARCHIVE_ENTRY_ACL_STYLE_MARK_DEFAULT: int
ARCHIVE_ENTRY_ACL_STYLE_SEPARATOR_COMMA: int
ARCHIVE_ENTRY_ACL_STYLE_SOLARIS: int
ARCHIVE_ENTRY_ACL_SYNCHRONIZE: int
ARCHIVE_ENTRY_ACL_TYPE_ACCESS: int
ARCHIVE_ENTRY_ACL_TYPE_ALARM: int
ARCHIVE_ENTRY_ACL_TYPE_ALLOW: int
ARCHIVE_ENTRY_ACL_TYPE_AUDIT: int
ARCHIVE_ENTRY_ACL_TYPE_DEFAULT: int
ARCHIVE_ENTRY_ACL_TYPE_DENY: int
ARCHIVE_ENTRY_ACL_TYPE_NFS4: int
ARCHIVE_ENTRY_ACL_TYPE_POSIX1E: int
ARCHIVE_ENTRY_ACL_USER: int
ARCHIVE_ENTRY_ACL_USER_OBJ: int
ARCHIVE_ENTRY_ACL_WRITE: int
ARCHIVE_ENTRY_ACL_WRITE_ACL: int
ARCHIVE_ENTRY_ACL_WRITE_ATTRIBUTES: int
ARCHIVE_ENTRY_ACL_WRITE_DATA: int
ARCHIVE_ENTRY_ACL_WRITE_NAMED_ATTRS: int
ARCHIVE_ENTRY_ACL_WRITE_OWNER: int
ARCHIVE_ENTRY_DIGEST_MD5: int
ARCHIVE_ENTRY_DIGEST_RMD160: int
ARCHIVE_ENTRY_DIGEST_SHA1: int
ARCHIVE_ENTRY_DIGEST_SHA256: int
ARCHIVE_ENTRY_DIGEST_SHA384: int
ARCHIVE_ENTRY_DIGEST_SHA512: int
ARCHIVE_EOF: int
ARCHIVE_EXTRACT_ACL: int
ARCHIVE_EXTRACT_CLEAR_NOCHANGE_FFLAGS: int
ARCHIVE_EXTRACT_FFLAGS: int
ARCHIVE_EXTRACT_HFS_COMPRESSION_FORCED: int
ARCHIVE_EXTRACT_MAC_METADATA: int
ARCHIVE_EXTRACT_NO_AUTODIR: int
ARCHIVE_EXTRACT_NO_HFS_COMPRESSION: int
ARCHIVE_EXTRACT_NO_OVERWRITE: int
ARCHIVE_EXTRACT_NO_OVERWRITE_NEWER: int
ARCHIVE_EXTRACT_OWNER: int
ARCHIVE_EXTRACT_PERM: int
ARCHIVE_EXTRACT_SAFE_WRITES: int
ARCHIVE_EXTRACT_SECURE_NOABSOLUTEPATHS: int
ARCHIVE_EXTRACT_SECURE_NODOTDOT: int
ARCHIVE_EXTRACT_SECURE_SYMLINKS: int
ARCHIVE_EXTRACT_SPARSE: int
ARCHIVE_EXTRACT_TIME: int
ARCHIVE_EXTRACT_UNLINK: int
ARCHIVE_EXTRACT_XATTR: int
ARCHIVE_FAILED: int
ARCHIVE_FATAL: int
ARCHIVE_FILTER_BZIP2: int
ARCHIVE_FILTER_COMPRESS: int
ARCHIVE_FILTER_GRZIP: int
ARCHIVE_FILTER_GZIP: int
ARCHIVE_FILTER_LRZIP: int
ARCHIVE_FILTER_LZ4: int
ARCHIVE_FILTER_LZIP: int
ARCHIVE_FILTER_LZMA: int
ARCHIVE_FILTER_LZOP: int
ARCHIVE_FILTER_NONE: int
ARCHIVE_FILTER_PROGRAM: int
ARCHIVE_FILTER_RPM: int
ARCHIVE_FILTER_UU: int
ARCHIVE_FILTER_XZ: int
ARCHIVE_FILTER_ZSTD: int
ARCHIVE_FORMAT_7ZIP: int
ARCHIVE_FORMAT_AR: int
ARCHIVE_FORMAT_AR_BSD: int
ARCHIVE_FORMAT_AR_GNU: int
ARCHIVE_FORMAT_BASE_MASK: int
ARCHIVE_FORMAT_CAB: int
ARCHIVE_FORMAT_CPIO: int
ARCHIVE_FORMAT_CPIO_AFIO_LARGE: int
ARCHIVE_FORMAT_CPIO_BIN_BE: int
ARCHIVE_FORMAT_CPIO_BIN_LE: int
ARCHIVE_FORMAT_CPIO_POSIX: int
ARCHIVE_FORMAT_CPIO_PWB: int
ARCHIVE_FORMAT_CPIO_SVR4_CRC: int
ARCHIVE_FORMAT_CPIO_SVR4_NOCRC: int
ARCHIVE_FORMAT_EMPTY: int
ARCHIVE_FORMAT_ISO9660: int
ARCHIVE_FORMAT_ISO9660_ROCKRIDGE: int
ARCHIVE_FORMAT_LHA: int
ARCHIVE_FORMAT_MTREE: int
ARCHIVE_FORMAT_RAR: int
ARCHIVE_FORMAT_RAR_V5: int
ARCHIVE_FORMAT_RAW: int
ARCHIVE_FORMAT_SHAR: int
ARCHIVE_FORMAT_SHAR_BASE: int
ARCHIVE_FORMAT_SHAR_DUMP: int
ARCHIVE_FORMAT_TAR: int
ARCHIVE_FORMAT_TAR_GNUTAR: int
ARCHIVE_FORMAT_TAR_PAX_INTERCHANGE: int
ARCHIVE_FORMAT_TAR_PAX_RESTRICTED: int
ARCHIVE_FORMAT_TAR_USTAR: int
ARCHIVE_FORMAT_WARC: int
ARCHIVE_FORMAT_XAR: int
ARCHIVE_FORMAT_ZIP: int
ARCHIVE_MATCH_CTIME: int
ARCHIVE_MATCH_EQUAL: int
ARCHIVE_MATCH_MTIME: int
ARCHIVE_MATCH_NEWER: int
ARCHIVE_MATCH_OLDER: int
ARCHIVE_OK: int
ARCHIVE_READDISK_HONOR_NODUMP: int
ARCHIVE_READDISK_MAC_COPYFILE: int
ARCHIVE_READDISK_NO_ACL: int
ARCHIVE_READDISK_NO_FFLAGS: int
ARCHIVE_READDISK_NO_SPARSE: int
ARCHIVE_READDISK_NO_TRAVERSE_MOUNTS: int
ARCHIVE_READDISK_NO_XATTR: int
ARCHIVE_READDISK_RESTORE_ATIME: int
ARCHIVE_READ_FORMAT_CAPS_ENCRYPT_DATA: int
ARCHIVE_READ_FORMAT_CAPS_ENCRYPT_METADATA: int
ARCHIVE_READ_FORMAT_CAPS_NONE: int
ARCHIVE_READ_FORMAT_ENCRYPTION_DONT_KNOW: int
ARCHIVE_READ_FORMAT_ENCRYPTION_UNSUPPORTED: int
ARCHIVE_RETRY: int
ARCHIVE_WARN: int
OLD_ARCHIVE_ENTRY_ACL_STYLE_EXTRA_ID: int
OLD_ARCHIVE_ENTRY_ACL_STYLE_MARK_DEFAULT: int

class Archive:
    @classmethod
    def __init__(cls, *args, **kwargs) -> None: ...
    def clear_error(self) -> None: ...
    def copy_error(self, other: Archive) -> None: ...
    def error_string(self) -> bytes: ...
    def file_count(self) -> int: ...
    def filter_bytes(self, n: int) -> int : ...
    def filter_code(self, n: int) -> int: ...
    def filter_count(self) -> int: ...
    def format(self) -> int: ...
    def format_name(self) -> bytes: ...
    def get_errno(self) -> int: ...
    def set_error(self, int_err, msg: str) -> None: ...

class ArchiveEntry:
    atime: int
    atime_is_set: int
    atime_nsec: int
    birthtime: int
    birthtime_is_set: bool
    birthtime_nsec: int
    ctime: int
    ctime_is_set: bool
    ctime_nsec: int
    dev: int
    dev_is_set: bool
    devmajor: int
    devminor: int
    fflags: tuple
    fflags_text: bytes
    filetype: int
    gid: int
    gname: bytes
    gname_utf8: str
    gname_w: str
    hardlink: bytes
    hardlink_utf8: str
    hardlink_w: str
    ino: int
    ino64: int
    ino_is_set: bool
    is_data_encrypted: bool
    is_encrypted: bool
    is_metadata_encrypted: bool
    mac_metadata: bytes
    mode: int
    mtime: int
    mtime_is_set: bool
    mtime_nsec: int
    nlink: int
    pathname: bytes
    pathname_utf8: str
    pathname_w: str
    perm: int
    rdev: int
    rdevmajor: int
    rdevminor: int
    size: int
    size_is_set: bool
    sourcepath: bytes
    sourcepath_w: str
    stat: tuple
    strmode: bytes
    symlink: bytes
    symlink_type: int
    symlink_utf8: str
    symlink_w: str
    uid: int
    uname: bytes
    uname_utf8: str
    uname_w: str
    @classmethod
    def __init__(cls, *args, **kwargs) -> None: ...
    def acl_add_entry(self, type_: int, permset: int, tag: int, id_: int, name) -> int: ...
    def acl_add_entry_w(self, type_: int, permset: int, tag: int, id_: int, name: str) -> int: ...
    def acl_clear(self) -> None: ...
    def acl_count(self, want_type: int) -> int: ...
    def acl_from_text(self, text, type_: int) -> int: ...
    def acl_from_text_w(self, text: str, type_: int) -> int: ...
    def acl_next(self, want_type: int) -> tuple: ...
    def acl_reset(self, want_type: int) -> int: ...
    def acl_to_text(self, flags: int) -> bytes: ...
    def acl_to_text_w(self, flags: int) -> str: ...
    def acl_types(self) -> int: ...
    def clear(self) -> None: ...
    def clone(self) -> ArchiveEntry: ...
    def copy_fflags_text(self, flags: bytes) -> bytes: ...
    def copy_fflags_text_w(self, flags: str) -> str: ...
    def digest(self, type_: int) -> bytes: ...
    def set_atime(self, t: int, ns: int) -> None: ...
    def set_birthtime(self, t: int, ns: int) -> None: ...
    def set_ctime(self, t: int, ns: int) -> None: ...
    def set_link(self, target) -> None: ...
    def set_link_utf8(self, target) -> None: ...
    def set_link_w(self, target: str) -> None: ...
    def sparse_add_entry(self, offset: int, length: int) -> None: ...
    def sparse_clear(self) -> None: ...
    def sparse_count(self) -> int: ...
    def sparse_next(self) -> tuple: ...
    def sparse_reset(self) -> int: ...
    def unset_atime(self, t: int, ns: int) -> None: ...
    def unset_birthtime(self, t: int, ns: int) -> None: ...
    def unset_ctime(self, t: int, ns: int) -> None: ...
    def update_gname_utf8(self, gname: str) -> int: ...
    def update_hardlink_utf8(self, target: str) -> int: ...
    def update_link_utf8(self, target: str) -> int: ...
    def update_pathname_utf8(self, name: str) -> int: ...
    def update_symlink_utf8(self, linkname: str) -> int: ...
    def update_uname_utf8(self, name: str) -> int: ...
    def xattr_add_entry(self, *args, **kwargs) -> None: ...
    def xattr_clear(self) -> None: ...
    def xattr_count(self) -> int: ...
    def xattr_next(self) -> tuple: ...
    def xattr_reset(self) -> int: ...

class ArchiveEntryLinkresolver:

    @classmethod
    def __init__(cls, *args, **kwargs) -> None: ...
    def linkify(self, a: ArchiveEntry, b: ArchiveEntry) -> None: ...
    def partial_links(self) -> tuple: ...
    def set_strategy(self, format_code: int) -> None: ...


class ArchiveError(Exception):
    def __init__(self, msg, errno: int = ..., retcode: int = ..., archive_p = ...) -> ArchiveError: ...

class ArchiveMatch(Archive):

    @classmethod
    def __init__(cls, *args, **kwargs) -> None: ...
    def exclude_entry(self, flag: int, entry: ArchiveEntry) -> int: ...
    def exclude_pattern(self, pattern) -> int: ...
    def exclude_pattern_from_file(self, *args, **kwargs) -> int: ...
    def exclude_pattern_from_file_w(self, *args, **kwargs) -> int: ...
    def exclude_pattern_w(self, pattern) -> int: ...
    def excluded(self, entry: ArchiveEntry) -> int: ...
    def include_date(self, flag: int, datestr) -> int: ...
    def include_date_w(self, flag: int, datestr: str) -> int: ...
    def include_file_time(self, flag: int, pathname) -> int: ...
    def include_file_time_w(self, flag: int, pathname: str) -> int: ...
    def include_gid(self, gid: int) -> int: ...
    def include_gname(self, gname) -> int: ...
    def include_gname_w(self, gname: str) -> int: ...
    def include_pattern(self, pattern) -> int: ...
    def include_pattern_from_file(self, *args, **kwargs) -> int: ...
    def include_pattern_from_file_w(self, *args, **kwargs) -> int: ...
    def include_pattern_w(self, pattern: str) -> int: ...
    def include_time(self, flag: int, sec: int, nsec: int) -> int: ...
    def include_uid(self, uid: int) -> int: ...
    def include_uname(self, uname) -> int: ...
    def include_uname_w(self, uname: str) -> int: ...
    def owner_excluded(self, entry: ArchiveEntry) -> int: ...
    def path_unmatched_inclusions(self) -> int: ...
    def path_unmatched_inclusions_next(self) -> tuple: ...
    def path_unmatched_inclusions_next_w(self) -> tuple: ...
    def set_inclusion_recursion(self, enabled: bool) -> int: ...
    def time_excluded(self, entry: ArchiveEntry) -> int: ...

class ArchiveRead(Archive):

    format_capabilities: int
    has_encrypted_entries: int
    header_position: int
    def __init__(self, *args, **kwargs) -> None: ...
    def add_passphrase(self, passphrase) -> int: ...
    def append_filter(self, code: int) -> int: ...
    def append_filter_program(self, command) -> int: ...
    def append_filter_program_signature(self, *args, **kwargs) -> int: ...
    def close(self) -> int: ...
    def extract(self, entry: ArchiveEntry, flags: int) -> int: ...
    def extract2(self, entry: ArchiveEntry, d: Archive) -> int: ...
    def extract_set_progress_callback(self, func) -> None: ...
    def extract_set_skip_file(self, dev: int, ino: int) -> None: ...
    def iter_entries(self) -> Iterable[ArchiveEntry]: ...
    def open(self, file, block_size: int, close: bool = ...) -> int: ...
    def open_fd(self, fd: int, block_size: int) -> int: ...
    def open_memory(self, *args, **kwargs) -> int: ...
    def read_data_block(self) -> tuple: ...
    def read_data_into_fd(self, fd: int) -> int: ...
    def readinto(self, buf: bytearray) -> int: ...
    def seek(self, offset: int, whence: int) -> int : ...
    def set_filter_option(self, module, option, value) -> int: ...
    def set_format(self, code: int) -> int: ...
    def set_format_option(self, module, option, value) -> int: ...
    def set_option(self, module, option, value) -> int: ...
    def set_options(self, opts) -> int: ...
    def set_passphrase_callback(self, func) -> int: ...
    def skip(self) -> int: ...
    def support_filter_all(self) -> int: ...
    def support_filter_by_code(self, code: int) -> int: ...
    def support_filter_bzip2(self) -> int: ...
    def support_filter_grzip(self) -> int: ...
    def support_filter_gzip(self) -> int: ...
    def support_filter_lrzip(self) -> int: ...
    def support_filter_lz4(self) -> int: ...
    def support_filter_lzip(self) -> int: ...
    def support_filter_lzma(self) -> int: ...
    def support_filter_lzop(self) -> int: ...
    def support_filter_none(self) -> int: ...
    def support_filter_program(self, command) -> int: ...
    def support_filter_program_signature(self, command: bytes, signature: bytes) -> int: ...
    def support_filter_rpm(self) -> int: ...
    def support_filter_uu(self) -> int: ...
    def support_filter_xz(self) -> int: ...
    def support_filter_zstd(self) -> int: ...
    def support_format_7zip(self) -> int: ...
    def support_format_all(self) -> int: ...
    def support_format_ar(self) -> int: ...
    def support_format_by_code(self, code: int) -> int: ...
    def support_format_cab(self) -> int: ...
    def support_format_cpio(self) -> int: ...
    def support_format_empty(self) -> int: ...
    def support_format_gnutar(self) -> int: ...
    def support_format_iso9660(self) -> int: ...
    def support_format_lha(self) -> int: ...
    def support_format_mtree(self) -> int: ...
    def support_format_rar(self) -> int: ...
    def support_format_rar5(self) -> int: ...
    def support_format_raw(self) -> int: ...
    def support_format_tar(self) -> int: ...
    def support_format_warc(self) -> int: ...
    def support_format_xar(self) -> int: ...
    def support_format_zip(self) -> int: ...
    def support_format_zip_seekable(self) -> int: ...
    def support_format_zip_streamable(self) -> int: ...

class ArchiveReadDisk(ArchiveRead):
    def __init__(self, *args, **kwargs) -> None: ...
    def can_descend(self) -> int: ...
    def current_filesystem(self) -> int: ...
    def current_filesystem_is_remote(self) -> int: ...
    def current_filesystem_is_synthetic(self) -> int: ...
    def descend(self) -> int: ...
    def entry_from_file(self, entry: ArchiveEntry, fd: int, stat) -> int: ...
    def gname(self, gid: int) -> bytes: ...
    def open_a(self, *args, **kwargs) -> int: ...
    def open_w(self, name: str) -> int: ...
    def set_atime_restored(self) -> int: ...
    def set_behavior(self, flags: int) -> int: ...
    def set_gname_lookup(self, lookup, cleanup) -> int: ...
    def set_matching(self, ArchiveMatchma, excluded_func) -> int: ...
    def set_metadata_filter_callback(self, filter_func) -> int: ...
    def set_standard_lookup(self) -> int: ...
    def set_symlink_hybrid(self) -> int: ...
    def set_symlink_logical(self) -> int: ...
    def set_symlink_physical(self) -> int: ...
    def set_uname_lookup(self, lookup, cleanup) -> int: ...
    def uname(self, uid: int) -> bytes: ...

class ArchiveWrite(Archive):

    bytes_in_last_block: int
    bytes_per_block: int
    def __init__(self, *args, **kwargs) -> None: ...
    def add_filter(self, filter_code: int) -> int: ...
    def add_filter_b64encode(self) -> int: ...
    def add_filter_by_name(self, name) -> int: ...
    def add_filter_bzip2(self) -> int: ...
    def add_filter_compress(self) -> int: ...
    def add_filter_grzip(self) -> int: ...
    def add_filter_gzip(self) -> int: ...
    def add_filter_lrzip(self) -> int: ...
    def add_filter_lz4(self) -> int: ...
    def add_filter_lzip(self) -> int: ...
    def add_filter_lzma(self) -> int: ...
    def add_filter_lzop(self) -> int: ...
    def add_filter_none(self) -> int: ...
    def add_filter_program(self, cmd) -> int: ...
    def add_filter_uuencode(self) -> int: ...
    def add_filter_xz(self) -> int: ...
    def add_filter_zstd(self) -> int: ...
    def close(self) -> int: ...
    def fail(self) -> int: ...
    def finish_entry(self) -> int: ...
    def get_bytes_in_last_block(self) -> int: ...
    def get_bytes_per_block(self) -> int: ...
    def open(self, file, block_size: int, close: bool = ...) -> int: ...
    def open_fd(self, fd: int) -> int: ...
    def open_memory(self, data: bytearray, used: memoryview) -> int: ...
    def set_bytes_in_last_block(self, bytes_in_last_block: int) -> int: ...
    def set_bytes_per_block(self, bytes_per_block: int) -> int: ...
    def set_filter_option(self, module, option, value) -> int: ...
    def set_format(self, format_code: int) -> int: ...
    def set_format_7zip(self) -> int: ...
    def set_format_ar_bsd(self) -> int: ...
    def set_format_ar_svr4(self) -> int: ...
    def set_format_by_name(self, name) -> int: ...
    def set_format_cpio(self) -> int: ...
    def set_format_cpio_bin(self) -> int: ...
    def set_format_cpio_newc(self) -> int: ...
    def set_format_cpio_odc(self) -> int: ...
    def set_format_cpio_pwb(self) -> int: ...
    def set_format_filter_by_ext(self, filename) -> int: ...
    def set_format_filter_by_ext_def(self, filename, def_ext) -> int: ...
    def set_format_gnutar(self) -> int: ...
    def set_format_iso9660(self) -> int: ...
    def set_format_mtree(self) -> int: ...
    def set_format_mtree_classic(self) -> int: ...
    def set_format_option(self, module, option, value) -> int: ...
    def set_format_pax(self) -> int: ...
    def set_format_pax_restricted(self) -> int: ...
    def set_format_raw(self) -> int: ...
    def set_format_shar(self) -> int: ...
    def set_format_shar_dump(self) -> int: ...
    def set_format_ustar(self) -> int: ...
    def set_format_v7tar(self) -> int: ...
    def set_format_warc(self) -> int: ...
    def set_format_xar(self) -> int: ...
    def set_format_zip(self) -> int: ...
    def set_option(self, module, option, value) -> int: ...
    def set_options(self, opts) -> int: ...
    def set_passphrase(self, passphrase) -> int: ...
    def set_passphrase_callback(self, func) -> int: ...
    def set_skip_file(self, dev: int, ino: int) -> int: ...
    def write(self, data: bytes) -> int: ...
    def write_data_block(self, *args, **kwargs) -> int: ...
    def write_header(self, entry: ArchiveEntry) -> int: ...
    def zip_set_compression_deflate(self) -> int: ...
    def zip_set_compression_store(self) -> int: ...

class ArchiveWriteDisk(ArchiveWrite):
    def __init__(self, *args, **kwargs) -> None: ...
    def gid(self, name, gid: int) -> int : ...
    def set_group_lookup(self, lookup, cleanup) -> int: ...
    def set_options(self, flags: int) -> int: ...
    def set_skip_file(self, dev: int, ino: int) -> int: ...
    def set_standard_lookup(self) -> int: ...
    def set_user_lookup(self, lookup, cleanup) -> int: ...
    def uid(self, name, uid: int) -> int : ...

def bzlib_version() -> str: ...
def copy_data_to_disk(ar: ArchiveRead, aw: ArchiveRead) -> int: ...
def liblz4_version() -> str: ...
def liblzma_version() -> str: ...
def libzstd_version() -> str: ...
def version_details() -> str: ...
def version_number() -> int: ...
def version_string() -> str: ...
def zlib_version() -> str: ...
```