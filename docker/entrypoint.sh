#!/usr/bin/env sh
set -e

JAVA_RAM_INITIAL="${JAVA_RAM_INITIAL:-40.0}"
JAVA_RAM_MAX="${JAVA_RAM_MAX:-75.0}"

exec java \
  -javaagent:opentelemetry-javaagent.jar \
  -XX:+UseContainerSupport \
  -XX:InitialRAMPercentage="${JAVA_RAM_INITIAL}" \
  -XX:MaxRAMPercentage="${JAVA_RAM_MAX}" \
  -jar app.jar
