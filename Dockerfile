# build: docker buildx build --platform linux/amd64,linux/arm64 -f Dockerfile -t wzdnzd/aggregator:tag --build-arg PIP_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple" .

FROM python:3.12.3-slim

LABEL maintainer="wzdnzd"

# github personal access token
ENV GIST_PAT=""

# github gist info, format: username/gist_id
ENV GIST_LINK=""

# customize airport listing url address
ENV CUSTOMIZE_LINK=""

# pip default index url
ARG PIP_INDEX_URL="https://pypi.org/simple"
ARG TARGETARCH

WORKDIR /aggregator

# copy files
COPY requirements.txt /aggregator
COPY subscribe /aggregator/subscribe 
COPY clash /aggregator/clash

COPY subconverter /aggregator/subconverter
RUN set -eux; \
    case "${TARGETARCH}" in \
        "amd64") BIN_ARCH="amd" ;; \
        "arm64") BIN_ARCH="arm" ;; \
        *) echo "unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    rm -rf "clash/clash-darwin-amd" \
        "clash/clash-darwin-arm" \
        "clash/clash-windows-amd.exe" \
        "subconverter/subconverter-darwin-amd" \
        "subconverter/subconverter-darwin-arm" \
        "subconverter/subconverter-windows-amd.exe"; \
    if [ "${BIN_ARCH}" = "amd" ]; then \
        rm -rf "clash/clash-linux-arm" "subconverter/subconverter-linux-arm"; \
    else \
        rm -rf "clash/clash-linux-amd" "subconverter/subconverter-linux-amd"; \
    fi

# install dependencies
RUN pip install -i ${PIP_INDEX_URL} --no-cache-dir -r requirements.txt

# start and run
CMD ["python", "-u", "subscribe/collect.py", "--all", "--overwrite", "--skip"]
