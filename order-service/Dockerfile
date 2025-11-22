# Build stage
FROM maven:3.9.4-eclipse-temurin-17 AS build
WORKDIR /build

# copy only what we need for dependency resolution first
COPY pom.xml ./
COPY src ./src

RUN mvn -B -DskipTests package

# Runtime stage
FROM eclipse-temurin:17-jre
WORKDIR /app

# copy jar from build stage
COPY --from=build /build/target/*.jar /app/app.jar

EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]
