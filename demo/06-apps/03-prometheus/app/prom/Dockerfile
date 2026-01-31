# syntax=docker/dockerfile:1
ARG PROMETHEUS_VERSION=v2.54.1
# TODO MAKE VAR
FROM 123456789012.dkr.ecr.us-east-1.amazonaws.com/prometheus:${PROMETHEUS_VERSION}

USER root
RUN mkdir -p /etc/prometheus /etc/prometheus/rules /prometheus \
 && chown -R nobody:nobody /etc/prometheus /prometheus

COPY --chown=nobody:nobody prometheus.yml /etc/prometheus/prometheus.yml
# Optional. Remove this line if you do not ship rules yet.
COPY --chown=nobody:nobody rules/ /etc/prometheus/rules/

USER nobody

EXPOSE 9090

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://127.0.0.1:9090/-/ready || exit 1

ENV PROMETHEUS_STORAGE_TSDB_PATH=/prometheus \
    PROMETHEUS_STORAGE_TSDB_RETENTION_TIME=15d \
    PROMETHEUS_WEB_ENABLE_LIFECYCLE=true

VOLUME ["/prometheus"]

ENTRYPOINT ["/bin/prometheus"]
CMD ["--config.file=/etc/prometheus/prometheus.yml", "--storage.tsdb.path=/prometheus", "--storage.tsdb.retention.time=15d", "--web.enable-lifecycle", "--web.listen-address=0.0.0.0:9090"]
