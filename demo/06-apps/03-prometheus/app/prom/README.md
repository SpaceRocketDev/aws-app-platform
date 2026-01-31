# Prometheus

Local build and run:
```bash
docker build -t my-prometheus .
```
```bash
docker run --rm -p 9090:9090 \
  --tmpfs /prometheus:rw,uid=65534,gid=65534,mode=0755,noexec,nosuid,size=1024m \
  -v "$(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml:ro" \
  --name prom prom/prometheus:v2.54.1
# open http://localhost:9090
```

Push latest from Mac Silicon to ECS AMD Fargate
```bash
export AWS_REGION=us-east-1
export AWS_ACCOUNT_ID=123456789012
export ECR_REPO=space-rocket/prod/prometheus
export IMAGE_TAG=latest
export ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}"

aws ecr get-login-password --region "$AWS_REGION" \
| docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

docker buildx create --use >/dev/null 2>&1 || true
docker buildx build --platform linux/arm64 -t "$ECR_URI" --push .
```

```bash
topk(10,
  sum by (function_name) (
    sum_over_time(aws_lambda_invocations_sum[24h])
  )
)```# prometheus
