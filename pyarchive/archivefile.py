"""
Copyright (c) 2008-2023 synodriver <diguohuangjiajinweijun@gmail.com>
"""
import os
import stat
import tarfile
from builtins import open as _builtin_open
from typing import List, Union

from pyarchive.backends import (
    AE_IFBLK,
    AE_IFCHR,
    AE_IFDIR,
    AE_IFIFO,
    AE_IFLNK,
    AE_IFREG,
    AE_SYMLINK_TYPE_FILE,
)

# import zipfile
# import bz3
from pyarchive.backends import ArchiveEntry, ArchiveRead, ArchiveWrite

# class ArchiveInfo(object):
#     """Informational class which holds the details about an
#        archive member given by a tar header block.
#        TarInfo objects are returned by TarFile.getmember(),
#        TarFile.getmembers() and TarFile.gettarinfo() and are
#        usually created internally.
#     """
#
#     __slots__ = dict(
#         name='Name of the archive member.',
#         mode='Permission bits.',
#         uid='User ID of the user who originally stored this member.',
#         gid='Group ID of the user who originally stored this member.',
#         size='Size in bytes.',
#         mtime='Time of last modification.',
#         chksum='Header checksum.',
#         type=('File type. type is usually one of these constants: '
#               'REGTYPE, AREGTYPE, LNKTYPE, SYMTYPE, DIRTYPE, FIFOTYPE, '
#               'CONTTYPE, CHRTYPE, BLKTYPE, GNUTYPE_SPARSE.'),
#         linkname=('Name of the target file name, which is only present '
#                   'in TarInfo objects of type LNKTYPE and SYMTYPE.'),
#         uname='User name.',
#         gname='Group name.',
#         devmajor='Device major number.',
#         devminor='Device minor number.',
#         offset='The tar header starts here.',
#         offset_data="The file's data starts here.",
#         pax_headers=('A dictionary containing key-value pairs of an '
#                      'associated pax extended header.'),
#         sparse='Sparse member information.',
#         tarfile=None,
#         _sparse_structs=None,
#         _link_target=None,
#     )
#
#     def __init__(self, name=""):
#         """Construct a TarInfo object. name is the optional name
#            of the member.
#         """
#         self.name = name  # member name
#         self.mode = 0o644  # file permissions
#         self.uid = 0  # user id
#         self.gid = 0  # group id
#         self.size = 0  # file size
#         self.mtime = 0  # modification time
#         self.chksum = 0  # header checksum
#         self.type = REGTYPE  # member type
#         self.linkname = ""  # link name
#         self.uname = ""  # user name
#         self.gname = ""  # group name
#         self.devmajor = 0  # device major number
#         self.devminor = 0  # device minor number
#
#         self.offset = 0  # the tar header starts here
#         self.offset_data = 0  # the file's data starts here
#
#         self.sparse = None  # sparse member information
#         self.pax_headers = {}  # pax header information
#
#     @property
#     def path(self):
#         """In pax headers, "name" is called "path"."""
#         return self.name
#
#     @path.setter
#     def path(self, name):
#         self.name = name
#
#     @property
#     def linkpath(self):
#         'In pax headers, "linkname" is called "linkpath".'
#         return self.linkname
#
#     @linkpath.setter
#     def linkpath(self, linkname):
#         self.linkname = linkname
#
#     def __repr__(self):
#         return "<%s %r at %#x>" % (self.__class__.__name__, self.name, id(self))
#
#     def get_info(self):
#         """Return the TarInfo's attributes as a dictionary.
#         """
#         info = {
#             "name": self.name,
#             "mode": self.mode & 0o7777,
#             "uid": self.uid,
#             "gid": self.gid,
#             "size": self.size,
#             "mtime": self.mtime,
#             "chksum": self.chksum,
#             "type": self.type,
#             "linkname": self.linkname,
#             "uname": self.uname,
#             "gname": self.gname,
#             "devmajor": self.devmajor,
#             "devminor": self.devminor
#         }
#
#         if info["type"] == DIRTYPE and not info["name"].endswith("/"):
#             info["name"] += "/"
#
#         return info


# def _entry_to_info(entry: ArchiveEntry):
#     return ArchiveInfo(entry.pathname_w)


