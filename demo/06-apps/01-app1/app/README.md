# App1

```bash
docker build -t hello-world:local .
docker run --rm -p 9091:9091 --name hello hello-world:local
```

```bash
curl -s http://localhost:9091/-/ready
curl -s http://localhost:9091/metrics | head
```


```bash
export AWS_REGION=us-east-1
export AWS_ACCOUNT_ID=078618946307
export ECR_REPO=space-rocket/prod/hello-world
export IMAGE_TAG=latest
export ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}"
```

```bash
aws ecr get-login-password --region "$AWS_REGION" \
| docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
```

```bash
docker buildx create --use >/dev/null 2>&1 || true
docker buildx build --platform linux/arm64 \
  -t "$ECR_URI" \
  --push .
```# hello-world
