FROM alpine:latest

# Install dependencies
RUN apk add --no-cache \
    bash \
    git \
    curl \
    jq \
    github-cli

# Copy pre-built tidybot binary
COPY tidybot /usr/local/bin/tidybot
RUN chmod +x /usr/local/bin/tidybot

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Add branding files
COPY assets/ /assets/

ENTRYPOINT ["/entrypoint.sh"]