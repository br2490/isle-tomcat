# ISLE Tomcat Base Image

Based on:  
 - [Tomcat 8.5.31](https://hub.docker.com/_/tomcat/)
 - Oracle Java

# Generic Usage

Designed as a base for ISLE components requiring Tomcat and Oracle Java.
```
docker run -p 8080:8080 -it --rm islandoracollabgroup/isle-tomcat
```
## Tomcat users

admin:isle_admin  
manager:isle_manager  
