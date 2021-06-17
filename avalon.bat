@echo off

set CURL=C:\WINDOWS\system32\curl.exe
set POWERSHELL=C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe
set GENESIS_DIR=mongo_seed\genesis
set GENESIS_URL=https://testnet-api.oneloved.tube/genesis.zip
set SNAPSHOT_URL=https://backup.d.tube/$(date +%H).tar.gz
set MONGODB_DIR=db

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
        echo Downloading genesis block.
        %CURL% -o .\genesis.zip %GENESIS_URL%
        echo unzipping genesis.zip
        %POWERSHELL% Expand-Archive .\genesis.zip -DestinationPath .\
    :ok
        echo Genesis block exists
    cd ../..
    echo Building avalon docker images ...
    docker-compose build
    echo Checking genesis block ...
    docker-compose up mongo-seed
    echo Starting avalon node ...
    docker-compose up
exit

:DROP
    echo Dropping avalan database ...
    docker-compose run mongo-seed sh -c "/wait && chmod +x drop.sh && ./drop.sh"
exit

:DELETE
    echo Stopping avalon node.
    set MONGO=avalon_mongo
    set MONGO_EXPRESS=avalon_mongo_express
    set MONGO_SEED=avalon_mongo_seed
    set AVALON=avalon
    
    docker stop %MONGO% %MONGO_EXPRESS% %MONGO_EXPRESS% %MONGO_SEED% %AVALON%
    
    echo Removing all stopped containers.
    docker rm -f %MONGO% %MONGO_EXPRESS% %MONGO_EXPRESS% %MONGO_SEED% %AVALON%

    echo Removing avalon docker network.
    docker network rm avalon_net

    echo Removing avalon node docker images.
    docker rmi -f avalon
    docker rmi -f avalon_mongo_seed

    echo Removing MongoDB databases.
    cd %MONGODB_DIR%
    RMDIR "mongo" /S /Q
    MD mongo
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
    set MONGO=avalon_mongo
    set MONGO_EXPRESS=avalon_mongo_express
    set MONGO_SEED=avalon_mongo_seed
    set AVALON=avalon
    
    docker stop %MONGO% %MONGO_EXPRESS% %MONGO_EXPRESS% %MONGO_SEED% %AVALON%
exit
