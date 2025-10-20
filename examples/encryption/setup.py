from setuptools import setup, Extension
from Cython.Build import cythonize
from typing import Sequence
import os
import numpy as np
import pyarrow as pa
from pathlib import Path
import re


def pyarrow_extensions() -> Sequence[Extension]:
    pa.create_library_symlinks()

    base_dir = Path(__file__).absolute().parent
    extensions = [str(f.relative_to(base_dir)) for f in base_dir.glob('**/*.pyx') ]
    ext_modules: Sequence[Extension] = cythonize(extensions)

    for ext in ext_modules:
        # The Numpy C headers are currently required
        ext.name = 'pfparsons.' + ext.name
        print(f" ************************ {ext.name}")
        ext.include_dirs.append(np.get_include())
        ext.include_dirs.append(pa.get_include())
        ext.libraries.extend(pa.get_libraries())
        ext.library_dirs.extend(pa.get_library_dirs())

        #ext.define_macros.append(("_GLIBCXX_USE_CXX11_ABI", "0"))

        if os.name == 'posix':
            ext.extra_compile_args.append('-std=c++17')

    return ext_modules

#setup(ext_modules=pyarrow_extensions())
setup()
