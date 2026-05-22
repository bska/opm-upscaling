#!/bin/bash
set -e

if test $# -eq 0
then
  echo -e "Usage:\t$0 <options> -- [additional simulator options]"
  echo -e "\tMandatory options:"
  echo -e "\t\t -i <path>     Path to read deck from"
  echo -e "\t\t -r <path>     Path to store results in"
  echo -e "\t\t -n <name>     Test name"
  echo -e "\t\t -a <tol>      Absolute tolerance in comparison"
  echo -e "\t\t -t <tol>      Relative tolerance in comparison"
  echo -e "\t\t -e <filename> Simulator binary to use"
  echo -e "\t\t -c <filename> Path to comparison binary"
  echo -e "\t\t -p <nproc > Number of processors to use"
  exit 1
fi

OPTIND=1
NPROC=1
while getopts "i:r:n:a:t:e:c:p:" OPT
do
  case "${OPT}" in
    i) INPUT_DATA_PATH=${OPTARG} ;;
    r) RESULT_PATH=${OPTARG} ;;
    n) TEST_NAME=${OPTARG} ;;
    a) ABS_TOL=${OPTARG} ;;
    t) REL_TOL=${OPTARG} ;;
    e) EXE_NAME=${OPTARG} ;;
    c) COMP_NAME=${OPTARG} ;;
    p) NPROC=${OPTARG} ;;
  esac
done
shift $(($OPTIND-1))
TEST_ARGS="$@"

rm -Rf ${RESULT_PATH}
mkdir -p ${RESULT_PATH}

if test $NPROC -gt 1
then
  OMP_NUM_THREADS=1 mpirun -np ${NPROC} "${EXE_NAME}" ${TEST_ARGS}
else
  OMP_NUM_THREADS=1 "${EXE_NAME}" ${TEST_ARGS}
fi
"${COMP_NAME}" "${INPUT_DATA_PATH}/reference_solutions/${TEST_NAME}.txt" "${RESULT_PATH}/${TEST_NAME}.txt" ${ABS_TOL} ${REL_TOL}
