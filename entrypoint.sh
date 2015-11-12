#!/bin/bash
set -e

if [ "$ROOT_USER" = "true" ]
then
  exec "$@"
else
  exec gosu git "$@"
fi
