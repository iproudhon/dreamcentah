#!/bin/bash

if [ "${NODES}" = "" ]; then
    NODES="node1 node2 node3"
fi
CHAINID=15
DIR=${HOME}/eth
GETH=${DIR}/bin/geth
LHN=$(hostname -s)

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
    [ -d "${DIR}" ] || die "${DIR} not found"
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
    [ -d "${DIR}" ] || die "${DIR} not found"
    [ -d "${DIR}/logs" ] || mkdir -p ${DIR}/logs
    stop
    nohup ${GETH} --datadir ${DIR} --nodiscover --networkid ${CHAINID} --rpc > ${DIR}/logs/log 2>&1 &
}

function stop ()
{
    while true; do
        GETHID=$(ps axww | grep -v grep | grep "geth --datadir" | awk '{print $1}')
        if [ "$GETHID" = "" ]; then
            break
        else
            kill $GETHID
            sleep 1
        fi
    done
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
    [ -f ${DIR}/rc.js ] && RCJS="--preload ${DIR}/rc.js"
    exec ${GETH} attach ${RCJS} ${DIR}/geth.ipc
    ;;
"wipe")
    wipe;
    ;;
"start-all")
    [ "${NODES}" = "" ] && die "NODES is not defined"
    for i in ${NODES}; do
        if [ $i = $LHN ]; then
            start;
        else
            ssh $i "${HOME}/eth/bin/geth.sh start"
        fi
    done
    ;;
"stop-all")
    [ "${NODES}" = "" ] && die "NODES is not defined"
    for i in ${NODES}; do
        if [ $i = $LHN ]; then
            stop;
        else
            ssh $i "${HOME}/eth/bin/geth.sh stop"
        fi
    done
    ;;
*)
    usage;
    ;;
esac

# EOF
