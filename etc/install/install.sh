#!/bin/bash

# Bootstrap script to set up a Python 3 Django project on Vagrant.

PROJECT_NAME=$1
VAGRANT_BASENAME=$2
echo $VAGRANT_BASENAME

DB_NAME=$PROJECT_NAME
VIRTUALENV_NAME=$PROJECT_NAME

PROJECT_DIR=/home/vagrant/$PROJECT_NAME
VIRTUALENV_DIR=/home/vagrant/.virtualenvs/$PROJECT_NAME

PGSQL_VERSION=9.3

mkdir -p $PROJECT_DIR

# Need to fix locale so that Postgres creates databases in UTF-8
cp -p $PROJECT_DIR/$VAGRANT_BASENAME/etc/install/etc-bash.bashrc /etc/bash.bashrc
locale-gen en_GB.UTF-8
dpkg-reconfigure locales

export LANGUAGE=en_GB.UTF-8
export LANG=en_GB.UTF-8
export LC_ALL=en_GB.UTF-8

# Install essential packages from Apt
apt-get update -y

# Python dev packages
apt-get install -y build-essential python3 python3-dev python3-pip

# Dependencies for image processing with Pillow (drop-in replacement for PIL)
# supporting: jpeg, tiff, png, freetype, littlecms
# (pip install pillow to get pillow itself, it is not in requirements.txt)
apt-get install -y libjpeg-dev libtiff-dev zlib1g-dev libfreetype6-dev liblcms2-dev

apt-get install -y git

# Postgresql
if ! command -v psql; then
    apt-get install -y postgresql-$PGSQL_VERSION libpq-dev 
    cp $PROJECT_DIR/$VAGRANT_BASENAME/etc/install/pg_hba.conf /etc/postgresql/$PGSQL_VERSION/main/
    /etc/init.d/postgresql reload
fi

if [[ ! -f /usr/local/bin/virtualenv ]]; then
    pip3 install virtualenv virtualenvwrapper stevedore virtualenv-clone
fi

# bash environment global setup
cp -p $PROJECT_DIR/$VAGRANT_BASENAME/etc/install/bashrc /home/vagrant/.bashrc

# bash Vagrant user setup
cp -p $PROJECT_DIR/$VAGRANT_BASENAME/etc/install/bash_aliases /home/vagrant/.bash_aliases
cp -p $PROJECT_DIR/$VAGRANT_BASENAME/etc/install/bash_prompt /home/vagrant/.bash_prompt

# su - vagrant -c "mkdir -p /home/vagrant/.pip_download_cache"

 # Node.js, CoffeeScript 
apt-get install -y nodejs npm
ln -sf /usr/bin/nodejs /usr/local/bin/node

if ! command -v coffee; then
    npm install -g coffee-script
fi
# ---

# postgresql setup for project
su - postgres -c "createuser -d -e -hlocalhost -Upostgres $PROJECT_NAME"
su - postgres -c "createdb -E 'UTF-8' -O $PROJECT_NAME -hlocalhost -U$PROJECT_NAME $PROJECT_NAME"

# virtualenv setup for project
su - vagrant -c "/usr/local/bin/virtualenv $VIRTUALENV_DIR" 

echo "workon $VIRTUALENV_NAME" >> /home/vagrant/.bashrc

# Remove the annoying MOTDs
rm /etc/update-motd.d/*

echo "------------------------------------------"
echo "|    $PROJECT_NAME Bootstrap Complete    |"
echo "------------------------------------------"
