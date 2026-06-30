# pryzm-docker

## What it is

Dockerfile to build `ghcr.io/bryanlabs/pryzm` container images for the Pryzm blockchain node (`pryzmd`). No application logic lives here; this repo is purely a build artifact.

## Where it's used

- Images are consumed by `cosmos-operator` `CosmosFullNode` CRDs in the bare-metal cluster (e.g. `bare-metal/cluster/chains/cosmos/fullnode/mainnet/pryzm-1/patch.cosmosfullnode.yaml`).
- Not deployed as a standalone workload.
- `bare-metal/docker/pryzm/` may contain overlapping or older build artifacts; verify which is canonical before making changes to either.

## How it works

- Two-stage build: `alpine:3.19` builder downloads the pre-built `pryzmd` binary from Pryzm's official GCS bucket (`https://storage.googleapis.com/pryzm-zone/core/{VERSION}/`), then copies it into a minimal `alpine:3.19` runtime image.
- Source code is not publicly available; binary-only builds are the only option.
- Architecture selected at build time via `TARGETARCH` (amd64 or arm64).
- `versions.txt` tracks version history with date and notes.
- Current version: `v0.29.0` (image `ghcr.io/bryanlabs/pryzm:v0.29.0`).

## Build

Use the cloud builder for amd64 (cluster requirement):

```bash
docker buildx build --builder cloud-bryanlabs-builder --platform linux/amd64 \
  -t ghcr.io/bryanlabs/pryzm:v0.29.0 --push .
```

For multi-arch (amd64 + arm64):

```bash
docker buildx build --builder cloud-bryanlabs-builder --platform linux/amd64,linux/arm64 \
  -t ghcr.io/bryanlabs/pryzm:v0.29.0 --push .
```

To upgrade: update the `VERSION` ARG default in the Dockerfile, build/test, push, then update the `image` field in the `patch.cosmosfullnode.yaml` and apply with kustomize.

## Gotchas

- Binary source is GCS, not a public GitHub release; if Pryzm changes the URL scheme the download step silently fails.
- Always run `docker run --rm ghcr.io/bryanlabs/pryzm:<version> version` to verify the binary before updating the cluster manifest.
- Check `recommended_version` in the [chain registry](https://github.com/cosmos/chain-registry/blob/master/pryzm/chain.json) before upgrading; do not chase arbitrary tags.
- Cloud builder (`cloud-bryanlabs-builder`) may be broken; fall back to local multiarch-builder if needed (see memory note on Docker cloud builder).
