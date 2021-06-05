#!/bin/bash

BUILD="build"
DROP="drop"
DELETE="delete"
LOG="log"
START="start"
STOP="stop"

if [ "$#" -eq 0 ] || [ $1 = "-h" ] || [ $1 = "--help" ]; then
    echo "Usage: ./avalon.sh [OPTIONS] COMMAND [arg...]"
    echo "       ./avalon.sh [ -h | --help ]"
    echo ""
    echo "Options:"
    echo "  -h, --help    Prints usage."
    echo ""
    echo "Commands:"
    echo "  $BUILD      - Build and Run avalon node."
    echo "  $DROP       - Remove MongoDB avalon database."
    echo "  $DELETE     - Delete avalon node."
    echo "  $LOG        - Display the avalon docker container log."
    echo "  $START      - Start avalon node in background."
    echo "  $STOP       - Stop avalon node."
    exit
fi

drop() {
    drop_mongo_db
}

delete() {
    stop_existing
    remove_stopped_containers
    remove_unused_volumes
    remove_avalon_network
    remove_avalon_node_images
    remove_mongo_db
}

log() {
    docker-compose logs -f avalon
}

build() {
    echo "Running Avalon Node."
    echo "Checking genesis block ..."
    FILE=$PWD/mongo_seed/genesis/genesis.zip
    if [ -f "$FILE" ]; then
        echo "Genesis block exists."
    else 
        echo "Downloading genesis block."
        wget https://backup.d.tube/genesis.zip -P $PWD/mongo_seed/genesis
        cd mongo_seed/genesis
        unzip genesis.zip
        cd ../..
    fi

    # Build & Run the avalon node
    docker-compose build
    echo "Starting avalon node ..."
    docker-compose up mongo-seed
    docker-compose up
}

start() {
    echo "Running Avalon Node."
    echo "Checking genesis block ..."
    FILE=$PWD/mongo_seed/genesis/genesis.zip
    if [ -f "$FILE" ]; then
        echo "Genesis block exists."
    else 
        echo "Downloading genesis block."
        wget https://backup.d.tube/genesis.zip -P $PWD/mongo_seed/genesis
        cd mongo_seed/genesis
        unzip genesis.zip
        cd ../..
    fi
    # Run docker in background
    docker-compose up mongo-seed
    docker-compose up -d
}

drop_mongo_db() {
    echo "Dropping avalan database ..."
    docker-compose run mongo-seed sh -c "/wait && chmod +x drop.sh && ./drop.sh"
}

remove_mongo_db() {
    # Check for mongodb exisits 
    if [ -d "$PWD/db/mongo/journal" ] 
    then
        echo "MongoDB database removed" 
        $(rm -r $PWD/db/mongo/*)
    else
        echo "Error: MongoDB database does not exists."
    fi
}

stop_existing() {
    echo "Stopping avalon node."
    MONGO="$(docker ps --all --quiet --filter=name=avalon_mongo)"
    MONGO_EXPRESS="$(docker ps --all --quiet --filter=name=avalon_mongo_express)"
    MONGO_SEED="$(docker ps --all --quiet --filter=name=avalon_mongo_seed)"
    AVALON="$(docker ps --all --quiet --filter=name=avalon)"

    if [ -n "$MONGO" ]; then
        docker stop $MONGO
    fi

    if [ -n "$MONGO_EXPRESS" ]; then
        docker stop $MONGO_EXPRESS
    fi

    if [ -n "$MONGO_SEED" ]; then
        docker stop $MONGO_SEED
    fi

    if [ -n "$AVALON" ]; then
        docker stop $AVALON
    fi
}

remove_stopped_containers() {
    CONTAINERS="$(docker ps -a -f status=exited -q)"
    if [ ${#CONTAINERS} -gt 0 ]; then
        echo "Removing all stopped containers."
        docker rm $MONGO
        docker rm $MONGO_EXPRESS
        docker rm $MONGO_SEED
        docker rm $AVALON   
    else
        echo "There are no stopped containers to be removed."
    fi
}

remove_avalon_network() {
    docker network rm avalon_net
}

remove_unused_volumes() {
    CONTAINERS="$(docker volume ls -qf dangling=true)"
    if [ ${#CONTAINERS} -gt 0 ]; then
        echo "Removing all unused volumes."
        docker volume rm $CONTAINERS
    else
        echo "There are no unused volumes to be removed."
    fi
}

remove_avalon_node_images() {
    echo "Removing avalon node docker images."
    docker rmi avalon
    docker rmi avalon_mongo_seed
}

if [ $1 = $BUILD ]; then
    build
    exit
fi

if [ $1 = $DROP ]; then
    drop
    exit
fi

if [ $1 = $DELETE ]; then
    delete
    exit
fi

if [ $1 = $LOG ]; then
    log
    exit
fi

if [ $1 = $START ]; then
    start
    exit
fi

if [ $1 = $STOP ]; then
    stop_existing
    exit
fi