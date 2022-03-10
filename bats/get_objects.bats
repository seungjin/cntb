#!/usr/bin/env bats

load handling_conf_files.bash
load globals.bash
load cleanup-object-storage.bash
load_lib bats-support
load_lib bats-assert

function setup_file() {
    store_config_files
    ensureTestConfig
    deleteCache
}

function teardown_file() {
    restore_config_files
}

@test 'get objects : ok' {
  if [ ${INT_ENVIRONMENT} == 'test' ]; then
    skip "Skip: test env has no CMS backend"
  fi

  deleteObjectStorageIfExisting "EU"
  sleep 5
  run ./cntb create objectStorage --region "EU" --totalPurchasedSpaceTB 1 --scalingState "enabled" --scalingLimitTB 1
  assert_success

  run ./cntb create bucket EU ${TEST_SUFFIX}
  assert_success

  run ./cntb create object --region "EU" --bucket ${TEST_SUFFIX} --prefix '/test/${TEST_SUFFIX}'
  assert_success

  run ./cntb get objects --region "EU" --bucket ${TEST_SUFFIX}
  assert_success
  assert_output --partial 'NAME'
  assert_output --partial 'SIZE'
  assert_output --partial 'LASTMODIFIED'

  deleteObjectStorageIfExisting "EU"
}

@test 'get objects : nok : missing arguments' {
  if [ ${INT_ENVIRONMENT} == 'test' ]; then
      skip "Skip: test env has no CMS backend"
  fi

  run ./cntb get objects --bucket ${TEST_SUFFIX}
  assert_failure
  assert_output --partial 'Argument region is empty.'

  run ./cntb get objects --region "EU"
  assert_failure
  assert_output --partial 'Argument bucket is empty.'
}
