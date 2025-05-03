# ---------- BUILD STAGE ----------
FROM python:3.10-slim AS builder

# Set working directory
WORKDIR /app

# Copy only requirements first (for caching)
COPY requirements.txt .

# Install all Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy your entire plugin source
COPY . .

# ---------- RUNTIME STAGE ----------
FROM python:3.10-slim

# Working dir for container
WORKDIR /code

# Copy installed packages from builder
COPY --from=builder /usr/local/lib/python3.10/site-packages/ /usr/local/lib/python3.10/site-packages/
COPY --from=builder /usr/local/bin/uvicorn /usr/local/bin/uvicorn

# Copy application code
COPY --from=builder /app /code

# Expose default port (Railway, Fly, Azure, etc.)
EXPOSE 8080

# Start the FastAPI app with Uvicorn
CMD ["sh", "-c", "uvicorn server.main:app --host 0.0.0.0 --port ${PORT:-8080}"]
