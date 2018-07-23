#!/bin/bash

# set -o xtrace

print_usage(){
  echo "Usage: shadow_upload.sh <SECRET_KEY> <FOLDER_PATH>"
}

if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]];then
  print_usage
  exit 0;
fi

CREDENTIALS_URL=https://5vv2z6j3a7.execute-api.eu-west-2.amazonaws.com/prod
KEY=$1
FOLDER=$2

if [[ -z "$KEY" ]] || [[ -z "$FOLDER" ]]; then
  print_usage
  exit 1;
fi
MY_CURL=`which curl`
if [[ -z "$MY_CURL" ]]; then
  echo "curl utility is required to run this script"
  exit 1;
fi

response=`$MY_CURL --silent -H "x-api-key: $KEY" $CREDENTIALS_URL`
if [[ $response = *"forbidden"* ]];then
  echo "Access if forbidden. Check the correctness of the secret key or contact support."
  print_usage
  exit 1;
fi
if [[ $response != *"SESSION_TOKEN"* ]];then
  echo "Unable to get temporary credentials. Read the following message to figure out the root cause or contact support."
  $MY_CURL -verbose -H "x-api-key: $KEY" $CREDENTIALS_URL
  print_usage
  exit 1;
fi

ACCESS_KEY_ID=`echo -e "$response" | grep ACCESS_KEY_ID | sed 's/ACCESS_KEY_ID=//'`
SECRET_ACCESS_KEY=`echo -e "$response" | grep SECRET_ACCESS_KEY | sed 's/SECRET_ACCESS_KEY=//'`
SESSION_TOKEN=`echo -e "$response" | grep SESSION_TOKEN | sed 's/SESSION_TOKEN=//'`
UPLOAD_URL=`echo -e "$response" | grep URL | sed 's/URL=//'`

export AWS_ACCESS_KEY_ID=$ACCESS_KEY_ID; \
export AWS_SECRET_ACCESS_KEY=$SECRET_ACCESS_KEY; \
export AWS_SESSION_TOKEN=$SESSION_TOKEN; \
aws s3 cp --recursive $FOLDER $UPLOAD_URL
