"""
Copyright (c) 2008-2023 synodriver <diguohuangjiajinweijun@gmail.com>
"""
chunk_size = 8192

with open("tmp/arpl.img", "rb") as origin, open("arpl.img", "rb") as decompressed:
    current_ptr = 0
    while True:
        chunk_origin = origin.read(chunk_size)
        chunk_decompressed = decompressed.read(chunk_size)
        if chunk_origin != chunk_decompressed:
            print(f"从 {current_ptr} 开始不一样")
        current_ptr += chunk_size
