# syntax=docker/dockerfile:1

FROM python:3.9-slim

WORKDIR /appFlask

COPY requirements.txt /appFlask

# Install dependencies using a cache to save dependency installation. 
# When requirements.txt changes the cache maintains the old dependencies and only new dependencies are installed
# target/root/.cache/pip is the default directory where pip stores dependencies. It is copied in the PC and used as a cache in the next build.
RUN --mount=type=cache,target=/root/.cache/pip pip3 install -r requirements.txt
 

ENTRYPOINT ["python3", "app.py"]



