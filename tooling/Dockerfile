FROM golang:1.19.2-alpine3.16

ENV USER root

RUN set -x && \
  apk --no-cache add git gcc make libc-dev && \
  git clone https://github.com/cloudflare/cfssl.git /go/src/github.com/cloudflare/cfssl && \
  cd /go/src/github.com/cloudflare/cfssl && \
  make && \
  git clone https://github.com/cloudflare/cfssl_trust.git /go/src/github.com/cloudflare/cfssl_trust && \
  echo "Build complete."

FROM ruby:2.3.5-alpine
COPY --from=0 /go/src/github.com/cloudflare/cfssl_trust /etc/cfssl
COPY --from=0 /go/src/github.com/cloudflare/cfssl/bin/ /usr/bin
COPY . /etc/k8s

RUN set -x && \
  apk --no-cache add git openssl

WORKDIR /mnt

ENTRYPOINT ["sh", "-c", "/etc/k8s/start-kubetool.sh"]
