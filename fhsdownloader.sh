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
# 02-12-2022    Bitwise - Zahid Khan         Release-1 development
#ALL Functions

extract_base_filename() {
  local full_path="$1"
  local base_filename

  # Ensure that the input is a non-empty string
  if [ -z "$full_path" ]; then
    echo "Error: Empty filename passed." >&2
    return 1
  fi

  base_filename=$(basename "$full_path")
  echo "$base_filename"
  return 0
}

make_custom_filename() {
  local filename="$1"
  local expected_file_type="$2"
  # Split the filename into base and extension(s)
  base="$(echo "$filename" | sed -E 's/\.([^\.]+)$//')"
  extension="$(echo "$filename" | grep -oE '[^\.]+$')"

  local new_filename="${base}_${expected_file_type}.${extension}"

  echo "$new_filename"
}

download_file() {
  local local_directory_path="C:\Users\Zahidk\Desktop\Taas\File Processing\fhs_subscription\files"
  local gcs_directory_path="gs://pid-gousenaid-eaei-tokn-01-file-processing/output/"
  local filename=$(extract_base_filename "$1")
  local gt_file_name
  local mt_file_name
  local et_file_name

  # INITIALIZATION #
  mt_file_name=$(make_custom_filename "$filename" "MT")
  et_file_name=$(make_custom_filename "$filename" "ET")
  gt_file_name=$(make_custom_filename "$filename" "GT")

  # Download the files#
  echo "Downloading the file ${gt_file_name}"
  gsutil cp "${gcs_directory_path}${gt_file_name}" "${local_directory_path}"

  echo "Downloading the file ${mt_file_name}"
  gsutil cp "${gcs_directory_path}${mt_file_name}" "${local_directory_path}"

  echo "Downloading the file ${local_directory_path}"
  gsutil cp "${gcs_directory_path}${et_file_name}" "${local_directory_path}"
}

listen_pubsub_events() {
  # Constants
  local PROJECT_ID="pid-gousenaid-eaei-tokn-01"
  local SUBSCRIPTION_NAME="projects/pid-gousenaid-eaei-tokn-01/subscriptions/taas-output-file-processor-fhs-subscription"

  # Listen to events from the subscription
  ACKNOWLEDGED=0
#  MESSAGE_TRY_COUNT=$(gcloud pubsub subscriptions pull $SUBSCRIPTION_NAME --project $PROJECT_ID --format='value(publishTime)')
#  MESSAGE_TRY_COUNT=$(echo "$MESSAGE_TRY_COUNT" | wc -l)
#
#  echo "Number of messages are : ${MESSAGE_TRY_COUNT}"
#
  MESSAGE_TRY_COUNT=1
  while [ $ACKNOWLEDGED -lt "$MESSAGE_TRY_COUNT" ]; do
    MESSAGE=$(gcloud beta pubsub subscriptions pull $SUBSCRIPTION_NAME --auto-ack --wait --limit=1 )
    if [ "$MESSAGE" ]; then
      echo "Received message: $MESSAGE"
      echo "$MESSAGE"

      name_with_directory_path=$(echo "$MESSAGE" | grep '"name"' | cut -d '"' -f4)
      echo "Filename is : $name_with_directory_path"
      download_file "$name_with_directory_path"
    else
      echo "No message in the PUBSUB."
    fi
    ((ACKNOWLEDGED++))
    sleep 1
  done
}
main() {
  if [ -z "$TEST_EXECUTION" ]; then
    echo "Started listening pubsub events."
    listen_pubsub_events
    echo "Exited successfully."
  fi
}
main
