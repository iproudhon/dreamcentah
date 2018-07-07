#!/bin/bash


function usage ()
{
    echo "$(basename $0) <sol-file>"
}

if [ $# != 1 ]; then
    usage
    exit 1
fi

docker run -v $(pwd):/tmp --workdir /tmp --rm ethereum/solc:stable --optimize --abi --bin $* | awk '
function flush() {
  if (length(code_name) > 0) {
    printf "\
function %s_new() {\
  %s = %s_contract.new(\
  {\
    from: web3.eth.accounts[0],\
    data: %s_data,\
    gas: \"0x2000000\"\
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

# binary: 60.06040 for contracts, 610eb861 for libraries
/^610|^60.06040/ {
  if (length(code_name) > 0) {
    print "var " code_name "_data = \"0x" $0 "\";";
  }
}
';

# EOF
