"""
Copyright (c) 2008-2023 synodriver <diguohuangjiajinweijun@gmail.com>
"""
import os
from unittest import TestCase

from pyarchive import ArchiveFile


class TestArchiveFile(TestCase):
    def test_close_file(self):
        fileobj = open(os.path.join(os.path.dirname(__file__), "./ZJYX.rar"), "rb")
        file = ArchiveFile(mode="r", fileobj=fileobj)
        print(file.getnames())
        print("here")
        # print(file.getnames())


if __name__ == "__main__":
    import unittest

    unittest.main()
