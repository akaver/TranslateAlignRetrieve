#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_DIR=${SCRIPT_DIR}/../translate/env
source ${ENV_DIR}/bin/activate

# Train the alignment model with eflomal and generated priors
# The text should be tokenized before computing the alignment.
FILE_SRC=$1
LANG_SRC=$2
FILE_TGT=$3
LANG_TGT=$4

# Compute forward and reverse alignment models
TOOLS_DIR=${SCRIPT_DIR}/../translate/tools
EFLOMAL_DIR=${TOOLS_DIR}/eflomal
FASTALIGN_DIR=${TOOLS_DIR}/fast_align
MOSES_DIR=${TOOLS_DIR}/mosesdecoder

DATA_DIR=${SCRIPT_DIR}/data
mkdir -p ${DATA_DIR}

export LC_ALL=en_US.UTF8
#tokenize(){
#    INPUT_FILE=$1
#    INPUT_LANG=$2
#    cat ${INPUT_FILE} | \
#    perl ${MOSES_DIR}/scripts/tokenizer/tokenizer.perl -l ${INPUT_LANG} < ${INPUT_FILE}
#}

echo 'Train the alignment model...'
FWD_ALIGN=$(mktemp)
REV_ALIGN=$(mktemp)
SYM_ALIGN=$(mktemp)

# Tokenize and convert into FastAlign format
FILE_SRC_TGT_TOK=$(mktemp)
paste -d '|' ${FILE_SRC} ${FILE_TGT} \
    | sed 's/|/ ||| /g' \
    > ${FILE_SRC_TGT_TOK}

python ${EFLOMAL_DIR}/align.py \
    -i ${FILE_SRC_TGT_TOK} \
    --model 3 \
    -f ${FWD_ALIGN} \
    -r ${REV_ALIGN} \
    -v --overwrite

#echo "Symmetrize alignments..."
#${FASTALIGN_DIR}/build/atools \
#    -c grow-diag-final-and \
#    -i ${FWD_ALIGN} \
#    -j ${REV_ALIGN} > ${SYM_ALIGN}

cp ${FWD_ALIGN} ${DATA_DIR}/align.fwd."${LANG_SRC}"-"${LANG_TGT}"
cp ${REV_ALIGN} ${DATA_DIR}/align.rev."${LANG_SRC}"-"${LANG_TGT}"
#cp ${SYM_ALIGN} ${DATA_DIR}/align.sym."${LANG_SRC}"-"${LANG_TGT}"

python ${EFLOMAL_DIR}/makepriors.py \
    -i ${FILE_SRC_TGT_TOK} \
    -f ${DATA_DIR}/align.fwd."${LANG_SRC}"-"${LANG_TGT}" \
    -r ${DATA_DIR}/align.rev."${LANG_SRC}"-"${LANG_TGT}" \
    --priors ${DATA_DIR}/align.priors."${LANG_SRC}"-"${LANG_TGT}" \


rm ${FWD_ALIGN} ${REV_ALIGN} ${SYM_ALIGN} ${FILE_SRC_TGT_TOK}













