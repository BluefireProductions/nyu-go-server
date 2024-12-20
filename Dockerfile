FROM --platform=$BUILDPLATFORM golang:1-bookworm@sha256:3f3b9daa3de608f3e869cd2ff8baf21555cf0fca9fd34251b8f340f9b7c30ec5 AS builder
ARG BUILDARCH TARGETOS TARGETARCH

# Install GoReleaser
RUN wget --no-verbose "https://github.com/goreleaser/goreleaser/releases/download/v1.26.2/goreleaser_1.26.2_$BUILDARCH.deb"
RUN dpkg -i "goreleaser_1.26.2_$BUILDARCH.deb"

# Create and change to the app directory.
WORKDIR /app

# Retrieve application dependencies.
# This allows the container build to reuse cached dependencies.
# Expecting to copy go.mod and if present go.sum.
COPY go.* ./
RUN go mod download

# Copy local code to the container image.
COPY . ./

# RUN git lfs pull && ls -alh publications

# Run goreleaser
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg \
    GOOS=$TARGETOS GOARCH=$TARGETARCH goreleaser build --single-target --id rwp --skip=validate --snapshot --output ./rwp

# Run tests
# FROM builder AS tester
# RUN go test ./...

# Produces very small images
FROM gcr.io/distroless/static-debian12 AS packager

# Extra metadata
LABEL org.opencontainers.image.source="https://github.com/readium/go-toolkit"

# Add Fedora's mimetypes (pretty up-to-date and expansive)
# since the distroless container doesn't have any. Go uses
# this file as part of its mime package, and readium/go-toolkit
# has a mediatype package that falls back to Go's mime
# package to discover a file's mimetype when all else fails.
ADD https://pagure.io/mailcap/raw/master/f/mime.types /etc/

# Add EPUBs to the container
ADD --chown=nonroot:nonroot https://bluefireproductions.github.io/jisu-epubs/9781479819454.epub /srv/publications/
ADD --chown=nonroot:nonroot https://bluefireproductions.github.io/jisu-epubs/9781479819492.epub /srv/publications/

# Copy built Go binary
COPY --from=builder "/app/rwp" /opt/

EXPOSE 15080

USER nonroot:nonroot

ENTRYPOINT ["/opt/rwp"]
CMD ["serve", "/srv/publications", "--address", "0.0.0.0"]