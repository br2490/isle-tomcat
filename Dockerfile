FROM tomcat:8.5-jre8
# Tomcat 8.5.31

LABEL "io.github.islandora-collaboration-group.name"="isle-tomcat-base" \
     "io.github.islandora-collaboration-group.description"="ISLE Tomcat Base" \
     "io.github.islandora-collaboration-group.license"="Apache-2.0" \
     "io.github.islandora-collaboration-group.vcs-url"="git@github.com:Islandora-Collaboration-Group/ISLE.git" \
     "io.github.islandora-collaboration-group.vendor"="Islandora Collaboration Group (ICG) - islandora-consortium-group@googlegroups.com" \
     "io.github.islandora-collaboration-group.maintainer"="Islandora Collaboration Group (ICG) - islandora-consortium-group@googlegroups.com"

# Set up ENV for Apache Tomcat:
ENV JAVA_HOME=/usr/lib/jvm/java-8-oracle \
     CATALINA_HOME=/usr/local/tomcat \
     CATALINA_BASE=/usr/local/tomcat \
     CATALINA_OPTS="-Djava.net.preferIPv4Stack=true" \
     CLASSPATH=$JAVA_HOME/jre/lib \
     JRE_HOME=/usr/lib/jvm/java-8-oracle/jre \
     JAVA_OPTS="-Djava.awt.headless=true -Xmx1024m -XX:+UseConcMarkSweepGC -Djava.net.preferIPv4Stack=true -Djava.net.preferIPv4Addresses=true" \
     JRE_PATH=$PATH:/usr/lib/jvm/java-8-oracle/bin:/usr/lib/jvm/java-8-oracle/jre/bin \
     LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CATALINA_HOME/lib \
     PATH=$PATH:/usr/lib/jvm/java-8-oracle/bin:/usr/lib/jvm/java-8-oracle/jre/bin \
     LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CATALINA_HOME/lib

###
# Generic Tomcat and dependency installation.
RUN GENERIC_DEPENDS="software-properties-common \
     curl \
     wget" && \
    # https://github.com/phusion/baseimage-docker/issues/58
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    apt-get update && \
    apt-get install -y $GENERIC_DEPENDS && \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

###
# Java - @TODO deprecate this and download the appropriate tar file and "install" it.  This is --
RUN JAVA_PACKS="oracle-java8-installer \
     oracle-java8-set-default" && \
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" > /etc/apt/sources.list.d/webupd8team-java.list && \
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 && \
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    echo 'oracle-java8-installer shared/accepted-oracle-license-v1-1 select true' | debconf-set-selections && \
    apt-get update && \
    apt-get purge -y --auto-remove openjdk* && \
    apt-get install -y $JAVA_PACKS && \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm /docker-java-home && \
    ln -s /usr/lib/jvm/java-8-oracle /docker-java-home && \
    # Clean Tomcat of docs and examples.
    cd /usr/local/tomcat/webapps && \
    rm -rf docs examples

COPY rootfs /
