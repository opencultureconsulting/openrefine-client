#!/bin/bash

# =============================== ENVIRONMENT ================================ #

if [[ ${1} ]]; then
  cmd="${1}"
else
  echo 1>&2 "execute tests-cli.sh to run all tests"; exit 1
fi
if [[ ${2} ]]; then
  version="${2}"
fi

t="$(basename "${BASH_SOURCE[0]}" .sh)"
cd "${BASH_SOURCE%/*}/" || exit 1
mkdir -p "tmp/${t}"

# =================================== DATA =================================== #

cp "data/example.xls" "tmp/${t}/${t}.xls"

# ================================= ASSERTION ================================ #

if [[ "${version}" = "2.7" ]]; then
  cat << "DATA" > "tmp/${t}/${t}.assert"
⌨	code	meaning
⛲	1F347	FOUNTAIN
⛳	1F349	FLAG IN HOLE
⛵	1F352	SAILBOAT
DATA
else
  #TODO
  echo "https://github.com/opencultureconsulting/openrefine-client/issues/4"
  exit 200
fi

# ================================== ACTION ================================== #

${cmd} --create "tmp/${t}/${t}.xls" --sheets 1
${cmd} --export "${t}" --output "tmp/${t}/${t}.output"

# =================================== TEST =================================== #

diff -u "tmp/${t}/${t}.assert" "tmp/${t}/${t}.output"
