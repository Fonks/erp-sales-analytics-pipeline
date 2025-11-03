# ============================================================================
# ERP Sales Analytics - Docker Image
# Base: Apache Spark with Python 3.11
# ============================================================================

FROM apache/spark-py:3.5.0

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    SPARK_HOME=/opt/spark \
    PYSPARK_PYTHON=python3 \
    PYSPARK_DRIVER_PYTHON=python3

# Install system dependencies
USER root

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

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
