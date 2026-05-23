FROM ubuntu:24.04

ARG RUSTCFML_VERSION=v0.13.0
ARG TARGETARCH=amd64

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    case "$TARGETARCH" in \
      amd64) RUSTCFML_ARCH="x86_64" ;; \
      arm64) RUSTCFML_ARCH="aarch64" ;; \
      *) echo "Unsupported TARGETARCH: $TARGETARCH" && exit 1 ;; \
    esac; \
    curl -fsSL \
      "https://github.com/RustCFML/RustCFML/releases/download/${RUSTCFML_VERSION}/rustcfml-linux-${RUSTCFML_ARCH}" \
      -o /usr/local/bin/rustcfml; \
    chmod +x /usr/local/bin/rustcfml; \
    rustcfml --version

WORKDIR /app
COPY app/ /app/

EXPOSE 8500

CMD ["rustcfml", "--serve", "/app", "--port", "8500"]
