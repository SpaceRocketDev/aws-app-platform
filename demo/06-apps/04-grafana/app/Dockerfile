# syntax=docker/dockerfile:1
ARG GRAFANA_VERSION=12.2.0
FROM grafana/grafana:${GRAFANA_VERSION}

USER root

RUN mkdir -p /etc/grafana/provisioning/datasources \
             /etc/grafana/provisioning/dashboards \
             /var/lib/grafana \
 && chown -R 472:472 /etc/grafana /var/lib/grafana

COPY --chown=472:472 grafana.ini /etc/grafana/grafana.ini
COPY --chown=472:472 provisioning/ /etc/grafana/provisioning/

USER 472

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://127.0.0.1:3000/api/health || exit 1

VOLUME ["/var/lib/grafana"]