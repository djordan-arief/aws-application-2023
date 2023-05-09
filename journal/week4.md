# Week 4 — Postgres and RDS

# github instruction link 
https://github.com/omenking/aws-bootcamp-cruddur-2023/blob/week-4/journal/week4.md


# security consideration
For AWS side: 
- Use VPC to create a private network for your RDS instance to prevent unauthorized access
- Compliance standard
- RDS instances should only be in the AWS region that you are legally allowed to be holding user data in
- Enable AWS CloudTail & monitored to trigger alerts on malicious RDS behaviour by an identity in AWS

For developers side: 
- Use a secret manager
- Not have RDS be internet accessible
- Security group to be restricted only to known IPs
- Database User lifecycle management - change/revoke roles

# create a postgres docker image
In your docker compose:
db:
    image: postgres:13-alpine
    restart: always
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=your_custom_password
    ports:
      - '5432:5432'
    volumes: 
      - db:/var/lib/postgresql/data


- Compose up the docker compose file
- run the container

# Create a RDS instance on AWS with AWS CLI
aws rds create-db-instance \
  --db-instance-identifier your_custome_db_instance \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version  14.6 \
  --master-username root \
  --master-user-password your_custom_password \
  --allocated-storage 20 \
  --availability-zone eu-west-3a \
  --backup-retention-period 0 \
  --port 5432 \
  --db-name your_custom_db_name \
  --storage-type gp2 \
  --publicly-accessible \
  --storage-encrypted \
  --enable-performance-insights \
  --performance-insights-retention-period 7 \
  --no-deletion-protection

# Connect to your rds instance with a connection url
RDS_CONNECTION_URL=postgresql://<your-db-username>:<your-db-password>@<your-rds-instance-endpoint>:<your-db-port>/<your-db-name>

# cmd to connect to rds instance
psql $RDS_CONNECTION_URL

# Connect to your rds instance from terminal
psql --host=[your-rds-endpoint] --port=[your-rds-port] --username=[your-rds-username] --password [your-rds-password]

Note: you must add your ip address to your security group as an inbound rule

# connect to postgres server
psql -Upostgres --host localhost

# list all databases
\l

# quit the psql command
\q

# Create a postgres database
CREATE DATABASE [db_name]; 

# connect to a specific postgres database
psql -d [db_name] -Upostgres --host localhost

# to drop a database 
DROP DATABASE [db_name]; 

# import script
create a db folder in the backend-flask directory.
create a schema.sql file in that folder

# Add UUID extension
in schema.sql, we will use this extension: 
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

run the schema file:
psql [db_name] < db/schema.sql -h localhost -U postgres


# bash scripting
create a bin folder in the backend-flask directory
inside the bin folder, create the bash scripts:
db-connect
db-drop
db-create
db-schema-load
db-seed

find where your bash is by typing: "whereis bash"
put the bash directory into your bash script

# to change the file mode to be executable
chmod u+x [bash-script-directory]

# connect to postgres using a connection url 
export CONNECTION_URL=postgresql://[user[:password]@][netloc][:port][/db_name]

Example: postgresql://postgres:password@localhost:5432/my-db

# drop the database from the bash script:
#!/bin/bash

NO_DB_CONNECTION_URL=$(sed 's/\/[db_name]//g' <<<"$CONNECTION_URL")
psql $NO_DB_CONNECTION_URL -c "DROP database [db_name];"

# create database from bash script:
#!/bin/bash

NO_DB_CONNECTION_URL=$(sed 's/\/twitter//g' <<<"$CONNECTION_URL")
psql $NO_DB_CONNECTION_URL -c "CREATE DATABASE twitter;"

# update bash scripts for production
if [ "$1" = "prod" ]; then
  echo "Running in production mode"
  URL=$CONNECTION_URL
else
  echo "Running in development mode"
  URL=$RDS_CONNECTION_URL
fi
psql $URL

# create database from bash scripting
in db/schema.sql:
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.activities;

CREATE TABLE public.users (
  uuid UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  display_name text,
  handle text,
  cognito_user_id text,
  created_at TIMESTAMP default current_timestamp NOT NULL
);

CREATE TABLE public.activities (
  uuid UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_uuid UUID NOT NULL,
  message text NOT NULL,
  replies_count integer DEFAULT 0,
  reposts_count integer DEFAULT 0,
  likes_count integer DEFAULT 0,
  reply_to_activity_uuid integer,
  expires_at TIMESTAMP,
  created_at TIMESTAMP default current_timestamp NOT NULL
);

in bin/db-schema-load:
if [ "$1" = "prod" ]; then
  echo "Running in production mode"
  URL=$RDS_CONNECTION_URL
else
  echo "Running in development mode"
  URL=$CONNECTION_URL
fi
psql $URL twitter < db/schema.sql

# insert value into the database from bash scripting
in db/seed.sql:
INSERT INTO public.users(display_name, handle, cognito_user_id)
VALUES 
    ('Andrew Brown', 'andrewbrown', 'MOCK'),
    ('Andrew Bayko', 'bayko', 'MOCK');


INSERT INTO public.activities (user_uuid, message, expires_at)
VALUES 
    (
        (SELECT uuid from public.users WHERE users.handle='andrewbrown' LIMIT 1),
        'This was imported as seed data',
        CURRENT_TIMESTAMP + interval '10 day'
    );

in bin/db-seed:
if [ "$1" = "prod" ]; then
  echo "Running in production mode"
  URL=$RDS_CONNECTION_URL
else
  echo "Running in development mode"
  URL=$CONNECTION_URL
fi
psql $URL twitter < db/seed.sql



# install postgres client
add these to requirements.txt:
- psycopg[binary]
- psycopg[pool]

pip install -r requirements.txt
Note: if it does not work, upgrade your pip version