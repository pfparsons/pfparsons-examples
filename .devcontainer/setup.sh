#/bin/bash
python3.12 -m venv venv
. venv/bin/activate
pip3.12 install uv
python3.12 -m pip install -e examples/llm/playground
