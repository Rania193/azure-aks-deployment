FROM python:3.11-slim AS base
ENV PYTHONDONTWRITEBYTECODE=1 \
PYTHONUNBUFFERED=1 \
PIP_NO_CACHE_DIR=1


WORKDIR /app


# System deps (curl useful for healthchecks / debugging)
RUN apt-get update && apt-get install -y --no-install-recommends \
curl ca-certificates && \
rm -rf /var/lib/apt/lists/*


# Install Python deps first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt


# Copy application code
COPY . .

EXPOSE 5000

# If your app uses Flask or FastAPI, this works; otherwise swap the CMD for your runner
CMD ["python", "run.py"]