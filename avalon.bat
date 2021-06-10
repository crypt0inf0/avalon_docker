@echo off

set CURL=C:\WINDOWS\system32\curl.exe
set POWERSHELL=C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe
set GENESIS_DIR=avalon_docker\mongo_seed\genesis
set GENESIS_URL=https://codeload.github.com/crypt0inf0/avalon_docker/zip/refs/heads/master
set SNAPSHOT_URL=https://backup.d.tube/$(date +%H).tar.gz
set MONGODB=mongo_seed
:GETOPTS
if /I "%1" == "-h" goto HELP
if /I "%1" == "build" goto BUILD
if /I "%1" == "drop" goto DROP
if /I "%1" == "delete" goto DELETE
if /I "%1" == "log" goto LOG
if /I "%1" == "start" goto START
if /I "%1" == "restart" goto RESTART
if /I "%1" == "stop" goto STOP
shift
if not "%1" == "" goto GETOPTS
goto HELP
exit

:HELP
    echo Usage: .\avalon.bat [OPTIONS] COMMAND [arg...]
    echo        .\avalon.bat [ -h ]
    echo Options:
    echo   -h           Prints usage.
    echo Commands:
    echo   build      - Build and Run avalon node.
    echo   drop       - Remove MongoDB avalon database.
    echo   delete     - Delete avalon node.
    echo   log        - Display the avalon docker container log.
    echo   start      - Start avalon node in background.
    echo   restart    - Restart avalon node in background.
    echo   stop       - Stop avalon node.
exit

:BUILD
    cd %GENESIS_DIR%
    echo checking genesis block ...
    if exist "genesis.zip" (
          goto :ok
    ) else goto :download

    :download
        echo downloading missing files.
        %CURL% -o .\genesis.zip %GENESIS_URL%
        echo unzipping genesis.zip
        %POWERSHELL% Expand-Archive .\genesis.zip -DestinationPath .\
    :ok
        echo Genesis block exists
    cd ../..
    echo Building avalon docker images ...
    %POWERSHELL% Start-Sleep -s 5
    docker-compose build
    echo Starting avalon node ...
    docker-compose up mongo-seed
    docker-compose up
exit

:DROP
    docker start mongo_avalon
    echo "Dropping avalan database ..."
    %POWERSHELL% Start-Sleep -s 5
    docker exec -it mongo_avalon sh -c 'echo "db.dropDatabase()" | mongo avalon'
exit

:DELETE
    echo Stopping avalon node.
    set MONGO=docker ps --all --quiet --filter=name=avalon_mongo
    set MONGO_EXPRESS=docker ps --all --quiet --filter=name=avalon_mongo_express
    set MONGO_SEED=docker ps --all --quiet --filter=name=avalon_mongo_seed
    set AVALON=docker ps --all --quiet --filter=name=avalon
    
    docker stop %MONGO% %MONGO_EXPRESS% %MONGO_EXPRESS% %MONGO_SEED% %AVALON%
    
    echo Removing all stopped containers.
    docker rm %MONGO% %MONGO_EXPRESS% %MONGO_EXPRESS% %MONGO_SEED% %AVALON%

    echo Removing avalon docker network.
    docker network rm avalon_net

    echo Removing avalon node docker images.
    docker rmi avalon
    docker rmi avalon_mongo_seed

    echo Removing MongoDB databases.
    cd %MONGODB%
    RMDIR "db" /S /Q
    MD db
    cd ../..
exit

:LOG
    echo Avalon node log.
    docker-compose logs -f avalon
exit

:START   
    echo Checking genesis block ...
    docker-compose up mongo-seed
    echo Starting avalon node in background.
    docker-compose up -d
exit

:RESTART   
    echo Restarting avalon node ...
    docker-compose down
    echo Checking genesis block ...
    docker-compose up mongo-seed
    echo Starting avalon node in background.
    docker-compose up -d
exit

:STOP
    echo Stopping avalon node.
    set MONGO=docker ps --all --quiet --filter=name=avalon_mongo
    set MONGO_EXPRESS=docker ps --all --quiet --filter=name=avalon_mongo_express
    set MONGO_SEED=docker ps --all --quiet --filter=name=avalon_mongo_seed
    set AVALON=docker ps --all --quiet --filter=name=avalon
    
    docker stop %MONGO% %MONGO_EXPRESS% %MONGO_EXPRESS% %MONGO_SEED% %AVALON%
exit