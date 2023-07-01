# pyarchive
# WIP

The goal is to provide a fast and feature-rich binding for latest version 
of libarchive, with almost every function bind in python, and
a clear bridge from Python's ```BytesIO``` to libarchive's
stream, which means it's able to extra files in memory and direct use
Python's file-like object.


# Build

Build pyarchive with all features available is not very easy, especially
on Windows, you'll have to link against the right libarchive. The recommend
way is to use a conda environment. Use ```conda install -c conda-forge libarchive```
to install a pre-build libarchive with header-files available, and build use
the following script

```bash
python setup.py build_ext -i --use-cython --lib-path "D:\conda\envs\py310\Library\lib\archive.lib" --include-path "D:\conda\envs\py310\Library\include"
```
On linux, this may be

```bash
python setup.py build_ext -i --use-cython --lib-path "/root/conda/envs/py310/Library/lib/libarchive.so" --include-path "/root/miniconda/envs/py310/Library/include"
```