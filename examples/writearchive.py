"""
Copyright (c) 2008-2023 synodriver <diguohuangjiajinweijun@gmail.com>
"""
import os
from typing import List

from pyarchive import AE_IFREG, ArchiveEntry, ArchiveWrite


def write_archive(outfile: str, files: List[str], chunk_size: int = 8192):
    a = ArchiveWrite()
    a.add_filter_gzip()
    a.set_format_pax_restricted()

    with open(outfile, "wb") as out_stream:
        a.open(out_stream, 1000)
        entry = ArchiveEntry()
        for each_file in files:
            with open(each_file, "rb") as inpstream:
                stat = os.stat(each_file)
                # print(stat)
                # stat.st_ino = 0
                entry.pathname_utf8 = each_file
                entry.size = stat.st_size
                entry.filetype = AE_IFREG
                entry.perm = 644
                # entry.stat = stat # copy stat
                a.write_header(entry)
                while chunk := inpstream.read(chunk_size):
                    a.write(chunk)
                entry.clear()
        a.close()


if __name__ == "__main__":
    write_archive("arpl.img.tar.gz", ["arpl.img"])
