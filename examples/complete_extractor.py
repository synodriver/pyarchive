"""
Copyright (c) 2008-2023 synodriver <diguohuangjiajinweijun@gmail.com>
"""
from pyarchive import (
    ARCHIVE_EXTRACT_ACL,
    ARCHIVE_EXTRACT_FFLAGS,
    ARCHIVE_EXTRACT_PERM,
    ARCHIVE_EXTRACT_TIME,
    ArchiveRead,
    ArchiveWriteDisk,
)


def copy_data(
    a: ArchiveRead, ext: ArchiveWriteDisk
):  # there is a real zerocopy version called ```copy_data_to_disk``` written in cython
    while True:
        ret = a.read_data_block()
        if not ret:
            break
        buf, offset = ret
        ext.write_data_block(buf, offset)


def extract(filename: str):
    a = ArchiveRead()
    ext = ArchiveWriteDisk()

    a.support_format_all()
    a.support_filter_all()

    flags = (
        ARCHIVE_EXTRACT_TIME
        | ARCHIVE_EXTRACT_PERM
        | ARCHIVE_EXTRACT_ACL
        | ARCHIVE_EXTRACT_FFLAGS
    )
    ext.set_options(flags)
    ext.set_standard_lookup()

    with open(filename, "rb") as inpstream:
        a.open(inpstream, 1024 * 1024)
        for entry in a.iter_entries():
            ext.write_header(entry)
            if entry.size > 0:
                copy_data(a, ext)
            ext.finish_entry()
