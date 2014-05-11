## Apache Configuration Builder (Modified)

#### Instructions:

```
> ./apacheBuilder.sh
> New Domain Name: playground.me
> Link to Current Folder? (Y/n): Y
Linking http://playground.me to ~/workspace/playground...
```
or
```
> ./apacheBuilder.sh
New Domain Name: playground.me
> Link to Current Folder? (Y/n): n
> Project Folder Name? playground
Creating Directory playground
Linking http://playground.me to ~/workspace/playground...
```

This works best when it is placed in the root of your development folder that contains your project directories
* Clone or copy the bash script into your workspace directory
* Call it with sudo -- sudo ./apacheBuilder.sh
* Fill out the prompts and your site will pop up as soon as you're done!


Notes: This is configured for Mac OS X environments with apache2 installed.
It is hardcoded to use the following settings:

* Hosts File: /etc/hosts
* VHosts File: /etc/apache2/extra/httpd-vhosts.conf
* Symlink folder: ~/Sites/"

If your files exist in other places, make sure to edit the *VHOST_FILE* and *HOST_FILE* and *siteDirectory*


