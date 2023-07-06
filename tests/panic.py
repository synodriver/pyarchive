"""
Copyright (c) 2008-2023 synodriver <diguohuangjiajinweijun@gmail.com>
"""
from pyarchive import ArchiveFile, ArchiveRead

def t1():
    f = ArchiveFile(name=r"E:\pyproject\pyarchive\tests\ZJYX.rar")
    print(f.getmembers())
    del f # calls  archive_read_free and sth happens

def t2():
    a = ArchiveRead()
    a.support_filter_all()
    a.support_format_all()
    f  = open(r"E:\pyproject\pyarchive\tests\ZJYX.rar", "rb")
    a.open(f, 1000000)

t1()