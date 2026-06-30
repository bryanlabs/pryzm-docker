# Pryzm Docker Image

This repository contains the Dockerfile for building Pryzm blockchain node images.

## Current Version
- **Version**: v0.29.0
- **Image**: `ghcr.io/bryanlabs/pryzm:v0.29.0`

## Building the Image

```bash
# Build for linux/amd64 only
docker buildx build --platform linux/amd64 -t ghcr.io/bryanlabs/pryzm:v0.29.0 .

# Build multi-arch (amd64 and arm64)
docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/bryanlabs/pryzm:v0.29.0 .
```

## Pushing to Registry

```bash
docker push ghcr.io/bryanlabs/pryzm:v0.29.0
```

## Testing the Image

```bash
# Test version
docker run --rm ghcr.io/bryanlabs/pryzm:v0.29.0 version

# Test init
docker run --rm -v /tmp/pryzm-test:/home/pryzm/.pryzm ghcr.io/bryanlabs/pryzm:v0.29.0 init test-moniker --chain-id pryzm-1
```

## Upgrading to a New Version

1. Check the Pryzm chain registry for the latest version:
   - https://github.com/cosmos/chain-registry/blob/master/pryzm/chain.json
   - Look for `recommended_version` field

2. Update the Dockerfile:
   - Change the `VERSION` argument default value
   - Update any version-specific configurations if needed

3. Build and test the new image:
   ```bash
   # Example for v0.30.0
   docker buildx build --platform linux/amd64 -t ghcr.io/bryanlabs/pryzm:v0.30.0 .
   docker run --rm ghcr.io/bryanlabs/pryzm:v0.30.0 version
   ```

4. Push the new image:
   ```bash
   docker push ghcr.io/bryanlabs/pryzm:v0.30.0
   ```

5. Update the fullnode configuration:
   - Edit `/Users/danb/code/github.com/bryanlabs/bare-metal/cluster/chains/cosmos/fullnode/mainnet/pryzm-1/patch.cosmosfullnode.yaml`
   - Update the `image` field to the new version
   - Apply the changes with kustomize

## Binary Sources

Pryzm provides pre-built binaries at:
- Base URL: `https://storage.googleapis.com/pryzm-zone/core/{VERSION}/`
- Linux AMD64: `pryzmd-{VERSION}-linux-amd64`
- Linux ARM64: `pryzmd-{VERSION}-linux-arm64`

## Notes

- The Dockerfile downloads pre-built binaries from Pryzm's official storage
- The source code is not publicly available, so we cannot build from source
- Always test new versions before deploying to production