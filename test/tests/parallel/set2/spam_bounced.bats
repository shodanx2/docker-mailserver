TEST_NAME_PREFIX='spam (Amavis):'
CONTAINER_NAME='dms-test-spam_bounced'

load "${REPOSITORY_ROOT}/test/helper/setup"
load "${REPOSITORY_ROOT}/test/helper/common"

function setup_file() {
  init_with_defaults

  local CUSTOM_SETUP_ARGUMENTS=(
    --env ENABLE_AMAVIS=1
    --env ENABLE_SPAMASSASSIN=1
    --env PERMIT_DOCKER=container
    --env SPAMASSASSIN_SPAM_TO_INBOX=0
  )

  common_container_setup 'CUSTOM_SETUP_ARGUMENTS'
  wait_for_smtp_port_in_container_to_respond "${CONTAINER_NAME}"
}

function teardown_file() { _default_teardown ; }

@test "${TEST_NAME_PREFIX} spam message is bounced (rejected)" {
  # send a spam message
  _run_in_container /bin/sh -c "nc 0.0.0.0 25 < /tmp/docker-mailserver-test/email-templates/amavis-spam.txt"
  assert_success

  # message will be added to a queue with varying delay until amavis receives it
  run repeat_until_success_or_timeout 60 sh -c "docker logs ${CONTAINER_NAME} | grep 'Blocked SPAM {NoBounceInbound,Quarantined}'"
  assert_success
}
