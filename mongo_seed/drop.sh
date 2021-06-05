#!/bin/bash

if [ "$(mongo mongo:27017 --eval 'db.getMongo().getDBNames().indexOf("avalon")' --quiet)" -lt 0 ]; then
    echo "avalon db does not exists"
else
    mongo avalon --host mongo --eval "db.dropDatabase()"
fi