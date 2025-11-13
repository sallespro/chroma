# Custom ChromaDB Docker Image
FROM chromadb/chroma:1.3.4.dev21

# Create simple config for testing
RUN echo 'persist_path: "/data"' > /config.yaml

# Set environment variables for additional configuration
ENV CHROMA_SERVER_HOST=0.0.0.0
ENV CHROMA_SERVER_HTTP_PORT=8000
ENV CHROMA_SERVER_CORS_ALLOW_ORIGINS=*
ENV CHROMA_SERVER_AUTH_CREDENTIALS_PROVIDER=chromadb.auth.basic.BasicAuthServerProvider
ENV CHROMA_SERVER_AUTH_PROVIDER=chromadb.auth.basic.BasicAuthServerProvider
ENV CHROMA_ALLOW_RESET=true
ENV CHROMA_LOG_LEVEL=INFO

# Ensure data directory exists
RUN mkdir -p /data

EXPOSE 8000

# Keep the same entrypoint and command as the official image
CMD ["run", "/config.yaml"]