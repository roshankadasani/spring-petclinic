### BASE BUILD STAGE
#using openjdk:11-jdk-slim as the base image
FROM openjdk:11-jdk-slim AS base

USER root

## creating a system group and a user
RUN groupadd -g 999 appgroup && \
  useradd -r -u 999 -g appgroup -m appuser

#setting a non-root user for runtime 
USER appuser:appgroup

#declaring arguments
ARG JAR_FILE=target/*.jar

#renaming jar
COPY ${JAR_FILE} app.jar

#startup command for the container
ENTRYPOINT ["java","-jar","/app.jar"]