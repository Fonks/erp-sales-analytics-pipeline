# ============================================================================
# ERP Sales Analytics - Docker Image
# Base: Python 3.11 with PySpark
# ============================================================================

FROM python:3.11-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYSPARK_PYTHON=python3 \
    PYSPARK_DRIVER_PYTHON=python3

# Install system dependencies (Java for PySpark)
RUN apt-get update && apt-get install -y \
    default-jdk \
    build-essential \
    curl \
    git \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME after installation
ENV JAVA_HOME=/usr/lib/jvm/default-java

# Set working directory
WORKDIR /app

# Copy requirements first (for better caching)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Create necessary directories
RUN mkdir -p /app/data/raw \
             /app/data/cleaned \
             /app/data/warehouse \
             /app/data/quality_reports

# Expose ports
# 8501: Streamlit dashboard
# 4040: Spark UI
EXPOSE 8501 4040

# Default command (will be overridden by docker-compose)
CMD ["bash"]
