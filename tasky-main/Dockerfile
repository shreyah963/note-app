# Building the binary of the App
FROM golang:1.19 AS build

WORKDIR /go/src/tasky
COPY . .
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /go/src/tasky/tasky

# Production stage
FROM alpine:3.17.0 as release

WORKDIR /app
COPY --from=build /go/src/tasky/tasky .
COPY --from=build /go/src/tasky/assets ./assets
COPY --from=build /go/src/tasky/wizexercise.txt ./wizexercise.txt

# Create non-root user for security
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Change ownership of the app directory
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

EXPOSE 8080
ENTRYPOINT ["/app/tasky"]


