# ISLE Tomcat Base Image
## Release Candidate
Build: 2018-08-04:10:23EST-4

Based on:  
 - [Tomcat 8.5.31](https://tomcat.apache.org/)
 - Oracle Java 8

# Generic Usage

Designed as a base for ISLE components requiring Tomcat and Oracle Java.
```
docker run -p 8080:8080 -it --rm islandoracollabgroup/isle-tomcat
```
## Tomcat users

admin:isle_admin  
manager:isle_manager  
