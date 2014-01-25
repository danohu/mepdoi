#! /bin/bash

DIR="$( cd "$( dirname "$0" )" && pwd )" 

cd $DIR 
mkdir -p tmp

wget "http://parltrack.euwiki.org/meps/?format=json" --output-document=tmp/ep_meps_current.json


