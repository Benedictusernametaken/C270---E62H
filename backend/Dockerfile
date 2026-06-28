# Use an official, lightweight Python runtime as a parent image
FROM python:3.10-slim

# Set environment variables to prevent Python from writing pyc files and buffering stdout
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements file first to leverage Docker's caching mechanism
COPY requirements.txt /app/

# Install the backend dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of your application code into the container
COPY . /app/

# Expose the port Flask runs on locally
EXPOSE 5000

# Run Flask in development mode with hot-reloading turned on
CMD ["flask", "--app", "app.main", "run", "--host=0.0.0.0", "--port=5000", "--debug"]