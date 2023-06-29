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
to install a pre-build libarchive with header-files available.
