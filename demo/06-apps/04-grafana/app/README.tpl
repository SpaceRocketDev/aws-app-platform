# Grafana

Local build and run:
```bash
docker build -t my-grafana .
```
```bash
docker run --rm -p @{PORT}:@{PORT} \
  -v $(pwd)/grafana.ini:/etc/grafana/grafana.ini:ro \
  -v $(pwd)/provisioning:/etc/grafana/provisioning:ro \
  -v grafana-data:/var/lib/grafana \
  --name grafana my-grafana
# open http://localhost:@{PORT}
# default login: admin/admin
```

Push latest from Mac Silicon to ECS AMD Fargate
```bash
export AWS_REGION=@{AWS_REGION}
export AWS_ACCOUNT_ID=@{AWS_ACCOUNT_ID}
export ECR_REPO=@{ECR_REPO}
export IMAGE_TAG=latest
export ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}"

aws ecr get-login-password --region "$AWS_REGION" \
| docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

docker buildx create --use >/dev/null 2>&1 || true
docker buildx build --platform linux/arm64 -t "$ECR_URI" --push .
```