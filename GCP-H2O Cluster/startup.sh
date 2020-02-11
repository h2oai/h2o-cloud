#!/bin/bash

memTotalKb=`cat /proc/meminfo | grep MemTotal | sed 's/MemTotal:[ \t]*//' | sed 's/ kB//'`
memTotalMb=$[ $memTotalKb / 1024 ]
tmp=$[ $memTotalMb * 90 ]
xmxMb=$[ $tmp / 100 ]

cd /opt

java -Xmx${xmxMb}m -jar h2o.jar -flatfile /opt/h2oai/flatfile.txt -jks /opt/h2oai/h2o.jks -hash_login -login_conf /opt/h2oai/realm.properties
