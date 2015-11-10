#!/bin/bash
set -e

exec gosu git "$@"
