"""
Copyright (c) 2008-2023 synodriver <diguohuangjiajinweijun@gmail.com>
"""
from pyarchive import AE_IFREG, ARCHIVE_EXTRACT_TIME, ArchiveEntry, ArchiveWriteDisk

disk = ArchiveWriteDisk()
disk.set_options(ARCHIVE_EXTRACT_TIME)
entry = ArchiveEntry()
entry.pathname_utf8 = "myfile.txt"
entry.filetype = AE_IFREG
entry.size = 5
entry.mtime = (123456789, 0)

disk.write_header(entry)
disk.write(b"abcde")
disk.finish_entry()
