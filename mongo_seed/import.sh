#!/bin/bash

if [ $(mongo mongo:27017 --eval 'db.getMongo().getDBNames().indexOf("avalon")' --quiet) -lt 0 ]; then
    $(cd genesis && mongorestore --host mongo -d avalon ./)
else
    echo "avalon db exists"
fi