"""
Copyright (c) 2008-2023 synodriver <diguohuangjiajinweijun@gmail.com>
"""
from pyarchive import version_details, zlib_version, liblzma_version, bzlib_version, liblz4_version, libzstd_version, \
    ArchiveError


def main():
    try:
        print(f"libarchive version {version_details()}")
    except ArchiveError:
        print("can not find libarchive")

    try:
        print(f"zlib version {zlib_version()}")
    except ArchiveError:
        print("can not find zlib")

    try:
        print(f"liblzma version {liblzma_version()}")
    except ArchiveError:
        print("can not find liblzma")

    try:
        print(f"bzip version {bzlib_version()}")
    except ArchiveError:
        print("can not find libbzip")

    try:
        print(f"lz4 version {liblz4_version()}")
    except ArchiveError:
        print("can not find lz4")

    try:
        print(f"zstd version {libzstd_version()}")
    except ArchiveError:
        print("can not find zstd")


if __name__ == "__main__":
    main()
