#!/bin/sh

# Run with sudo from /var/www/html root
# Link to vhs content

src=/home/billy/Desktop/vhs/web
dst=/var/www/html

ln -s $src/vhs.html $dst/index.html
ln -s $src/content $dst/content
ln -s $src/scripts $dst/scripts
ln -s $src/js $dst/js

