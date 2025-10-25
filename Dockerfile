 Dockerfile
FROM rocker/plumber:latest

# Install system dependencies required for building some R packages (ragg, ggraph, etc.)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libxml2-dev libssl-dev libcurl4-openssl-dev \
    libfontconfig1-dev libfreetype6-dev libharfbuzz-dev libfribidi-dev \
    libpng-dev libjpeg-dev libcairo2-dev \
  && rm -rf /var/lib/apt/lists/*

# Copy and install R packages
COPY requirements.R /app/requirements.R
RUN Rscript /app/requirements.R

# Copy API
COPY app.R /app/app.R
WORKDIR /app

# Expose port used by plumber
EXPOSE 8000

# Start the API
CMD ["Rscript", "app.R"]

