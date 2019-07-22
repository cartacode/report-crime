Website for reporting crimes
=====================================

To create the website:

* run the new.crimenmexico repo to create the json and zip files with crime info
* run infographics.py in this repo to create the html files for the website
* git deploy to live
* rsync -avz --exclude ".git/" report-crime/ deploy@ip:/var/www/report-crime

The template to build the website is not free software



License: pixelarity.com/license
