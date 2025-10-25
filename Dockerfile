FROM rstudio/plumber:latest

# Install system dependencies required for building some R packages
RUN apt-get update -y && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libpng-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements.R and install R packages
COPY requirements.R /tmp/requirements.R
RUN Rscript /tmp/requirements.R

# Set working directory
WORKDIR /app
COPY . /app

# Expose Plumber port
EXPOSE 8000

# Run the API
CMD ["Rscript", "app.R"]

