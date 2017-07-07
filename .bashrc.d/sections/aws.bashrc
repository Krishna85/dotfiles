#!/bin/bash

# Add autocomplete for AWS cli
complete -C aws_completer aws
export AWS_DEFAULT_REGION=us-east-1
