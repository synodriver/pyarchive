"""
Copyright (c) 2008-2023 synodriver <diguohuangjiajinweijun@gmail.com>
"""
from pyarchive import ArchiveRead

a = ArchiveRead()
a.support_filter_all()
a.support_format_all()
buff = bytearray(1000)
with open(r"D:\arpl-1.0-beta6.img.zip", "rb") as inp:
    out = bytearray(2000)
    try:
        a.open(inp, 1000)
    except Exception as e:
        print(e)
    # print("here")
    # print("error", a.get_errno(), a.error_string())
    for entry in a.iter_entries():
        print(entry.pathname_w)
        a.skip()
