Hey!! this is my DynamoDB repository. Hope you enjoy =)

# The lab ask to rode this command on the terminal to dowload the files used in the lab

cd ~/environment
curl -sL https://s3.amazonaws.com/ddb-labs/battle-royale.tar | tar -xv

## To create a table using pyhton

python scripts/create_table.py

## To obtain a count of the datas in your table put:
(Battle-royale is my table name, of course you have to change to your own)

aws dynamodb scan \
 --table-name battle-royale \
 --select COUNT
 
 
