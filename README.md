# ISLE Tomcat Base Image

## Part of the ISLE Islandora 7.x Docker Images
Designed as a base for ISLE components requiring Tomcat and Oracle Java.

Based on:  
  - [ISLE-ubuntu-basebox](https://hub.docker.com/r/benjaminrosner/isle-ubuntu-basebox/)
    - Ubuntu 18.04 "Bionic"
    - General Dependencies (@see [ISLE-ubuntu-basebox](https://hub.docker.com/r/benjaminrosner/isle-ubuntu-basebox/))
    - Oracle Java Server JRE.
 - [Tomcat 8.5.31](https://tomcat.apache.org/)

Contains and Includes:
  - `cron` and `tmpreaper` to clean /tmp *and* /usr/local/tomcat/temp
  - Tomcat Native library

Size: 499MB

## Important Paths
  - $CATALINA_HOME is `/usr/local/tomcat`

## Java Options
Based on reading and testing, with the help and direction of [@g7Morris](https://github.com/g7morris)!
  - $JAVA_OPTS are `-Djava.awt.headless=true -server -Xmx4096M -Xms512m -XX:+UseG1GC -XX:+UseStringDeduplication -XX:MaxGCPauseMillis=200 -XX:InitiatingHeapOccupancyPercent=70 -Djava.net.preferIPv4Stack=true -Djava.net.preferIPv4Addresses=true`
  - **NB**: these are not to be confused with $CATALINA_OPTS

## Generic Usage

```
docker run -p 8080:8080 -it --rm islandoracollabgroup/isle-tomcat:{version} bash
```

### Default Login information

Tomcat Admin
  - Username: admin
  - Password: isle_admin 

Tomcat Manager
  - Username: manager
  - Password: isle_manager  
