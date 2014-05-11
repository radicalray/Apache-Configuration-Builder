#!/bin/bash


## Copyright (c) 2011 Atticus White (www.atticuswhite.com)
## Github project available at: https://github.com/ajwhite/Apache-Configuration-Builder
##
## Permission is hereby granted, free of charge, to any person obtaining
## a copy of this software and associated documentation files (the
## "Software"), to deal in the Software without restriction, including
## without limitation the rights to use, copy, modify, merge, publish,
## distribute, sublicense, and/or sell copies of the Software, and to
## permit persons to whom the Software is furnished to do so, subject to
## the following conditions:
##
## The above copyright notice and this permission notice shall be
## included in all copies or substantial portions of the Software.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
## EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
## MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
## NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
## LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
## OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
## WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



VHOST_FILE=/etc/apache2/extra/httpd-vhosts.conf
HOST_FILE=/etc/hosts
# This is where your symlink happens
USER_HOME=$(eval echo ~${SUDO_USER})
siteDirectory="${USER_HOME}/Sites/"


if [[ $UID != 0 ]]; then
	echo "This script requires root"
	echo "sudo $0 $*"
	exit 1
fi

echo "##################################################"
echo "##################################################"
echo "########  APACHE CONFIGURATION BUILDER  ##########"
echo "##################################################"
echo "##################################################"


currentDir=${PWD}
currentDir="$currentDir/"


function createIndex {
	indexFile="$projectDirectory/index.html"
	touch $indexFile
	chown "$SUDO_USER" "$indexFile"
	chmod 775 $indexFile

	echo "<h2>It works!</h2>" >> $indexFile
	echo "<code>" >> $indexFile
	echo "Project Location: $projectDirectory<br/>" >> $indexFile
	echo "Project Domain: $projectDomain<br/>" >> $indexFile
    echo "SymLink to local network: $symLinkDirectory<br/>" >> $indexFile
	echo "</code>" >> $indexFile
}


## PROJECT DOMAIN NAME
read -p "New Domain Name: " projectDomain


## PROJECT DIRECTORY
projectDirectory=""

read -p "Link to Current Folder? (Y/n): " projectInCwd

if [ "$projectInCwd" == "n" ]; then
	read -p "Project Folder Name? " folderName

	projectDirectory="$currentDir$folderName"

  if [ ! -d "$projectDirectory" ]; then
    echo "Creating Directory $projectDirectory"
    mkdir $projectDirectory
    chown "$SUDO_USER" "$projectDirectory"
    chmod 775 $projectDirectory
    symLinkDirectory="$siteDirectory$projectDomain"
    createIndex
  fi
else
	projectDirectory="$currentDir"
fi

echo "Linking http://$projectDomain to $projectDirectory..."

symLinkDirectory="$siteDirectory$projectDomain"


## Sym link from Site Directory
ln -s $projectDirectory $symLinkDirectory

## HOST FILE
echo "127.0.0.1   $projectDomain"  >> $HOST_FILE
echo "::1         $projectDomain"  >> $HOST_FILE

echo "

## [http://$projectDomain] -> [$symLinkDirectory]
<VirtualHost *:80>
        ServerAdmin     webmaster@localhost
        DocumentRoot    \"$symLinkDirectory\"
        ServerName      $projectDomain
        ErrorLog        \"/private/var/log/apache2/$projectDomain-error_log\"
        CustomLog       \"/private/var/log/apache2/$projectDomain-access_log\" common

        <Directory \"$symLinkDirectory\">
                Options Indexes Includes FollowSymLinks MultiViews
                AllowOverride AuthConfig FileInfo
                Order allow,deny
                Allow from all
        </Directory>
</VirtualHost>" >> $VHOST_FILE

apachectl stop
apachectl start

open -a "Google Chrome" "http://$projectDomain"
