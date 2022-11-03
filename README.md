# Description
Golang Hello World by b3o

# Standalone mode

## Requirements
- Golang >= v1.17

## Build
```go
go build -o b3o ./src/*.go
```

## Execution

**Compiled file**:
```shell
chmod +x b3o && \
    PORT=8080 LOCATION=AZURE ./b3o
```

Or

**Quick run** without build:
```shell
PORT=8080 LOCATION=GCP go run ./src/main.go
```

# Docker mode

## Requirements
- Docker >= v20.10
## Build

```shell
docker build -t b3o/hello-world .
```

## Execution

```shell
docker run \
    -p 8080:8080 \
    -e PORT=8080 \
    -e LOCATION=GOOGLE-CLOUD
    b3o/hello-world
```


