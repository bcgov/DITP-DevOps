#!/bin/bash
set -e

TEST_HOME="$(cd "$(dirname "$0")" && pwd)"
MANAGE_SCRIPT="${TEST_HOME}/../manage"
bash -n "${MANAGE_SCRIPT}"
source <(sed '/^pushd ${SCRIPT_HOME}/,$d' "${MANAGE_SCRIPT}")
JQ_EXE=jq
CURL_EXE=mockCurl
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

mockCurl() {
  local method=GET url="" query="" payload="" argument
  while (( $# )); do
    argument=$1
    shift
    case "${argument}" in
      -X) method=$1; shift ;;
      -H) shift ;;
      --data) payload=$1; shift ;;
      --data-urlencode) query="${query} $1"; shift ;;
      http*) url=${argument} ;;
    esac
  done
  printf '%s %s %s\n' "${method}" "${url}" "${query}" >> "${work}/requests"
  case "${url}" in
    */token) printf '{"token_type":"Bearer","access_token":"mock"}' ;;
    */clients) printf '[{"id":"client-uuid","clientId":"application"}]' ;;
    */roles/reviewer) printf '{"id":"role-uuid","name":"reviewer"}' ;;
    */users)
      [[ "${query}" == *exact=true* ]] || return 99
      case "${query}" in
        *username=existing@example.com*) printf '[{"id":"existing","username":"existing@example.com"}]' ;;
        *username=new+user@example.com*) printf '[{"id":"new","username":"new+user@example.com"}]' ;;
        *username=failed@example.com*) printf '[{"id":"failed","username":"failed@example.com"}]' ;;
        *username=missing@example.com*) printf '[]' ;;
        *username=lookup-error@example.com*) return 22 ;;
        *username=malformed@example.com*) printf '{"error":"unexpected"}' ;;
        *username=ambiguous@example.com*) printf '[{"id":"first","username":"ambiguous@example.com"},{"id":"second","username":"ambiguous@example.com"}]' ;;
        *) return 99 ;;
      esac ;;
    */existing/role-mappings/*/composite) printf '[{"id":"role-uuid","name":"reviewer"}]' ;;
    */new/role-mappings/*/composite|*/failed/role-mappings/*/composite) printf '[]' ;;
    */new/role-mappings/*)
      [[ "${method}" == POST ]] || return 99
      printf '%s' "${payload}" | jq -e 'length == 1 and .[0].id == "role-uuid"' >/dev/null ;;
    */failed/role-mappings/*) return 22 ;;
    *) return 99 ;;
  esac
}

for scope in realm client; do
  mkdir "${work}/${scope}"
  printf 'existing@example.com\r\n\r\nnew+user@example.com\r\nfailed@example.com\r\nmissing@example.com' > "${work}/${scope}/users.txt"
  : > "${work}/requests"
  roleClient=""
  if [[ "${scope}" == client ]]; then
    roleClient=application
  fi
  status=0
  assignRole https://keycloak.example test 'Authorization: Bearer mock' reviewer \
    "${work}/${scope}/users.txt" "${roleClient}" > "${work}/${scope}/summary" || status=$?
  [[ "${status}" == 1 ]]
  result=$(find "${work}/${scope}" -type d -name 'assignRole-*')
  [[ $(find "${result}" -type f | wc -l) == 3 ]]
  [[ $(cat "${result}"/success-*.txt) == $'existing@example.com\nnew+user@example.com' ]]
  [[ $(cat "${result}"/failure-*.txt) == failed@example.com ]]
  [[ $(cat "${result}"/not-found-*.txt) == missing@example.com ]]
  grep -q '^Total users: 4$' "${work}/${scope}/summary"
  grep -q '^Success: 2$' "${work}/${scope}/summary"
  grep -q '^Failure: 1$' "${work}/${scope}/summary"
  grep -q '^Not found: 1$' "${work}/${scope}/summary"
  [[ $(grep -c '^POST ' "${work}/requests") == 2 ]]
  ! grep -q '^POST .*existing/' "${work}/requests"
  if [[ "${scope}" == client ]]; then
    grep -q '/role-mappings/clients/client-uuid' "${work}/requests"
  else
    grep -q '/role-mappings/realm' "${work}/requests"
  fi
  printf 'PASS: %s role, no-op, classification, summary, CRLF, unterminated final line\n' "${scope}"
done

mkdir "${work}/all-success"
printf 'existing@example.com\nnew+user@example.com\n' > "${work}/all-success/users.txt"
for run in first second; do
  assignRole https://keycloak.example test 'Authorization: Bearer mock' reviewer \
    "${work}/all-success/users.txt" '' > "${work}/all-success/${run}-summary"
  grep -q '^Success: 2$' "${work}/all-success/${run}-summary"
done
[[ $(find "${work}/all-success" -type d -name 'assignRole-*' | wc -l) == 2 ]]
printf 'PASS: all-success return code and unique output sets for repeated runs\n'

for user in lookup-error malformed ambiguous; do
  mkdir "${work}/${user}"
  printf '%s@example.com\nnew+user@example.com\n' "${user}" > "${work}/${user}/users.txt"
  status=0
  assignRole https://keycloak.example test 'Authorization: Bearer mock' reviewer \
    "${work}/${user}/users.txt" '' > "${work}/${user}/summary" 2>/dev/null || status=$?
  [[ "${status}" == 1 ]]
  grep -q '^Unprocessed: 2$' "${work}/${user}/summary"
  result=$(find "${work}/${user}" -type d -name 'assignRole-*')
  [[ $(cat "${result}"/*.txt | wc -l) == 0 ]]
  printf 'PASS: %s lookup stops without misclassifying users\n' "${user}"
done

curl() {
  mockCurl "$@"
}
export -f curl mockCurl
export work
mkdir "${work}/cli"
printf 'existing@example.com\nnew+user@example.com\n' > "${work}/cli/users.txt"
pushd "${work}" >/dev/null
clientId=service-account clientSecret=mock bash "${MANAGE_SCRIPT}" assignRole \
  https://keycloak.example test reviewer cli/users.txt application > "${work}/cli/summary"
popd >/dev/null
grep -q '^Success: 2$' "${work}/cli/summary"
[[ $(find "${work}/cli" -type d -name 'assignRole-*' | wc -l) == 1 ]]
printf 'PASS: command dispatcher, authentication, relative input path, and exit status\n'
