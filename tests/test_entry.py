"""
Copyright (c) 2008-2023 synodriver <diguohuangjiajinweijun@gmail.com>
"""
import os
from unittest import TestCase

from pyarchive import ArchiveEntry


class TestArchiveEntry(TestCase):
    def test_eq(self):
        a = ArchiveEntry()
        a.pathname_utf8 = "/1"
        b = ArchiveEntry()
        b.pathname_utf8 = "/2"
        c = ArchiveEntry()
        c.pathname_utf8 = "/3"
        self.assertNotIn(c, [a, b], "entry __eq__ wrong")

    def test_eq2(self):
        a = ArchiveEntry()
        a.pathname_utf8 = "/1"
        b = ArchiveEntry()
        b.pathname_utf8 = "/2"
        c = ArchiveEntry()
        c.pathname_utf8 = "/1"
        self.assertIn(c, [a, b], "entry __eq__ wrong")


if __name__ == "__main__":
    import unittest

    unittest.main()
