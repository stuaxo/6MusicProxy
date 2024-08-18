FROM golang:1.20-alpine AS builder

WORKDIR /app
RUN apk add --no-cache git
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o /6MusicProxy main.go

FROM alpine:3.18
RUN apk add --no-cache ca-certificates dumb-init
RUN addgroup -S abc && adduser -S abc -G abc
WORKDIR /app
COPY --from=builder /6MusicProxy .

RUN mkdir -p /var/log /var/db /var/run && chown abc:abc /var/log /var/db /var/run
USER abc

VOLUME /var/log /var/db /var/run
EXPOSE 8888
ENV PUID=1000
ENV PGID=1000
ENV TZ="Europe/London"

CMD ["dumb-init", "/app/6MusicProxy"]
