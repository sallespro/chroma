# Custom ChromaDB Docker Image
FROM chromadb/chroma:1.3.4.dev21

# Create config.yaml with echo commands
RUN echo '# server settings #' > /config.yaml && \
    echo 'port: 8000' >> /config.yaml && \
    echo 'listen_address: "0.0.0.0"' >> /config.yaml && \
    echo 'max_payload_size_bytes: 41943040' >> /config.yaml && \
    echo 'cors_allow_origins: ["https://chroma.cloudpilot.com.br"]' >> /config.yaml && \
    echo 'persist_path: "./data"' >> /config.yaml && \
    echo 'allow_reset: true' >> /config.yaml

# Ensure data directory exists
RUN mkdir -p /data

EXPOSE 8000

# Keep the same entrypoint and command as the official image
CMD ["run", "/config.yaml"]