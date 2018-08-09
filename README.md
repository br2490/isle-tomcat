# ISLE Tomcat Base Image

## Part of the ISLE Islandora 7.x Docker Images
Designed as a base for ISLE components requiring Tomcat and Oracle Java.

Based on:  
 - Ubuntu 18.04 "Bionic"
 - [Tomcat 8.5.31](https://tomcat.apache.org/)
 - Oracle Java 8.x latest (via APT repo.)

Contains and Includes:
  - [S6 Overlay](https://github.com/just-containers/s6-overlay) to manage services
  - `cron` and `tmpreaper` to clean /tmp *and* /usr/local/tomcat/temp
  - Tomcat Native library

Important Paths:
  - $CATALINA_HOME is `/usr/local/tomcat`
  - $JAVA_HOME is `/usr/lib/jvm/java-8-oracle`

## Java Options
Based on reading and testing, with the help and direction of [@g7Morris](https://github.com/g7morris)!
  - $JAVA_OPTS are `-Djava.awt.headless=true -server -Xmx4096M -Xms512m -XX:+UseG1GC -XX:+UseStringDeduplication -XX:MaxGCPauseMillis=200 -XX:InitiatingHeapOccupancyPercent=70 -Djava.net.preferIPv4Stack=true -Djava.net.preferIPv4Addresses=true`
  - **NB**: these are not to be confused with $CATALINA_OPTS

## Generic Usage

```
docker run -p 8080:8080 -it --rm islandoracollabgroup/isle-tomcat
```

## Tomcat default users

admin:isle_admin  
manager:isle_manager  
