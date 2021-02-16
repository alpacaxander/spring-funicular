ARG JAVA_VERSION=8
ARG NAME=demo
ARG VERSION=0.0.1-SNAPSHOT

FROM maven:3-openjdk-$JAVA_VERSION as BUILDER
ARG NAME
ARG VERSION

WORKDIR /builder

# Add pom and get dependancies to cache for faster builds
COPY ./pom.xml ./
RUN mvn -B -e -C -T 1C org.apache.maven.plugins:maven-dependency-plugin:3.0.2:go-offline

COPY ./src ./src
RUN mvn clean package -DskipTests

FROM amazoncorretto:$JAVA_VERSION
ARG NAME
ARG VERSION

WORKDIR /$NAME

COPY --from=BUILDER builder/target/$NAME-$VERSION.jar ./target/$NAME.jar

ENV NAME=$NAME
CMD java -cp ./target/$NAME.jar org.springframework.boot.loader.JarLauncher
