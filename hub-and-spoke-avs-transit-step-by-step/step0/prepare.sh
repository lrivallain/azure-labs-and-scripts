#!/bin/bash

# This script will copu the files from the next step to the "current" folder

echo "Copying files from $(dirname $0) to current folder"
cp $(dirname $0)/*.tf* ../current/
cp -r $(dirname $0)/scripts ../current/