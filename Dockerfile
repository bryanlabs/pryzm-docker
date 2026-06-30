# Multi-arch Dockerfile for Pryzm
# Downloads pre-built binaries from Pryzm's official storage

FROM alpine:3.19 as builder

# Install necessary dependencies
RUN apk add --no-cache \
    ca-certificates \
    curl \
    jq

# Define the version
ARG VERSION=0.29.0
ARG TARGETARCH

# Download the appropriate binary based on architecture
RUN if [ "$TARGETARCH" = "amd64" ]; then \
        BINARY_URL="https://storage.googleapis.com/pryzm-zone/core/${VERSION}/pryzmd-${VERSION}-linux-amd64"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        BINARY_URL="https://storage.googleapis.com/pryzm-zone/core/${VERSION}/pryzmd-${VERSION}-linux-arm64"; \
    else \
        echo "Unsupported architecture: $TARGETARCH" && exit 1; \
    fi && \
    echo "Downloading from: $BINARY_URL" && \
    curl -L -o /usr/local/bin/pryzmd "$BINARY_URL" && \
    chmod +x /usr/local/bin/pryzmd

# Verify the binary works
RUN /usr/local/bin/pryzmd version || true

# Final stage - minimal runtime image
FROM alpine:3.19

# Install runtime dependencies
RUN apk add --no-cache \
    ca-certificates \
    bash \
    jq \
    curl

# Copy binary from builder
COPY --from=builder /usr/local/bin/pryzmd /usr/local/bin/pryzmd

# Create non-root user
RUN addgroup -g 1000 pryzm && \
    adduser -u 1000 -G pryzm -s /bin/sh -D pryzm

# Set up data directory
RUN mkdir -p /home/pryzm/.pryzm && \
    chown -R pryzm:pryzm /home/pryzm/.pryzm

# Switch to non-root user
USER pryzm
WORKDIR /home/pryzm

# Expose standard Cosmos ports
EXPOSE 26656 26657 1317 9090 9091

# Set entrypoint
ENTRYPOINT ["pryzmd"]