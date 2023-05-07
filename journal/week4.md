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

# connect to your postgres RDS instance
psql --host=[your-rds-endpoint] --port=[your-rds-port] --username=[your-rds-username] --password [your-rds-password]

# set the connection url to your database rds instance
postgresql://<your-db-username>:<your-db-password>@<your-rds-instance-endpoint>:<your-db-port>/<your-db-name>

# to connect to your rds instance using the connection url
psql postgresql://<your-db-username>:<your-db-password>@<your-rds-instance-endpoint>:<your-db-port>/<your-db-name>

Note: you must add your ip address to your security group as an inbound rule

# bash scripting
create a bin folder in the backend-flask directory

inside the bin folder, create the bash files

inside the bash files, put : #!/bin/bash

# to change the file mode to executable
chmod u+x [bash-file-directory]

# connect to postgres using bash 
export CONNECTION_URL=postgresql://[user[:password]@][netloc][:port][/dbname]

Example: postgresql://postgres:password@localhost:5432/my-db

create a db-connect bash file in the bin directory and put this:
psql $CONNECTION_URL

# update bash scripts for production
if [ "$1" = "prod" ]; then
  echo "Running in production mode"
else
  echo "Running in development mode"
fi

# install postgres client
add these to requirements.txt:
- psycopg[binary]
- psycopg[pool]

pip install -r requirements.txt
Note: if it does not work, upgrade your pip version