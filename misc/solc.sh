#!/bin/bash


function usage ()
{
    echo "$(basename $0) [-l <name>:<addr>]+ <sol-file> <js-file>

SOL_LIBS environment variable can be used instead of -l option."
}

# int compile(string solFile, string jsFile)
function compile ()
{
    docker run -v $(pwd):/tmp --workdir /tmp --rm ethereum/solc:stable --optimize --abi --bin $1 | awk -v libs="$SOL_LIBS" '
function flush() {
  if (length(code_name) > 0) {
    printf "\
function %s_new() {\
  %s = %s_contract.new(\
  {\
    from: web3.eth.accounts[0],\
    data: %s_data,\
    gas: \"0x20000000\"\
  }, function (e, contract) {\
    console.log(e, contract);\
    if (typeof contract.address !== \"undefined\") {\
      console.log(\"Contract mined! address: \" + contract.address + \" transactionHash: \" + contract.transactionHash);\
    }\
  });\
}\
\
function %s_load(addr) {\
   %s = %s_contract.at(addr);\
}\
\
", code_name, code_name, code_name, code_name, code_name, code_name, code_name;
  }
}

END {
  flush()
}

/^$/ {
  flush()
  code_name = ""
}

/^=======/ {
  code_name = $0
  sub("^=.*:", "", code_name)
  sub(" =======$", "", code_name)
}

# abi
/^\[/ {
  if (length(code_name) > 0) {
    print "var " code_name "_contract = web3.eth.contract(" $0 ");";
  }
}

# binary: 60606040, 60806040 for contracts, 610eb861 for libraries
/^6[01]/ {
  if (length(code_name) > 0) {
    code = $0;
    n = split(libs, alibs, " +");
    for (i = 1; i <= n; i++) {
      if (split(alibs[i], nv, ":") != 2)
        continue;
      sub("^0x", "", nv[2]);
      gsub("_+[^_]*" nv[1] "_+", nv[2], code);
    }
    print "var " code_name "_data = \"0x" code "\";";
  }
}
' > $2;
}

args=`getopt l: $*`
if [ $? != 0 ]; then
    usage;
    exit 1;
fi
set -- $args

#SOL_LIBS
for i; do
    case "$i" in
    -l)
	[ "$SOL_LIBS" = "" ] || SOL_LIBS="$SOL_LIBS "
	SOL_LIBS="${SOL_LIBS}$2";
	shift;
	shift;;
    esac
done

if [ $# != 3 ]; then
    usage
    exit 1
fi

compile "$2" "$3"

# EOF
