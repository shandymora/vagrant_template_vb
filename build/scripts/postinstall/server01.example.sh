#!/bin/bash

# Setup any required directories
mkdir -p /opt/logstash/log
chown -R logstash:logstash /opt/logstash/log

mkdir -p /opt/logstash/conf.d
chown -R logstash:logstash /opt/logstash/conf.d

chown -R logstash:logstash /opt/logstash/ssl
# Service Management
# chkconfig logstash on
# service logstash restart

