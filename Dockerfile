FROM golang:1.23-alpine AS builder

# Install git for go modules
RUN apk add --no-cache git

# Copy tidybot source
WORKDIR /build
COPY ../go/tidybot/go.mod ../go/tidybot/go.sum ./
RUN go mod download

COPY ../go/tidybot/ ./
RUN go build -o tidybot cmd/tidybot/main.go

# Final stage
FROM alpine:latest

# Install dependencies
RUN apk add --no-cache \
    bash \
    git \
    curl \
    jq \
    github-cli

# Copy tidybot binary
COPY --from=builder /build/tidybot /usr/local/bin/tidybot

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Add branding files
COPY assets/ /assets/

ENTRYPOINT ["/entrypoint.sh"]