#!/bin/bash

if [ "${NODES}" = "" ]; then
    NODES="node1 node2 node3"
fi
DIR=${HOME}/eth
GETH=${DIR}/bin/geth

function die ()
{
    echo $*
    exit 1
}

# void init(string genesisFile)
function init ()
{
    [ -f "$1" ] || die "$1 not found"
    [ -d "${DIR}" ] || mkdir -p "${DIR}";
    ${GETH} --datadir ${DIR} init $1
}

function clean ()
{
    [ -d "${DIR}" ] || mkdir -p "${DIR}";
    ${GETH} --datadir removedb
}

function wipe ()
{
    [ -d "${DIR}" ] || die "${DIR} not found"
    cd "$DIR"
    /bin/rm -rf geth/LOCK geth/chaindata geth/ethash geth/lightchaindata \
        geth/transactions.rlp geth.ipc
}

function start ()
{
}

function stop ()
{
}

function usage ()
{
    echo "Usage: $(basename $0) [init <genesis.json> | start | stop | clean |
    wipe | console | start-all | stop-all]"
}

[ -x "${GETH}" ] || die "${GETH} not found"

case "$1" in 
"init")
    [ $# != 2 ] || (usage; exit)
    init $2
    ;;
"start")
    start;
    ;;
"stop")
    stop;
    ;;
"clean")
    clean;
    ;;
"console")
    ${GETH} attach ${DIR}/geth.ipc
    ;;
"wipe")
    wipe;
    ;;
"start-all")
    [ "${NODES}" = "" ] || die "NODES is not defined"
    for i in ${NODES}; do
        echo $i;
    done
    ;;
"stop-all")
    [ "${NODES}" = "" ] || die "NODES is not defined"
    for i in ${NODES}; do
        echo $i;
    done
    ;;
esac

# EOF
