# syntax=docker/dockerfile:1

##
## STEP 1 - BUILD
##
FROM golang:1.17-alpine as build

RUN adduser \
    --disabled-password \
    --home "/app" \
    --no-create-home \
    --uid 1313 \
    b3o

WORKDIR /app

COPY ./src/go.mod ./

RUN go mod download

COPY ./src/*.go ./

RUN CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64 \
    go build -a -tags netgo -ldflags '-w' -o ./b3o *.go

##
## STEP 2 - DEPLOY
##
FROM scratch

WORKDIR /

COPY --from=build /app/b3o /server

COPY --from=build /etc/passwd /etc/passwd

ENV PORT=8080

ARG IMAGE_VERSION
ENV IMAGE_VERSION=$IMAGE_VERSION

USER b3o

ENTRYPOINT ["/server"]