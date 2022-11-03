TEST_NAME_PREFIX='Dovecot protocols:'
CONTAINER_NAME='dummy'
CONTAINER_NAME_ALL='dms-test-dovecot_protocols_all'
CONTAINER_NAME_IPV4='dms-test-dovecot_protocols_ipv4'
CONTAINER_NAME_IPV6='dms-test-dovecot_protocols_ipv6'

load "${REPOSITORY_ROOT}/test/helper/setup"
load "${REPOSITORY_ROOT}/test/helper/common"

function setup_file() {
  CONTAINER_NAME=${CONTAINER_NAME_ALL}
  init_with_defaults
  local CUSTOM_SETUP_ARGUMENTS=(--env DOVECOT_INET_PROTOCOLS=)
  common_container_setup 'CUSTOM_SETUP_ARGUMENTS'

  CONTAINER_NAME=${CONTAINER_NAME_IPV4}
  init_with_defaults
  local CUSTOM_SETUP_ARGUMENTS=(--env DOVECOT_INET_PROTOCOLS=ipv4)
  common_container_setup 'CUSTOM_SETUP_ARGUMENTS'

  CONTAINER_NAME=${CONTAINER_NAME_IPV6}
  init_with_defaults
  local CUSTOM_SETUP_ARGUMENTS=(--env DOVECOT_INET_PROTOCOLS=ipv6)
  common_container_setup 'CUSTOM_SETUP_ARGUMENTS'
}

@test "${TEST_NAME_PREFIX} dual-stack IP configuration" {
  run docker exec "${CONTAINER_NAME_ALL}" grep '^#listen = \*, ::' /etc/dovecot/dovecot.conf
  assert_success
  assert_output '#listen = *, ::'
}

@test "${TEST_NAME_PREFIX} IPv4 configuration" {
  run docker exec "${CONTAINER_NAME_IPV4}" grep '^listen = \*$' /etc/dovecot/dovecot.conf
  assert_success
  assert_output 'listen = *'
}

@test "${TEST_NAME_PREFIX} IPv6 configuration" {
  wait_for_finished_setup_in_container 'dms-test-dovecot_protocols_ipv6'
  run docker exec "${CONTAINER_NAME_IPV6}" grep '^listen = \[::\]$' /etc/dovecot/dovecot.conf
  assert_success
  assert_output 'listen = [::]'
}

function teardown_file {
  docker rm -f "${CONTAINER_NAME_ALL}" "${CONTAINER_NAME_IPV4}" "${CONTAINER_NAME_IPV6}"
}
