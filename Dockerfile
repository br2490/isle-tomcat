ARG BASE=ubuntu:bionic
FROM $BASE as isle-tomcat-base

##
LABEL "io.github.islandora-collaboration-group.name"="isle-tomcat base" \
      "io.github.islandora-collaboration-group.license"="GPL3" \
      "io.github.islandora-collaboration-group.vcs-url"="git@github.com:Islandora-Collaboration-Group/ISLE.git" \
      "io.github.islandora-collaboration-group.vendor"="Islandora Collaboration Group (ICG) - islandora-consortium-group@googlegroups.com" \
      "io.github.islandora-collaboration-group.maintainer"="Islandora Collaboration Group (ICG) - islandora-consortium-group@googlegroups.com"
##

## S6-Overlay @see: https://github.com/just-containers/s6-overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.21.4.0/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && \
    rm /tmp/s6-overlay-amd64.tar.gz

## General Package Installation, Dependencies, Requires.
RUN GEN_DEP_PACKS="software-properties-common \
    tmpreaper \
    dnsutils \
    ca-certificates \
    cron \
    curl \
    wget \
    libapr1-dev \
    libssl-dev \
    gcc \
    make" && \
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    apt-get update && \
    apt-get install --no-install-recommends -y $GEN_DEP_PACKS && \
    ## Cleanup phase.
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## tmpreaper - cleanup /tmp on the running container
# @todo as Gavin is this is actually doing anything.
RUN touch /var/log/cron.log && \
    touch /etc/cron.d/tmpreaper-cron && \
    echo "0 */12 * * * root /usr/sbin/tmpreaper -am 4d /tmp >> /var/log/cron.log 2>&1" | tee /etc/cron.d/tmpreaper-cron && \
    chmod 0644 /etc/cron.d/tmpreaper-cron

# Environment
ENV JAVA_HOME=/usr/lib/jvm/java-8-oracle \
    JRE_HOME=/usr/lib/jvm/java-8-oracle/jre \
    CLASSPATH=/usr/lib/jvm/java-8-oracle/jre/lib \
    JRE_PATH=$PATH:/usr/lib/jvm/java-8-oracle/bin:/usr/lib/jvm/java-8-oracle/jre/bin \
    CATALINA_HOME=/usr/local/tomcat \
    CATALINA_PID=/usr/local/tomcat/temp/tomcat.pid \
    CATALINA_BASE=/usr/local/tomcat \
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/tomcat/lib:/usr/local/apr/lib \
    PATH=$PATH:/usr/lib/jvm/java-8-oracle/bin:/usr/lib/jvm/java-8-oracle/jre/bin:/usr/local/tomcat/bin \
    JAVA_OPTS="-Djava.awt.headless=true -server -Xmx1024M -XX:+UseParallelGC -Djava.net.preferIPv4Stack=true -Djava.net.preferIPv4Addresses=true"

# JAVA PHASE
# Oracle Java 8
RUN JAVA_PACKAGES="oracle-java8-installer \
    oracle-java8-set-default" && \
    echo 'oracle-java8-installer shared/accepted-oracle-license-v1-1 boolean true' | debconf-set-selections && \
    add-apt-repository -y ppa:webupd8team/java && \
    apt-get update && \
    apt-get install --no-install-recommends -y $JAVA_PACKAGES && \
    ## Cleanup phase.
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/oracle-jdk8-installer

# TOMCAT PHASE
# Apache Tomcat 8.5.32
RUN mkdir -p /usr/local/tomcat && \
    mkdir -p /tmp/tomcat-native && \
    curl -o /tmp/apache-tomcat-8.5.32.tar.gz -L http://mirrors.koehn.com/apache/tomcat/tomcat-8/v8.5.32/bin/apache-tomcat-8.5.32.tar.gz && \
    tar xzf /tmp/apache-tomcat-8.5.32.tar.gz -C /usr/local/tomcat --strip-components=1 && \
    useradd --comment 'Tomcat User' --no-create-home -d /usr/local/tomcat --user-group -s /bin/false tomcat && \
    chgrp -R tomcat /usr/local/tomcat && \
    chmod -R 760 /usr/local/tomcat/conf && \
    chmod 750 /usr/local/tomcat/conf && \
    tar xzf /usr/local/tomcat/bin/tomcat-native.tar.gz -C /tmp/tomcat-native --strip-components=1 && \
    cd /tmp/tomcat-native/native && \
    ./configure && \
    make && \
    make install && \
    ## Cleanup phase.
    apt-get purge -y --auto-remove gcc gcc-7-base make software-properties-common openjdk* && \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/local/tomcat/bin/tomcat-native.tar.gz && \
    cd /usr/local/tomcat/webapps/ && \
    rm -rf docs examples

COPY rootfs /

EXPOSE 8080

ENTRYPOINT ["/init"]