# Easy Kolide Fleet
Easy docker-compose deployment of Kolide Fleet (https://kolide.com/fleet) for osquery centralized management

To simplify the turn up I also created a basic setup.sh bash script to create the necessary directories, generate the self signed ssl certificate, and create the .env files based on user input.  The .env files are utilized in the docker-compose.yml to tie all the services together and quickly turn up new kolide fleet deployments.

This uses the stock containers for kolide/fleet, mysql:latest, and redis:alpine to create an instant Kolide fleet deployment.

**Warning:** This has not been tested in a production deployment (yet!).

### Dependencies
```bash
bash
docker
docker-compose
```

### Quick start
```bash
git clone https://github.com/landonc/easy-kolide-fleet.git
cd easy-kolide-fleet
bash setup.sh
sudo docker-compose up -d
```

It takes about 2min to initialize the database and start all the containers the first time.  Once the fleet container is started you can access the fleet web interface at https://yourdockerserver/ and go through the setup process.

### Overview of running folder structure
```bash
kolide-fleet-docker
├── docker-compose.yml
├── fleet.env # created by setup.sh
├── fleet_tmp # created by setup.sh
│   ├── osquery_result # created by fleet for results of scheduled queries, should be log forwarded
│   ├── osquery_status # created by fleet
│   ├── server.cert # created by setup.sh for osquery and kolide fleet website
│   └── server.key # created by setup.sh for osquery and kolide fleet website
├── mysql_data # created by setup.sh
│   ├── # lots of files/folders created by the mysql container
├── mysql.env # created by setup.sh
└── setup.sh
```

To keep from passing all environment variables to all containers with a single .env or having to manage them in the docker-compose.yml I am using separate .env files for each service/container.  The .env files are created via setup.sh, if you would like to manually create them, here are examples of the contents.

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
