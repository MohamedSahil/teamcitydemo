# Use OpenJDK 23 as the base image for building the app
FROM openjdk:23-jdk-slim as build

# Install Gradle (optional, if you don't use the wrapper)
RUN apt-get update && apt-get install -y wget unzip \
    && wget https://services.gradle.org/distributions/gradle-8.10.2-bin.zip -P /tmp \
    && unzip -d /opt/gradle /tmp/gradle-8.10.2-bin.zip \
    && ln -s /opt/gradle/gradle-8.10.2/bin/gradle /usr/local/bin/gradle \
    && rm -rf /tmp/*

# Set the working directory in the container
WORKDIR /app

# Copy the Gradle wrapper and project files
COPY gradle /app/gradle
COPY gradlew /app/gradlew
COPY build.gradle /app/build.gradle
COPY settings.gradle /app/settings.gradle
COPY src /app/src

# Make the Gradle wrapper executable (if you're using the Gradle wrapper)
RUN chmod +x gradlew

# Build the application (this will compile the app and create a jar file)
RUN ./gradlew build --no-daemon

# Use OpenJDK 23 again for the runtime environment (lightweight final image)
FROM openjdk:23-jdk-slim

# Set the working directory for the runtime container
WORKDIR /app

# Copy the built JAR from the build stage
COPY --from=build /build/libs/teamcitydemo-0.0.1-SNAPSHOT.jar /app/app.jar

# Expose the port your app will run on (change if your app uses another port)
EXPOSE 8080

# Run the application
CMD ["java", "-jar", "app.jar"]
