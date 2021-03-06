#!/bin/bash

# =============================== ENVIRONMENT ================================ #

if [[ ${1} ]]; then
  cmd="${1}"
else
  echo 1>&2 "execute tests-cli.sh to run all tests"; exit 1
fi

t="$(basename "${BASH_SOURCE[0]}" .sh)"
cd "${BASH_SOURCE%/*}/" || exit 1
mkdir -p "tmp/${t}"

# =================================== DATA =================================== #

cat << "DATA" > "tmp/${t}/${t}.csv"
email,name,state,gender,purchase
danny.baron@example1.com,Danny Baron,CA,M,TV
melanie.white@example2.edu,Melanie White,NC,F,iPhone
danny.baron@example1.com,D. Baron,CA,M,Winter jacket
ben.tyler@example3.org,Ben Tyler,NV,M,Flashlight
arthur.duff@example4.com,Arthur Duff,OR,M,Dining table
danny.baron@example1.com,Daniel Baron,CA,M,Bike
jean.griffith@example5.org,Jean Griffith,WA,F,Power drill
melanie.white@example2.edu,Melanie White,NC,F,iPad
ben.morisson@example6.org,Ben Morisson,FL,M,Amplifier
arthur.duff@example4.com,Arthur Duff,OR,M,Night table
DATA

# ================================= ASSERTION ================================ #

cat << "DATA" > "tmp/${t}/${t}.assert"
{ "events" : [
    { "name" : "Melanie White", "purchase" : "iPhone" },
    { "name" : "Jean Griffith", "purchase" : "Power drill" },
    { "name" : "Melanie White", "purchase" : "iPad" }
] }
DATA

# ================================== ACTION ================================== #

${cmd} --create "tmp/${t}/${t}.csv"
${cmd} --export "${t}" \
--prefix '{ "events" : [
' \
--template '    { "name" : {{jsonize(cells["name"].value)}}, "purchase" : {{jsonize(cells["purchase"].value)}} }' \
--rowSeparator ',
' \
--suffix '
] }
' \
--facets '{"type":"list","name":"gender","columnName":"gender","expression":"value","omitBlank":false,"omitError":false,"selection":[{"v":{"v":"F","l":"F"}}],"selectBlank":false,"selectError":false,"invert":false}' \
--output "tmp/${t}/${t}.output"

# =================================== TEST =================================== #

diff -u "tmp/${t}/${t}.assert" "tmp/${t}/${t}.output"
