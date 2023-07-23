"""
Copyright (c) 2008-2023 synodriver <diguohuangjiajinweijun@gmail.com>
"""
import os
from unittest import TestCase

from pyarchive import ArchiveRead


class TestArchive(TestCase):
    def test_close_file(self):
        fileobj = open(os.path.join(os.path.dirname(__file__), "./ZJYX.rar"), "rb")
        archive = ArchiveRead()
        archive.support_format_all()
        archive.support_filter_all()
        archive.open(fileobj, 1000000, True)
        del archive
        self.assertTrue(fileobj.closed)

    def test_notclose_file(self):
        with open(os.path.join(os.path.dirname(__file__), "./ZJYX.rar"), "rb") as fileobj:
            archive = ArchiveRead()
            archive.support_format_all()
            archive.support_filter_all()
            archive.open(fileobj, 1000000)
            del archive
            self.assertFalse(fileobj.closed)

    def test_list_content(self):
        fileobj = open(os.path.join(os.path.dirname(__file__), "./ZJYX.rar"), "rb")
        archive = ArchiveRead()
        archive.support_format_all()
        archive.support_filter_all()
        archive.open(fileobj, 1000000, True)
        for entry in archive.iter_entries():
            print(entry.pathname_w)


if __name__ == "__main__":
    import unittest

    unittest.main()
