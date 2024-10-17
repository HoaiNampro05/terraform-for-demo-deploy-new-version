#!/bin/bash
cd /home/ubuntu
git clone https://github.com/HoaiNampro05/demo-django-v2.git
source .venv/bin/activate
echo "activated venv" > file.txt
cd demo-django-v2
echo "cd django-v2" > file.txt
echo "db_user: ${db_user}, db_host: ${db_host}, db_password: ${db_password}" >> file.txt
python run.py --db_name blogs --db_user ${db_user} --db_password '${db_password}' --db_host ${db_host} --makemigration
echo "maked" > file.txt
python run.py --db_name blogs --db_user ${db_user} --db_password '${db_password}' --db_host ${db_host} --migrate
echo "mig" > file.txt
python run.py --db_name blogs --db_user ${db_user} --db_password '${db_password}' --db_host ${db_host} --runserver