Hey! this my repository for MySQL commands for AWS CLI.

# I will start hith my EC2 ARN and the Database endpoint to connect to the database and connect to the DB using the SSM (session manager) of the EC2.

arn:aws:secretsmanager:ap-southeast-1:787431072858:secret:secretMysqlMasterUser-Xr2GOQ
labstack-mysql.cilnlheunfm3.ap-southeast-1.rds.amazonaws.com

## remember that those address will not work in your enviroment, you have to use your own addresses. ##

## let's start seeing the user. 

sudo su -l ssm-user
cd ~

## Now we will see if we properly configure correctlu the DB 

tail -n1 /debug.log

## Let's set the username, password and the ARN instance in the local user/home

cd ~
CREDS=`aws secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:ap-southeast-1:787431072858:secret:secretMysqlMasterUser-Xr2GOQ | jq -r '.SecretString'`
DBUSER="`echo $CREDS | jq -r '.username'`"
DBPASS="`echo $CREDS | jq -r '.password'`"
echo "export DBPASS=\"$DBPASS\"" >> /home/ssm-user/.bashrc
echo "export DBUSER=$DBUSER" >> /home/ssm-user/.bashrc

## check if the user was set

echo $DBUSER

## check the version of the DB

mysql -hlabstack-mysql.cilnlheunfm3.ap-southeast-1.rds.amazonaws.com -u$DBUSER -p"$DBPASS" -e"SELECT @@version;"

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
## This command will show a table with the informations of the DB, like ip address and the number of the instance (if is the 1º or the failover instance) 

while true;
do
mysql -hlabstack-mysql.cilnlheunfm3.ap-southeast-1.rds.amazonaws.com -u$DBUSER -p"$DBPASS" -e "  SELECT now(),@@hostname,@@global.innodb_read_only;"
echo -e "\n\n"
sleep 10
done

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Now we will set the database endpoint and inspect the instance

# Define your database endpoint (you have to use another enpoint)
DBEndpoint=labstack-mysql.cilnlheunfm3.ap-southeast-1.rds.amazonaws.com

# Inspect the instance (change the name of the "example" change the name in single quotes to the name of your DATABASE name)
mysql -h$DBEndpoint -u masteruser -p"$DBPASS" -e"show databases like 'exemple1'
mysql -h$DBEndpoint -u masteruser -p"$DBPASS" -e"use mylab; show tables;

## Now let's create a Table and add some rows.

```
# Write script to file in user's home directory
cat << EoF > ~/generate_data.sql

USE mylab;

# Create a table to hold dummy data to export
CREATE TABLE IF NOT EXISTS export_data (
  id int NOT NULL AUTO_INCREMENT,
  data VARCHAR (255) NOT NULL,
  PRIMARY KEY (id))
ENGINE=InnoDB DEFAULT CHARSET=utf8;

# Set delimiter so we can include semicolons in the procedure
DELIMITER $$

# Create procedure to insert dummy data
DROP PROCEDURE IF EXISTS generate_dummy_data;
CREATE PROCEDURE generate_dummy_data()
BEGIN
  DECLARE i int;
  DECLARE str VARCHAR(255);
  SET i = 1;
  WHILE (i <= 1000) DO
    SET str = CONCAT('data',i);
    INSERT INTO export_data (data)
    VALUES (str);
    SET i = i + 1;
  END WHILE;
END
$$

# Reset delimiter to default
DELIMITER ;

# Call the procedure we just created to insert 1000 rows of data in export_data
CALL generate_dummy_data();
SELECT COUNT(*) AS 'Rows Inserted' FROM export_data;
EoF

# Run the script
cd ~
mysql -h labstack-mysql.cilnlheunfm3.ap-southeast-1.rds.amazonaws.com -u masteruser -p"$DBPASS" < generate_data.sql

# View a sample of the data
mysql -h labstack-mysql.cilnlheunfm3.ap-southeast-1.rds.amazonaws.com -u masteruser -p"$DBPASS" -e"SELECT * FROM mylab.export_data LIMIT 20;"
```
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Do a count of the lines

 SELECT
	COUNT(*)
 FROM
	mylab;

## define a bucket to do the backup

# Define your s3 bucket
S3Bucket=mysql-backups-lab-gabriel

# Backup database with mysqldump
mysqldump -u masteruser -p"$DBPASS" -h$DBEndpoint --databases mylab --triggers --routines --events --single-transaction --set-gtid-purged=OFF --order-by-primary | gzip -1 | aws s3 cp - s3://$S3Bucket/backups/mylabbackup.sql.gz

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## View tables within the 'exemple1' database
mysql -h$DBEndpoint -u$DBUSER -p"$DBPASS" -e"USE mylab; show tables;"

# Now if you make the backup of your database and are using another one (copy)

# Define your restore database endpoint
DBEndpoint=lab-mysql-restore-gabriel.cilnlheunfm3.ap-southeast-1.rds.amazonaws.com

# View version and show databases
mysql -h$DBEndpoint -u$DBUSER -p"$DBPASS" -e"SELECT @@version; show databases;"

# Define your restored database endpoint
DBEndpoint=lab-mysql-restore-gabriel.cilnlheunfm3.ap-southeast-1.rds.amazonaws.com


# Define your s3 bucket 
S3Bucket=mysql-backups-lab-gabriel

# Restore database file we created earlier with mysqldump
 aws s3 cp s3://$S3Bucket/backups/mylabbackup.sql.gz - | gzip -d | mysql -h$DBEndpoint -u$DBUSER -p"$DBPASS"

# Verify the export_data table was restored and count the number of rows in the table
mysql -h$DBEndpoint -u$DBUSER -p"$DBPASS" -e"USE mylab; show tables; SELECT COUNT(*) AS 'Total rows in export_data table' FROM export_data;"


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Get the row count of the export_data table and the current time
mysql -h$DBEndpoint -u$DBUSER -p"$DBPASS" -e"USE mylab; SELECT COUNT(*) AS 'Total rows in export_data table' FROM export_data; SELECT NOW() AS 'Current Time in UTC';"


# Get the row count of the export_data table
mysql -h$DBEndpoint -u$DBUSER -p"$DBPASS" -e"USE mylab; SELECT COUNT(*) AS 'Total rows in export_data table' FROM export_data;"

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
										instancia de replica


mysql -hlabstack-mysql-reader.cilnlheunfm3.ap-southeast-1.rds.amazonaws.com -u$DBUSER -p"$DBPASS" -e"show variables like 'read_only';"

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


aws ssm send-command \
--document-name labstack-sql-ssmDocSysbenchTest-x9K6HQaKvJA7 \
--instance-ids i-040a44c83c2676ce2 \
--parameters \
InstanceEndpoint=labstack-mysql.cilnlheunfm3.ap-southeast-1.rds.amazonaws.com,\
dbUser=$DBUSER,\
dbPassword="$DBPASS"



