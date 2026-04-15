FROM python:3.12-slim

WORKDIR /app

RUN pip install --no-cache-dir requests typer

COPY joplin_api_wrapper.py .

# Run as non-root
RUN useradd -m appuser
USER appuser

ENTRYPOINT ["python", "/app/joplin_api_wrapper.py"]