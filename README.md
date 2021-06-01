# avalon_docker

## Get avalon node running

#### Dependencies
* [Docker](https://docs.docker.com/engine/install/)
* [Docker compose](https://docs.docker.com/compose/install/) version [1.29.2](https://github.com/docker/compose/releases/tag/1.29.2), build 1110ad01

#### Run avalon node (Tested on ubuntu)
Start avalon node docker container with `sudo ./avalon.sh build`
```
avalon_docker$sudo ./avalon.sh -h
Usage: ./avalon.sh [OPTIONS] COMMAND [arg...]
       ./avalon.sh [ -h | --help ]

Options:
  -h, --help    Prints usage.

Commands:
  build      - Build and Run avalon node.
  drop       - Remove MongoDB avalon database.
  delete     - Delete avalon node.
  log        - Display the avalon docker container log.
  start      - Start avalon node in background.
  stop       - Stop avalon node.
```

### Tested on windows 10
#### Git clone avalon_docker
Open PowerShell & Run the following commands,
```
git clone https://github.com/crypt0inf0/avalon_docker.git
cd avalon_docker
```
#### Download genesis block
```
curl -o .\mongo_seed\genesis\genesis.zip https://backup.d.tube/genesis.zip
Expand-Archive .\mongo_seed\genesis\genesis.zip -DestinationPath .\mongo_seed\genesis
```

#### Run avalon node 
##### You will be an observer node by default.
Build avalon node images,
```
docker-compose build
```
Run avalon node (**Press `Ctrl+C` to stop**)

```
docker-compose up
```
OR

Run avalon node in background,
```
docker-compose up -d
```

To stop avalon node in background,
```
docker-compose down
```

To view docker avalon node log use (**Press `Ctrl+C` to exit**)
```
docker-compose logs -f avalon
```

#### Check Block explorer for current stats:
* Run by leader [brishtiteveja0595](https://d.tube/#!/c/brishtiteveja0595): [https://dtube.club/explorer/#/]
* Run by leader [fasolo97](https://d.tube/#!/c/fasolo97): [https://dtube.fso.ovh/explorer/#/]
* Run and created by leader [techcoderx](https://d.tube/#!/c/techcoderx): [https://blocks.oneloved.tube/]


#### Run avalon node as a leader

Once the avalon node sync completely, Now we can setup the leader node by executing the follwing command. 
```
docker exec avalon node src/cli enable-node YOUR_LEADER_PUB_KEY -M YOUR_USERNAME -K YOUR_PRIVATE_KEY
```
