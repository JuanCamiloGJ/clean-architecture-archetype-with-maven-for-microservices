FROM alpine:latest

# Define JAVA VERSION
ARG VJAVA
ENV VJAVA=17

# Default Settings (Time ZONE)
ARG TZ
ENV TZ=America/Bogota

# Set Variables
ENV JAVA_HOME=/usr/lib/jvm/java-${VJAVA}-openjdk\
    PATH=/usr/lib/jvm/java-${VJAVA}-openjdk/bin:$PATH\
    CLASSPATH=$JAVA_HOME/jre/lib/rt.jar:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar\
    NLS_LANG=SPANISH_SPAIN.AL32UTF8

# Update the system and prepare it
RUN apk update && apk upgrade --available && sync\
    && apk add --no-cache nano bash tzdata openssl openjdk${VJAVA}-jre curl\
    && cat /usr/share/zoneinfo/${TZ} > /etc/localtime\
    && echo ${TZ} > /etc/timezone\
    && sed -i 's/ash/bash/g' /etc/passwd\
    && addgroup -g 1000 smartusr\
    && adduser smartusr --shell /sbin/nologin\
    --disabled-password --uid 1000 --ingroup smartusr\
	&& chown 1000:1000 /etc/localtime\
    && chown 1000:1000 /etc/timezone\
    && rm -rf /var/lib/apt/lists/* && rm -rf /var/cache/apt/*\
    && rm -rf /tmp/{.}* /tmp/*\
    && rm -rf /var/cache/apk/*

USER smartusr
WORKDIR /home/smartusr
#COPY target/*.jar app.jar
ARG MODULE_TARGET=application/app-service/target
COPY ${MODULE_TARGET}/*.jar app.jar

ARG OTEL_VERSION=2.15.0
RUN curl -L -o opentelemetry-javaagent.jar https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v${OTEL_VERSION}/opentelemetry-javaagent.jar

# Defaults heap por porcentaje (override por DevOps)
ENV JAVA_RAM_INITIAL="40.0"
ENV JAVA_RAM_MAX="75.0"
COPY --chown=1000:1000 docker/entrypoint.sh /home/smartusr/entrypoint.sh
RUN chmod +x /home/smartusr/entrypoint.sh
EXPOSE 8793
# Run the application
ENTRYPOINT ["/home/smartusr/entrypoint.sh"]
