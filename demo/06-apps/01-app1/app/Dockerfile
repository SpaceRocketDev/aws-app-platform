# FROM python:3.12-alpine
FROM public.ecr.aws/docker/library/python:3.12-alpine

# Reduce Python noise and prevent .pyc writes
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install curl for health checks
RUN apk add --no-cache curl

# Create an unprivileged user and group
# 10001 is arbitrary but fixed for consistency in K8s/ECS
RUN addgroup -S app && adduser -S -G app -u 10001 app

WORKDIR /app

# Install dependencies as root during build
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app files and set ownership for runtime
COPY bump.txt .
COPY app.py .
RUN chown -R app:app /app

EXPOSE 9091

# Aligns with your healthcheck_endpoint tfvar
HEALTHCHECK --interval=10s --timeout=5s --retries=3 --start-period=5s \
  CMD curl -fsS http://localhost:9091/-/ready || exit 1

# Drop privileges for runtime
USER app

CMD ["python", "app.py"]
