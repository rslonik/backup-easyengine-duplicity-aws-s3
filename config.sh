#!/bin/bash
# Export some ENV variables so you don't have to type anything

export AWS_ACCESS_KEY_ID="[key]"
export AWS_SECRET_ACCESS_KEY="[secret]"

MAILADDR="my@email.com"

# The S3 destination followed by bucket name
# Ex: s3://s3.amazonaws.com/my-little-bucket/
DEST="s3://s3.amazonaws.com/my-bucket/"
SOURCE=/
