# Stage 1: install dependencies into a virtual environment
FROM python:3.10-slim AS builder

WORKDIR /app

# Copy only requirements.txt and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY . .

# Stage 2: create the lightweight runtime image
FROM python:3.10-slim

WORKDIR /code

# Copy installed packages from builder
COPY --from=builder /usr/local/lib/python3.10/site-packages/ /usr/local/lib/python3.10/site-packages/
COPY --from=builder /usr/local/bin/uvicorn /usr/local/bin/uvicorn

# Copy application code
COPY --from=builder /app /code

# Expose default port (override with PORT or WEBSITES_PORT)
EXPOSE 8080

CMD ["sh", "-c", "uvicorn server.main:app --host 0.0.0.0 --port ${PORT:-${WEBSITES_PORT:-8080}}"]

