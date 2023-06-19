# pyarchive
# WIP

The goal is to provide a fast and feature-rich binding for latest version 
of libarchive, with almost every function bind in python, and
a clear bridge from Python's ```BytesIO``` to libarchive's
stream, which means it's able to extra files in memory and direct use
Python's file-like object.