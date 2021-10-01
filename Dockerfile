FROM maven:latest as build
WORKDIR /app
COPY src ./src
COPY pom.xml .