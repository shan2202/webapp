import boto3
import requests

client = boto3.client('ssm')

master_username = client.get_parameter(
    Name='/scb/dev/DBUSER'
)["Parameter"]["Value"]

db_password = client.get_parameter(
    Name='/scb/dev/DBPASSWORD',
    WithDecryption=True
)["Parameter"]["Value"]

endpoint = client.get_parameter(
    Name='/scb/dev/mysqldb_SERVER'
)["Parameter"]["Value"]

db_instance_name = client.get_parameter(
    Name='/scb/dev/DBNAME'
)["Parameter"]["Value"]


if __name__ == "__main__":
    print(master_username, db_password, endpoint, db_instance_name)
