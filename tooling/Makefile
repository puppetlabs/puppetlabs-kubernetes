NAME=puppet/kubetool

all: build

.phony: build

build:
	grep "^FROM" Dockerfile | awk '{ print $$2 }' | uniq | xargs -P2 -n1 docker pull
	docker build -t $(NAME) .
