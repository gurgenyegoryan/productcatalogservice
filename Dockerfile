FROM golang:1.15-alpine AS compiler

RUN apk add --no-cache ca-certificates git
RUN apk add build-base

WORKDIR /src

# restore dependencies
COPY . .
RUN go mod download

# build
RUN go build -o /go/bin/productcatalogservice .

FROM alpine AS release

RUN apk add --no-cache ca-certificates
RUN GRPC_HEALTH_PROBE_VERSION=v0.4.6 && \
    wget -qO/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64 && \
    chmod +x /bin/grpc_health_probe

WORKDIR /src
WORKDIR /src
COPY --from=compiler /productcatalogservice ./server
COPY products.json .

EXPOSE 3550
ENTRYPOINT ["/src/server"]
