#!/bin/sh
set -e

exec /usr/local/bin/gosu fitnesse java -jar /opt/fitnesse/fitnesse-standalone.jar -p 9090 "$@"
