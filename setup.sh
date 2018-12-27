#!/bin/bash

# create directories if they don't exist
if [ ! -d fleet_tmp ]; then
    mkdir fleet_tmp
fi

if [ ! -d mysql_data ]; then
    mkdir mysql_data
fi

# generate the tls key and cert if it doesn't exist
if [ ! -f fleet_tmp/server.key ]; then
    # generate the tls key
    openssl genrsa -out fleet_tmp/server.key
fi

if [ ! -f fleet_tmp/server.cert ]; then
    # generate the csr to self sign
    #openssl req -new -batch -key fleet_tmp/server.key -out server.csr
    openssl req -new -key fleet_tmp/server.key -out server.csr -subj "/O=Kolide"
    # generate the self signed certificate valid for 1 yr
    openssl x509 -req -days 365 -in server.csr -signkey fleet_tmp/server.key -out fleet_tmp/server.cert
fi

# cleanup the csr
if [ -f server.csr ]; then
    rm server.csr
fi

base64url() {
    base64 -w 0 | tr '+/' '-_' | tr -d '='
}

# generate simple "random" jwt token
rand_num=$(od  -An -N8 -tu8 < /dev/urandom |tr -d ' ')
jwt_header=$(echo -n '{"alg":"RS256","typ":"JWT"}' | base64url)
jwt_claims=$(echo -n '{"rnd":"'$rand_num'"}' | base64url)
jwt="${jwt_header}.${jwt_claims}"

echo "Mysql Root Password?"
read -s mysql_root_pass
echo "Mysql Kolide fleet user password?"
read -s mysql_kolide_pass
echo "Redis password?"
read -s redis_pass

# generate mysql.env file
cat <<EOF > mysql.env
MYSQL_ROOT_PASSWORD=$mysql_root_pass
MYSQL_DATABASE=kolide
MYSQL_USER=kolide
MYSQL_PASSWORD=$mysql_kolide_pass
EOF

# generate redis.env file
cat <<EOF > redis.env
REDIS_PASSWORD=$redis_pass
EOF

# generate fleet.env file
cat <<EOF > fleet.env
KOLIDE_MYSQL_ADDRESS=mysql:3306
KOLIDE_MYSQL_DATABASE=kolide
KOLIDE_MYSQL_USERNAME=kolide
KOLIDE_MYSQL_PASSWORD=$mysql_kolide_pass
KOLIDE_REDIS_ADDRESS=redis:6379
KOLIDE_REDIS_PASSWORD=$redis_pass
KOLIDE_SERVER_ADDRESS=0.0.0.0:443
KOLIDE_SERVER_CERT=/tmp/server.cert
KOLIDE_SERVER_KEY=/tmp/server.key
KOLIDE_LOGGING_JSON=true
KOLIDE_AUTH_JWT_KEY=$jwt
EOF
