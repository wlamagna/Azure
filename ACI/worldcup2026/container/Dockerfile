# Use an official, lightweight Python image as the base
FROM python:3.12-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements file and install dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

RUN apt-get update && apt-get install -y --no-install-recommends \
vim && rm -rf /var/lib/apt/lists/*

# Copy the rest of the application code into the container
COPY . .

EXPOSE 5000

# Specify the command to run when the container starts
CMD ["python", "app.py"]

