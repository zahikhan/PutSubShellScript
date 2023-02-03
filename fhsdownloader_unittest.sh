#!/usr/bin/bash
#
#============================================================================
# Script Name:
# Description: Downloads processed files from the FHS Server.
#
#
# Command Line Arguments: None
#
# Exit or Return Codes: None
#
# Development History
#
# Environment : GCS Cloud Fusion - DEV
# ----------------------------------------------------------------
# 02-12-2022    Bitwise - Zahid Khan         Release-1 FILE PROCESSING Development.
export TEST_EXECUTION=1
. fhsdownloader.sh

# Define a function for testing
assert_equals() {
  expected_result="$1"
  actual_result="$2"

  if [ "$expected_result" = "$actual_result" ]; then
    echo "Test passed: $expected_result = $actual_result"
  else
    echo "Test failed: $expected_result != $actual_result"
  fi
}

# Call the function and test its output
result=$(extract_base_filename "/backup/filename.txt")
assert_equals "filename.txt" "$result"

result=$(extract_base_filename "/path/to/another_file.txt")
assert_equals "another_file.txt" "$result"


result=$(make_custom_filename "filename.txt" "gt")
assert_equals "filename_gt.txt" $result

result=$(make_custom_filename "filename.txt" "et")
assert_equals "filename_et.txt" $result

result=$(make_custom_filename "filename.txt" "mt")
assert_equals "filename_mt.txt" $result

result=$(make_custom_filename "CARD_EXTRACT_MT.MERCHANTID.TIMESTAMP.EXTENSION" "eT")
assert_equals "CARD_EXTRACT_MT.MERCHANTID.TIMESTAMP_eT.EXTENSION" $result

