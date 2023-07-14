# Stage 1 - Install dependencies and build the app
FROM ubuntu:latest AS build-env

# Install flutter dependencies
RUN apt-get update 
RUN apt-get install -y curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback lib32stdc++6 python3 xz-utils

# Download flutter and extract it and turst the dist dir
RUN wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.7.12-stable.tar.xz && tar xf flutter_linux_3.7.12-stable.tar.xz -C /opt
RUN git config --global --add safe.directory /opt/flutter

# Set flutter path
ENV PATH="/opt/flutter/bin:${PATH}"

# Run flutter doctor
RUN flutter doctor -v

# Enable flutter web
RUN flutter config --enable-web

# Copy files to container and build
RUN mkdir /app/
COPY . /app/
WORKDIR /app/

# Do the build
RUN flutter clean
RUN flutter pub get
RUN flutter packages pub run build_runner build --delete-conflicting-outputs
RUN flutter build web --csp --web-renderer canvaskit

# Stage 2 - Create the run-time image
FROM nginx:latest
COPY --from=build-env /app/build/web /usr/share/nginx/html
