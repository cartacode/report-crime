
# report crimes

Web application that analyze crimes and visualize

The easiest way to create the website is to run the docker container

![Alt Text](https://github.com/it-avenger/report-crime/blob/master/report-crime/images/home.png)
![Alt Text](https://github.com/it-avenger/report-crime/blob/master/report-crime/images/leaftlet.png)

and change to the /root/report-crime, ```git pull``` to get the latest version and run make. The website will
be available in the _crimenmexico.diegovalle.net_ subdir. If you don't have
the private key to deploy you can always run the command:

```
make download_csv download_inegi clean_data analysis website
```

to skip the deploy step.
