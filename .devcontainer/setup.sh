#/bin/bash
python -m venv venv
. venv/bin/activate
python -m pip install uv
uv pip install pyarrow
python -c "import pyarrow; pyarrow.create_library_symlinks()"
