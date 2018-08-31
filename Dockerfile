FROM benjaminrosner/isle-ubuntu-basebox:serverjre8

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
ARG TOMCAT_MAJOR
ARG TOMCAT_VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="ISLE Apache Tomcat Base Image" \
      org.label-schema.url="https://islandora-collaboration-group.github.io" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/Islandora-Collaboration-Group/isle-tomcat" \
      org.label-schema.vendor="Islandora Collaboration Group (ICG) - islandora-consortium-group@googlegroups.com" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"

## General Package Installation, Dependencies, Requires.
RUN GEN_DEP_PACKS="cron \
    tmpreaper \
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
# @todo ask Gavin is this is still necessary and/or what the intention was/is!
RUN touch /var/log/cron.log && \
    touch /etc/cron.d/tmpreaper-cron && \
    echo "0 */12 * * * root /usr/sbin/tmpreaper -am 4d /tmp >> /var/log/cron.log 2>&1" | tee /etc/cron.d/tmpreaper-cron && \
    echo "0 */12 * * * root /usr/sbin/tmpreaper -am 4d /usr/local/tomcat/temp >> /var/log/cron.log 2>&1" | tee -a /etc/cron.d/tmpreaper-cron && \
    chmod 0644 /etc/cron.d/tmpreaper-cron

# Environment
ENV TOMCAT_MAJOR=${TOMCAT_MAJOR:-8} \
    TOMCAT_VERSION=${TOMCAT_VERSION:-8.5.33} \
    CATALINA_HOME=/usr/local/tomcat \
    CATALINA_BASE=/usr/local/tomcat \
    CATALINA_PID=/usr/local/tomcat/tomcat.pid \
    LD_LIBRARY_PATH=/usr/local/tomcat/lib:$LD_LIBRARY_PATH \
    PATH=$PATH:/usr/local/tomcat/bin \
    JAVA_MAX_MEM=${JAVA_MAX_MEM:-2G} \
    JAVA_MIN_MEM=${JAVA_MIN_MEM:-256M} \
    ## Per Gavin, we are no longer using -XX:+UseConcMarkSweepGC, instead G1GC.
    ## Ben's understanding after reading and review: though the new G1GC causes greater pauses it GC, it has lower latency delay and pauses in GC over CMSGC.
    JAVA_OPTS='-Djava.awt.headless=true -server -Xmx${JAVA_MAX_MEM} -Xms${JAVA_MIN_MEM} -XX:+UseG1GC -XX:+UseStringDeduplication -XX:MaxGCPauseMillis=200 -XX:InitiatingHeapOccupancyPercent=70 -Djava.net.preferIPv4Stack=true -Djava.net.preferIPv4Addresses=true'

# TOMCAT PHASE
# Apache Tomcat
RUN mkdir -p /usr/local/tomcat && \
    mkdir -p /tmp/tomcat-native && \
    cd /tmp && \
    curl -O -L "https://www.apache.org/dyn/closer.cgi?action=download&filename=tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz" && \
    tar xzf /tmp/apache-tomcat-$TOMCAT_VERSION.tar.gz -C /usr/local/tomcat --strip-components=1 && \
    useradd --comment 'Tomcat User' --no-create-home -d /usr/local/tomcat --user-group -s /bin/bash tomcat && \
    # Tomcat Native
    tar xzf /usr/local/tomcat/bin/tomcat-native.tar.gz -C /tmp/tomcat-native --strip-components=1 && \
    cd /tmp/tomcat-native/native && \
    ./configure --with-apr=/usr/bin/apr-1-config --with-ssl=yes --prefix=$CATALINA_HOME && \
    make && \
    make install && \
    echo "/usr/local/tomcat/lib" > /etc/ld.so.conf.d/tomcat-native.conf && \
    ldconfig && \
    echo 'LD_LIBRARY_PATH=$CATALINA_HOME/lib:$LD_LIBRARY_PATH\nexport LD_LIBRARY_PATH' > $CATALINA_HOME/bin/setenv.sh && \
    chown -R tomcat:tomcat $CATALINA_HOME && \
    ## Cleanup phase.
    rm $CATALINA_HOME/bin/tomcat-native.tar.gz && \
    rm -rf $CATALINA_HOME/webapps/docs $CATALINA_HOME/webapps/examples $CATALINA_HOME/bin/*.bat && \
    apt-get purge -y --auto-remove gcc gcc-7-base make && \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY rootfs /

EXPOSE 8080

ENTRYPOINT ["/init"]