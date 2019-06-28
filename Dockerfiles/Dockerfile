# This file is copied from
# https://github.com/schu/docker-caddy/blob/master/Dockerfile
FROM alpine:3.10

RUN apk add --no-cache openssh-client git curl

RUN cd /tmp/ && curl -fsSL "https://caddyserver.com/download/linux/amd64?plugins=http.realip,tls.dns.route53&license=personal&telemetry=off" | tar xzvf - caddy && install -m 0755 caddy /usr/bin/caddy

EXPOSE 80 443 2015
VOLUME /root/.caddy /srv
WORKDIR /srv

ENTRYPOINT ["/usr/bin/caddy"]
CMD ["--conf", "/etc/Caddyfile", "--log", "stdout"]
