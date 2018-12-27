# kolide-fleet-docker
Easy docker-compose deployment of Kolide Fleet for osquery centralized management

After spending time working with the different options that already existed to quickly turn up a kolide fleet deployment using docker I found it was easier to work out all the kinks and build a docker-compose deployment.  To simplify the turn up I also created a simple setup.sh bash script to generate the self signed ssl certificate and create the .env files utilized in the docker-compose.yml.

This uses the stock containers for kolide/fleet, mysql:latest, and redis:alpine to create an instant Kolide fleet deployment.  This has not been tested at scale but the immediate components that should easily scale are redis and kolide/fleet.

### Quick start
```bash
git clone CLONEURLHERE
cd kolide-fleet-docker
bash setup.sh
sudo docker-compose up
```

### Overview of running folder structure
```bash
kolide-fleet-docker
├── docker-compose.yml
├── fleet.env # created by setup.sh
├── fleet_tmp # created by setup.sh
│   ├── osquery_result # created by fleet for results of scheduled queries, should be log forwarded
│   ├── osquery_status
│   ├── server.cert # created by setup.sh
│   └── server.key # created by setup.sh
├── mysql_data # created by setup.sh
│   ├── # lots of files/folders created by the mysql container
├── mysql.env # created by setup.sh
└── setup.sh
```

To keep from unnecessaryily passing all environment variables to all containers with a single .env or having to modify them in docker-compose.yml I am using separate .env files for each service/container.  The .env files are created via setup.sh, if you would like to manually create them, here are examples of the contents.

### redis.env contents
```bash
REDIS_PASSWORD=YOUR_REDIS_PASSWORD
```

### mysql.env contents
```bash
MYSQL_ROOT_PASSWORD=YOUR_MYSQL_ROOT_PASSWORD
MYSQL_DATABASE=kolide
MYSQL_USER=kolide
MYSQL_PASSWORD=YOUR_MYSQL_KOLIDE_PASSWORD
```

### fleet.env contents
```bash
KOLIDE_MYSQL_ADDRESS=mysql:3306
KOLIDE_MYSQL_DATABASE=kolide
KOLIDE_MYSQL_USERNAME=kolide
KOLIDE_MYSQL_PASSWORD=YOUR_MYSQL_KOLIDE_PASSWORD
KOLIDE_REDIS_ADDRESS=redis:6379
KOLIDE_REDIS_PASSWORD=YOUR_REDIS_PASSWORD
KOLIDE_SERVER_ADDRESS=0.0.0.0:443
KOLIDE_SERVER_CERT=/tmp/server.cert
KOLIDE_SERVER_KEY=/tmp/server.key
KOLIDE_LOGGING_JSON=true
KOLIDE_AUTH_JWT_KEY=YOUR_UNIQUE_GENERATED_JWT_TOKEN
```
