FROM python:3.11-slim AS backend

# Set working directory
WORKDIR /GreaterWMS

# Set environment variable
ENV port=8008

# Copy dependencies first for better caching
COPY ./requirements.txt .

# Install system packages
RUN apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        ca-certificates \
        tar \
        gzip \
        supervisor && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN python3 -m pip install --upgrade pip && \
    pip install supervisor && \
    pip install -U 'Twisted[tls,http2]' && \
    pip install -r requirements.txt && \
    pip install daphne

# Prepare directories for logs and templates
RUN mkdir -p /var/log/supervisor /GreaterWMS/templates

# Copy application code last
COPY . .

# Final user stays root
USER root

# Run the app
CMD sh -c "python3 manage.py makemigrations && \
           python3 manage.py migrate && \
           supervisord -c /etc/supervisor/supervisord.conf"