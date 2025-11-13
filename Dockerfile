FROM python:3.11-slim-bookworm AS builder
ARG REBUILD_HNSWLIB
ARG PROTOC_VERSION=31.1

RUN apt-get update --fix-missing && apt-get install -y --fix-missing \
    build-essential \
    gcc \
    g++ \
    cmake \
    autoconf \
    python3-dev \
    unzip \
    curl \
    make && \
    curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain stable && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /install

ENV PATH="/root/.cargo/bin:$PATH"

RUN ARCH=$(uname -m) && \
  if [ "$ARCH" = "x86_64" ]; then \
    PROTOC_ZIP=protoc-${PROTOC_VERSION}-linux-x86_64.zip; \
  elif [ "$ARCH" = "aarch64" ]; then \
    PROTOC_ZIP=protoc-${PROTOC_VERSION}-linux-aarch_64.zip; \
  else \
    echo "Unsupported architecture: $ARCH" && exit 1; \
  fi && \
  curl -OL https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/$PROTOC_ZIP && \
  unzip -o $PROTOC_ZIP -d /usr/local bin/protoc && \
  unzip -o $PROTOC_ZIP -d /usr/local 'include/*' && \
  rm -f $PROTOC_ZIP && \
  chmod +x /usr/local/bin/protoc

WORKDIR /chroma

COPY ./requirements.txt requirements.txt

RUN pip install --no-cache-dir --upgrade -r requirements.txt -t /install

COPY ./ /chroma

RUN if [ "$REBUILD_HNSWLIB" = "true" ]; then \
    cd /chroma/chromadb/third_party/hnswlib && \
    python setup.py install --prefix=/install; \
  fi

RUN cd /chroma && python -m build --wheel --outdir /chroma/dist

# Runtime stage
FROM python:3.11-slim-bookworm AS runtime

RUN apt-get update --fix-missing && apt-get install -y --fix-missing \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /chroma

COPY --from=builder /install /usr/local
COPY --from=builder /chroma/dist /chroma/dist

RUN pip install --no-cache-dir /chroma/dist/*.whl

# Create data directory
RUN mkdir -p /chroma/chroma

ENV CHROMA_HOST_ADDR="0.0.0.0"
ENV CHROMA_HOST_PORT=8000
ENV CHROMA_WORKERS=1
ENV CHROMA_LOG_CONFIG="chromadb/log_config.yml"
ENV PERSIST_DIRECTORY="/chroma/chroma"

EXPOSE 8000

CMD ["uvicorn", "chromadb.app:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1", "--log-config", "chromadb/log_config.yml"]