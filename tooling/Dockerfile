FROM golang:1.19-alpine3.16

ENV USER root

RUN set -x && \
  apk --no-cache add gcc libc-dev && \
  go install github.com/cloudflare/cfssl/cmd/...@v1.6.3 && \
  go install github.com/cloudflare/cfssl_trust/...@latest && \
  echo "Build complete."

FROM ruby:3.0-alpine3.16
RUN mkdir /etc/cfssl
COPY --from=0 /go/pkg/mod/github.com/cloudflare/cfssl_trust@*/*.crt* /etc/cfssl/
COPY --from=0 /go/bin/ /usr/bin/
RUN gem install slop
COPY . /etc/k8s

RUN set -x && \
  apk --no-cache add git openssl

WORKDIR /mnt

ENTRYPOINT ["ruby", "/etc/k8s/kube_tool.rb"]
