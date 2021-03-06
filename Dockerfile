# Defining App builder image
FROM golang:alpine AS builder

ARG VERSION=unversioned
ARG PRIVATE_KEY

# Add git to determine build git version
RUN apk add --no-cache --update git openssh

# Set GOPATH to build Go app
ENV GOPATH=/go

# Set apps source directory
ENV SRC_DIR=${GOPATH}/src/github.com/sanjid133/rest-user-store

# Define current working directory
WORKDIR ${SRC_DIR}

# Copy apps scource code to the image
COPY . ${SRC_DIR}

# Build App
RUN ./build.sh

# Defining App image
FROM alpine:latest

RUN apk add --no-cache --update ca-certificates

# Add health check probe binary
RUN wget -qO/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/v0.2.2/grpc_health_probe-linux-amd64 && \
    chmod +x /bin/grpc_health_probe

# Copy App binary to image
COPY --from=builder /go/bin/user /usr/local/bin/user

EXPOSE 8000

ENTRYPOINT ["user"]