class ArchiveFile:
    dereference = False

    def __init__(
        self,
        name: str = None,
        mode: str = "r",
        fileobj=None,
        format: str = None,
        pwd: bytes = None,
        block_size: int = 1000000,
    ):
        modes = {"r": "rb", "a": "r+b", "w": "wb", "x": "xb"}
        if mode not in modes:
            raise ValueError("mode must be 'r', 'a', 'w' or 'x'")
        self.mode = mode
        self._mode = modes[mode]

        if not fileobj:
            if self.mode == "a" and not os.path.exists(name):
                # Create nonexistent files in append mode.
                self.mode = "w"
                self._mode = "wb"
            fileobj = _builtin_open(name, self._mode)
            self._extfileobj = False
        else:
            if (
                name is None
                and hasattr(fileobj, "name")
                and isinstance(fileobj.name, (str, bytes))
            ):
                name = fileobj.name
            if hasattr(fileobj, "mode"):
                self._mode = fileobj.mode
            self._extfileobj = True
        self.name = os.path.abspath(name) if name else None
        self.fileobj = fileobj

        # Init attributes.
        if format is not None:
            self.format = format
        self.pwd = pwd
        self.closed = False
        self.block_size = block_size
        self.members = []  # type: List["ArchiveEntry"]
        if self.mode == "r":
            self._archive = ArchiveRead()
            self._archive.support_filter_all()
            self._archive.support_format_all()
            self._archive.open(self.fileobj, self.block_size)
            self._loaded = False
        else:
            # self._archive = ArchiveWrite()
            pass  # todo set write format

    def _check(self, mode=None):
        """Check if ArchiveFile is still open, and if the operation's mode
        corresponds to ArchiveFile's mode.
        """
        if self.closed:
            raise OSError("%s is closed" % self.__class__.__name__)
        if mode is not None and self.mode not in mode:
            raise OSError("bad operation for mode %r" % self.mode)

    def __del__(self):
        self._archive.close()  # would panic without this

    def _rewind(self):
        self.fileobj.seek(0, 0)
        if isinstance(self._archive, ArchiveRead):
            self._archive = ArchiveRead()
            self._archive.support_filter_all()
            self._archive.support_format_all()
            self._archive.open(self.fileobj, self.block_size)

    def _load(self) -> None:
        for entry in self._archive.iter_entries():
            self.members.append(entry)
        self._loaded = True
        self._rewind()

    def getnames(self) -> List[str]:
        return [archiveinfo.pathname_utf8 for archiveinfo in self.getmembers()]

    def getmember(self, name: str):
        members = self.getmembers()
        for member in members:
            if member.pathname_utf8 == name:
                return member

    def getmembers(self) -> List["ArchiveEntry"]:
        self._check()
        if not self._loaded:  # if we want to obtain a list of
            self._load()  # all members, we first have to
            # scan the whole archive.
        return self.members

    def list(self):
        ...

    def extractall(
        self, path=".", members: List[Union[str, "ArchiveEntry"]] = None
    ) -> None:
        self._check("r")
        buff = bytearray(self.block_size)
        if members is None:
            members = self.getmembers()
        else:
            temp = []
            for each in members:
                if isinstance(members, str):
                    newitem = self.getmember(each)
                else:
                    newitem = each
                temp.append(newitem)
            members = temp
        for entry in self._archive.iter_entries():
            if entry in members:
                with open(os.path.join(path, entry.pathname_utf8), "wb") as outputfile:
                    while read_size := self._archive.readinto(buff):
                        outputfile.write(buff[:read_size])
        self._rewind()

    def extract(self, member: Union[str, "ArchiveEntry"], path="") -> None:
        self._check("r")
        buff = bytearray(self.block_size)
        if isinstance(member, str):
            entry = self.getmember(member)
        else:
            entry = member
        for entry_ in self._archive.iter_entries():
            if entry_ == entry:
                with open(os.path.join(path, entry_.pathname_utf8), "wb") as outputfile:
                    while read_size := self._archive.readinto(buff):
                        outputfile.write(buff[:read_size])
        self._rewind()

    def get_archive_entry(self, name=None, arcname=None, fileobj=None):
        self._check("awx")
        if fileobj is not None:
            name = fileobj.name
        if arcname is None:
            arcname = name
        drv, arcname = os.path.splitdrive(arcname)
        arcname = arcname.replace(os.sep, "/")
        arcname = arcname.lstrip("/")

        if fileobj is None:
            if not self.dereference:
                statres = os.lstat(name)
            else:
                statres = os.stat(name)
        else:
            statres = os.fstat(fileobj.fileno())
        linkname = ""

        stmd = statres.st_mode
        if stat.S_ISREG(stmd):
            inode = (statres.st_ino, statres.st_dev)
            if not self.dereference and statres.st_nlink > 1:
                # Is it a hardlink to an already
                # archived file?
                type = AE_IFLNK
                linkname = self.inodes[inode]
            else:
                # The inode is added only if its valid.
                # For win32 it is always 0.
                type = AE_IFREG
        elif stat.S_ISDIR(stmd):
            type = AE_IFDIR
        elif stat.S_ISFIFO(stmd):
            type = AE_IFIFO
        elif stat.S_ISLNK(stmd):
            type = AE_SYMLINK_TYPE_FILE
            linkname = os.readlink(name)
        elif stat.S_ISCHR(stmd):
            type = AE_IFCHR
        elif stat.S_ISBLK(stmd):
            type = AE_IFBLK
        else:
            return None

        entry = ArchiveEntry()
        entry.pathname_utf8 = arcname
        # entry.size = statres.st_size
        # entry.mode = statres.st_mode
        # entry.mtime = (statres.st_mtime, statres.st_mtime_ns)
        # entry.set_ctime(statres.st_ctime, statres.st_ctime_ns)
        # entry.set_atime(statres.st_atime, statres.st_atime_ns)
        entry.stat = statres
        entry.filetype = type
        entry.perm = 644
        if linkname:
            entry.hardlink_utf8 = linkname
        if type in (AE_IFCHR, AE_IFBLK):
            if hasattr(os, "major") and hasattr(os, "minor"):
                entry.devmajor = os.major(statres.st_rdev)
                entry.devminor = os.minor(statres.st_rdev)
        return entry

    def add(self, name, arcname=None, recursive=True, *, filter=None):
        self._check("awx")

        if arcname is None:
            arcname = name

        entry = self.get_archive_entry(name, arcname)

    def addfile(self, entry, fileobj=None):
        ...

    def gettarinfo(self, name=None, arcname=None, fileobj=None):
        ...

    def close(self):
        ...
