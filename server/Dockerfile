FROM golang:1.26-alpine AS builder

WORKDIR /build

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o squared-store ./cmd/server

FROM alpine:3.21

RUN apk --no-cache add ca-certificates

WORKDIR /app

COPY --from=builder /build/squared-store .
COPY --from=builder /build/migrations ./migrations

EXPOSE 8080

ENTRYPOINT ["./squared-store"]
