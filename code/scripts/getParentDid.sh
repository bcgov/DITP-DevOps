#!/bin/bash
export MSYS_NO_PATHCONV=1
SCRIPT_HOME="$( cd "$( dirname "$0" )" && pwd )"

function isInstalled () {
  rtnVal=$(type "$1" >/dev/null 2>&1)
  rtnCd=$?
  if [ ${rtnCd} -ne 0 ]; then
    return 1
  else
    return 0
  fi
}

function isCurlInstalled () {
  CURL_EXE=curl
  if ! isInstalled ${CURL_EXE}; then
    echoError "The ${CURL_EXE} executable is required and was not found on your path."
    echoError "If your shell of choice doesn't come with curl preinstalled, try installing it using either [Homebrew](https://brew.sh/) (MAC) or [Chocolatey](https://chocolatey.org/) (Windows)."
    exit 1
  fi
}

function isJQInstalled () {
  JQ_EXE=jq
  if ! isInstalled ${JQ_EXE}; then
    echoError "The ${JQ_EXE} executable is required and was not found on your path."
    echoError "Installation instructions can be found here: https://stedolan.github.io/jq/download"
    echoError "Alternatively, a package manager such as Chocolatey (Windows) or Brew (Mac) can be used to install this dependecy."
    exit 1
  fi
}

function getParentDid() {
  did=${1}
  result=$(${CURL_EXE} \
          -s \
          -X GET \
          -H "accept: application/json" \
          "https://indyscan.io/api/networks/SOVRIN_MAINNET/ledgers/domain/txs?filterTxNames=%5B%22NYM%22%5D&format=full&search=${did}&size=1&skip=0&sortFromRecent=false")

    fromDid=$(${JQ_EXE} -nr "${result} | .[0].idata.expansion.idata.txn.metadata.from")
    role=$(${JQ_EXE} -nr "${result} | .[0].idata.expansion.idata.txn.data.role?")

    echo -e "${did}\t${fromDid}\t${role}"
}

isCurlInstalled
isJQInstalled

# getParentDid "Y8Ucwwts7w3CgGrakvuw3t"


didList="./list.txt"
while read -r item; do
  getParentDid ${item}
done < ${didList}
