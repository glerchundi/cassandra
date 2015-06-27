FROM quay.io/justcontainers/java:oraclejdk8
MAINTAINER Gorka Lerchundi Osa <glertxundi@gmail.com>


##
## INSTALL
##

# adding the cassandra repository with its corresponding retrieve gpg key
RUN apt-key adv --keyserver pgp.mit.edu --recv-keys F758CE318D77295D && \
    apt-key adv --keyserver pgp.mit.edu --recv-keys 2B5C1B00 && \
    apt-key adv --keyserver pgp.mit.edu --recv-keys 0353B12C && \
    add-apt-repository -s 'deb http://www.apache.org/dist/cassandra/debian 21x main'

# cassandra
RUN apt-get-min update && \
    apt-get-install-min cassandra=2.1.7 cassandra-tools=2.1.7

# Necessary since cassandra is trying to override the system limitations
# See https://groups.google.com/forum/#!msg/docker-dev/8TM_jLGpRKU/dewIQhcs7oAJ
RUN rm -f /etc/security/limits.d/cassandra.conf

# confd
ADD https://github.com/glerchundi/confd/releases/download/v0.11.0-beta1/confd-0.11.0-beta1-linux-amd64 /usr/bin/confd
RUN chmod 0755 /usr/bin/confd

# kubernetes cassandra seed provider
ADD https://github.com/glerchundi/kubernetes-cassandra-seed-provider/releases/download/v0.1.2/kubernetes-cassandra-0.1.2-jar-with-dependencies.jar /kubernetes-cassandra-with-deps.jar
# kubernetes cassandra seed provider
ADD https://github.com/glerchundi/kubernetes-cassandra-seed-provider/releases/download/v0.1.2/kubernetes-cassandra-0.1.2.jar /kubernetes-cassandra-without-deps.jar
RUN ln -s /kubernetes-cassandra-without-deps.jar /kubernetes-cassandra.jar


##
## ROOTFS
##

# root filesystem
COPY rootfs /

# data & log volumes
VOLUME [ "/var/lib/cassandra" ]
VOLUME [ "/var/log/cassandra" ]

# ports (7000=inter-node,7001=inter-node-ssl,7199=jmx,9042=client,9160=client-thrift)
EXPOSE 7000 7001 7199 9042 9160

##
## CLEANUP
##

RUN apt-cleanup
