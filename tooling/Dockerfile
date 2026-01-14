FROM golang:1.25.3-alpine3.21

ENV USER=root
ENV CGO_ENABLED=1 \
    CGO_CFLAGS="-D_LARGEFILE64_SOURCE"

RUN set -x && \
  apk --no-cache add gcc git libc-dev && \
  go install github.com/cloudflare/cfssl/cmd/...@v1.6.3 && \
  go install github.com/cloudflare/cfssl_trust/...@latest && \
  echo "Build complete."

FROM ruby:3.2-alpine3.21
RUN mkdir /etc/cfssl
COPY --from=0 /go/pkg/mod/github.com/cloudflare/cfssl_trust@*/*.crt* /etc/cfssl/
COPY --from=0 /go/bin/ /usr/bin/
RUN gem install slop
COPY . /etc/k8s

RUN set -x && \
  apk --no-cache add git openssl

WORKDIR /mnt

ENTRYPOINT ["ruby", "/etc/k8s/kube_tool.rb"]
