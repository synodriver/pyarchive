# pyarchive

Pyarchive provide a bridge between file-like objects and libarchive, making it easy to
use and extend libarchive itself. For instance, libarchive [doesn't support bzip3](https://github.com/libarchive/libarchive/issues/1904) at
this moment, however, pyarchive can do that with the help of other libraries.
```python
import bz3
from pyarchive import ArchiveRead

with bz3.open("test.tar.bz3", 'rb') as f:
    a = ArchiveRead()
    a.support_filter_all()
    a.support_format_all()
    a.open(f, 1000)
    for entry in a.iter_entries():
        print(entry.pathname_w)
        a.skip()
```
Besides, it's also possible to read a file in memory using ```open_memory``` method,
and read a fd using ```open_fd```


# Build

Build pyarchive with all features available is not very easy, especially
on Windows, you'll have to link against the right libarchive. The recommend
way is to use a conda environment. Use ```conda install -c conda-forge libarchive```
to install a pre-build libarchive with header-files available, and build use
the following script

```bash
python -m pip install -r requirements.txt
python setup.py sdist bdist_wheel --use-cython --lib-path "D:\conda\envs\py310\Library\lib\archive.lib" --include-path "D:\conda\envs\py310\Library\include"
```
On linux, this may be

```bash
python -m pip install -r requirements.txt
python setup.py sdist bdist_wheel --use-cython --lib-path "/root/conda/envs/py310/Library/lib/libarchive.so" --include-path "/root/conda/envs/py310/Library/include"
```
The path should depend on where you install conda

# Develop
Use 
```
python -m pip install -r requirements.txt
python setup.py build_ext -i --use-cython --lib-path "D:\conda\envs\py310\Library\lib\archive.lib" --include-path "D:\conda\envs\py310\Library\include"
```
and so on