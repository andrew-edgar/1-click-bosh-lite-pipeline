#!/bin/bash -e

. 1-click/tasks/bosh-login.sh

bosh2 -n clean-up --all
