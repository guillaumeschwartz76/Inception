FROM debian:12.10

ENV DEBIAN_FRONTEND=noninteractive

# Installer Grafana OSS
RUN apt-get update && apt-get install -y \
    gnupg2 curl software-properties-common apt-transport-https ca-certificates \
    && curl -fsSL https://apt.grafana.com/gpg.key | gpg --dearmor -o /usr/share/keyrings/grafana.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/grafana.gpg] https://apt.grafana.com stable main" > /etc/apt/sources.list.d/grafana.list \
    && apt-get update \
    && apt-get install -y grafana \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copier config + certificats
COPY conf/grafana.ini /etc/grafana/grafana.ini
COPY ssl/grafana.crt /etc/grafana/ssl/grafana.crt
COPY ssl/grafana.key /etc/grafana/ssl/grafana.key

# Rediriger les logs (facultatif mais conseillé)
RUN ln -sf /dev/stdout /var/log/grafana/grafana.log \
 && ln -sf /dev/stderr /var/log/grafana/grafana.log

# Exposer le port HTTPS
EXPOSE 443

WORKDIR /var/lib/grafana

CMD ["/usr/sbin/grafana-server", "--homepath=/usr/share/grafana", "--config=/etc/grafana/grafana.ini"]
