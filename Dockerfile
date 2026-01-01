# Use the official Python 3.9 image based on Alpine Linux (small footprint).
FROM python:3.9-alpine

# Add image metadata (documentation only; no runtime effect).
LABEL maintainer="ahmedelnour"

# Make Python output appear immediately in Docker logs (no buffering).
ENV PYTHONUNBUFFERED=1

# Copy dependency list first to leverage Docker layer caching.
# Fix: "requirments" -> "requirements" (typo) and keep path consistent.
COPY ./requirements.txt /temp/requirements.txt
COPY ./requirements.dev.txt /temp/requirements.dev.txt
# Copy your Django app source code into the image.
COPY ./app /app
# Set the working directory for all following commands (like `cd /app`).
WORKDIR /app

# Document that the container intends to listen on port 8000 (does not publish it).
EXPOSE 8000

# Create an isolated Python environment at /py (venv).
# Install dependencies into that venv using its pip.
# Clean up build temp files to keep the image smaller.
# Create a non-root user for safer runtime execution.
ARG DEV=false

RUN python -m venv /py \
  && /py/bin/pip install --upgrade pip \
  && apk add --update --no-cache postgresql-client \
  && apk add --update --no-cache --virtual .tmp-build-deps build-base postgresql-dev musl-dev \
  && /py/bin/pip install -r /temp/requirements.txt \
  && if [ "$DEV" = "true" ] ; then /py/bin/pip install -r /temp/requirements.dev.txt ; fi \
  && rm -rf /temp \
  && apk del .tmp-build-deps \
  && adduser --disabled-password --no-create-home django-user

# Put the venv binaries first in PATH so `python`, `pip`, `django-admin` use /py/bin versions.
ENV PATH="/py/bin:$PATH"

# Fix: user name must match the created user (no spaces) -> django-user.
# Run the application as a non-root user for better security.
USER django-user
