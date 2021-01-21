#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_DIR=${SCRIPT_DIR}/env/bin
source $ENV_DIR/activate

# minimal set of packages needed
pip install fasttext tqdm subword-nmt

# download fasttext models for language identification
mkdir -p /content/TranslateAlignRetrieve/src/tar/src/nmt/data/fastText
wget -O /content/TranslateAlignRetrieve/src/tar/src/nmt/data/fastText/lid.176.bin https://dl.fbaipublicfiles.com/fasttext/supervised-models/lid.176.bin
